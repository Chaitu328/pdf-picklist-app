import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../login/controllers/login_controller.dart';
import '../controllers/regester_vilage_controller.dart';
import '../models/get_pick_list_model.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════════════════════

class _DT {
  static const bg = Color(0xFF060A16);
  static const bg2 = Color(0xFF0E1220);
  static const bg3 = Color(0xFF141829);
  static const bg4 = Color(0xFF1A1F35);

  static const List<Color> violetTeal = [Color(0xFF6C63FF), Color(0xFF3ECFCF)];
  static const List<Color> indigoCyan = [Color(0xFF4158D0), Color(0xFF0FBCF9)];
  static const List<Color> roseAmber = [Color(0xFFFF6B6B), Color(0xFFFFD93D)];
  static const List<Color> emeraldMint = [Color(0xFF0FCF7D), Color(0xFF43E8A8)];
  static const List<Color> purpleBlue = [Color(0xFF9B8FFF), Color(0xFF3ECFCF)];

  static const green = Color(0xFF2ECC71);
  static const amber = Color(0xFFF39C12);
  static const red = Color(0xFFE74C3C);

  static const textPrimary = Color(0xFFE8EAF6);
  static const textSecondary = Color(0xFF8B92A9);
  static const textDim = Color(0xFF4A5068);

  static const white06 = Color(0x0FFFFFFF);
  static const white10 = Color(0x1AFFFFFF);
  static const white15 = Color(0x26FFFFFF);
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN VIEW
// ═══════════════════════════════════════════════════════════════════════════════

class ViewPickList extends StatelessWidget {
  const ViewPickList({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(RegisterVillageController());
    Get.put(LoginController());

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: _DT.bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _DT.bg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(ctrl),
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -80,
            child: _GlowOrb(colors: _DT.violetTeal, size: 260, opacity: 0.18),
          ),
          Positioned(
            bottom: 120,
            left: -60,
            child: _GlowOrb(colors: _DT.indigoCyan, size: 200, opacity: 0.12),
          ),
          Positioned(
            top: 300,
            right: -40,
            child: _GlowOrb(colors: _DT.emeraldMint, size: 160, opacity: 0.08),
          ),
          Obx(() => _buildBody(ctrl)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(RegisterVillageController ctrl) {
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
        _LogoBadge(),
        const SizedBox(width: 10),
        ShaderMask(
          shaderCallback: (bounds) =>
              const LinearGradient(colors: _DT.violetTeal).createShader(bounds),
          child: const Text(
            'Pick Lists',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ]),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: _ActionButton(
            icon: Icons.refresh_rounded,
            onTap: ctrl.fetchPickLists,
            tooltip: 'Refresh',
          ),
        ),
      ],
    );
  }

  Widget _buildBody(RegisterVillageController ctrl) {
    if (ctrl.isLoading.value) return const _LoadingState();
    if (ctrl.errorMessage.value.isNotEmpty) return _ErrorState(ctrl: ctrl);
    if (ctrl.pickLists.isEmpty) return const _EmptyState();

    return RefreshIndicator(
      color: _DT.violetTeal[0],
      backgroundColor: _DT.bg3,
      onRefresh: ctrl.fetchPickLists,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 108)),
          SliverToBoxAdapter(child: _StatsBanner(lists: ctrl.pickLists)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _PickListCard(
                    pickList: ctrl.pickLists[i],
                    index: i,
                    onDelete: () => _confirmDelete(ctx, ctrl, i),
                  ),
                ),
                childCount: ctrl.pickLists.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    RegisterVillageController ctrl,
    int index,
  ) {
    final p = ctrl.pickLists[index];
    final codeLabel =
        (p.pickListCode?.isNotEmpty == true) ? p.pickListCode! : '—';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: BoxDecoration(
          color: _DT.bg3,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _DT.red.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
                color: _DT.red.withOpacity(0.12),
                blurRadius: 30,
                spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                  color: _DT.white15, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  _DT.red.withOpacity(0.18),
                  _DT.red.withOpacity(0.06)
                ]),
                shape: BoxShape.circle,
                border:
                    Border.all(color: _DT.red.withOpacity(0.35), width: 1.5),
              ),
              child: Icon(Icons.delete_rounded,
                  size: 30, color: _DT.red.withOpacity(0.9)),
            ),
            const SizedBox(height: 16),
            Text('Delete Pick List?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _DT.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Pick list $codeLabel will be permanently removed.\nThis action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: _DT.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _DT.white10,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _DT.white15),
                    ),
                    alignment: Alignment.center,
                    child: Text('Cancel',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _DT.textSecondary)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    // 2. Get the specific item using the index
                    final itemToDelete = ctrl.pickLists[index];

                    // 3. Call the API function from the controller
                    // This will hit the backend and then update the UI list on success
                    ctrl.deletePickList(index);
                    // ctrl.pickLists.removeAt(index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        _DT.red.withOpacity(0.85),
                        const Color(0xFFFF8A65)
                      ]),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: _DT.red.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_rounded,
                            color: Colors.white, size: 17),
                        SizedBox(width: 7),
                        Text('Delete',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LOGO BADGE
// ═══════════════════════════════════════════════════════════════════════════════

class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: _DT.violetTeal,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: _DT.violetTeal[0].withOpacity(0.5),
              blurRadius: 14,
              offset: const Offset(0, 4))
        ],
      ),
      child: const Icon(Icons.list_alt_rounded, color: Colors.white, size: 20),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ACTION BUTTON
// ═══════════════════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _ActionButton(
      {required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _DT.white10,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: _DT.white15),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
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
  const _GlowOrb(
      {required this.colors, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
            colors: [colors[0].withOpacity(opacity), Colors.transparent]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STATS BANNER
// ═══════════════════════════════════════════════════════════════════════════════

class _StatsBanner extends StatelessWidget {
  final List<PickListModel> lists;
  const _StatsBanner({required this.lists});

  @override
  Widget build(BuildContext context) {
    final total = lists.length;
    final completed =
        lists.where((l) => l.status.toLowerCase() == 'completed').length;
    final processing =
        lists.where((l) => l.status.toLowerCase() == 'processing').length;
    final unassigned =
        lists.where((l) => l.status.toLowerCase() == 'unassigned').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        _StatPill(label: 'Total', value: '$total', colors: _DT.violetTeal),
        const SizedBox(width: 8),
        _StatPill(label: 'Done', value: '$completed', colors: _DT.emeraldMint),
        const SizedBox(width: 8),
        _StatPill(
            label: 'Active', value: '$processing', colors: _DT.indigoCyan),
        const SizedBox(width: 8),
        _StatPill(
            label: 'Waiting', value: '$unassigned', colors: _DT.roseAmber),
      ]),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final List<Color> colors;
  const _StatPill(
      {required this.label, required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: colors.map((c) => c.withOpacity(0.12)).toList()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors[0].withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (b) =>
                  LinearGradient(colors: colors).createShader(b),
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: _DT.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
          ],
        ),
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
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 0.92 + 0.08 * _pulse.value,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Color.lerp(
                        _DT.violetTeal[0], _DT.indigoCyan[0], _pulse.value)!,
                    Color.lerp(
                        _DT.violetTeal[1], _DT.indigoCyan[1], _pulse.value)!,
                  ]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color:
                            _DT.violetTeal[0].withOpacity(0.4 * _pulse.value),
                        blurRadius: 24,
                        spreadRadius: 4)
                  ],
                ),
                child: const Icon(Icons.list_alt_rounded,
                    color: Colors.white, size: 30),
              ),
            ),
            const SizedBox(height: 20),
            Opacity(
              opacity: 0.5 + 0.5 * _pulse.value,
              child: Text('Loading pick lists…',
                  style: TextStyle(
                      color: _DT.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ERROR STATE
// ═══════════════════════════════════════════════════════════════════════════════

class _ErrorState extends StatelessWidget {
  final RegisterVillageController ctrl;
  const _ErrorState({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  _DT.red.withOpacity(0.15),
                  _DT.red.withOpacity(0.05)
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
                border:
                    Border.all(color: _DT.red.withOpacity(0.35), width: 1.5),
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 38, color: _DT.red.withOpacity(0.9)),
            ),
            const SizedBox(height: 20),
            Text(ctrl.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: _DT.textSecondary, height: 1.6)),
            const SizedBox(height: 28),
            _GradientButton(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                colors: _DT.violetTeal,
                onTap: ctrl.fetchPickLists),
          ],
        ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [_DT.bg3, _DT.bg4],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              shape: BoxShape.circle,
              border: Border.all(color: _DT.white10, width: 1.5),
            ),
            child:
                Icon(Icons.inbox_rounded, size: 44, color: _DT.textDim),
          ),
          const SizedBox(height: 20),
          Text('No pick lists found',
              style: TextStyle(
                  fontSize: 17,
                  color: _DT.textSecondary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Pull down to refresh',
              style: TextStyle(fontSize: 13, color: _DT.textDim)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GRADIENT BUTTON
// ═══════════════════════════════════════════════════════════════════════════════

class _GradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  const _GradientButton(
      {required this.label,
      required this.icon,
      required this.colors,
      required this.onTap});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.colors),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: widget.colors[0].withOpacity(0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 7))
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 19),
              const SizedBox(width: 9),
              Text(widget.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PICK LIST CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _PickListCard extends StatefulWidget {
  final PickListModel pickList;
  final int index;
  final VoidCallback onDelete;
  const _PickListCard(
      {required this.pickList, required this.index, required this.onDelete});

  @override
  State<_PickListCard> createState() => _PickListCardState();
}

class _PickListCardState extends State<_PickListCard>
    with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late AnimationController _expandCtrl;
  late Animation<double> _fadeSlide;
  late Animation<double> _expandAnim;
  late Animation<double> _rotateAnim;
  bool _isExpanded = false;

  static const _cardGradients = [
    _DT.violetTeal,
    _DT.indigoCyan,
    _DT.emeraldMint,
    _DT.roseAmber,
    _DT.purpleBlue,
  ];

  List<Color> get _accentColors =>
      _cardGradients[widget.index % _cardGradients.length];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _fadeSlide =
        CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic);
    _expandCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _expandAnim =
        CurvedAnimation(parent: _expandCtrl, curve: Curves.easeInOutCubic);
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

  @override
  Widget build(BuildContext context) {
    final p = widget.pickList;
    // final displayCode =
    //     (p.pickListCode?.isNotEmpty == true) ? p.pickListCode! : '—';
    final displayCode = (p.pickListNo.isNotEmpty) ? p.pickListNo : '—';

    return AnimatedBuilder(
      animation: _fadeSlide,
      builder: (_, child) => Opacity(
        opacity: _fadeSlide.value,
        child: Transform.translate(
            offset: Offset(0, 28 * (1 - _fadeSlide.value)), child: child),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: _DT.bg2,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: _isExpanded
                      ? _accentColors[0].withOpacity(0.35)
                      : _DT.white06),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 10)),
                if (_isExpanded)
                  BoxShadow(
                      color: _accentColors[0].withOpacity(0.12),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(22)),
                  child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: _accentColors))),
                ),
                GestureDetector(
                  onTap: _toggleExpand,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _accentColors[0].withOpacity(0.12),
                          _accentColors[1].withOpacity(0.06)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.vertical(
                          bottom: _isExpanded
                              ? Radius.zero
                              : const Radius.circular(20)),
                    ),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: _accentColors),
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: [
                            BoxShadow(
                                color: _accentColors[0].withOpacity(0.45),
                                blurRadius: 10,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: Text(displayCode,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                letterSpacing: 0.5)),
                      ),
                      const Spacer(),
                      _StatusChip(status: p.status),
                      const SizedBox(width: 10),
                      AnimatedBuilder(
                        animation: _rotateAnim,
                        builder: (_, child) => Transform.rotate(
                            angle: _rotateAnim.value * math.pi * 2,
                            child: child),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                              color: _DT.white10,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(color: _DT.white15)),
                          child: Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.white70, size: 19),
                        ),
                      ),
                    ]),
                  ),
                ),
                SizeTransition(
                  sizeFactor: _expandAnim,
                  axisAlignment: -1,
                  child: Column(children: [
                    _GradientDivider(colors: _accentColors),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: _InfoTile(
                                icon: Icons.person_rounded,
                                label: 'Client',
                                value: p.clientId?.email ?? '—',
                                colors: const [
                                  Color(0xFF6C63FF),
                                  Color(0xFF9B8FFF)
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoTile(
                                icon: Icons.engineering_rounded,
                                label: 'Worker',
                                value: p.workerId?.email ?? 'Unassigned',
                                colors: p.workerId == null
                                    ? [
                                        Colors.orange.shade400,
                                        Colors.deepOrange.shade300
                                      ]
                                    : _DT.emeraldMint,
                                valueColor: p.workerId == null
                                    ? Colors.orange.shade400
                                    : null,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 18),
                          _PartsHeader(
                              count: p.parts.length, colors: _accentColors),
                          const SizedBox(height: 10),
                          ...p.parts.map((part) => _PartRow(part: part)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: _DT.white06,
                                borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 11, color: _DT.textDim),
                                const SizedBox(width: 4),
                                Text(_formatDate(p.createdAt),
                                    style: TextStyle(
                                        fontSize: 11, color: _DT.textDim)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isExpanded
                      ? const SizedBox.shrink()
                      : _CollapsedSummary(
                          key: const ValueKey('collapsed'), pickList: p),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: widget.onDelete,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    _DT.red.withOpacity(0.18),
                    _DT.red.withOpacity(0.08)
                  ]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _DT.red.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 15, color: _DT.red.withOpacity(0.85)),
                    const SizedBox(width: 6),
                    Text('Delete',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _DT.red.withOpacity(0.85),
                            letterSpacing: 0.3)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}  '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GRADIENT DIVIDER
// ═══════════════════════════════════════════════════════════════════════════════

class _GradientDivider extends StatelessWidget {
  final List<Color> colors;
  const _GradientDivider({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.transparent,
          colors[0].withOpacity(0.3),
          colors[1].withOpacity(0.15),
          Colors.transparent,
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PARTS HEADER
// ═══════════════════════════════════════════════════════════════════════════════

class _PartsHeader extends StatelessWidget {
  final int count;
  final List<Color> colors;
  const _PartsHeader({required this.count, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: colors.map((c) => c.withOpacity(0.15)).toList()),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: colors[0].withOpacity(0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inventory_2_rounded,
              size: 12, color: colors[0].withOpacity(0.9)),
          const SizedBox(width: 5),
          Text('PARTS',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: colors[0].withOpacity(0.9),
                  letterSpacing: 1.2)),
        ]),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: _DT.white06, borderRadius: BorderRadius.circular(7)),
        child: Text('$count',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white70)),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COLLAPSED SUMMARY
// ═══════════════════════════════════════════════════════════════════════════════

class _CollapsedSummary extends StatelessWidget {
  final PickListModel pickList;
  const _CollapsedSummary({super.key, required this.pickList});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Icon(Icons.person_outline_rounded, size: 14, color: _DT.textDim),
        const SizedBox(width: 6),
        Expanded(
          child: Text(pickList.clientId?.email ?? '—',
              style: TextStyle(fontSize: 12, color: _DT.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
              color: _DT.white06,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: _DT.white10)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.inventory_2_rounded,
                size: 12, color: Color(0xFF9B8FFF)),
            const SizedBox(width: 5),
            Text(
              '${pickList.parts.length} part${pickList.parts.length != 1 ? 's' : ''}',
              style: TextStyle(
                  fontSize: 11,
                  color: _DT.textSecondary,
                  fontWeight: FontWeight.w600),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PART ROW
// ═══════════════════════════════════════════════════════════════════════════════

class _PartRow extends StatelessWidget {
  final PartModel part;
  const _PartRow({required this.part});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = part.status == 'completed';
    final Color accent = isCompleted ? _DT.green : _DT.amber;
    final List<Color> barColors = isCompleted
        ? [const Color(0xFF1A8A4A), _DT.green]
        : [const Color(0xFFB7650A), _DT.amber];

    // ✅ FIX 1: strip \n here in the view as final safety net
    // (model already strips it, but this guarantees it)
    final String partNo = part.partno
        .replaceAll('\r\n', '')
        .replaceAll('\r', '')
        .replaceAll('\n', '')
        .trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.05), accent.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: accent.withOpacity(0.18)),
      ),
      child: Row(children: [
        Container(
          width: 3.5,
          height: 38,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: barColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                part.description,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _DT.textPrimary,
                    height: 1.3),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              // ✅ FIX 2: softWrap:false  — never wraps to a second line
              // ✅ FIX 3: overflow:visible — never clips any characters
              Text(
                partNo,
                style: TextStyle(
                  fontSize: 11,
                  color: _DT.textDim,
                  fontWeight: FontWeight.w500,
                ),
                softWrap: false, // ✅ no line wrap
                overflow: TextOverflow.visible, // ✅ never clips
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _QtyBadge(
                label: 'Req',
                value: '${part.reqQty}',
                color: _DT.textSecondary),
            const SizedBox(height: 4),
            _QtyBadge(label: 'Allo', value: '${part.alloQty}', color: accent),
          ],
        ),
        const SizedBox(width: 10),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: barColors.map((c) => c.withOpacity(0.2)).toList()),
            shape: BoxShape.circle,
            border: Border.all(color: accent.withOpacity(0.3)),
          ),
          child: Icon(
              isCompleted ? Icons.check_rounded : Icons.hourglass_top_rounded,
              size: 15,
              color: accent),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// QTY BADGE
// ═══════════════════════════════════════════════════════════════════════════════

class _QtyBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _QtyBadge(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$label ',
          style: TextStyle(
              fontSize: 10, color: _DT.textDim, fontWeight: FontWeight.w500)),
      Text(value,
          style: TextStyle(
              fontSize: 13, color: color, fontWeight: FontWeight.w800)),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// INFO TILE
// ═══════════════════════════════════════════════════════════════════════════════

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> colors;
  final Color? valueColor;

  const _InfoTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.colors,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
                color: colors[0].withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Icon(icon, size: 15, color: Colors.white),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: _DT.textDim,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? _DT.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ]),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STATUS CHIP
// ═══════════════════════════════════════════════════════════════════════════════

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    List<Color> gradient;

    switch (status.toLowerCase()) {
      case 'processing':
        color = const Color(0xFF4FC3F7);
        icon = Icons.sync_rounded;
        gradient = [const Color(0xFF0288D1), const Color(0xFF4FC3F7)];
        break;
      case 'completed':
        color = _DT.green;
        icon = Icons.check_circle_rounded;
        gradient = [const Color(0xFF1A8A4A), _DT.green];
        break;
      case 'unassigned':
        color = _DT.amber;
        icon = Icons.person_add_rounded;
        gradient = [const Color(0xFFB7650A), _DT.amber];
        break;
      default:
        color = _DT.textSecondary;
        icon = Icons.help_rounded;
        gradient = [_DT.textDim, _DT.textSecondary];
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradient.map((c) => c.withOpacity(0.18)).toList()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.38)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 5),
        Text(status.capitalizeFirst ?? status,
            style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3)),
      ]),
    );
  }
}
