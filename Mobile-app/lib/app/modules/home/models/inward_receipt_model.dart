class InwardPartModel {
  final String partno;
  final String description;
  final int expectedQty;
  final int receivedQty;
  final InwardLocation? location;
  final String status;
  final List<InwardScannedItem> scannedItems;

  InwardPartModel({
    required this.partno,
    required this.description,
    required this.expectedQty,
    required this.receivedQty,
    this.location,
    required this.status,
    required this.scannedItems,
  });

  factory InwardPartModel.fromJson(Map<String, dynamic> json) {
    return InwardPartModel(
      partno: json['partno']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      expectedQty: (json['expected_qty'] as num?)?.toInt() ?? 0,
      receivedQty: (json['received_qty'] as num?)?.toInt() ?? 0,
      location: json['location'] != null ? InwardLocation.fromJson(json['location']) : null,
      status: json['status']?.toString() ?? 'pending',
      scannedItems: (json['scanned_items'] as List?)
              ?.map((e) => InwardScannedItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'partno': partno,
        'description': description,
        'expected_qty': expectedQty,
        'received_qty': receivedQty,
        'location': location?.toJson(),
        'status': status,
        'scanned_items': scannedItems.map((e) => e.toJson()).toList(),
      };
}

class InwardLocation {
  final String rack;
  final String bin;

  InwardLocation({required this.rack, required this.bin});

  factory InwardLocation.fromJson(Map<String, dynamic> json) {
    return InwardLocation(
      rack: json['rack']?.toString() ?? '',
      bin: json['bin']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'rack': rack,
        'bin': bin,
      };
}

class InwardScannedItem {
  final String qrCode;
  final DateTime scannedAt;

  InwardScannedItem({required this.qrCode, required this.scannedAt});

  factory InwardScannedItem.fromJson(Map<String, dynamic> json) {
    return InwardScannedItem(
      qrCode: json['qr_code']?.toString() ?? '',
      scannedAt: json['scannedAt'] != null
          ? DateTime.parse(json['scannedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'qr_code': qrCode,
        'scannedAt': scannedAt.toIso8601String(),
      };
}

class BoxModel {
  final String boxNo;
  final List<InwardPartModel> parts;

  BoxModel({required this.boxNo, required this.parts});

  factory BoxModel.fromJson(Map<String, dynamic> json) {
    return BoxModel(
      boxNo: json['box_no']?.toString() ?? '',
      parts: (json['parts'] as List?)
              ?.map((e) => InwardPartModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'box_no': boxNo,
        'parts': parts.map((e) => e.toJson()).toList(),
      };
}

class InwardReceiptModel {
  final String id;
  final String truckNo;
  final String supplierName;
  final String invoiceNo;
  final String inwardDate;
  final Map<String, dynamic>? workerId;
  final String status;
  final List<BoxModel> boxes;

  InwardReceiptModel({
    required this.id,
    required this.truckNo,
    required this.supplierName,
    required this.invoiceNo,
    required this.inwardDate,
    this.workerId,
    required this.status,
    required this.boxes,
  });

  factory InwardReceiptModel.fromJson(Map<String, dynamic> json) {
    return InwardReceiptModel(
      id: json['_id']?.toString() ?? '',
      truckNo: json['truck_no']?.toString() ?? '',
      supplierName: json['supplier_name']?.toString() ?? '',
      invoiceNo: json['invoice_no']?.toString() ?? '',
      inwardDate: json['inward_date']?.toString() ?? '',
      workerId: json['workerId'] is Map<String, dynamic> ? json['workerId'] as Map<String, dynamic> : null,
      status: json['status']?.toString() ?? 'unassigned',
      boxes: (json['boxes'] as List?)
              ?.map((e) => BoxModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'truck_no': truckNo,
        'supplier_name': supplierName,
        'invoice_no': invoiceNo,
        'inward_date': inwardDate,
        'workerId': workerId,
        'status': status,
        'boxes': boxes.map((e) => e.toJson()).toList(),
      };
}
