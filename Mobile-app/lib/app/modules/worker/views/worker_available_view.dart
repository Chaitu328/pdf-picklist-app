import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app_utils/color_constants.dart';
import '../../regester_village/models/get_pick_list_model.dart';
import '../controllers/worker_controller.dart';
import '../../../../services/theme_controller.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════════════════════

class _DT {
  static ThemeController get _tc => Get.find<ThemeController>();
  static bool get isDark => _tc.isDarkMode.value;

  static Color get bg   => isDark ? const Color(0xFF060A16) : AppColor.cAppBackgroundColor;
  static Color get bg2  => isDark ? const Color(0xFF0E1220) : Colors.white;
  static Color get bg3  => isDark ? const Color(0xFF141829) : const Color(0xFFE2E8F0);
  static Color get bg4  => isDark ? const Color(0xFF1A1F35) : const Color(0xFFCBD5E1);

  static List<Color> get violetTeal  => [AppColor.cPrimaryButtonColor, AppColor.cAppPrimaryColor];
  static List<Color> get indigoCyan  => [const Color(0xFF2E7D32), const Color(0xFF81C784)];
  static List<Color> get roseAmber   => [const Color(0xFF1B5E20), const Color(0xFF4CAF50)];
  static List<Color> get emeraldMint => [const Color(0xFF0FCF7D), const Color(0xFF43E8A8)];
  static List<Color> get purpleBlue  => [const Color(0xFF33691E), const Color(0xFF8BC34A)];
  static List<Color> get sunsetOrange=> [const Color(0xFF00796B), const Color(0xFF4DB6AC)];

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

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN VIEW
// ═══════════════════════════════════════════════════════════════════════════════

class WorkerAvailableView extends GetView<WorkerController> {
  const WorkerAvailableView({super.key});

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
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            // Background glow orbs
            Positioned(top: -60, right: -80,
                child: _GlowOrb(colors: _DT.violetTeal, size: 260, opacity: isDarkTheme ? 0.18 : 0.08)),
            Positioned(bottom: 120, left: -60,
                child: _GlowOrb(colors: _DT.emeraldMint, size: 200, opacity: isDarkTheme ? 0.12 : 0.06)),
            Positioned(top: 300, right: -40,
                child: _GlowOrb(colors: _DT.indigoCyan, size: 160, opacity: isDarkTheme ? 0.08 : 0.04)),
            _buildBody(),
          ],
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
      title: Row(children: [
        // Logo badge
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: _DT.emeraldMint,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(
              color: _DT.emeraldMint[0].withOpacity(0.5),
              blurRadius: 14, offset: const Offset(0, 4),
            )],
          ),
          child: const Icon(Icons.assignment_ind_rounded,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        ShaderMask(
          shaderCallback: (bounds) =>
              const LinearGradient(colors: _DT.emeraldMint).createShader(bounds),
          child: const Text('Available Lists',
              style: TextStyle(color: Colors.white, fontSize: 22,
                  fontWeight: FontWeight.w800, letterSpacing: 0.3)),
        ),
      ]),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Tooltip(
            message: 'Refresh',
            child: GestureDetector(
              onTap: controller.fetchAllLists,
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
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value) return const _LoadingState();

    // Never show error screen — silently fall through
    if (controller.availableLists.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      color: _DT.emeraldMint[0],
      backgroundColor: _DT.bg3,
      onRefresh: controller.fetchAllLists,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 108)),

          // Stats banner
          SliverToBoxAdapter(
            child: _StatsBanner(count: controller.availableLists.length),
          ),

          // Cards
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _AvailablePickListCard(
                    pickList: controller.availableLists[i],
                    index: i,
                    onClaim: () => controller.assignPickList(
                        ctx, controller.availableLists[i].id),
                  ),
                ),
                childCount: controller.availableLists.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STATS BANNER
// ═══════════════════════════════════════════════════════════════════════════════

class _StatsBanner extends StatelessWidget {
  final int count;
  const _StatsBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _DT.emeraldMint.map((c) => c.withOpacity(0.12)).toList(),
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _DT.emeraldMint[0].withOpacity(0.3)),
        ),
        child: Row(children: [
          ShaderMask(
            shaderCallback: (b) =>
                const LinearGradient(colors: _DT.emeraldMint).createShader(b),
            child: Text('$count',
                style: const TextStyle(fontSize: 32,
                    fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Unassigned Pick Lists',
                style: TextStyle(fontSize: 13, color: _DT.textPrimary,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('Tap a card to claim & start picking',
                style: TextStyle(fontSize: 11, color: _DT.textSecondary)),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _DT.emeraldMint.map((c) => c.withOpacity(0.2)).toList(),
              ),
              shape: BoxShape.circle,
              border: Border.all(color: _DT.emeraldMint[0].withOpacity(0.4)),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                color: _DT.green, size: 22),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LOADING STATE
// ═══════════════════════════════════════════════════════════════════════════════

class _LoadingState extends StatefulWidget {
  const _LoadingState();
  @override
  State<_LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<_LoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => Column(mainAxisSize: MainAxisSize.min, children: [
          Transform.scale(
            scale: 0.92 + 0.08 * _pulse.value,
            child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color.lerp(_DT.emeraldMint[0], _DT.indigoCyan[0], _pulse.value)!,
                  Color.lerp(_DT.emeraldMint[1], _DT.indigoCyan[1], _pulse.value)!,
                ]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(
                    color: _DT.emeraldMint[0].withOpacity(0.4 * _pulse.value),
                    blurRadius: 24, spreadRadius: 4)],
              ),
              child: const Icon(Icons.assignment_ind_rounded,
                  color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(height: 20),
          Opacity(
            opacity: 0.5 + 0.5 * _pulse.value,
            child: Text('Loading available lists…',
                style: TextStyle(color: _DT.textSecondary, fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 96, height: 96,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_DT.bg3, _DT.bg4],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle,
            border: Border.all(color: _DT.white10, width: 1.5),
          ),
          child: Icon(Icons.inbox_rounded, size: 44, color: _DT.textDim),
        ),
        const SizedBox(height: 20),
        Text('No available pick lists',
            style: TextStyle(fontSize: 17, color: _DT.textSecondary,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Pull down to refresh',
            style: TextStyle(fontSize: 13, color: _DT.textDim)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GLOW ORB
// ═══════════════════════════════════════════════════════════════════════════════

class _GlowOrb extends StatelessWidget {
  final List<Color> colors;
  final double size;
  final double opacity;
  const _GlowOrb({required this.colors, required this.size,
    required this.opacity});

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

// ═══════════════════════════════════════════════════════════════════════════════
// AVAILABLE PICK LIST CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _AvailablePickListCard extends StatefulWidget {
  final PickListModel pickList;
  final int index;
  final VoidCallback onClaim;

  const _AvailablePickListCard({
    required this.pickList,
    required this.index,
    required this.onClaim,
  });

  @override
  State<_AvailablePickListCard> createState() =>
      _AvailablePickListCardState();
}

class _AvailablePickListCardState extends State<_AvailablePickListCard>
    with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late AnimationController _expandCtrl;
  late Animation<double> _fadeSlide;
  late Animation<double> _expandAnim;
  late Animation<double> _rotateAnim;
  bool _isExpanded = false;

  List<List<Color>> get _cardGradients => [
    _DT.emeraldMint,
    _DT.indigoCyan,
    _DT.violetTeal,
    _DT.sunsetOrange,
    _DT.purpleBlue,
  ];

  List<Color> get _accent =>
      _cardGradients[widget.index % _cardGradients.length];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 550));
    _fadeSlide = CurvedAnimation(parent: _entranceCtrl,
        curve: Curves.easeOutCubic);

    _expandCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 380));
    _expandAnim = CurvedAnimation(parent: _expandCtrl,
        curve: Curves.easeInOutCubic);
    _rotateAnim = Tween<double>(begin: 0.0, end: 0.5).animate(
        CurvedAnimation(parent: _expandCtrl, curve: Curves.easeInOutCubic));

    Future.delayed(Duration(milliseconds: widget.index * 90), () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
    _isExpanded ? _expandCtrl.forward() : _expandCtrl.reverse();
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}  '
        '${date.hour.toString().padLeft(2,'0')}:'
        '${date.minute.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pickList;

    return AnimatedBuilder(
      animation: _fadeSlide,
      builder: (_, child) => Opacity(
        opacity: _fadeSlide.value,
        child: Transform.translate(
            offset: Offset(0, 28 * (1 - _fadeSlide.value)), child: child),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _DT.bg2,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: _isExpanded
                  ? _accent[0].withOpacity(0.4) : _DT.white06),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.35),
                blurRadius: 22, offset: const Offset(0, 10)),
            if (_isExpanded)
              BoxShadow(color: _accent[0].withOpacity(0.12),
                  blurRadius: 30, spreadRadius: 2,
                  offset: const Offset(0, 4)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Top accent bar ──
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: Container(height: 3,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: _accent))),
              ),

              // ── Header ──
              GestureDetector(
                onTap: _toggleExpand,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      _accent[0].withOpacity(0.12),
                      _accent[1].withOpacity(0.06),
                    ], begin: Alignment.centerLeft, end: Alignment.centerRight),
                    borderRadius: BorderRadius.vertical(
                        bottom: _isExpanded ? Radius.zero
                            : const Radius.circular(20)),
                  ),
                  child: Row(children: [
                    // Pick list number badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: _accent),
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [BoxShadow(
                            color: _accent[0].withOpacity(0.45),
                            blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: Text(p.pickListNo,
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13, letterSpacing: 0.5)),
                    ),
                    const SizedBox(width: 10),
                    // Parts count pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: _DT.white06,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _DT.white10),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.inventory_2_rounded, size: 11,
                            color: _accent[0]),
                        const SizedBox(width: 4),
                        Text('${p.parts.length} parts',
                            style: TextStyle(fontSize: 11, color: _accent[0],
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                    const Spacer(),
                    // Unassigned chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: _DT.amber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _DT.amber.withOpacity(0.4)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.person_add_rounded, size: 11,
                            color: _DT.amber),
                        const SizedBox(width: 4),
                        Text('Unassigned',
                            style: TextStyle(fontSize: 10,
                                color: _DT.amber,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                    const SizedBox(width: 8),
                    // Expand chevron
                    AnimatedBuilder(
                      animation: _rotateAnim,
                      builder: (_, child) => Transform.rotate(
                          angle: _rotateAnim.value * 3.14159, child: child),
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: _DT.white10,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _DT.white15),
                        ),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.white70, size: 18),
                      ),
                    ),
                  ]),
                ),
              ),

              // ── Expanded body ──
              SizeTransition(
                sizeFactor: _expandAnim,
                axisAlignment: -1,
                child: Column(children: [
                  // Divider
                  Container(height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        _accent[0].withOpacity(0.3),
                        _accent[1].withOpacity(0.15),
                        Colors.transparent,
                      ]),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Manager row ──
                        _InfoRow(
                          icon: Icons.person_rounded,
                          label: 'Manager',
                          value: p.clientId?.email ?? '—',
                          accent: _accent,
                        ),
                        const SizedBox(height: 12),

                        // ── Date row ──
                        _InfoRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Created',
                          value: _formatDate(p.createdAt),
                          accent: _DT.indigoCyan,
                        ),
                        const SizedBox(height: 18),

                        // ── Parts header ──
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: _accent
                                  .map((c) => c.withOpacity(0.15)).toList()),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                  color: _accent[0].withOpacity(0.25)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.inventory_2_rounded, size: 11,
                                      color: _accent[0].withOpacity(0.9)),
                                  const SizedBox(width: 5),
                                  Text('PARTS TO PICK',
                                      style: TextStyle(fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: _accent[0].withOpacity(0.9),
                                          letterSpacing: 1.0)),
                                ]),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: _DT.white06,
                                borderRadius: BorderRadius.circular(7)),
                            child: Text('${p.parts.length}',
                                style: const TextStyle(fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white70)),
                          ),
                        ]),
                        const SizedBox(height: 10),

                        // ── Part rows ──
                        ...p.parts.map((part) => _PartItem(
                            part: part, accent: _accent)),
                        const SizedBox(height: 14),

                        // ── Claim button ──
                        _ClaimButton(
                            onClaim: widget.onClaim, accent: _accent),
                      ],
                    ),
                  ),
                ]),
              ),

              // ── Collapsed summary ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isExpanded
                    ? const SizedBox.shrink()
                    : _CollapsedRow(pickList: p,
                    key: const ValueKey('collapsed')),
              ),
            ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// INFO ROW
// ═══════════════════════════════════════════════════════════════════════════════

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> accent;
  const _InfoRow({required this.icon, required this.label,
    required this.value, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: accent,
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: accent[0].withOpacity(0.3),
              blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 10,
            color: _DT.textDim, fontWeight: FontWeight.w500,
            letterSpacing: 0.4)),
        const SizedBox(height: 1),
        Text(value, style: TextStyle(fontSize: 12,
            fontWeight: FontWeight.w600, color: _DT.textPrimary)),
      ]),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PART ITEM
// ═══════════════════════════════════════════════════════════════════════════════

class _PartItem extends StatelessWidget {
  final PartModel part;
  final List<Color> accent;
  const _PartItem({required this.part, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          accent[0].withOpacity(0.06),
          accent[1].withOpacity(0.03),
        ], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent[0].withOpacity(0.15)),
      ),
      child: Row(children: [
        // Accent bar
        Container(width: 3, height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: accent,
                  begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: BorderRadius.circular(2),
            )),
        const SizedBox(width: 10),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(part.description, style: TextStyle(fontSize: 12,
              fontWeight: FontWeight.w600, color: _DT.textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(part.partno, style: TextStyle(
              fontSize: 10, color: _DT.textDim)),
        ])),
        const SizedBox(width: 10),
        // Req qty badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: accent[0].withOpacity(0.15),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: accent[0].withOpacity(0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('Req ',
                style: TextStyle(fontSize: 10, color: _DT.textDim)),
            Text('${part.reqQty}', style: TextStyle(fontSize: 12,
                color: accent[0], fontWeight: FontWeight.w800)),
          ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CLAIM BUTTON
// ═══════════════════════════════════════════════════════════════════════════════

class _ClaimButton extends StatefulWidget {
  final VoidCallback onClaim;
  final List<Color> accent;
  const _ClaimButton({required this.onClaim, required this.accent});

  @override
  State<_ClaimButton> createState() => _ClaimButtonState();
}

class _ClaimButtonState extends State<_ClaimButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 130));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onClaim(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.accent),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(
                color: widget.accent[0].withOpacity(0.45),
                blurRadius: 18, offset: const Offset(0, 6))],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.assignment_ind_rounded,
                    color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Claim This List',
                    style: TextStyle(color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.w800, letterSpacing: 0.3)),
              ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COLLAPSED ROW
// ═══════════════════════════════════════════════════════════════════════════════

class _CollapsedRow extends StatelessWidget {
  final PickListModel pickList;
  const _CollapsedRow({super.key, required this.pickList});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Icon(Icons.person_outline_rounded,
            size: 13, color: _DT.textDim),
        const SizedBox(width: 5),
        Expanded(
          child: Text(pickList.clientId?.email ?? '—',
              style: TextStyle(fontSize: 12,
                  color: _DT.textSecondary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _DT.white06,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: _DT.white10),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.inventory_2_rounded, size: 11,
                color: Color(0xFF0FCF7D)),
            const SizedBox(width: 4),
            Text(
              '${pickList.parts.length} part${pickList.parts.length != 1 ? 's' : ''}',
              style: TextStyle(fontSize: 11,
                  color: _DT.textSecondary, fontWeight: FontWeight.w600),
            ),
          ]),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _DT.amber.withOpacity(0.10),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: _DT.amber.withOpacity(0.3)),
          ),
          child: Text('Tap to expand',
              style: TextStyle(fontSize: 10, color: _DT.amber,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}