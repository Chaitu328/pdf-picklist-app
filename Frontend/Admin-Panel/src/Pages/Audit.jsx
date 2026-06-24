import { useEffect, useState, useMemo } from "react";
import {
  Calendar,
  Clock,
  LogIn,
  LogOut,
  Users,
  Route,
  ClipboardList,
  UserCheck,
  ChevronDown,
  ChevronUp,
  Search,
  Activity,
  TrendingUp,
  Package,
  AlertTriangle,
  CheckCircle2,
  XCircle,
  Inbox,
  Hash,
  Building2,
  MapPin,
  Truck,
  Loader2,
  X,
  Plus,
  Trash2
} from "lucide-react";

/* ═══════════════════════════════════════════════════════════════
   SHARED COMPONENTS
   ═══════════════════════════════════════════════════════════════ */

function Card({ children, className = "" }) {
  return (
    <div className={`bg-white rounded-2xl border border-slate-100 shadow-sm ${className}`}>
      {children}
    </div>
  );
}

function Badge({ children, color = "gray", className = "" }) {
  const colors = {
    gray: "bg-slate-50 text-slate-600 border-slate-200",
    blue: "bg-blue-50 text-blue-700 border-blue-200",
    green: "bg-emerald-50 text-emerald-700 border-emerald-200",
    red: "bg-rose-50 text-rose-700 border-rose-200",
    amber: "bg-amber-50 text-amber-700 border-amber-200",
    purple: "bg-purple-50 text-purple-700 border-purple-200",
  };
  return (
    <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-xs font-semibold border ${colors[color] || colors.gray} ${className}`}>
      {children}
    </span>
  );
}

function TimeBadge({ time, type = "login" }) {
  if (!time) return null;

  const isLogin = type === "login";

  return (
    <span
      className={`inline-flex items-center gap-1 px-2 py-1 rounded-md text-[11px] font-medium ${
        isLogin
          ? "bg-emerald-50 text-emerald-700"
          : "bg-rose-50 text-rose-700"
      }`}
    >
      {isLogin ? (
        <LogIn className="w-3 h-3" />
      ) : (
        <LogOut className="w-3 h-3" />
      )}

      {time}
    </span>
  );
}

function EmptyState({ icon: Icon, title, subtitle }) {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-center">
      <div className="p-5 bg-slate-50 rounded-2xl mb-4">
        <Icon className="w-10 h-10 text-slate-300" />
      </div>
      <h3 className="text-base font-semibold text-slate-900">{title}</h3>
      <p className="text-sm text-slate-400 mt-1 max-w-xs">{subtitle}</p>
    </div>
  );
}

function SectionHeader({ icon: Icon, title, count, color = "blue" }) {
  const colors = {
    blue: "bg-blue-50 text-blue-600",
    green: "bg-emerald-50 text-emerald-600",
    red: "bg-rose-50 text-rose-600",
    amber: "bg-amber-50 text-amber-600",
    purple: "bg-purple-50 text-purple-600",
  };
  return (
    <div className="flex items-center gap-2 mb-3">
      <div className={`p-1.5 rounded-lg ${colors[color]}`}>
        <Icon className="w-4 h-4" />
      </div>
      <h4 className="text-sm font-bold text-slate-800">{title}</h4>
      {count !== undefined && (
        <Badge color={color === "red" ? "red" : color}>{count}</Badge>
      )}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   SKELETON COMPONENTS
   ═══════════════════════════════════════════════════════════════ */

function SummarySkeleton() {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      {[1, 2, 3, 4].map((i) => (
        <div key={i} className="h-28 bg-white rounded-2xl border border-slate-100 animate-pulse" />
      ))}
    </div>
  );
}

function TabSkeleton() {
  return (
    <div className="space-y-4 animate-pulse">
      {[1, 2, 3].map((i) => (
        <div key={i} className="h-32 bg-white rounded-2xl border border-slate-100" />
      ))}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   SUMMARY CARDS
   ═══════════════════════════════════════════════════════════════ */

function SummaryCards({ loginData, routeData, workerData, managerData, date }) {
  const stats = useMemo(() => {
    const logins = loginData?.login?.managers?.reduce((acc, m) => {
      const dayData = m.loginDetails?.[date];
      return acc + (dayData?.loginCount || 0);
    }, 0) || 0;

    const routesCreated = routeData?.managers?.reduce((acc, m) => acc + (m.createdRoutes?.length || 0), 0) || 0;
    const routesDeleted = routeData?.managers?.reduce((acc, m) => acc + (m.deletedRoutes?.length || 0), 0) || 0;

    const totalPicklists = managerData?.managers?.reduce((acc, m) => {
      return acc + (m.createdPicklists?.length || 0) + (m.deletedPicklists?.length || 0);
    }, 0) || 0;

    const activeWorkers = workerData?.workers?.filter(w => 
      (w.acceptedPicklists?.length || 0) > 0 || (w.workedPicklists?.length || 0) > 0
    ).length || 0;

    return [
      { label: "Total Logins", value: logins, icon: LogIn, color: "blue", sub: "Today" },
      { label: "Routes Created", value: routesCreated, icon: Route, color: "green", sub: `${routesDeleted} deleted` },
      { label: "Total Picklists", value: totalPicklists, icon: ClipboardList, color: "purple", sub: "All activity" },
      { label: "Active Workers", value: activeWorkers, icon: Users, color: "amber", sub: "With assignments" },
    ];
  }, [loginData, routeData, workerData, managerData, date]);

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      {stats.map((stat) => (
        <Card key={stat.label} className="p-5 hover:shadow-md transition-shadow">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">{stat.label}</p>
              <p className="text-3xl font-bold text-slate-900 mt-1">{stat.value}</p>
              <p className="text-xs text-slate-400 mt-1">{stat.sub}</p>
            </div>
            <div className={`p-2.5 rounded-xl bg-${stat.color}-50`}>
              <stat.icon className={`w-5 h-5 text-${stat.color}-600`} />
            </div>
          </div>
        </Card>
      ))}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   LOGIN TAB
   ═══════════════════════════════════════════════════════════════ */

function LoginTab({ data, date }) {
  const [search, setSearch] = useState("");
  
  const managers = data?.login?.managers || [];
  const workers = data?.login?.workers || [];
  
  const filterUsers = (users) => {
    if (!search) return users;
    return users.filter(u => u.email?.toLowerCase().includes(search.toLowerCase()));
  };

  const UserCard = ({ user, type }) => {
    const dayData = user.loginDetails?.[date] || {};
   const loginTimes = dayData.loginTimings || [];
const logoutTimes = dayData.logoutTimings || [];
    
    return (
      <Card className="p-5 hover:shadow-md transition-shadow">
        <div className="flex items-start justify-between mb-4">
          <div className="flex items-center gap-3">
            <div className={`w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold ${
              type === "manager" ? "bg-blue-100 text-blue-700" : "bg-emerald-100 text-emerald-700"
            }`}>
              {user.email?.charAt(0).toUpperCase() || "?"}
            </div>
            <div>
              <p className="text-sm font-bold text-slate-900">{user.email}</p>
              <p className="text-xs text-slate-500 capitalize">{type}</p>
            </div>
          </div>
          <div className="flex gap-2">
            <Badge color="green">
              <LogIn className="w-3 h-3" />
              {dayData.loginCount || 0}
            </Badge>
            <Badge color="red">
              <LogOut className="w-3 h-3" />
              {dayData.logoutCount || 0}
            </Badge>
          </div>
        </div>

        {loginTimes.length > 0 && (
          <div className="mb-3">
            <p className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider mb-2">Login Times</p>
            <div className="flex flex-wrap gap-1.5">
              {loginTimes.map((t, i) => <TimeBadge key={i} time={t} type="login" />)}
            </div>
          </div>
        )}

        {logoutTimes.length > 0 && (
          <div>
            <p className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider mb-2">Logout Times</p>
            <div className="flex flex-wrap gap-1.5">
              {logoutTimes.map((t, i) => <TimeBadge key={i} time={t} type="logout" />)}
            </div>
          </div>
        )}
      </Card>
    );
  };

  return (
    <div className="space-y-4">
      <div className="relative max-w-md">
        <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
        <input
          type="text"
          placeholder="Search by email..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm text-slate-900 placeholder:text-slate-400 outline-none focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 transition-all"
        />
        {search && (
          <button onClick={() => setSearch("")} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
            <X className="w-3.5 h-3.5" />
          </button>
        )}
      </div>

      {managers.length === 0 && workers.length === 0 ? (
        <EmptyState icon={Users} title="No login activity" subtitle="No users logged in on the selected date." />
      ) : (
        <div className="space-y-6">
          {managers.length > 0 && (
            <div>
              <SectionHeader icon={UserCheck} title="Managers" count={managers.length} color="blue" />
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                {filterUsers(managers).map((m) => <UserCard key={m.userId} user={m} type="manager" />)}
              </div>
            </div>
          )}
          {workers.length > 0 && (
            <div>
              <SectionHeader icon={Users} title="Workers" count={workers.length} color="emerald" />
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                {filterUsers(workers).map((w) => <UserCard key={w.userId} user={w} type="worker" />)}
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   ROUTES TAB
   ═══════════════════════════════════════════════════════════════ */

function RoutesTab({ data }) {
  const [search, setSearch] = useState("");
  const [expandedManagers, setExpandedManagers] = useState(new Set());

  const managers = data?.managers || [];
  
  const filtered = managers.filter(m => 
    !search || m.email?.toLowerCase().includes(search.toLowerCase())
  );

  const toggleExpand = (id) => {
    setExpandedManagers(prev => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const RouteItem = ({ route, type }) => (
    <div className={`flex items-center gap-3 p-3 rounded-xl border ${
      type === "created" ? "bg-emerald-50/50 border-emerald-100" : "bg-rose-50/50 border-rose-100"
    }`}>
      <div className={`p-2 rounded-lg ${type === "created" ? "bg-emerald-100 text-emerald-600" : "bg-rose-100 text-rose-600"}`}>
        {type === "created" ? <CheckCircle2 className="w-4 h-4" /> : <XCircle className="w-4 h-4" />}
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span className="font-mono text-xs font-bold text-slate-700 bg-white px-2 py-0.5 rounded border border-slate-200">
            {route.networkCode}
          </span>
          <span className="text-sm font-semibold text-slate-800 truncate">{route.companyName}</span>
        </div>
        <div className="flex items-center gap-3 mt-1 text-xs text-slate-500">
          <span className="flex items-center gap-1"><MapPin className="w-3 h-3" />{route.city}</span>
          <span className="flex items-center gap-1"><Calendar className="w-3 h-3" />{route.deliveryDay}</span>
          {route.timestamp && (
            <span className="flex items-center gap-1"><Clock className="w-3 h-3" />{new Date(route.timestamp).toLocaleTimeString()}</span>
          )}
        </div>
      </div>
      <Badge color={type === "created" ? "green" : "red"} className="shrink-0 capitalize">
        {type}
      </Badge>
    </div>
  );

  return (
    <div className="space-y-4">
      <div className="relative max-w-md">
        <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
        <input
          type="text"
          placeholder="Search manager..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm text-slate-900 placeholder:text-slate-400 outline-none focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 transition-all"
        />
        {search && (
          <button onClick={() => setSearch("")} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
            <X className="w-3.5 h-3.5" />
          </button>
        )}
      </div>

      {filtered.length === 0 ? (
        <EmptyState icon={Route} title="No route activity" subtitle="No routes were created or deleted on this date." />
      ) : (
        <div className="space-y-4">
          {filtered.map((manager) => {
            const isExpanded = expandedManagers.has(manager.managerId);
            const createdCount = manager.createdRoutes?.length || 0;
            const deletedCount = manager.deletedRoutes?.length || 0;
            
            return (
              <Card key={manager.managerId} className="overflow-hidden">
                <button
                  onClick={() => toggleExpand(manager.managerId)}
                  className="w-full flex items-center justify-between p-5 hover:bg-slate-50/50 transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center text-blue-700 font-bold text-sm">
                      {manager.email?.charAt(0).toUpperCase()}
                    </div>
                    <div className="text-left">
                      <p className="text-sm font-bold text-slate-900">{manager.email}</p>
                      <div className="flex items-center gap-2 mt-1">
                        <Badge color="green">{createdCount} created</Badge>
                        <Badge color="red">{deletedCount} deleted</Badge>
                      </div>
                    </div>
                  </div>
                  <div className={`p-1.5 rounded-lg bg-slate-50 text-slate-400 transition-transform duration-200 ${isExpanded ? "rotate-180" : ""}`}>
                    <ChevronDown className="w-4 h-4" />
                  </div>
                </button>

                <div className={`grid transition-all duration-300 ease-in-out ${isExpanded ? "grid-rows-[1fr] opacity-100" : "grid-rows-[0fr] opacity-0"}`}>
                  <div className="overflow-hidden">
                    <div className="p-5 pt-0 space-y-4">
                      {createdCount > 0 && (
                        <div>
                          <SectionHeader icon={CheckCircle2} title="Created Routes" count={createdCount} color="green" />
                          <div className="space-y-2">
                            {manager.createdRoutes.map((r) => <RouteItem key={r.routeId} route={r} type="created" />)}
                          </div>
                        </div>
                      )}
                      {deletedCount > 0 && (
                        <div>
                          <SectionHeader icon={XCircle} title="Deleted Routes" count={deletedCount} color="red" />
                          <div className="space-y-2">
                            {manager.deletedRoutes.map((r) => <RouteItem key={r.routeId} route={r} type="deleted" />)}
                          </div>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   WORKERS TAB
   ═══════════════════════════════════════════════════════════════ */

function WorkersTab({ data }) {
  const [search, setSearch] = useState("");
  const [expandedWorkers, setExpandedWorkers] = useState(new Set());

  const workers = data?.workers || [];
  const filtered = workers.filter(w => 
    !search || w.email?.toLowerCase().includes(search.toLowerCase())
  );

  const toggleExpand = (id) => {
    setExpandedWorkers(prev => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const PicklistSection = ({ title, items, icon: Icon, color, emptyText }) => {
    if (!items || items.length === 0) return null;
    return (
      <div className="mb-4">
        <SectionHeader icon={Icon} title={title} count={items.length} color={color} />
        <div className="space-y-2">
          {items.map((item, idx) => (
            <div key={idx} className="flex items-center justify-between p-3 bg-slate-50 rounded-xl border border-slate-100">
              <div className="flex items-center gap-3 min-w-0">
                <div className={`p-1.5 rounded-md bg-${color}-100 text-${color}-600`}>
                  <ClipboardList className="w-3.5 h-3.5" />
                </div>
                <div className="min-w-0">
                  <p className="text-sm font-semibold text-slate-800 truncate">{item.pickListNo || item.picklistNo || "—"}</p>
                  {item.status && (
                    <p className="text-xs text-slate-500 capitalize">{item.status.replace(/_/g, " ")}</p>
                  )}
                </div>
              </div>
              <div className="text-right shrink-0 ml-4">
                {item.timestamp && (
                  <p className="text-[11px] text-slate-400">{new Date(item.timestamp).toLocaleString()}</p>
                )}
                {item.managerEmail && (
                  <p className="text-[11px] text-slate-500">{item.managerEmail}</p>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  };

  return (
    <div className="space-y-4">
      <div className="relative max-w-md">
        <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
        <input
          type="text"
          placeholder="Search worker email..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm text-slate-900 placeholder:text-slate-400 outline-none focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 transition-all"
        />
        {search && (
          <button onClick={() => setSearch("")} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
            <X className="w-3.5 h-3.5" />
          </button>
        )}
      </div>

      {filtered.length === 0 ? (
        <EmptyState icon={Users} title="No worker activity" subtitle="No workers have activity records on this date." />
      ) : (
        <div className="space-y-4">
          {filtered.map((worker) => {
            const isExpanded = expandedWorkers.has(worker.workerId);
            const totalActivity = 
              (worker.acceptedPicklists?.length || 0) +
              (worker.workedPicklists?.length || 0) +
              (worker.reassignedPicklists?.length || 0) +
              (worker.reupdatedPicklists?.length || 0) +
              (worker.deletedPicklists?.length || 0);

            return (
              <Card key={worker.workerId} className="overflow-hidden">
                <button
                  onClick={() => toggleExpand(worker.workerId)}
                  className="w-full flex items-center justify-between p-5 hover:bg-slate-50/50 transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-emerald-100 rounded-full flex items-center justify-center text-emerald-700 font-bold text-sm">
                      {worker.email?.charAt(0).toUpperCase()}
                    </div>
                    <div className="text-left">
                      <p className="text-sm font-bold text-slate-900">{worker.email}</p>
                      <Badge color="purple">{totalActivity} activities</Badge>
                    </div>
                  </div>
                  <div className={`p-1.5 rounded-lg bg-slate-50 text-slate-400 transition-transform duration-200 ${isExpanded ? "rotate-180" : ""}`}>
                    <ChevronDown className="w-4 h-4" />
                  </div>
                </button>

                <div className={`grid transition-all duration-300 ease-in-out ${isExpanded ? "grid-rows-[1fr] opacity-100" : "grid-rows-[0fr] opacity-0"}`}>
                  <div className="overflow-hidden">
                    <div className="p-5 pt-0 space-y-2">
                      <PicklistSection title="Accepted" items={worker.acceptedPicklists} icon={CheckCircle2} color="green" />
                      <PicklistSection title="Worked" items={worker.workedPicklists} icon={Activity} color="blue" />
                      <PicklistSection title="Reassigned" items={worker.reassignedPicklists} icon={AlertTriangle} color="amber" />
                      <PicklistSection title="Reupdated" items={worker.reupdatedPicklists} icon={TrendingUp} color="purple" />
                      <PicklistSection title="Deleted" items={worker.deletedPicklists} icon={XCircle} color="red" />
                    </div>
                  </div>
                </div>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   MANAGERS TAB
   ═══════════════════════════════════════════════════════════════ */

function ManagersTab({ data }) {
  const [search, setSearch] = useState("");
  const [expandedManagers, setExpandedManagers] = useState(new Set());

  const managers = data?.managers || [];
  const filtered = managers.filter(m => 
    !search || m.email?.toLowerCase().includes(search.toLowerCase())
  );

  const toggleExpand = (id) => {
    setExpandedManagers(prev => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const PicklistDetailCard = ({ picklist, type }) => (
    <div className={`p-4 rounded-xl border ${
      type === "created" ? "bg-emerald-50/30 border-emerald-100" :
      type === "deleted" ? "bg-rose-50/30 border-rose-100" :
      "bg-amber-50/30 border-amber-100"
    }`}>
      <div className="flex items-start justify-between mb-2">
        <div className="flex items-center gap-2">
          <ClipboardList className={`w-4 h-4 ${
            type === "created" ? "text-emerald-600" :
            type === "deleted" ? "text-rose-600" :
            "text-amber-600"
          }`} />
          <span className="font-mono text-sm font-bold text-slate-800">{picklist.pickListNo || picklist.picklistNo}</span>
        </div>
        <Badge color={type === "created" ? "green" : type === "deleted" ? "red" : "amber"} className="capitalize">
          {type}
        </Badge>
      </div>
      
      {picklist.status && (
        <p className="text-xs text-slate-500 mb-2 capitalize">Status: {picklist.status.replace(/_/g, " ")}</p>
      )}
      
      {picklist.workerEmail && (
        <p className="text-xs text-slate-600 mb-2">Assigned to: <span className="font-semibold">{picklist.workerEmail}</span></p>
      )}
      
      {picklist.parts && picklist.parts.length > 0 && (
        <div className="mt-2 pt-2 border-t border-slate-200/60">
          <p className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider mb-1.5">Parts ({picklist.parts.length})</p>
          <div className="flex flex-wrap gap-1">
            {picklist.parts.slice(0, 5).map((part, i) => (
              <span key={i} className="px-2 py-0.5 bg-white rounded text-[11px] font-mono text-slate-600 border border-slate-200">
                {part.partno || part}
              </span>
            ))}
            {picklist.parts.length > 5 && (
              <span className="px-2 py-0.5 text-[11px] text-slate-400">+{picklist.parts.length - 5} more</span>
            )}
          </div>
        </div>
      )}

      {picklist.selectedParts && picklist.selectedParts.length > 0 && (
        <div className="mt-2 pt-2 border-t border-slate-200/60">
          <p className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider mb-1.5">Selected Parts</p>
          <div className="flex flex-wrap gap-1">
            {picklist.selectedParts.map((part, i) => (
              <span key={i} className="px-2 py-0.5 bg-white rounded text-[11px] font-mono text-slate-600 border border-slate-200">
                    {part.partno} ({part.afterReupdateStatus})
              </span>
            ))}
          </div>
        </div>
      )}

      {picklist.note && (
        <p className="mt-2 text-xs text-slate-500 italic">"{picklist.note}"</p>
      )}
    </div>
  );

  return (
    <div className="space-y-4">
      <div className="relative max-w-md">
        <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
        <input
          type="text"
          placeholder="Search manager..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm text-slate-900 placeholder:text-slate-400 outline-none focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 transition-all"
        />
        {search && (
          <button onClick={() => setSearch("")} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
            <X className="w-3.5 h-3.5" />
          </button>
        )}
      </div>

      {filtered.length === 0 ? (
        <EmptyState icon={UserCheck} title="No manager activity" subtitle="No managers have records on this date." />
      ) : (
        <div className="space-y-4">
          {filtered.map((manager) => {
            const isExpanded = expandedManagers.has(manager.managerId);
            const created = manager.createdPicklists || [];
            const deleted = manager.deletedPicklists || [];
            const reupdates = manager.reupdateRequests || [];

            return (
              <Card key={manager.managerId} className="overflow-hidden">
                <button
                  onClick={() => toggleExpand(manager.managerId)}
                  className="w-full flex items-center justify-between p-5 hover:bg-slate-50/50 transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-purple-100 rounded-full flex items-center justify-center text-purple-700 font-bold text-sm">
                      {manager.email?.charAt(0).toUpperCase()}
                    </div>
                    <div className="text-left">
                      <p className="text-sm font-bold text-slate-900">{manager.email}</p>
                      <div className="flex items-center gap-2 mt-1">
                        <Badge color="green">{created.length} created</Badge>
                        <Badge color="red">{deleted.length} deleted</Badge>
                        <Badge color="amber">{reupdates.length} reupdates</Badge>
                      </div>
                    </div>
                  </div>
                  <div className={`p-1.5 rounded-lg bg-slate-50 text-slate-400 transition-transform duration-200 ${isExpanded ? "rotate-180" : ""}`}>
                    <ChevronDown className="w-4 h-4" />
                  </div>
                </button>

                <div className={`grid transition-all duration-300 ease-in-out ${isExpanded ? "grid-rows-[1fr] opacity-100" : "grid-rows-[0fr] opacity-0"}`}>
                  <div className="overflow-hidden">
                    <div className="p-5 pt-0 space-y-6">
                      {created.length > 0 && (
                        <div>
                          <SectionHeader icon={Plus} title="Created Picklists" count={created.length} color="green" />
                          <div className="space-y-3">
                            {created.map((p, i) => <PicklistDetailCard key={i} picklist={p} type="created" />)}
                          </div>
                        </div>
                      )}
                      {deleted.length > 0 && (
                        <div>
                          <SectionHeader icon={Trash2} title="Deleted Picklists" count={deleted.length} color="red" />
                          <div className="space-y-3">
                            {deleted.map((p, i) => <PicklistDetailCard key={i} picklist={p} type="deleted" />)}
                          </div>
                        </div>
                      )}
                      {reupdates.length > 0 && (
                        <div>
                          <SectionHeader icon={AlertTriangle} title="Reupdate Requests" count={reupdates.length} color="amber" />
                          <div className="space-y-3">
                            {reupdates.map((p, i) => <PicklistDetailCard key={i} picklist={p} type="reupdate" />)}
                          </div>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   MAIN COMPONENT
   ═══════════════════════════════════════════════════════════════ */

export default function AuditDashboard() {
  const [date, setDate] = useState(() => {
    const today = new Date();
    return today.toISOString().split("T")[0];
  });
  
  const [activeTab, setActiveTab] = useState("login");
  const [loginData, setLoginData] = useState(null);
  const [routeData, setRouteData] = useState(null);
  const [workerData, setWorkerData] = useState(null);
  const [managerData, setManagerData] = useState(null);
  const [loading, setLoading] = useState(true);

  const token = localStorage.getItem("token");
  const BASE_URL = "http://localhost:3000";

  const tabs = [
    { id: "login", label: "Login", icon: LogIn },
    { id: "routes", label: "Routes", icon: Route },
    { id: "workers", label: "Workers", icon: Users },
    { id: "managers", label: "Managers", icon: UserCheck },
  ];

  /* ─── Safe JSON parser ─── */
  const safeJson = async (res) => {
    if (!res.ok) {
      console.error("API error:", res.status);
      return null;
    }
    try {
      return await res.json();
    } catch (err) {
      console.error("Invalid JSON:", err);
      return null;
    }
  };

  /* ─── Fetch all audit data ─── */
  const fetchAll = async () => {
    try {
      setLoading(true);
      const headers = { Authorization: `Bearer ${token}` };

      const [loginRes, routeRes, workerRes, managerRes] = await Promise.all([
        fetch(`${BASE_URL}/api/audit/user-events?date=${date}`, { headers }),
        fetch(`${BASE_URL}/api/audit/route-events?date=${date}`, { headers }),
        fetch(`${BASE_URL}/api/audit/worker-progress?date=${date}`, { headers }),
        fetch(`${BASE_URL}/api/audit/manager-progress?date=${date}`, { headers }),
      ]);

      setLoginData(await safeJson(loginRes));
      setRouteData(await safeJson(routeRes));
      setWorkerData(await safeJson(workerRes));
      setManagerData(await safeJson(managerRes));
    } catch (err) {
      console.error("Fetch error:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAll();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [date]);

  /* ─── Tab content renderer ─── */
  const renderTabContent = () => {
    if (loading) return <TabSkeleton />;
    
    switch (activeTab) {
      case "login":
        return <LoginTab data={loginData} date={date} />;
      case "routes":
        return <RoutesTab data={routeData} />;
      case "workers":
        return <WorkersTab data={workerData} />;
      case "managers":
        return <ManagersTab data={managerData} />;
      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-slate-50/50 p-4 sm:p-6 lg:p-8">
      <div className="max-w-6xl mx-auto space-y-6">

        {/* ─── HEADER ─── */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-blue-500 rounded-xl shadow-sm">
              <Activity className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Audit Dashboard</h1>
              <p className="text-sm text-slate-500 mt-0.5">Track system activity and user progress</p>
            </div>
          </div>

          <div className="flex items-center gap-2 bg-white px-4 py-2.5 rounded-xl border border-slate-200 shadow-sm">
            <Calendar className="w-4 h-4 text-slate-400" />
            <input
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
              className="text-sm text-slate-700 outline-none bg-transparent font-medium"
            />
          </div>
        </div>

        {/* ─── SUMMARY CARDS ─── */}
        {/* {loading ? <SummarySkeleton /> : (
          <SummaryCards
            loginData={loginData}
            routeData={routeData}
            workerData={workerData}
            managerData={managerData}
            date={date}
          />
        )} */}

        {/* ─── TABS ─── */}
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
          <div className="flex border-b border-slate-100 overflow-x-auto">
            {tabs.map((tab) => {
              const isActive = activeTab === tab.id;
              const Icon = tab.icon;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`relative flex items-center gap-2 px-6 py-4 text-sm font-semibold transition-all whitespace-nowrap ${
                    isActive
                      ? "text-blue-600"
                      : "text-slate-500 hover:text-slate-700 hover:bg-slate-50/50"
                  }`}
                >
                  <Icon className="w-4 h-4" />
                  {tab.label}
                  {isActive && (
                    <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-blue-600 rounded-t-full" />
                  )}
                </button>
              );
            })}
          </div>

          {/* ─── TAB CONTENT ─── */}
          <div className="p-5 sm:p-6">
            {renderTabContent()}
          </div>
        </div>

      </div>
    </div>
  );
}