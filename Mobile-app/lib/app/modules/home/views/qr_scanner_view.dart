import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import '../../../../app_utils/color_constants.dart';
import '../controllers/home_controller.dart';

class QRScannerView extends StatefulWidget {
  const QRScannerView({Key? key}) : super(key: key);

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  late HomeController homeController;
  bool _screenOpened = false;

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomeController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.cAppPrimaryColor,
        centerTitle: true,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
            color: AppColor.whiteColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.whiteColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: homeController.mobileScannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (!_screenOpened) {
                _screenOpened = true;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    print('QR Code Scanned: ${barcode.rawValue}');
                    _showQRResult(barcode.rawValue!);
                  }
                }
              }
            },
          ),
          // Overlay guide
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          // Scanner frame border
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColor.cAppPrimaryColor,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Instructions text
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Align the QR code within the frame',
                  style: TextStyle(
                    color: AppColor.whiteColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: FloatingActionButton(
                    backgroundColor: AppColor.cAppPrimaryColor,
                    mini: true,
                    onPressed: () async {
                      await homeController.mobileScannerController.toggleTorch();
                    },
                    child: const Icon(
                      Icons.flashlight_on,
                      color: AppColor.whiteColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQRResult(String qrValue) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('QR Code Scanned'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scanned Value:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  qrValue,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _screenOpened = false;
              },
              child: const Text('Scan Again'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, qrValue);
              },
              child: const Text(
                'Use',
                style: TextStyle(color: AppColor.whiteColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

