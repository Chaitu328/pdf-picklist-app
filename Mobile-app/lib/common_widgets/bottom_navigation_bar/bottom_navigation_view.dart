import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../app/modules/home/views/pick_list_view.dart';
import '../../app/modules/home/views/manager_audit_view.dart';
import '../../app/modules/profile/views/profile_view.dart';
import '../../app/modules/regester_village/views/picklist_view.dart'
    hide ViewPickList;
import '../../app/modules/worker/controllers/worker_controller.dart';
import '../../app/modules/worker/views/worker_available_view.dart';
import '../../app/modules/worker/views/worker_my_lists_view.dart';
import '../../app/modules/worker/views/worker_inward_list_view.dart';
import '../../app_utils/color_constants.dart';
import '../../main.dart';
import 'bottom_navigation_controller.dart';

class BottomMainBar extends StatelessWidget {
  BottomMainBar({super.key});

  final NavigationController navController = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    final String role = box.read("user_role") ?? 'worker';
    final bool isManager = role == 'manager';

    if (!isManager) {
      Get.put(WorkerController());
      print("Current Role: $role");
    }

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor:
          Colors.transparent, // ✅ transparent lets Flutter control it
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    final List<_NavItem> managerNavItems = [
      _NavItem(icon: Icons.upload_file_rounded, label: 'Upload List'),
      _NavItem(icon: Icons.list_alt_rounded, label: 'All Lists'),
      _NavItem(icon: Icons.analytics_rounded, label: 'Audits'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];

    final List<_NavItem> workerNavItems = [
      _NavItem(icon: Icons.assignment_outlined, label: 'Available'),
      _NavItem(icon: Icons.assignment_turned_in_outlined, label: 'My Lists'),
      _NavItem(icon: Icons.downloading_rounded, label: 'Inwards'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];

    final navItems = isManager ? managerNavItems : workerNavItems;

    return Obx(() {
      final int currentIndex = navController.currentIndex.value;

      Widget currentPage;
      if (isManager) {
        switch (currentIndex) {
          case 0:
            currentPage = const PickListView();
            break;
          case 1:
            currentPage = ViewPickList();
            break;
          case 2:
            currentPage = const ManagerAuditView();
            break;
          default:
            currentPage = ProfileView();
        }
      } else {
        switch (currentIndex) {
          case 0:
            currentPage = const WorkerAvailableView();
            break;
          case 1:
            currentPage = const WorkerMyListsView();
            break;
          case 2:
            currentPage = const WorkerInwardListView();
            break;
          default:
            currentPage = ProfileView();
        }
      }

      return Scaffold(
        extendBody: false, // ✅ false — body must NOT go under nav bar
        body: currentPage,
        bottomNavigationBar: _CustomBottomBar(
          navItems: navItems,
          currentIndex: currentIndex,
          onTap: (index) => navController.changeTab(index),
        ),
      );
    });
  }
}

// class ViewPickList {
//   const ViewPickList();
// }

class _CustomBottomBar extends StatelessWidget {
  final List<_NavItem> navItems;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CustomBottomBar({
    required this.navItems,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ viewPadding is NEVER consumed by SafeArea — always has the real device inset
    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      color: AppColor.cAppPrimaryColor,
      // ✅ No fixed height — let content define height naturally
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ shrink-wrap to content
        children: [
          // Shadow divider on top
          Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
              color: AppColor.cAppPrimaryColor,
            ),
          ),
          // Nav items row — fixed 62px
          SizedBox(
            height: 62,
            child: Row(
              children: List.generate(navItems.length, (index) {
                final isSelected = currentIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.18)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            navItems[index].icon,
                            size: isSelected ? 21 : 18,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          navItems[index].label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          // ✅ Fills exactly the gesture/nav bar height — never 0, never too big
          SizedBox(height: bottomInset),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}
