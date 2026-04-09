import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inventory/app_utils/color_constants.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../app_data/api_url.dart';
import '../../../../app_data/base_api_service.dart';

// ─────────────────────────────────────────────────────────────
// LOCAL DATA MODELS
// ─────────────────────────────────────────────────────────────

class PickListItem {
  final String sNo;
  final String partNumber;
  final String description;
  final String hsnNo;
  final String moq;
  final String stockOnHand;
  final String mrp;
  final String orderQty;
  final String allocatedQty;
  final String pickedQty;

  PickListItem({
    required this.sNo,
    required this.partNumber,
    required this.description,
    required this.hsnNo,
    required this.moq,
    required this.stockOnHand,
    required this.mrp,
    required this.orderQty,
    required this.allocatedQty,
    this.pickedQty = '',
  });
}

class PickListData {
  final String pickListNo;
  final String pickListDate;
  final String orderNo;
  final String orderDate;
  final List<PickListItem> items;

  PickListData({
    required this.pickListNo,
    required this.pickListDate,
    required this.orderNo,
    required this.orderDate,
    required this.items,
  });
}

// ─────────────────────────────────────────────────────────────
// MODEL FOR API PICK LIST SUMMARY (list screen)
// ─────────────────────────────────────────────────────────────

class PickListSummary {
  final String id;
  final String pickListNo;
  final String orderNo;
  final String pickListDate;
  final int partCount;
  final String status;

  PickListSummary({
    required this.id,
    required this.pickListNo,
    required this.orderNo,
    required this.pickListDate,
    required this.partCount,
    this.status = 'pending',
  });

  factory PickListSummary.fromJson(Map<String, dynamic> json) {
    return PickListSummary(
      id: json['_id']?.toString() ?? '',
      pickListNo: json['pick_list_no']?.toString() ?? '',
      orderNo: json['order_no']?.toString() ?? '',
      pickListDate: json['pick_list_date']?.toString() ?? '',
      partCount: (json['parts'] as List?)?.length ?? json['part_count'] ?? 0,
      status: json['status']?.toString() ?? 'pending',
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PDF EXTRACTION SERVICE
// ─────────────────────────────────────────────────────────────

class PdfExtractionService {
  static Future<PickListData?> extractPickListData(File pdfFile) async {
    try {
      final String fullText = await ReadPdfText.getPDFtext(pdfFile.path);
      if (fullText.trim().isEmpty) return null;
      return _parsePickListText(fullText);
    } catch (e, st) {
      debugPrint('PDF extraction error: $e\n$st');
      return null;
    }
  }

  static PickListData _parsePickListText(String text) {
    final lines = text
        .replaceAll('\r\n', '\n')
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String pickListNo = '', pickListDate = '', orderNo = '', orderDate = '';

    for (final line in lines) {
      _matchFirst(line, RegExp(r'Pick\s+List\s+No\s+(\S+)'),
              (v) { if (pickListNo.isEmpty) pickListNo = v; });
      _matchFirst(line, RegExp(r'Pick\s+List\s+Date\s+(\d{2}/\d{2}/\d{4}\s+\d{2}:\d{2}:\d{2})'),
              (v) { if (pickListDate.isEmpty) pickListDate = v; });
      _matchFirst(line, RegExp(r'Order\s+No\s+(\S+)'),
              (v) { if (orderNo.isEmpty) orderNo = v; });
      _matchFirst(line, RegExp(r'Order\s+Date\s+(\d{2}/\d{2}/\d{4}\s+\d{2}:\d{2}:\d{2})'),
              (v) { if (orderDate.isEmpty) orderDate = v; });
    }

    return PickListData(
      pickListNo: pickListNo,
      pickListDate: pickListDate,
      orderNo: orderNo,
      orderDate: orderDate,
      items: _parseTableRows(lines),
    );
  }

  static void _matchFirst(String line, RegExp re, void Function(String) setter) {
    final m = re.firstMatch(line);
    if (m != null) setter(m.group(1)!);
  }

  static List<PickListItem> _parseTableRows(List<String> lines) {
    int tableStart = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('Part Number') && lines[i].contains('Description')) {
        tableStart = i + 2;
        break;
      }
    }
    if (tableStart == -1) return [];

    final rowStartRe = RegExp(r'^\d+\s');
    final footerRe   = RegExp(r'^(Picked By|Checked By|Packed By|Remarks)');
    final List<String> mergedRows = [];
    String buf = '';

    for (int i = tableStart; i < lines.length; i++) {
      final line = lines[i];
      if (footerRe.hasMatch(line)) break;
      if (rowStartRe.hasMatch(line)) {
        if (buf.isNotEmpty) mergedRows.add(_norm(buf));
        buf = line;
      } else if (buf.isNotEmpty) {
        buf += ' $line';
      }
    }
    if (buf.isNotEmpty) mergedRows.add(_norm(buf));

    final hsnRe = RegExp(r'(\d{8})\s+(\d+)\s+(\d+)\s+([\d,\.]+)\s+(\d+)\s+(\d+)');
    final List<String> pairedRows = [];
    int idx = 0;
    while (idx < mergedRows.length) {
      final row = mergedRows[idx];
      if (hsnRe.hasMatch(row)) {
        pairedRows.add(row);
        idx++;
      } else {
        if (idx + 1 < mergedRows.length) {
          pairedRows.add('$row ${mergedRows[idx + 1]}');
          idx += 2;
        } else {
          idx++;
        }
      }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // PART NUMBER EXTRACTION — THE FIX
    // ═══════════════════════════════════════════════════════════════════════
    //
    // ROOT CAUSE: The PDF wraps long part numbers across two printed lines.
    // The text extractor returns them as two separate tokens in the merged row:
    //
    //   "K12121AAWA00"  and  "0S"   → should be  "K12121AAWA000S"
    //   "17208AAT00099" and  "S"    → should be  "17208AAT00099S"
    //   "33702AAGA0099" and  "S"    → should be  "33702AAGA0099S"
    //   "61100KST940ZC" and  "S"    → should be  "61100KST940ZCS"
    //   "K83834AAEAH0"  and  "0SS"  → should be  "K83834AAEAH00SS"
    //
    // The old code used RegExp(r'[A-Z0-9]{8,}') to find the part number.
    // It matched the first fragment and stopped — never joined the second token.
    //
    // FIX: After finding the first fragment, check if the NEXT token is also
    // purely alphanumeric (no spaces, short, all uppercase/digits). If so,
    // join them. This reconstructs the full part number.
    // ═══════════════════════════════════════════════════════════════════════

    // Matches any uppercase-alphanumeric token (part number candidates)
    final partFragmentRe  = RegExp(r'^[A-Z0-9]+$');
    // Matches the primary fragment: 8+ chars, has both letters and digits
    final partPrimaryRe   = RegExp(r'^[A-Z0-9]{8,}$');
    final hasLetterRe     = RegExp(r'[A-Z]');
    final hasDigitRe      = RegExp(r'[0-9]');

    final List<PickListItem> items = [];

    for (final row in pairedRows) {
      final hm = hsnRe.firstMatch(row);
      if (hm == null) continue;

      final hsn      = hm.group(1)!;
      final moq      = hm.group(2)!;
      final stock    = hm.group(3)!;
      final mrp      = hm.group(4)!;
      final orderQty = hm.group(5)!;
      final allocQty = hm.group(6)!;

      final prefix   = row.substring(0, hm.start).trim();
      final snoMatch = RegExp(r'^(\d+)\s+').firstMatch(prefix);
      final sno      = snoMatch?.group(1) ?? '';
      final afterSno = snoMatch != null
          ? prefix.substring(snoMatch.end).trim()
          : prefix;

      final tokens = afterSno.split(RegExp(r'\s+'));

      // Skip bin-location tokens (short, all-alpha or mixed short tokens)
      int skipCount = 0;
      for (final tok in tokens) {
        if (tok.length < 8) {
          skipCount++;
        } else {
          break;
        }
      }

      // ── Find the primary part-number fragment ──────────────────────────
      String partNumber = '';
      int partTokenIdx  = -1;

      for (int t = skipCount; t < tokens.length; t++) {
        final tok = tokens[t];
        if (partPrimaryRe.hasMatch(tok) &&
            hasLetterRe.hasMatch(tok) &&
            hasDigitRe.hasMatch(tok)) {
          partNumber   = tok;
          partTokenIdx = t;
          break;
        }
      }
      if (partNumber.isEmpty) continue;

      // ── ✅ FIX: Join the continuation token if the part number is split ──
      //
      // When the PDF wraps a part number across two lines, the second half
      // appears as the very next token in the merged row. It will be:
      //   - Short (1–6 chars typically)
      //   - Purely uppercase alphanumeric (no spaces, no punctuation)
      //   - NOT a known field value (not a digit-only HSN/MOQ/etc.)
      //
      // We join it to reconstruct the full part number.
      if (partTokenIdx >= 0 && partTokenIdx + 1 < tokens.length) {
        final nextTok = tokens[partTokenIdx + 1];
        final isAlphanumContinuation = partFragmentRe.hasMatch(nextTok) &&
            nextTok.length <= 6 &&          // continuation is always short
            !RegExp(r'^\d+$').hasMatch(nextTok); // not a pure number (HSN etc.)

        if (isAlphanumContinuation) {
          partNumber = partNumber + nextTok;  // ← THE FIX
        }
      }

      // ── Extract description (text between partNumber and HSN) ──────────
      final partStart = row.indexOf(
        // search for the first fragment (before the join)
        partTokenIdx >= 0 ? tokens[partTokenIdx] : partNumber,
      );
      String description = '';
      if (partStart != -1) {
        // start after the full (possibly joined) part number
        final afterPartNumber = partStart + tokens[partTokenIdx].length +
            (partNumber.length > tokens[partTokenIdx].length
                ? tokens[partTokenIdx + 1].length + 1  // +1 for the space
                : 0);

        description = row
            .substring(afterPartNumber.clamp(0, hm.start), hm.start)
            .trim()
            .replaceAll(RegExp(r'(\s+[A-Z0-9]{1,3}){1,3}$'), '')
            .trim();
      }

      items.add(PickListItem(
        sNo:          sno,
        partNumber:   partNumber,   // ✅ now always the full part number
        description:  description,
        hsnNo:        hsn,
        moq:          moq,
        stockOnHand:  stock,
        mrp:          mrp,
        orderQty:     orderQty,
        allocatedQty: allocQty,
      ));
    }

    return items;
  }

  static String _norm(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

// ─────────────────────────────────────────────────────────────
// PICK LISTS BY ORDER NUMBER  ← LIST SCREEN
// ─────────────────────────────────────────────────────────────

class PickListsByOrderScreen extends StatefulWidget {
  const PickListsByOrderScreen({Key? key}) : super(key: key);

  @override
  State<PickListsByOrderScreen> createState() => _PickListsByOrderScreenState();
}

class _PickListsByOrderScreenState extends State<PickListsByOrderScreen> {
  static const _primary = AppColor.primaryButtonColor;

  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _errorMsg = '';
  String _searchQuery = '';

  Map<String, List<PickListSummary>> _grouped = {};
  final Set<String> _expanded = {};
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPickLists();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchPickLists() async {
    setState(() { _isLoading = true; _errorMsg = ''; });
    try {
      final response = await _apiService.getRaw(ApiConstants.postToPickList);

      if (response == null || response.statusCode != 200) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Failed to load pick lists (${response?.statusCode})';
        });
        return;
      }

      final List<dynamic> rawList = response.data is List
          ? response.data
          : (response.data['data'] ?? response.data['pick_lists'] ?? []);

      final summaries = rawList
          .map((e) => PickListSummary.fromJson(e as Map<String, dynamic>))
          .toList();

      final Map<String, List<PickListSummary>> grouped = {};
      for (final s in summaries) {
        final key = s.orderNo.isNotEmpty ? s.orderNo : 'No Order';
        grouped.putIfAbsent(key, () => []).add(s);
      }

      setState(() {
        _grouped = grouped;
        _isLoading = false;
        if (grouped.length == 1) _expanded.add(grouped.keys.first);
      });
    } catch (e) {
      setState(() { _isLoading = false; _errorMsg = 'Error: $e'; });
    }
  }

  Map<String, List<PickListSummary>> get _filteredGrouped {
    if (_searchQuery.isEmpty) return _grouped;
    final q = _searchQuery.toLowerCase();
    final Map<String, List<PickListSummary>> result = {};
    _grouped.forEach((orderNo, lists) {
      if (orderNo.toLowerCase().contains(q)) {
        result[orderNo] = lists;
        return;
      }
      final matched = lists.where((l) =>
      l.pickListNo.toLowerCase().contains(q) ||
          l.orderNo.toLowerCase().contains(q)).toList();
      if (matched.isNotEmpty) result[orderNo] = matched;
    });
    return result;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':  return Colors.green.shade600;
      case 'processing': return Colors.blue.shade600;
      case 'cancelled':  return Colors.red.shade500;
      default:           return Colors.orange.shade700;
    }
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'completed':  return Colors.green.shade50;
      case 'processing': return Colors.blue.shade50;
      case 'cancelled':  return Colors.red.shade50;
      default:           return Colors.orange.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredGrouped;
    final totalOrders    = filtered.length;
    final totalPickLists = filtered.values.fold(0, (s, l) => s + l.length);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppBar(
        title: const Text('Pick Lists by Order',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColor.bottomNavBarBackground,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchPickLists,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Upload New Pick List',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PickListView()),
            ).then((_) => _fetchPickLists()),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColor.bottomNavBarBackground,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(children: [
              _statChip(Icons.shopping_cart_outlined,
                  '$totalOrders Orders', Colors.white70),
              const SizedBox(width: 12),
              _statChip(Icons.receipt_long,
                  '$totalPickLists Pick Lists', Colors.white70),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by order no or pick list no…',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search,
                    color: Colors.grey.shade500, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    BorderSide(color: Colors.grey.shade200)),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading pick lists…',
                      style: TextStyle(color: Colors.black54)),
                ],
              ),
            )
                : _errorMsg.isNotEmpty
                ? _buildError()
                : filtered.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
              onRefresh: _fetchPickLists,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final orderNo =
                  filtered.keys.elementAt(i);
                  final lists = filtered[orderNo]!;
                  return _orderCard(orderNo, lists);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(String orderNo, List<PickListSummary> lists) {
    final isExpanded     = _expanded.contains(orderNo);
    final allDone        = lists.every((l) => l.status.toLowerCase() == 'completed');
    final anyProcessing  = lists.any((l)  => l.status.toLowerCase() == 'processing');
    String groupStatus   = allDone ? 'completed' : anyProcessing ? 'processing' : 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: isExpanded ? Radius.zero : const Radius.circular(16),
            ),
            onTap: () => setState(() {
              if (isExpanded) _expanded.remove(orderNo);
              else _expanded.add(orderNo);
            }),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.shopping_bag_outlined,
                      color: _primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(orderNo,
                          style: const TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87)),
                      const SizedBox(height: 3),
                      Text(
                          '${lists.length} pick list${lists.length != 1 ? 's' : ''}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg(groupStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    groupStatus[0].toUpperCase() + groupStatus.substring(1),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: _statusColor(groupStatus)),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(Icons.keyboard_arrow_down,
                      color: Colors.grey.shade500),
                ),
              ]),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            ...lists.asMap().entries.map((e) =>
                _pickListRow(e.value, e.key == lists.length - 1)),
          ],
        ],
      ),
    );
  }

  Widget _pickListRow(PickListSummary item, bool isLast) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PickListView()),
      ).then((_) => _fetchPickLists()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE),
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(16))
              : BorderRadius.zero,
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.pickListNo.isNotEmpty ? item.pickListNo : '—',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                  color: _primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (item.pickListDate.isNotEmpty)
                Text(item.pickListDate,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.inventory_2_outlined,
                    size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('${item.partCount} part${item.partCount != 1 ? 's' : ''}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ]),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusBg(item.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.status[0].toUpperCase() + item.status.substring(1),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: _statusColor(item.status)),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
        ]),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 15),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(color: color, fontSize: 12,
          fontWeight: FontWeight.w600)),
    ],
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
        const SizedBox(height: 16),
        Text(_errorMsg, textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade700)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _fetchPickLists,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ]),
    ),
  );

  Widget _buildEmpty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.receipt_long_outlined,
            size: 72, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(
          _searchQuery.isNotEmpty
              ? 'No results for "$_searchQuery"'
              : 'No pick lists found',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
        ),
        if (_searchQuery.isEmpty) ...[
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PickListView()),
            ).then((_) => _fetchPickLists()),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Pick List PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// PICK LIST DETAIL / UPLOAD VIEW
// ─────────────────────────────────────────────────────────────

class PickListView extends StatefulWidget {
  const PickListView({Key? key}) : super(key: key);
  @override
  State<PickListView> createState() => _PickListViewState();
}

class _PickListViewState extends State<PickListView> {
  static const _primary = AppColor.primaryButtonColor;
  final apiService = ApiService();

  bool _isLoading = false;
  String _errorMsg = '';
  PickListData? _data;

  String? _savedPickListId;
  String? _authToken;

  final _plNoCtrl   = TextEditingController();
  final _plDateCtrl = TextEditingController();
  final _onCtrl     = TextEditingController();
  final _odCtrl     = TextEditingController();
  List<Map<String, TextEditingController>> _rows = [];

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    _authToken = 'YOUR_TOKEN_HERE';
  }

  @override
  void dispose() {
    _plNoCtrl.dispose(); _plDateCtrl.dispose();
    _onCtrl.dispose();   _odCtrl.dispose();
    _disposeRows();
    super.dispose();
  }

  void _disposeRows() {
    for (final r in _rows) for (final c in r.values) c.dispose();
    _rows = [];
  }

  Future<bool> _showDuplicateDialog(String pickListNo) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                  color: Colors.orange.shade50, shape: BoxShape.circle),
              child: Icon(Icons.warning_amber_rounded,
                  color: Colors.orange.shade700, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Already Uploaded',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                    color: Colors.black87)),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700,
                    height: 1.5),
                children: [
                  const TextSpan(text: 'Pick List '),
                  TextSpan(text: pickListNo,
                      style: TextStyle(fontWeight: FontWeight.w700,
                          color: _primary)),
                  const TextSpan(text: ' is already loaded.\n'
                      'Do you want to replace it with this PDF?'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text('Keep Current',
                      style: TextStyle(color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Replace',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
    return result ?? false;
  }

  Future<bool> _showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                  color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.delete_forever_rounded,
                  color: Colors.red.shade600, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Delete Pick List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                    color: Colors.black87)),
            const SizedBox(height: 10),
            Text(
              'Are you sure you want to delete this pick list?\nThis action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5,
                  color: Colors.grey.shade700, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text('Cancel',
                      style: TextStyle(color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Delete',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
    return result ?? false;
  }

  Future<void> _deletePickList() async {
    if (_savedPickListId == null) {
      _showSnack('Nothing to delete', Colors.orange);
      return;
    }
    final confirm = await _showDeleteDialog();
    if (!mounted || !confirm) return;
    setState(() => _isLoading = true);

    try {
      final response = await apiService
          .deleteRaw('${ApiConstants.postToPickList}/$_savedPickListId');
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 204)) {
        _showSnack('Pick list deleted successfully', Colors.green.shade700);
        _clear();
      } else {
        _showSnack('Failed to delete pick list', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Error: $e', Colors.red);
      }
    }
  }

  Future<void> _pickAndExtract() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf', 'PDF'],
    );
    if (result == null || result.files.single.path == null) return;

    setState(() { _isLoading = true; _errorMsg = ''; });

    final data = await PdfExtractionService.extractPickListData(
      File(result.files.single.path!),
    );

    if (!mounted) return;

    if (data == null || data.items.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMsg  = data == null
            ? 'Failed to read PDF.'
            : 'No table rows found in PDF.';
      });
      return;
    }

    if (_data != null &&
        _data!.pickListNo.isNotEmpty &&
        data.pickListNo.isNotEmpty &&
        _data!.pickListNo == data.pickListNo) {
      setState(() => _isLoading = false);
      final shouldReplace = await _showDuplicateDialog(data.pickListNo);
      if (!mounted) return;
      if (!shouldReplace) return;
      setState(() => _isLoading = true);
    }

    _disposeRows();

    final newRows = data.items.map((item) => {
      'sNo':          TextEditingController(text: item.sNo),
      'partNumber':   TextEditingController(text: item.partNumber),
      'description':  TextEditingController(text: item.description),
      'hsnNo':        TextEditingController(text: item.hsnNo),
      'moq':          TextEditingController(text: item.moq),
      'stockOnHand':  TextEditingController(text: item.stockOnHand),
      'mrp':          TextEditingController(text: item.mrp),
      'orderQty':     TextEditingController(text: item.orderQty),
      'allocatedQty': TextEditingController(text: item.allocatedQty),
    }).toList();

    setState(() {
      _data            = data;
      _rows            = newRows;
      _isLoading       = false;
      _errorMsg        = '';
      _savedPickListId = null;
    });

    _plNoCtrl.text   = data.pickListNo;
    _plDateCtrl.text = data.pickListDate;
    _onCtrl.text     = data.orderNo;
    _odCtrl.text     = data.orderDate;
  }

  void _clear() {
    _disposeRows();
    setState(() {
      _data            = null;
      _errorMsg        = '';
      _savedPickListId = null;
    });
    _plNoCtrl.clear(); _plDateCtrl.clear();
    _onCtrl.clear();   _odCtrl.clear();
  }

  Future<void> _save() async {
    if (_rows.isEmpty) return;

    final List<Map<String, dynamic>> parts = _rows.map((r) => {
      "partno":      r['partNumber']!.text,
      "description": r['description']!.text,
      "req_qty":     int.tryParse(r['orderQty']!.text) ?? 0,
    }).toList();

    final Map<String, dynamic> body = {
      "pick_list_no": _plNoCtrl.text,
      "order_no":     _onCtrl.text,
      "parts":        parts,
    };

    setState(() => _isLoading = true);

    try {
      final response =
      await apiService.postRaw(ApiConstants.postToPickList, body);

      if (!mounted) return;

      if (response == null) {
        _showSnack('PDF is Already Uploaded', Colors.orange);
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseBody = response.data;
          if (responseBody != null && responseBody['_id'] != null) {
            setState(() =>
            _savedPickListId = responseBody['_id'] as String);
          }
        } catch (_) {}

        _showSnack(
          'Pick list "${_plNoCtrl.text}" saved — ${parts.length} parts uploaded',
          Colors.green.shade700,
        );
      } else {
        _showSnack(
          'Upload failed: ${response.statusCode} — '
              '${response.statusMessage ?? 'Unknown error'}',
          Colors.red,
        );
      }
    } catch (e) {
      if (mounted) _showSnack('Error: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppBar(
        title: const Text('Pick List',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColor.bottomNavBarBackground,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          if (_data != null) ...[
            if (_savedPickListId != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                tooltip: 'Delete Pick List',
                onPressed: _deletePickList,
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _clear,
              tooltip: 'Clear',
            ),
          ],
        ],
      ),
      bottomNavigationBar: _data != null && !_isLoading
          ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(children: [
            if (_savedPickListId != null) ...[
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                  onPressed: _deletePickList,
                  icon: const Icon(Icons.delete, size: 20),
                  label: const Text('Delete',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                  onPressed: _save,
                  icon: const Icon(Icons.save, size: 20),
                  label: Text(
                    'Save Pick List  (${_rows.length} items)',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ]),
        ),
      )
          : null,
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _primary),
            SizedBox(height: 16),
            Text('Processing…',
                style: TextStyle(color: Colors.black54)),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bigBtn(
              label: _data == null
                  ? 'Upload Pick List PDF'
                  : 'Upload Another PDF',
              icon: Icons.upload_file,
              color: Colors.green.shade800,
              onTap: _pickAndExtract,
            ),
            if (_errorMsg.isNotEmpty) _errorBanner(_errorMsg),
            if (_data != null) ...[
              const SizedBox(height: 20),
              _card(
                title: 'Pick List Details',
                icon: Icons.receipt_long,
                child: Column(children: [
                  Row(children: [
                    Expanded(child: _lf('Pick List No', _plNoCtrl,
                        readOnly: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _lf('Pick List Date', _plDateCtrl,
                        readOnly: true)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _lf('Order No', _onCtrl,
                        readOnly: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _lf('Order Date', _odCtrl,
                        readOnly: true)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              _card(
                title: 'Items (${_rows.length})',
                icon: Icons.list_alt,
                child: ListView.builder(
                  key: ValueKey(_rows.length),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _rows.length,
                  itemBuilder: (context, index) => _itemCard(index),
                ),
              ),
              const SizedBox(height: 80),
            ],
            if (_data == null && _errorMsg.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Column(children: [
                    Icon(Icons.picture_as_pdf_outlined,
                        size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Upload a GST Pick List PDF\nto auto-fill the fields below',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15,
                          color: Colors.grey.shade500, height: 1.5),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _itemCard(int i) {
    final r = _rows[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: i.isEven ? const Color(0xFFEEF1FB) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDE3F0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _badge(r['sNo']!.text),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Part: ${r['partNumber']!.text}',
              style: const TextStyle(fontWeight: FontWeight.w700,
                  fontSize: 14, color: _primary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
        const SizedBox(height: 10),
        _lf('Description', r['description']!, readOnly: true),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _lf('HSN Code', r['hsnNo']!,
              type: TextInputType.number, readOnly: true)),
          const SizedBox(width: 12),
          Expanded(child: _lf('MOQ', r['moq']!,
              type: TextInputType.number, readOnly: true)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _lf('Stock on Hand', r['stockOnHand']!,
              type: TextInputType.number, readOnly: true)),
          const SizedBox(width: 12),
          Expanded(child: _lf('MRP', r['mrp']!,
              type: TextInputType.number, readOnly: true)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _lf('Order Qty', r['orderQty']!,
              type: TextInputType.number, hi: true, readOnly: true)),
          const SizedBox(width: 12),
          Expanded(child: _lf('Allocated Qty', r['allocatedQty']!,
              type: TextInputType.number, hi: true, readOnly: true)),
        ]),
      ]),
    );
  }

  Widget _badge(String label) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(
        color: _primary, borderRadius: BorderRadius.circular(6)),
    alignment: Alignment.center,
    child: Text(label,
        style: const TextStyle(color: Colors.white, fontSize: 12,
            fontWeight: FontWeight.bold)),
  );

  Widget _bigBtn({
    required String label, required IconData icon,
    required Color color, required VoidCallback onTap,
  }) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    ),
  );

  Widget _card({
    required String title, required IconData icon, required Widget child,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
          blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Row(children: [
          Icon(icon, color: _primary, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 15,
              fontWeight: FontWeight.w700, color: _primary)),
        ]),
      ),
      const Divider(height: 1),
      Padding(padding: const EdgeInsets.all(16), child: child),
    ]),
  );

  Widget _errorBanner(String msg) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200)),
      child: Text(msg,
          style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
    ),
  );

  Widget _lf(
      String label, TextEditingController ctrl, {
        TextInputType type = TextInputType.text,
        bool hi = false, bool readOnly = false,
      }) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
            color: Colors.grey.shade600, letterSpacing: 0.6)),
    const SizedBox(height: 4),
    TextFormField(
      controller: ctrl,
      keyboardType: type,
      readOnly: readOnly,
      showCursor: !readOnly,
      style: TextStyle(
          fontSize: 13,
          fontWeight: hi ? FontWeight.w700 : FontWeight.normal,
          color: readOnly
              ? Colors.black54
              : hi ? _primary : Colors.black87),
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        filled: true,
        fillColor: readOnly
            ? const Color(0xFFEEEEEE)
            : hi ? const Color(0xFFE8EAF6) : const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: readOnly
                    ? Colors.grey.shade400
                    : hi ? const Color(0xFF5C6BC0) : Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: readOnly
                    ? Colors.grey.shade400
                    : hi ? const Color(0xFF5C6BC0) : Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: readOnly ? Colors.grey.shade400 : _primary,
                width: readOnly ? 1.0 : 1.5)),
      ),
    ),
  ]);
}