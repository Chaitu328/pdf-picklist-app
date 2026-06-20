import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/audit_controller.dart';
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

class ManagerAuditView extends StatefulWidget {
  const ManagerAuditView({super.key});

  @override
  State<ManagerAuditView> createState() => _ManagerAuditViewState();
}

class _ManagerAuditViewState extends State<ManagerAuditView>
    with SingleTickerProviderStateMixin {
  final AuditController controller = Get.put(AuditController());
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: _DT.isDark ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.changeDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
          title: const Text("Operation Audits", style: TextStyle(fontWeight: FontWeight.bold)),
          foregroundColor: _DT.textPrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month_rounded),
              onPressed: () => _selectDate(context),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  controller.dateString,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.blueAccent,
            labelColor: _DT.textPrimary,
            unselectedLabelColor: _DT.textSecondary,
            tabs: const [
              Tab(text: "Users"),
              Tab(text: "Routes"),
              Tab(text: "Managers"),
              Tab(text: "Workers"),
            ],
          ),
        ),
        body: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildUserEventsTab(),
                  _buildRouteEventsTab(),
                  _buildManagerProgressTab(),
                  _buildWorkerProgressTab(),
                ],
              ),
      );
    });
  }

  Widget _buildUserEventsTab() {
    final data = controller.userEvents;
    if (data.isEmpty) return _buildEmpty();

    final reg = data['registration'] ?? {};
    final login = data['login'] ?? {};

    final List managersReg = reg['managers'] ?? [];
    final List workersReg = reg['workers'] ?? [];
    final List managersLogin = login['managers'] ?? [];
    final List workersLogin = login['workers'] ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader("Registrations Today"),
        const SizedBox(height: 8),
        _buildCard(
          child: Column(
            children: [
              _buildListRow("Manager Signups", "${managersReg.length}"),
              const Divider(),
              _buildListRow("Worker Signups", "${workersReg.length}"),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionHeader("Login Sessions"),
        const SizedBox(height: 8),
        if (managersLogin.isEmpty && workersLogin.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(16), child: Text("No login activity recorded"))),
        ...managersLogin.map((m) => _buildLoginRow(m, "Manager")),
        ...workersLogin.map((w) => _buildLoginRow(w, "Worker")),
      ],
    );
  }

  Widget _buildLoginRow(dynamic user, String role) {
    final name = user['name'] ?? '';
    final email = user['email'] ?? '';
    final loginDetails = user['loginDetails'] ?? {};
    final details = loginDetails[controller.dateString] ?? {};
    final int loginCount = details['loginCount'] ?? 0;
    final int logoutCount = details['logoutCount'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DT.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DT.white06),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: role == "Manager" ? Colors.blue.withOpacity(0.2) : Colors.green.withOpacity(0.2),
            child: Icon(
              role == "Manager" ? Icons.manage_accounts_rounded : Icons.engineering_rounded,
              color: role == "Manager" ? Colors.blue : Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: _DT.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(email, style: TextStyle(color: _DT.textDim, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Logins: $loginCount", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text("Logouts: $logoutCount", style: TextStyle(color: _DT.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteEventsTab() {
    final data = controller.routeEvents;
    if (data.isEmpty) return _buildEmpty();

    final List managers = data['managers'] ?? [];
    if (managers.isEmpty) return _buildEmpty("No route audit activity");

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: managers.length,
      itemBuilder: (context, index) {
        final mgr = managers[index];
        final List created = mgr['createdRoutes'] ?? [];
        final List deleted = mgr['deletedRoutes'] ?? [];

        return Card(
          color: _DT.bg2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(mgr['name'] ?? 'Unknown Manager', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Created: ${created.length} | Deleted: ${deleted.length}", style: TextStyle(color: _DT.textSecondary, fontSize: 12)),
            children: [
              ...created.map((r) => _buildRouteLogItem(r, "Created", Colors.green)),
              ...deleted.map((r) => _buildRouteLogItem(r, "Deleted", Colors.red)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRouteLogItem(dynamic route, String action, Color color) {
    return ListTile(
      leading: Icon(Icons.circle, color: color, size: 12),
      title: Text("Network: ${route['networkCode'] ?? ''} - ${route['city'] ?? ''}"),
      subtitle: Text("Company: ${route['companyName'] ?? ''} (${route['deliveryDay'] ?? ''})"),
      trailing: Text(route['time'] ?? '', style: TextStyle(color: _DT.textDim, fontSize: 11)),
    );
  }

  Widget _buildManagerProgressTab() {
    final data = controller.managerProgress;
    if (data.isEmpty) return _buildEmpty();

    final List managers = data['managers'] ?? [];
    if (managers.isEmpty) return _buildEmpty("No picklist progress logged");

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: managers.length,
      itemBuilder: (context, index) {
        final mgr = managers[index];
        final List created = mgr['createdPicklists'] ?? [];
        final List deleted = mgr['deletedPicklists'] ?? [];
        final List reupdates = mgr['reupdateRequests'] ?? [];

        return Card(
          color: _DT.bg2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(mgr['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Created: ${created.length} | Deleted: ${deleted.length} | Reupdates: ${reupdates.length}", style: TextStyle(color: _DT.textSecondary, fontSize: 12)),
            children: [
              ...created.map((p) => _buildPicklistEventItem("Created", p, Colors.green)),
              ...deleted.map((p) => _buildPicklistEventItem("Deleted", p, Colors.red)),
              ...reupdates.map((p) => _buildPicklistEventItem("Reupdate Req", p, Colors.orange)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPicklistEventItem(String action, dynamic picklist, Color color) {
    final String plNo = picklist['pick_list_no'] ?? '';
    final String time = picklist['createdAt']?['time'] ?? picklist['deletedAt']?['time'] ?? picklist['requestedAt']?['time'] ?? '';

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
        child: Text(action, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
      ),
      title: Text("Picklist No: $plNo"),
      trailing: Text(time, style: TextStyle(color: _DT.textDim, fontSize: 11)),
    );
  }

  Widget _buildWorkerProgressTab() {
    final data = controller.workerProgress;
    if (data.isEmpty) return _buildEmpty();

    final List workers = data['workers'] ?? [];
    if (workers.isEmpty) return _buildEmpty("No worker logs recorded");

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workers.length,
      itemBuilder: (context, index) {
        final worker = workers[index];
        final List accepted = worker['acceptedPicklists'] ?? [];
        final List worked = worker['workedPicklists'] ?? [];

        return Card(
          color: _DT.bg2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(worker['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Accepted: ${accepted.length} | Worked: ${worked.length}", style: TextStyle(color: _DT.textSecondary, fontSize: 12)),
            children: [
              if (accepted.isNotEmpty) const ListTile(title: Text("Accepted lists:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ...accepted.map((p) => ListTile(
                    dense: true,
                    title: Text("Picklist: ${p['pick_list_no'] ?? ''}"),
                    trailing: Text("Time: ${p['acceptedAt']?['time'] ?? ''}"),
                  )),
              if (worked.isNotEmpty) const ListTile(title: Text("Worked (Scanned) lists:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ...worked.map((p) => ListTile(
                    dense: true,
                    title: Text("Picklist: ${p['pick_list_no'] ?? ''}"),
                    subtitle: Text("QR: ${p['qrScannedCount'] ?? 0} | Manual: ${p['manualEnteredCount'] ?? 0}"),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(color: _DT.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DT.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _DT.white06),
      ),
      child: child,
    );
  }

  Widget _buildListRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: _DT.textSecondary, fontSize: 14)),
          Text(val, style: TextStyle(color: _DT.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEmpty([String text = "No logs recorded for this day"]) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: _DT.textDim),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: _DT.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
