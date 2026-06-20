import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app_utils/color_constants.dart';
import '../../home/models/inward_receipt_model.dart';
import '../controllers/inward_controller.dart';
import '../../../../services/theme_controller.dart';
import 'worker_inward_scan_view.dart';

class _DT {
  static ThemeController get _tc => Get.find<ThemeController>();
  static bool get isDark => _tc.isDarkMode.value;

  static Color get bg   => isDark ? const Color(0xFF060A16) : const Color(0xFFF5F7FA);
  static Color get bg2  => isDark ? const Color(0xFF0E1220) : Colors.white;
  static Color get bg3  => isDark ? const Color(0xFF141829) : const Color(0xFFE2E8F0);
  static Color get bg4  => isDark ? const Color(0xFF1A1F35) : const Color(0xFFCBD5E1);

  static const List<Color> violetTeal  = [Color(0xFF6C63FF), Color(0xFF3ECFCF)];
  static const List<Color> indigoCyan  = [Color(0xFF4158D0), Color(0xFF0FBCF9)];
  static const List<Color> roseAmber   = [Color(0xFFFF6B6B), Color(0xFFFFD93D)];
  static const List<Color> emeraldMint = [Color(0xFF0FCF7D), Color(0xFF43E8A8)];
  static const List<Color> purpleBlue  = [Color(0xFF9B8FFF), Color(0xFF3ECFCF)];
  static const List<Color> sunsetOrange= [Color(0xFFFF6B35), Color(0xFFFF9A3C)];

  static const green = Color(0xFF2ECC71);
  static const amber = Color(0xFFF39C12);
  static const red   = Color(0xFFE74C3C);

  static Color get textPrimary   => isDark ? const Color(0xFFE8EAF6) : const Color(0xFF1E293B);
  static Color get textSecondary => isDark ? const Color(0xFF8B92A9) : const Color(0xFF64748B);
  static Color get textDim       => isDark ? const Color(0xFF4A5068) : const Color(0xFF94A3B8);

  static Color get white06 => isDark ? const Color(0x0FFFFFFF) : const Color(0x0F000000);
  static Color get white10 => isDark ? const Color(0x1AFFFFFF) : const Color(0x1A000000);
  static Color get white15 => isDark ? const Color(0x26FFFFFF) : const Color(0x26000000);
}

class WorkerInwardListView extends StatefulWidget {
  const WorkerInwardListView({super.key});

  @override
  State<WorkerInwardListView> createState() => _WorkerInwardListViewState();
}

class _WorkerInwardListViewState extends State<WorkerInwardListView>
    with SingleTickerProviderStateMixin {
  final InwardController controller = Get.put(InwardController());
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkTheme = _DT.isDark;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkTheme ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _DT.bg,
        systemNavigationBarIconBrightness: isDarkTheme ? Brightness.light : Brightness.dark,
      ));

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
          title: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: _DT.indigoCyan,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _DT.indigoCyan[0].withOpacity(0.5),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(Icons.downloading_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              ShaderMask(
                shaderCallback: (bounds) =>
                    const LinearGradient(colors: _DT.indigoCyan).createShader(bounds),
                child: const Text('Inward Shipments',
                    style: TextStyle(color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.w800, letterSpacing: 0.3)),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Tooltip(
                message: 'Refresh',
                child: GestureDetector(
                  onTap: controller.fetchInwards,
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: _DT.white10,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: _DT.white15),
                    ),
                    child: const Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: _DT.indigoCyan[0],
            labelColor: _DT.textPrimary,
            unselectedLabelColor: _DT.textSecondary,
            tabs: const [
              Tab(text: "Available"),
              Tab(text: "My Inwards"),
            ],
          ),
        ),
        body: Stack(
          children: [
            Positioned(top: -60, right: -80,
                child: _GlowOrb(colors: _DT.indigoCyan, size: 260, opacity: isDarkTheme ? 0.18 : 0.08)),
            Positioned(bottom: 120, left: -60,
                child: _GlowOrb(colors: _DT.violetTeal, size: 200, opacity: isDarkTheme ? 0.12 : 0.06)),
            TabBarView(
              controller: _tabController,
              children: [
                Obx(() => _buildInwardList(controller.availableInwards, isAvailable: true)),
                Obx(() => _buildInwardList(controller.myInwards, isAvailable: false)),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInwardList(List<InwardReceiptModel> list, {required bool isAvailable}) {
    if (controller.isLoading.value) {
      return const _LoadingState();
    }

    if (list.isEmpty) {
      return _EmptyState(message: isAvailable ? "No unassigned inward shipments" : "No claimed inward shipments");
    }

    return RefreshIndicator(
      color: _DT.indigoCyan[0],
      backgroundColor: _DT.bg3,
      onRefresh: controller.fetchInwards,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return _InwardReceiptCard(
            item: item,
            index: index,
            isAvailable: isAvailable,
            onClaim: () => controller.assignInward(context, item.id),
            onScan: () => Get.to(() => WorkerInwardScanView(inward: item)),
          );
        },
      ),
    );
  }
}

class _InwardReceiptCard extends StatelessWidget {
  final InwardReceiptModel item;
  final int index;
  final bool isAvailable;
  final VoidCallback onClaim;
  final VoidCallback onScan;

  const _InwardReceiptCard({
    required this.item,
    required this.index,
    required this.isAvailable,
    required this.onClaim,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> accent = index % 2 == 0 ? _DT.indigoCyan : _DT.violetTeal;

    int totalExpected = 0;
    int totalReceived = 0;
    for (var box in item.boxes) {
      for (var part in box.parts) {
        totalExpected += part.expectedQty;
        totalReceived += part.receivedQty;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _DT.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _DT.white06),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with truck no
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accent[0].withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_rounded, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  item.truckNo.isNotEmpty ? item.truckNo : "Unknown Truck",
                  style: TextStyle(
                    color: _DT.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.status == 'unassigned' ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: TextStyle(
                      color: item.status == 'unassigned' ? Colors.orange : Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoDetail("Supplier", item.supplierName),
                const SizedBox(height: 8),
                _buildInfoDetail("Invoice No", item.invoiceNo),
                const SizedBox(height: 8),
                _buildInfoDetail("Date", item.inwardDate),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Boxes: ${item.boxes.length}", style: TextStyle(color: _DT.textSecondary, fontSize: 13)),
                    Text("Received: $totalReceived / $totalExpected", style: TextStyle(color: _DT.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent[0],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: isAvailable ? onClaim : onScan,
                    child: Text(
                      isAvailable ? "Claim Shipment" : "Start Checking / Scan",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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

  Widget _buildInfoDetail(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(color: _DT.textDim, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : "—",
            style: TextStyle(color: _DT.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: _DT.textDim),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: _DT.textSecondary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("Pull down to refresh", style: TextStyle(color: _DT.textDim, fontSize: 13)),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Loading shipments...", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final List<Color> colors;
  final double size;
  final double opacity;
  const _GlowOrb({required this.colors, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
            colors: [colors[0].withOpacity(opacity), Colors.transparent]),
      ),
    );
  }
}
