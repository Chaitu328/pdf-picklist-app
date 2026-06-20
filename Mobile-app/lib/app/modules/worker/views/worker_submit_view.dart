import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../regester_village/models/get_pick_list_model.dart';
import '../controllers/worker_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  QR Format:
//  D/[DOC]/[REF]/[PARTNO] /[SEQ]/[QTY]/...
//
//  Only segment[3] (part number) is used for matching.
//  The QR qty value is completely ignored.
//
//  SCAN RULE (simple):
//  • Every scan  →  allocated + 1
//  • Once allocated == required qty  →  show "Limit Reached", stop
//  • After "Scan Another" / rescan  →  camera restarts, next scan adds +1 again
// ─────────────────────────────────────────────────────────────────────────────

class WorkerSubmitView extends StatefulWidget {
  const WorkerSubmitView({super.key});

  @override
  State<WorkerSubmitView> createState() => _WorkerSubmitViewState();
}

class _WorkerSubmitViewState extends State<WorkerSubmitView> {
  late PickListModel pickList;
  late List<TextEditingController> _alloControllers;
  late List<FocusNode> _focusNodes;
  final WorkerController controller = Get.find<WorkerController>();
  Timer? _refreshTimer;

  // ── Scanner state ─────────────────────────────────────────────────────────
  bool _scannerOpen = false;
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  bool _isSubmitted = false;

  // ── Overlay states ────────────────────────────────────────────────────────
  bool _showSuccessOverlay = false;
  bool _showInvalidOverlay = false;
  bool _showLimitOverlay = false;


  int _overlayScannedQty = 0;
  int _overlayAllocatedQty = 0;

  String _overlayMessage = '';
  String _scannedRawValue = '';
  List<_ScanResultItem> _lastScanResults = [];

  // ── Per-part counters ─────────────────────────────────────────────────────
  late List<int> _scanCounts; // current allocated qty per part
  late List<int> _reqCounts; // required qty per part

  @override
  void initState() {
    super.initState();
    pickList = Get.arguments as PickListModel;
    _alloControllers = pickList.parts
        .map((p) => TextEditingController(
            text: p.alloQty > 0 ? p.alloQty.toString() : ''))
        .toList();
    _scanCounts =
        pickList.parts.map((p) => p.alloQty > 0 ? p.alloQty : 0).toList();
    _reqCounts = pickList.parts.map((p) => p.reqQty).toList();

    _focusNodes = List.generate(pickList.parts.length, (i) {
      final node = FocusNode();
      node.addListener(() {
        if (!node.hasFocus) {
          _syncManualQtyToServer(i);
        }
      });
      return node;
    });

    // Fetch immediately on view open to get latest data from other workers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAllLists();
    });

    // Start background polling every 5 seconds to sync concurrent workers
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && !_scannerOpen && !controller.isLoading.value) {
        controller.fetchAllLists();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    for (final fn in _focusNodes) fn.dispose();
    for (final c in _alloControllers) c.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _syncManualQtyToServer(int index) {
    final activePickList = controller.allLists.firstWhereOrNull((p) => p.id == pickList.id) ?? pickList;
    final text = _alloControllers[index].text.trim();
    if (text.isEmpty) return;

    final enteredQty = int.tryParse(text) ?? 0;
    final serverQty = activePickList.parts[index].alloQty;

    if (enteredQty > serverQty) {
      final needed = enteredQty - serverQty;

      setState(() {
        _scanCounts[index] = enteredQty;
      });

      controller.updatePartStatus(
        pickListId: activePickList.id,
        partNo: activePickList.parts[index].partno,
        isManual: true,
        quantity: needed,
        context: context,
      );
    }
  }

  bool _isLimitReached(int index) =>
      _reqCounts[index] > 0 && _scanCounts[index] >= _reqCounts[index];

  int _partIndexByPartNo(String partno) =>
      pickList.parts.indexWhere((p) => p.partno.trim() == partno.trim());

  void _syncController(int index) {
    _alloControllers[index].text = _scanCounts[index].toString();
  }

  bool _isFormValid() {
    for (int i = 0; i < _alloControllers.length; i++) {
      final text = _alloControllers[i].text.trim();

      // ❌ empty
      if (text.isEmpty) return false;

      final value = int.tryParse(text) ?? 0;

      // ❌ zero or invalid
      if (value <= 0) return false;

      // ❌ more than required
      if (value > _reqCounts[i]) return false;
    }
    return true;
  }

  // ── Scanner open / close ──────────────────────────────────────────────────

  void _openScanner() {
    _isProcessing = false;
    setState(() {
      _scannerOpen = true;
      _showSuccessOverlay = false;
      _showInvalidOverlay = false;
      _showLimitOverlay = false;
      _lastScanResults = [];
      _scannedRawValue = '';
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        autoStart: true,
      );
    });
  }

  void _closeScanner() {
    _scannerController?.stop();
    _scannerController?.dispose();
    setState(() {
      _scannerOpen = false;
      _scannerController = null;
      _isProcessing = false;
      _showSuccessOverlay = false;
      _showInvalidOverlay = false;
      _showLimitOverlay = false;
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BARCODE DETECTION
  // ══════════════════════════════════════════════════════════════════════════

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;
    final raw = barcode.rawValue!.trim();
    if (raw.isEmpty) return;

    _isProcessing = true;
    _scannerController?.stop();
    _scannedRawValue = raw;

    _parseAndIncrement(raw);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  CORE LOGIC: parse part number → increment allocated by +1
  //
  //  QR text: D/DOC/REF/PARTNO /SEQ/QTY/...
  //  segment[3] → part number (only field we need)
  //  QR qty (segment[5]) is intentionally ignored
  // ══════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════
//  CORE LOGIC: Simplified for Non-Educational Users
// ══════════════════════════════════════════════════════════════════════════

void _parseAndIncrement(String raw) {
    final segments = raw.split('/');

    print("=========== FULL QR RAW ===========");
    print(raw);

    print("=========== SEGMENTS ===========");
    for (int i = 0; i < segments.length; i++) {
      print("SEGMENT[$i]: ${segments[i]}");
    }
    print("=================================");

    if (segments.length < 6) {
      _showStatusOverlay(status: "Invalid QR", color: Colors.red);
      return;
    }

    final String uniqueId = segments[2].trim();
    final String partno = segments[3].trim();

    // ✅ CORRECT NET QTY FROM SEGMENT[4]
    final rawQty = segments[4].trim(); // "000040"

    print("RAW NET QTY (SEGMENT[4]): $rawQty");

    // ✅ Convert "000040" → 40
    final int qrNetQty = int.tryParse(rawQty) ?? 0;

    print("PARSED NET QTY: $qrNetQty");

    final int idx = _partIndexByPartNo(partno);

    if (idx == -1) {
      _showStatusOverlay(status: "Part Not Found", color: Colors.red);
      return;
    }

    final int requiredQty = _reqCounts[idx];

    // show in UI
    _overlayScannedQty = qrNetQty;
    _overlayAllocatedQty = requiredQty;

    // ✅ MATCH LOGIC
    if (qrNetQty == requiredQty) {
      _handleQtyMatchSuccess(idx, qrNetQty, uniqueId);
    } else {
      _showStatusOverlay(status: "Shortage", color: Colors.orange);
    }
  }
// ══════════════════════════════════════════════════════════════════════════
//  UNIVERSAL SIMPLE OVERLAY (Replaces all specific overlays)
// ══════════════════════════════════════════════════════════════════════════

  bool _isOverlayVisible = false;
  String _currentStatusText = "";
  Color _currentStatusColor = Colors.grey;

  void _showStatusOverlay({required String status, required Color color}) {
    _scannerController?.stop(); // ✅ IMPORTANT
    setState(() {
      _currentStatusText = status;
      _currentStatusColor = color;
      _isOverlayVisible = true;

      // Auto-hide these specific booleans from your old state
      _showSuccessOverlay = false;
      _showInvalidOverlay = false;
      _showLimitOverlay = false;
    });
  }

  Widget _buildSimpleStatusOverlay() {
    if (!_isOverlayVisible) return const SizedBox.shrink();

    IconData statusIcon;
    if (_currentStatusColor == Colors.green) {
      statusIcon = Icons.check_circle_rounded;
    } else if (_currentStatusColor == Colors.orange) {
      statusIcon = Icons.warning_rounded;
    } else {
      statusIcon = Icons.cancel_rounded;
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 100, color: _currentStatusColor),
                const SizedBox(height: 20),
                Text(
                  _currentStatusText.toUpperCase(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _currentStatusColor,
                  ),
                ),

                const SizedBox(height: 20),

// ── QUANTITY COMPARISON BLOCK ─────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ── SCANNED QTY ─────────────────────
                      Column(
                        children: [
                          Text(
                            "NET QTY",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _overlayScannedQty.toString(),
                            style: TextStyle(
                              fontSize: 42, // 🔥 BIG
                              fontWeight: FontWeight.bold,
                              color: _currentStatusColor,
                            ),
                          ),
                        ],
                      ),

                      // ── DIVIDER ─────────────────────────
                      Container(
                        height: 50,
                        width: 1.5,
                        color: Colors.grey.shade400,
                      ),

                      // ── ALLOCATED QTY ───────────────────
                      Column(
                        children: [
                          Text(
                            "REQUIRED",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _overlayAllocatedQty.toString(),
                            style: const TextStyle(
                              fontSize: 42, // 🔥 BIG
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _isOverlayVisible = false);

                      final String partno =
                          _scannedRawValue.split('/')[3].trim();
                      final int idx = _partIndexByPartNo(partno);

                      if (idx == -1) {
                        _rescan();
                        return;
                      }

                      // ✅ MATCH CASE
                      if (_currentStatusText == "MATCHED") {
                        _closeScanner();
                      }

                      // ✅ SHORTAGE CASE (IMPORTANT 🔥)
                      else if (_currentStatusText == "Shortage") {
                        setState(() {
                          // 🔥 Fill scanned NET QTY
                          _scanCounts[idx] = _overlayScannedQty;
                          _alloControllers[idx].text =
                              _overlayScannedQty.toString();
                        });

                        _closeScanner();
                      }

                      // ❌ Other errors
                      else {
                        _rescan();
                      }
},
                    // onPressed: () {
                    //   setState(() => _isOverlayVisible = false);

                    //   if (_currentStatusColor == Colors.green) {
                    //     _closeScanner(); // ✅ close after success
                    //   } else {
                    //     _rescan(); // ❌ only for mismatch
                    //   }
                    // },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStatusColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      // _currentStatusColor == Colors.green ? "ADD" : "TRY AGAIN",
                      (_currentStatusText == "MATCHED" ||
                              _currentStatusText == "Shortage")
                          ? "ADD"
                          : "TRY AGAIN",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _closeScanner,
                  child: const Text("CANCEL",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

// Case A: QTY MATCHES
  void _handleQtyMatchSuccess(int idx, int matchedQty, String uniqueId) {
    controller.updatePartStatus(
      context: context,
      pickListId: pickList.id,
      partNo: pickList.parts[idx].partno,
      isManual: false,
      uniqueId: uniqueId,
    );

    setState(() {
      _scanCounts[idx] = matchedQty;

      // ✅ UPDATE TEXTFIELD DIRECTLY WITH NET QTY
      _alloControllers[idx].text = matchedQty.toString();

      _overlayScannedQty = matchedQty;
      _overlayAllocatedQty = _reqCounts[idx];

      // ✅ SHOW SUCCESS SCREEN WITH ADD BUTTON
      _currentStatusText = "MATCHED";
      _currentStatusColor = Colors.green;
      _isOverlayVisible = true;
    });
  }

// Case B: QTY MISMATCH
  void _handleQtyMismatchError({
    required String description,
    required int required,
    required int scanned,
  }) {
    setState(() {
      _overlayMessage = "Quantity Mismatch for $description\n\n"
          "Required: $required\n"
          "Scanned QR says: $scanned\n\n"
          "Please check the physical box again.";
      _showInvalidOverlay = true;
    });
  }
  // ── Error / limit handlers ────────────────────────────────────────────────

  void _handleInvalidScan(String reason) {
    setState(() {
      _overlayMessage = reason;
      _showInvalidOverlay = true;
    });
  }

  void _handleLimitReached(int idx) {
    setState(() {
      _overlayMessage =
          '"${pickList.parts[idx].description}" has already reached '
          'its required quantity (${_reqCounts[idx]}).\n\nScan a different part.';
      _showLimitOverlay = true;
    });
  }

  // ── Rescan: dismiss overlay and restart camera ────────────────────────────

  void _rescan() {
    _isProcessing = false;
    _scannerController?.start();
    setState(() {
      _showSuccessOverlay = false;
      _showInvalidOverlay = false;
      _showLimitOverlay = false;
      _lastScanResults = [];
    });
  }

  // ── Submit ────────────────────────────────────────────────────────────────

Future<void> _submit() async {
    if (controller.isLoading.value) return; // prevent double click

    controller.isLoading.value = true; // 🔥 START LOADING IMMEDIATELY

    try {
      final activePickList = controller.allLists.firstWhereOrNull((p) => p.id == pickList.id) ?? pickList;

      for (int i = 0; i < activePickList.parts.length; i++) {
        int enteredQty = int.tryParse(_alloControllers[i].text.trim()) ?? 0;
        int alreadySavedQty = activePickList.parts[i].alloQty;

        if (enteredQty > alreadySavedQty) {
          int needed = enteredQty - alreadySavedQty;

          await controller.updatePartStatus(
            pickListId: activePickList.id,
            partNo: activePickList.parts[i].partno,
            isManual: true,
            quantity: needed,
            context: context,
          );
        }
      }

      // Finalize picklist status on the backend
      final success = await controller.proceedPickList(context, activePickList.id);
      if (success) {
        setState(() => _isSubmitted = true);
        Get.back();
      }
    } catch (e) {
      // handle error if needed
    } finally {
      controller.isLoading.value = false; // 🔥 STOP LOADING
    }
  }


  void _showSnackbar({
    required String message,
    required Color color,
    required IconData icon,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activePickList = controller.allLists.firstWhereOrNull((p) => p.id == pickList.id) ?? pickList;

      // Keep local state and controllers in sync with server-side quantities
      for (int i = 0; i < activePickList.parts.length; i++) {
        final serverQty = activePickList.parts[i].alloQty;
        if (!_focusNodes[i].hasFocus) {
          _scanCounts[i] = serverQty;
          _alloControllers[i].text = serverQty > 0 ? serverQty.toString() : '';
        }
      }

      _reqCounts = activePickList.parts.map((p) => p.reqQty).toList();
      pickList = activePickList;

      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pickList.pickListNo,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Text('${pickList.parts.length} parts',
                  style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _openScanner,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              tooltip: 'Scan QR to update quantities',
            ),
          ],
        ),
        body: _scannerOpen ? _buildScannerView() : _buildMainContent(),
        bottomNavigationBar: _scannerOpen ? null : _buildSubmitBar(),
      );
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SCANNER VIEW
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildScannerView() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController!,
          onDetect: _onBarcodeDetected,
        ),
        Positioned.fill(
          child: Column(
            children: [
              // ── Top info panel ───────────────────────────────────────────
              Container(
                color: Colors.black54,
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                child: Column(
                  children: [
                    const Text('Scan Pick-List QR Code',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text(
                      'Each scan adds +1 to allocated quantity',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    _buildOverallProgressPill(),
                  ],
                ),
              ),

              // ── Scan window ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                      child: Container(height: 240, color: Colors.black45)),
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFF60A5FA), width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        _cornerDeco(
                            top: 0,
                            left: 0,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(14))),
                        _cornerDeco(
                            top: 0,
                            right: 0,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(14))),
                        _cornerDeco(
                            bottom: 0,
                            left: 0,
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(14))),
                        _cornerDeco(
                            bottom: 0,
                            right: 0,
                            borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(14))),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Container(height: 240, color: Colors.black45)),
                ],
              ),

              // ── Bottom controls ──────────────────────────────────────────
              Expanded(
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _scannerActionBtn(
                            icon: Icons.flash_on_rounded,
                            label: 'Torch',
                            onTap: () => _scannerController?.toggleTorch(),
                          ),
                          const SizedBox(width: 28),
                          _scannerActionBtn(
                            icon: Icons.flip_camera_ios_rounded,
                            label: 'Flip',
                            onTap: () => _scannerController?.switchCamera(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      GestureDetector(
                        onTap: _closeScanner,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 36, vertical: 13),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2563EB),
                                  fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // // ── Overlays ──────────────────────────────────────────────────────
        if (_isOverlayVisible) _buildSimpleStatusOverlay(),

        // if (_showSuccessOverlay) _buildSuccessOverlay(),
        // if (_showInvalidOverlay) _buildInvalidOverlay(),
        // if (_showLimitOverlay) _buildLimitOverlay(),
      ],
    );
  }

  // ── Corner decorator ──────────────────────────────────────────────────────

  Widget _cornerDeco({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required BorderRadius borderRadius,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  // ── Overall progress pill ─────────────────────────────────────────────────

  Widget _buildOverallProgressPill() {
    final totalReq = _reqCounts.fold(0, (s, r) => s + r);
    final totalAllo = _scanCounts.fold(0, (s, a) => s + a);
    final completed =
        List.generate(pickList.parts.length, (i) => _isLimitReached(i))
            .where((b) => b)
            .length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.list_alt_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 8),
          Text(
            '$completed/${pickList.parts.length} parts complete'
            ' · $totalAllo/$totalReq total',
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SUCCESS OVERLAY  (+1 confirmed)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSuccessOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.78),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon ────────────────────────────────────────────────
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_circle_rounded,
                      color: Color(0xFF16A34A), size: 34),
                ),
                const SizedBox(height: 14),
                const Text('+1 Added!',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16A34A))),
                const SizedBox(height: 4),
                const Text('Allocated quantity updated',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 16),

                // ── Updated parts list ───────────────────────────────────
                Container(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: SingleChildScrollView(
                    child: Column(
                      children: _lastScanResults
                          .map((r) => _buildScanResultTile(r))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Buttons ──────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _closeScanner,
                        child: _overlayBtn(
                          label: 'Done',
                          color: const Color(0xFFF1F5F9),
                          textColor: const Color(0xFF475569),
                          border: const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _rescan,
                        child: _overlayBtn(
                          label: 'Scan Again (+1)',
                          icon: Icons.qr_code_scanner_rounded,
                          color: const Color(0xFF2563EB),
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanResultTile(_ScanResultItem r) {
    final complete = r.reqQty > 0 && r.alloQty >= r.reqQty;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: r.error
            ? const Color(0xFFFEF2F2)
            : complete
                ? const Color(0xFFF0FDF4)
                : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: r.error
              ? const Color(0xFFFCA5A5)
              : complete
                  ? const Color(0xFF86EFAC)
                  : const Color(0xFF93C5FD),
        ),
      ),
      child: Row(
        children: [
          // +1 badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color:
                  r.error ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              r.error ? '✗' : '+1',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.description,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF1E293B)),
                    overflow: TextOverflow.ellipsis),
                Text(
                  r.error
                      ? r.partno
                      : '${r.partno}  •  Allo: ${r.alloQty} / Req: ${r.reqQty}',
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          if (!r.error && r.reqQty > 0) ...[
            const SizedBox(width: 8),
            _miniProgressBar(r.alloQty, r.reqQty),
          ],
        ],
      ),
    );
  }

  Widget _miniProgressBar(int allo, int req) {
    final pct = (allo / req).clamp(0.0, 1.0);
    return SizedBox(
      width: 52,
      child: Column(
        children: [
          Text('${(pct * 100).round()}%',
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB))),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                pct >= 1.0 ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  INVALID OVERLAY
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildInvalidOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.80),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFFDBA74), width: 2),
                  ),
                  child: const Icon(Icons.qr_code_2_rounded,
                      color: Color(0xFFEA580C), size: 32),
                ),
                const SizedBox(height: 14),
                const Text('Invalid QR Code',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFEA580C))),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDBA74)),
                  ),
                  child: Text(
                    _overlayMessage,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Scanned: $_scannedRawValue',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontStyle: FontStyle.italic),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _closeScanner,
                        child: _overlayBtn(
                          label: 'Cancel',
                          color: const Color(0xFFF1F5F9),
                          textColor: const Color(0xFF475569),
                          border: const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _rescan,
                        child: _overlayBtn(
                          label: 'Try Again',
                          icon: Icons.qr_code_scanner_rounded,
                          color: const Color(0xFFEA580C),
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  LIMIT REACHED OVERLAY
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildLimitOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.80),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFFCA5A5), width: 2),
                  ),
                  child: const Icon(Icons.block_rounded,
                      color: Color(0xFFDC2626), size: 32),
                ),
                const SizedBox(height: 14),
                const Text('Quantity Limit Reached',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFDC2626))),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Text(
                    _overlayMessage,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFF7F1D1D)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _closeScanner,
                        child: _overlayBtn(
                          label: 'Done',
                          color: const Color(0xFFF1F5F9),
                          textColor: const Color(0xFF475569),
                          border: const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _rescan,
                        child: _overlayBtn(
                          label: 'Scan Another Part',
                          icon: Icons.qr_code_scanner_rounded,
                          color: const Color(0xFF2563EB),
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  MAIN CONTENT
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildMainContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(),
        const SizedBox(height: 12),
        _buildScanBanner(),
        const SizedBox(height: 16),
        ...List.generate(pickList.parts.length, (i) => _buildPartRow(i)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildScanBanner() {
    final totalReq = _reqCounts.fold(0, (s, r) => s + r);
    final totalAllo = _scanCounts.fold(0, (s, a) => s + a);
    final completed =
        List.generate(pickList.parts.length, (i) => _isLimitReached(i))
            .where((b) => b)
            .length;

    return GestureDetector(
      onTap: _openScanner,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.qr_code_scanner_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tap to Scan QR Code',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    '$completed/${pickList.parts.length} complete'
                    ' · $totalAllo/$totalReq qty',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('SCAN',
                  style: TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long,
                color: Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pickList.pickListNo,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(
                  pickList.clientId?.email ?? '—',
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${pickList.parts.length} Parts',
              style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartRow(int index) {
    final part = pickList.parts[index];
    final scanned = _scanCounts[index];
    final req = _reqCounts[index];
    final limitReached = _isLimitReached(index);
    final hasProgress = scanned > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: limitReached
            ? Border.all(color: const Color(0xFF86EFAC), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: limitReached
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: limitReached
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text('${index + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(part.description,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF1E293B)),
                        overflow: TextOverflow.ellipsis),
                    Text(part.partno,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              if (limitReached)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle_rounded,
                          color: Color(0xFF16A34A), size: 11),
                      SizedBox(width: 4),
                      Text('Complete',
                          style: TextStyle(
                              color: Color(0xFF16A34A),
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                )
              else if (hasProgress)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$scanned/$req',
                      style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _qtyBox(label: 'Required', value: '$req')),
              const SizedBox(width: 10),
              Expanded(child: _alloQtyField(index)),
            ],
          ),
          if (hasProgress) ...[
            const SizedBox(height: 10),
            _buildInlineProgress(scanned, req, limitReached),
          ],
        ],
      ),
    );
  }

  Widget _buildInlineProgress(int scanned, int req, bool limitReached) {
    final double progress = req > 0 ? (scanned / req).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(
              limitReached ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          limitReached
              ? '✓ Complete ($scanned/$req)'
              : '$scanned scanned · ${req - scanned} remaining',
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: limitReached
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _qtyBox({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569))),
        ),
      ],
    );
  }

  Widget _alloQtyField(int index) {
    final limitReached = _isLimitReached(index);
    final part = pickList.parts[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          limitReached ? 'Allocated ✓' : 'Allocated *',
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: limitReached
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF2563EB),
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: limitReached
                ? const Color(0xFFF0FDF4)
                : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: limitReached
                  ? const Color(0xFF86EFAC)
                  : const Color(0xFF93C5FD),
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: _alloControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            readOnly: limitReached,
            onFieldSubmitted: (_) => _syncManualQtyToServer(index),
            onChanged: (val) {
              final v = int.tryParse(val.trim()) ?? 0;
              setState(() {
                _scanCounts[index] = v;
              });
            },
            // onChanged: (val) {
            //   final v = int.tryParse(val.trim()) ?? 0;
            //   setState(() => _scanCounts[index] = v);
            // },
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: limitReached
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF1D4ED8)),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  // ── Submit bar ────────────────────────────────────────────────────────────

Widget _buildSubmitBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, -4)),
          ],
        ),
        child: Obx(() {
          final bool isValid = _isFormValid();

          final bool isDisabled =
              (!isValid || _isSubmitted); // ❗ DON'T include loading here

          return GestureDetector(
            onTap: (isDisabled || controller.isLoading.value) ? null : _submit,
            // onTap: isDisabled ? null : _submit, // ❗ disable click
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              decoration: BoxDecoration(
                color: controller.isLoading.value
                    ? const Color(0xFF2563EB) // 🔵 keep blue during loading
                    : isDisabled
                        ? Colors.grey.shade400 // ⚪ disabled
                        : const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (controller.isLoading.value)
                    const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                  else
                    Icon(
                      isDisabled
                          ? Icons.block
                          : Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  const SizedBox(width: 10),
                  Text(
                    controller.isLoading.value
                        ? 'Submitting…'
                        : 'Submit Pick List',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _overlayBtn({
    required String label,
    IconData? icon,
    required Color color,
    required Color textColor,
    Color? border,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: border != null ? Border.all(color: border) : null,
        boxShadow:
            color == const Color(0xFF2563EB) || color == const Color(0xFFEA580C)
                ? [
                    BoxShadow(
                        color: color.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ]
                : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14, color: textColor)),
        ],
      ),
    );
  }

  Widget _scannerActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white38),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Data class
// ─────────────────────────────────────────────────────────────────────────────

class _ScanResultItem {
  final String partno;
  final String description;
  final int alloQty;
  final int reqQty;
  final bool updated;
  final bool error;

  const _ScanResultItem({
    required this.partno,
    required this.description,
    required this.alloQty,
    required this.reqQty,
    required this.updated,
    this.error = false,
  });
}
