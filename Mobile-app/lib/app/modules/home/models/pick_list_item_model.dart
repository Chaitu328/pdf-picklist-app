import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../../app_data/api_url.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ROOT CAUSE:
// The backend saves part numbers exactly as extracted from the PDF.
// Long part numbers that wrap across two printed lines are stored with a
// real newline character (0x0A) in the middle:
//
//   "K12121AAWA00\n0S"   should be  "K12121AAWA000S"
//   "17208AAT00099\nS"   should be  "17208AAT00099S"
//   "33702AAGA0099\nS"   should be  "33702AAGA0099S"
//   "61100KST940ZC\nS"   should be  "61100KST940ZCS"
//   "K83834AAEAH0\n0SS"  should be  "K83834AAEAH00SS"
//
// Flutter's Text widget renders \n as a real line-break. The second
// line falls below the row height and becomes invisible → looks "missing".
//
// FIX: strip \n at the model level so it NEVER reaches any widget.
// ─────────────────────────────────────────────────────────────────────────────
String _fix(String? v) {
  if (v == null || v.isEmpty) return '';
  return v
      .replaceAll('\r\n', '')
      .replaceAll('\r', '')
      .replaceAll('\n', '')   // ← the main fix
      .trim();
}

// ═════════════════════════════════════════════════════════════════════════════
// PICK LIST MODEL
// ═════════════════════════════════════════════════════════════════════════════

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
      pickListNo: json['pick_list_no'],
      // pickListNo: (json['pick_list_no'] as String?)?.isNotEmpty == true
      //     ? json['pick_list_no'] as String
      //     : (json['code'] as String? ?? ''),
      orderNo: json['order_no'] as String? ?? '',
      clientId: json['clientId'] != null
          ? ClientWorkerInfo.fromJson(
          json['clientId'] as Map<String, dynamic>)
          : null,
      workerId: json['workerId'] != null
          ? ClientWorkerInfo.fromJson(
          json['workerId'] as Map<String, dynamic>)
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

  String? get code => null;
  get pickListCode => null;

  // ───────────────────────────────────────────────────────────────────────────
  // PERSISTED DELETED IDs
  // ───────────────────────────────────────────────────────────────────────────
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
    print('[PickList] persisted deleted id: $id');
  }

  // ───────────────────────────────────────────────────────────────────────────
  // DELETE  →  DELETE $baseURL/picklist/delete/{id}
  // ───────────────────────────────────────────────────────────────────────────
static Future<bool> delete(String pickListNo, String token) async {
  try {
    // The API requires the pick_list_no in the URL
    final response = await http.delete(
      Uri.parse('https://pick-list.onrender.com/api/picklist/$pickListNo'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("DELETE STATUS: ${response.statusCode}");
    print("DELETE URL: https://pick-list.onrender.com/api/picklist/$pickListNo");

    return response.statusCode == 200 || response.statusCode == 204;
  } catch (e) {
    print("DELETE ERROR: $e");
    return false;
  }
}
}

// ═════════════════════════════════════════════════════════════════════════════
// CLIENT / WORKER INFO
// ═════════════════════════════════════════════════════════════════════════════

class ClientWorkerInfo {
  final String id;
  final String email;

  ClientWorkerInfo({required this.id, required this.email});

  factory ClientWorkerInfo.fromJson(Map<String, dynamic> json) =>
      ClientWorkerInfo(
        id: json['_id'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'_id': id, 'email': email};
}

// ═════════════════════════════════════════════════════════════════════════════
// PART MODEL
// ═════════════════════════════════════════════════════════════════════════════

class PartModel {
  final String id;
  final String description;
  final int    reqQty;
  final int    alloQty;
  final String status;

  // ✅ partno is stored already clean — \n stripped in fromJson
  final String partno;

  PartModel({
    required this.id,
    required this.partno,
    required this.description,
    required this.reqQty,
    required this.alloQty,
    required this.status,
  });

  factory PartModel.fromJson(Map<String, dynamic> json) {
    // ✅ THE FIX — strip \n here, once, at the source
    // This runs every time the API response is parsed.
    // After this line, partno will NEVER contain a newline.
    final String cleanPartNo = _fix(json['partno']?.toString());

    // Remove this print after confirming it works:
    print('[PartModel] partno → "$cleanPartNo"');

    return PartModel(
      id:          json['_id']         as String? ?? '',
      partno:      cleanPartNo,                         // ✅ always clean
      description: json['description'] as String? ?? '',
      reqQty:      (json['req_qty']    as num?)?.toInt() ?? 0,
      alloQty:     (json['allo_qty']   as num?)?.toInt() ?? 0,
      status:      json['status']      as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id':         id,
    'partno':      partno,
    'description': description,
    'req_qty':     reqQty,
    'allo_qty':    alloQty,
    'status':      status,
  };
}