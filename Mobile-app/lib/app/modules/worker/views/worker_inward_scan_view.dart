import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../home/models/inward_receipt_model.dart';
import '../controllers/inward_controller.dart';
import '../../../../app_utils/color_constants.dart';
import '../../../../services/theme_controller.dart';

class _DT {
  static ThemeController get _tc => Get.find<ThemeController>();
  static bool get isDark => _tc.isDarkMode.value;

  static Color get bg   => isDark ? const Color(0xFF060A16) : const Color(0xFFF5F7FA);
  static Color get bg2  => isDark ? const Color(0xFF0E1220) : Colors.white;
  static Color get bg3  => isDark ? const Color(0xFF141829) : const Color(0xFFE2E8F0);
  static Color get bg4  => isDark ? const Color(0xFF1A1F35) : const Color(0xFFCBD5E1);

  static Color get textPrimary   => isDark ? const Color(0xFFE8EAF6) : const Color(0xFF1E293B);
  static Color get textSecondary => isDark ? const Color(0xFF8B92A9) : const Color(0xFF64748B);
  static Color get textDim       => isDark ? const Color(0xFF4A5068) : const Color(0xFF94A3B8);

  static Color get white06 => isDark ? const Color(0x0FFFFFFF) : const Color(0x0F000000);
}

class WorkerInwardScanView extends StatefulWidget {
  final InwardReceiptModel inward;
  const WorkerInwardScanView({super.key, required this.inward});

  @override
  State<WorkerInwardScanView> createState() => _WorkerInwardScanViewState();
}

class _WorkerInwardScanViewState extends State<WorkerInwardScanView> {
  final InwardController controller = Get.find<InwardController>();
  late InwardReceiptModel activeInward;

  @override
  void initState() {
    super.initState();
    activeInward = widget.inward;
  }

  void _refreshLocalData() {
    final updated = controller.allInwards.firstWhereOrNull((item) => item.id == activeInward.id);
    if (updated != null) {
      setState(() {
        activeInward = updated;
      });
    }
  }

  void _showScanOptions(InwardPartModel part) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: _DT.bg2,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Scan or Add: ${part.description}",
                style: TextStyle(color: _DT.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Part No: ${part.partno}",
                style: TextStyle(color: _DT.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.cPrimaryButtonColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _startCameraScan(part);
                      },
                      icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                      label: const Text("Scan Code", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColor.cPrimaryButtonColor),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        final success = await controller.updateScan(
                          inwardId: activeInward.id,
                          partNo: part.partno,
                          qrCode: "Manual-${DateTime.now().millisecondsSinceEpoch}",
                          entryMethod: "Manual",
                          context: context,
                        );
                        if (success) _refreshLocalData();
                      },
                      icon: const Icon(Icons.add_rounded, color: AppColor.cPrimaryButtonColor),
                      label: const Text("Manual Add", style: TextStyle(color: AppColor.cPrimaryButtonColor, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _startCameraScan(InwardPartModel part) {
    Get.to(() => _InwardCameraScanner(
      onCodeScanned: (code) async {
        final success = await controller.updateScan(
          inwardId: activeInward.id,
          partNo: part.partno,
          qrCode: code,
          entryMethod: "QR",
          context: context,
        );
        if (success) _refreshLocalData();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      _refreshLocalData(); // Sync with controller state
      final isDarkTheme = _DT.isDark;

      int totalExpected = 0;
      int totalReceived = 0;
      for (var box in activeInward.boxes) {
        for (var part in box.parts) {
          totalExpected += part.expectedQty;
          totalReceived += part.receivedQty;
        }
      }

      return Scaffold(
        backgroundColor: _DT.bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_DT.bg4, _DT.bg2],
              ),
            ),
          ),
          title: Text(
            activeInward.truckNo.isNotEmpty ? "Check ${activeInward.truckNo}" : "Inward Checklist",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          foregroundColor: _DT.textPrimary,
          actions: [
            TextButton.icon(
              onPressed: () => controller.completeInward(context, activeInward.id),
              icon: const Icon(Icons.done_all_rounded, color: Colors.greenAccent),
              label: const Text(
                "Submit",
                style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Discrepancy counter / stats banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: _DT.bg2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Verification Status", style: TextStyle(color: _DT.textDim, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        "$totalReceived / $totalExpected Parts Checked",
                        style: TextStyle(color: _DT.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (totalReceived == totalExpected) ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      (totalReceived == totalExpected) ? Icons.check_circle_rounded : Icons.pending_rounded,
                      color: (totalReceived == totalExpected) ? Colors.green : Colors.amber,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: activeInward.boxes.length,
                itemBuilder: (context, index) {
                  final box = activeInward.boxes[index];
                  return _buildBoxCard(box);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBoxCard(BoxModel box) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _DT.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _DT.white06),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          "Box No: ${box.boxNo.isNotEmpty ? box.boxNo : "Unnumbered"}",
          style: TextStyle(color: _DT.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          "${box.parts.length} parts inside",
          style: TextStyle(color: _DT.textSecondary, fontSize: 12),
        ),
        children: box.parts.map((part) => _buildPartItem(part)).toList(),
      ),
    );
  }

  Widget _buildPartItem(InwardPartModel part) {
    final bool isComplete = part.receivedQty == part.expectedQty;
    final bool isExcess = part.receivedQty > part.expectedQty;

    Color badgeColor = Colors.orange;
    if (isComplete) badgeColor = Colors.green;
    if (isExcess) badgeColor = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _DT.white06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part.description,
                  style: TextStyle(color: _DT.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  "Part No: ${part.partno}",
                  style: TextStyle(color: _DT.textDim, fontSize: 11),
                ),
                if (part.location != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    "Loc: Rack ${part.location!.rack}, Bin ${part.location!.bin}",
                    style: TextStyle(color: Colors.blue.shade400, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Checked counter badge
          GestureDetector(
            onTap: () => _showScanOptions(part),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: badgeColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Text(
                    "${part.receivedQty} / ${part.expectedQty}",
                    style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isComplete
                        ? Icons.check_circle_outline_rounded
                        : isExcess
                            ? Icons.warning_amber_rounded
                            : Icons.add_circle_outline_rounded,
                    color: badgeColor,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InwardCameraScanner extends StatefulWidget {
  final Function(String) onCodeScanned;
  const _InwardCameraScanner({required this.onCodeScanned});

  @override
  State<_InwardCameraScanner> createState() => _InwardCameraScannerState();
}

class _InwardCameraScannerState extends State<_InwardCameraScanner> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR / Barcode"),
        backgroundColor: AppColor.cAppPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (!_scanned && barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue;
                if (code != null) {
                  _scanned = true;
                  widget.onCodeScanned(code);
                  Get.back();
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.cAppPrimaryColor, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
