import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../../app_data/api_url.dart';

// ══════════════════════════════════════════════════════════════════════════════
// WHY THIS FIX EXISTS
// ══════════════════════════════════════════════════════════════════════════════
// The backend stores part numbers exactly as they appear in the printed PDF.
// Long part numbers that don't fit on one line in the PDF are stored with a
// real newline character (0x0A) in the middle, for example:
//
//   "K12121AAWA00\n0S"   → correct: "K12121AAWA000S"
//   "17208AAT00099\nS"   → correct: "17208AAT00099S"
//   "33702AAGA0099\nS"   → correct: "33702AAGA0099S"
//   "61100KST940ZC\nS"   → correct: "61100KST940ZCS"
//   "K83834AAEAH0\n0SS"  → correct: "K83834AAEAH00SS"
//
// Flutter's Text widget treats \n as a line break, so the second half of the
// part number is pushed to a second line and clipped when maxLines: 1 is set,
// making it look like the part number is missing / incomplete.
//
// The fix: remove all \n and \r characters from every partno value.
// ══════════════════════════════════════════════════════════════════════════════

/// Removes every newline/carriage-return from [v] and trims whitespace.
String _clean(dynamic v) {
  if (v == null) return '';
  return v
      .toString()
      .replaceAll('\r\n', '') // Windows line endings first
      .replaceAll('\r', '') // old Mac line endings
      .replaceAll('\n', '') // Unix/PDF line endings  ← THE MAIN FIX
      .trim();
}

// ══════════════════════════════════════════════════════════════════════════════
// PICK LIST MODEL
// ══════════════════════════════════════════════════════════════════════════════

class PickListModel {
  final String id;
  final String pickListNo;
  final String orderNo;
  final ClientWorkerInfo? clientId;
  final ClientWorkerInfo? workerId;
  final String status;
  final List<PartModel> parts;
  final DateTime createdAt;

  PickListModel({
    required this.id,
    required this.pickListNo,
    required this.orderNo,
    this.clientId,
    this.workerId,
    required this.status,
    required this.parts,
    required this.createdAt,
  });

  factory PickListModel.fromJson(Map<String, dynamic> json) {
    return PickListModel(
      id: json['_id'] as String? ?? '',
      pickListNo: (json['pick_list_no'] as String?)?.isNotEmpty == true
          ? json['pick_list_no'] as String
          : (json['code'] as String? ?? ''),
      orderNo: json['order_number'] as String? ?? json['order_no'] as String? ?? '',
      clientId: json['clientId'] != null
          ? ClientWorkerInfo.fromJson(json['clientId'] as Map<String, dynamic>)
          : null,
      workerId: json['workerId'] != null
          ? ClientWorkerInfo.fromJson(json['workerId'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String? ?? 'unassigned',
      parts: (json['parts'] as List<dynamic>?)
              ?.map((e) => PartModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'pick_list_no': pickListNo,
        'order_no': orderNo,
        'clientId': clientId?.toJson(),
        'workerId': workerId?.toJson(),
        'status': status,
        'parts': parts.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

   String get pickListCode => pickListNo;

  // ──────────────────────────────────────────────────────────────────────────
  // PERSISTED DELETED IDs
  // ──────────────────────────────────────────────────────────────────────────
  static final _box = GetStorage();
  static const _deletedKey = 'deleted_pick_list_ids';

  static Set<String> get deletedIds {
    final List stored = _box.read<List>(_deletedKey) ?? [];
    return stored.map((e) => e.toString()).toSet();
  }

  static void _persistDeletedId(String id) {
    final current = deletedIds;
    current.add(id);
    _box.write(_deletedKey, current.toList());
    print('[PickList] Persisted deleted id: $id — total: ${current.length}');
  }

  static Future<bool> delete(String pickListNo, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseURL}/picklist/$pickListNo'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("DELETE STATUS: ${response.statusCode}");
      print("DELETE BODY: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("DELETE ERROR: $e");
      return false;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CLIENT / WORKER INFO
// ══════════════════════════════════════════════════════════════════════════════

class ClientWorkerInfo {
  final String id;
  final String email;

  ClientWorkerInfo({required this.id, required this.email});

  factory ClientWorkerInfo.fromJson(Map<String, dynamic> json) {
    return ClientWorkerInfo(
      id: json['_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'_id': id, 'email': email};
}

// ══════════════════════════════════════════════════════════════════════════════
// PART MODEL
// ══════════════════════════════════════════════════════════════════════════════

class PartModel {
  final String id;
  final String description;
  final int reqQty;
  final int alloQty;
  final String status;

  // ✅ _partnoRaw stores exactly what the API sent (may contain \n)
  final String _partnoRaw;

  // ✅ partno GETTER — always returns the clean version, no \n ever
  // This is the ONLY place you need to call to get the part number.
  // Even if fromJson somehow stored a \n, this getter strips it.
  String get partno => _clean(_partnoRaw);

  PartModel({
    required this.id,
    required String partno, // constructor param named partno
    required this.description,
    required this.reqQty,
    required this.alloQty,
    required this.status,
  }) : _partnoRaw = partno; // stored in private field

  factory PartModel.fromJson(Map<String, dynamic> json) {
    final raw = json['partno']?.toString() ?? '';

    // ✅ FIX: strip newlines at parse time (belt)
    final clean = _clean(raw);

    // Debug log — remove after confirming fix works
    if (raw != clean) {
      print('[PartModel] FIXED partno: "$raw" → "$clean"');
    }

    return PartModel(
      id: json['_id'] as String? ?? '',
      partno: clean, // ✅ clean value stored
      description: json['description'] as String? ?? '',
      reqQty: (json['req_qty'] as num?)?.toInt() ?? 0,
      alloQty: (json['allo_qty'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'partno': partno, // uses the clean getter
        'description': description,
        'req_qty': reqQty,
        'allo_qty': alloQty,
        'status': status,
      };
}
