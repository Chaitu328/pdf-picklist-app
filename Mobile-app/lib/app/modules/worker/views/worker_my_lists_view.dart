import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app_utils/color_constants.dart';
import '../../../routes/app_routes.dart';
import '../../regester_village/models/get_pick_list_model.dart';
import '../controllers/worker_controller.dart';
import '../../../../services/theme_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLOR TOKENS
// ─────────────────────────────────────────────────────────────────────────────

Color get _kBg1 => Get.find<ThemeController>().isDarkMode.value ? const Color(0xFF07090F) : const Color(0xFFF5F7FA);
Color get _kBg2 => Get.find<ThemeController>().isDarkMode.value ? const Color(0xFF0D1017) : Colors.white;
Color get _kBg3 => Get.find<ThemeController>().isDarkMode.value ? const Color(0xFF131720) : const Color(0xFFE2E8F0);
Color get _kBg4 => Get.find<ThemeController>().isDarkMode.value ? const Color(0xFF1B2030) : const Color(0xFFCBD5E1);

Color get _kWhite06 => Get.find<ThemeController>().isDarkMode.value ? const Color(0x0FFFFFFF) : const Color(0x0F000000);
Color get _kWhite10 => Get.find<ThemeController>().isDarkMode.value ? const Color(0x1AFFFFFF) : const Color(0x1A000000);
Color get _kWhite18 => Get.find<ThemeController>().isDarkMode.value ? const Color(0x2EFFFFFF) : const Color(0x2E000000);

Color get _kTextPrimary => Get.find<ThemeController>().isDarkMode.value ? const Color(0xFFECEEF4) : const Color(0xFF1E293B);
Color get _kTextSecondary => Get.find<ThemeController>().isDarkMode.value ? const Color(0xFF8B92A9) : const Color(0xFF64748B);
Color get _kTextDim => Get.find<ThemeController>().isDarkMode.value ? const Color(0xFF4A5068) : const Color(0xFF94A3B8);

const _kGreen = Color(0xFF2ECC71);
const _kAmber = Color(0xFFF39C12);
const _kBlue = Color(0xFF4FC3F7);

const _kAccents = <List<Color>>[
  [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
  [Color(0xFF4158D0), Color(0xFF0FBCF9)],
  [Color(0xFF0FCF7D), Color(0xFF43E8A8)],
  [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
  [Color(0xFF9B8FFF), Color(0xFF3ECFCF)],
];

List<Color> _cardAccent(int index) => _kAccents[index % _kAccents.length];

// ─────────────────────────────────────────────────────────────────────────────
// MAIN VIEW
// ─────────────────────────────────────────────────────────────────────────────

class WorkerMyListsView extends GetView<WorkerController> {
  const WorkerMyListsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = Get.find<ThemeController>().isDarkMode.value;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _kBg1,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ));

      return Scaffold(
        backgroundColor: _kBg1,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            // ambient glow orbs
            Positioned(
              top: -40,
              right: -60,
              child: _GlowOrb(
                colors: _kAccents[0],
                size: 220,
                opacity: isDark ? 0.15 : 0.07,
              ),
            ),
            Positioned(
              bottom: 100,
              left: -50,
              child: _GlowOrb(
                colors: _kAccents[1],
                size: 180,
                opacity: isDark ? 0.10 : 0.05,
              ),
            ),
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
            colors: [_kBg4, _kBg2],
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.assignment_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
            ).createShader(bounds),
            child: const Text(
              'My Pick Lists',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: GestureDetector(
            onTap: controller.fetchAllLists,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _kWhite10,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kWhite18),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return const _LoadingState();
    }

    final lists = controller.myLists;

    if (lists.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      color: const Color(0xFF6C63FF),
      backgroundColor: _kBg3,
      onRefresh: controller.fetchAllLists,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 108)),
          SliverToBoxAdapter(child: _SummaryBar(lists: lists)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _MyPickListCard(
                    pickList: lists[i],
                    index: i,
                    onSubmit: () => Get.toNamed(
                      AppRoutes.workerSubmit,
                      arguments: lists[i],
                    ),
                  ),
                ),
                childCount: lists.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLOW ORB
// ─────────────────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final List<Color> colors;
  final double size;
  final double opacity;

  const _GlowOrb({
    required this.colors,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [colors[0].withOpacity(opacity), Colors.transparent],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUMMARY BAR
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final List<PickListModel> lists;

  const _SummaryBar({required this.lists});

  @override
  Widget build(BuildContext context) {
    final total = lists.length;
    final processing = lists.where((l) => l.status == 'processing').length;
    final assigned = lists.where((l) => l.status == 'assigned').length;
    final completed = lists.where((l) => l.status == 'completed').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _SummaryPill(label: 'Total', value: '$total', colors: _kAccents[0]),
          const SizedBox(width: 8),
          _SummaryPill(
              label: 'Active', value: '$processing', colors: _kAccents[1]),
          const SizedBox(width: 8),
          _SummaryPill(
              label: 'Assigned', value: '$assigned', colors: _kAccents[2]),
          const SizedBox(width: 8),
          _SummaryPill(
              label: 'Done', value: '$completed', colors: _kAccents[3]),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final List<Color> colors;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.map((c) => c.withOpacity(0.12)).toList(),
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors[0].withOpacity(0.28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (b) =>
                  LinearGradient(colors: colors).createShader(b),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: _kTextSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADING STATE
// ─────────────────────────────────────────────────────────────────────────────

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
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
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
        builder: (_, __) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 0.92 + 0.08 * _pulse.value,
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(
                          _kAccents[0][0],
                          _kAccents[1][0],
                          _pulse.value,
                        )!,
                        Color.lerp(
                          _kAccents[0][1],
                          _kAccents[1][1],
                          _pulse.value,
                        )!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _kAccents[0][0].withOpacity(0.4 * _pulse.value),
                        blurRadius: 22,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.assignment_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Opacity(
                opacity: 0.5 + 0.5 * _pulse.value,
                child: const Text(
                  'Loading your lists…',
                  style: TextStyle(
                    color: _kTextSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_kBg3, _kBg4],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: _kWhite10, width: 1.5),
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 42,
              color: _kTextDim,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No lists assigned yet',
            style: TextStyle(
              fontSize: 17,
              color: _kTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Go to Available Lists to claim one',
            style: TextStyle(fontSize: 13, color: _kTextDim),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MY PICK LIST CARD
// ─────────────────────────────────────────────────────────────────────────────

class _MyPickListCard extends StatefulWidget {
  final PickListModel pickList;
  final int index;
  final VoidCallback onSubmit;

  const _MyPickListCard({
    required this.pickList,
    required this.index,
    required this.onSubmit,
  });

  @override
  State<_MyPickListCard> createState() => _MyPickListCardState();
}

class _MyPickListCardState extends State<_MyPickListCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late Animation<double> _fadeSlide;

  // 1. ADD STATE FOR EXPANSION
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeSlide = CurvedAnimation(
      parent: _entranceCtrl,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(
      Duration(milliseconds: widget.index * 100),
      () {
        if (mounted) _entranceCtrl.forward();
      },
    );
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pickList;
    final colors = _cardAccent(widget.index);

    final bool isCompleted = p.status == 'completed';
    final bool isProcessing = p.status == 'processing';

    final Color statusColor;
    final IconData statusIcon;
    final String statusLabel;

    if (isCompleted) {
      statusColor = _kGreen;
      statusIcon = Icons.check_circle_rounded;
      statusLabel = 'Completed';
    } else if (isProcessing) {
      statusColor = _kBlue;
      statusIcon = Icons.sync_rounded;
      statusLabel = 'Processing';
    } else {
      statusColor = _kAmber;
      statusIcon = Icons.assignment_ind_rounded;
      statusLabel = p.status.capitalizeFirst ?? p.status;
    }

    return AnimatedBuilder(
      animation: _fadeSlide,
      builder: (_, child) => Opacity(
        opacity: _fadeSlide.value,
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - _fadeSlide.value)),
          child: child,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _kBg2,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors[0].withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top accent bar
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                ),
              ),
            ),

            // 2. HEADER (TAP TO TOGGLE)
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors[0].withOpacity(0.12),
                      colors[1].withOpacity(0.05),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: colors),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        p.pickListNo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Status Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 5),
                          Text(
                            statusLabel,
                            style: TextStyle(
                                fontSize: 11,
                                color: statusColor,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // 3. EXPAND/COLLAPSE INDICATOR
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: _kTextSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            // 4. ANIMATED BODY
            AnimatedCrossFade(
              firstChild:
                  const SizedBox(width: double.infinity), // Collapsed state
              secondChild: _buildExpandedContent(p, colors), // Expanded state
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(PickListModel p, List<Color> colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          // Manager Info
          _buildManagerInfo(p, colors),
          const SizedBox(height: 14),
          // Parts Section
          _buildPartsHeader(p, colors),
          const SizedBox(height: 10),
          ...p.parts.map((part) => _PartTile(part: part, accentColors: colors)),
          const SizedBox(height: 10),
          // Date
          _buildDateRow(p),
          // Submit Button
          if (p.status != 'completed') ...[
            const SizedBox(height: 14),
            _SubmitButton(
              colors: colors,
              onTap: widget.onSubmit,
            ),
          ],
        ],
      ),
    );
  }

  // Refactored UI helpers to keep the code clean
  Widget _buildManagerInfo(PickListModel p, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: _kWhite06,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kWhite10),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.person_rounded, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Manager',
                  style: TextStyle(fontSize: 10, color: _kTextDim)),
              Text(p.clientId?.email ?? '—',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kTextPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartsHeader(PickListModel p, List<Color> colors) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colors[0].withOpacity(0.15),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: colors[0].withOpacity(0.25)),
          ),
          child: Text('PARTS',
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w800, color: colors[0])),
        ),
        const SizedBox(width: 8),
        Text('${p.parts.length}',
            style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }

  Widget _buildDateRow(PickListModel p) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded, size: 11, color: _kTextDim),
        const SizedBox(width: 4),
        Text(_formatDate(p.createdAt),
            style: const TextStyle(fontSize: 11, color: _kTextDim)),
      ],
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
    return '${date.day} ${months[date.month - 1]} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// PART TILE
// ─────────────────────────────────────────────────────────────────────────────

class _PartTile extends StatelessWidget {
  final PartModel part;
  final List<Color> accentColors;

  const _PartTile({required this.part, required this.accentColors});

  @override
  Widget build(BuildContext context) {
    final bool done = part.status == 'completed';
    final Color accent = done ? _kGreen : _kAmber;
    final List<Color> barColors = done
        ? [const Color(0xFF1A8A4A), _kGreen]
        : [const Color(0xFFB7650A), _kAmber];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.05), accent.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: accent.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          // gradient left bar
          Container(
            width: 3.5,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: barColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // description + part no
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part.description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  part.partno,
                  style: const TextStyle(fontSize: 11, color: _kTextDim),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // qty
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _QtyRow(
                  label: 'Req',
                  value: '${part.reqQty}',
                  color: _kTextSecondary),
              const SizedBox(height: 4),
              _QtyRow(label: 'Allo', value: '${part.alloQty}', color: accent),
            ],
          ),
          const SizedBox(width: 10),
          // status circle
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: barColors.map((c) => c.withOpacity(0.2)).toList(),
              ),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withOpacity(0.3)),
            ),
            child: Icon(
              done ? Icons.check_rounded : Icons.hourglass_top_rounded,
              size: 14,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _QtyRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: const TextStyle(
              fontSize: 10, color: _kTextDim, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBMIT BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _SubmitButton extends StatefulWidget {
  final List<Color> colors;
  final VoidCallback onTap;

  const _SubmitButton({required this.colors, required this.onTap});

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.colors),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.colors[0].withOpacity(0.4),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner_rounded,
                  color: Colors.white, size: 18),
              SizedBox(width: 9),
              Text(
                'Enter Quantities & Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
