import React, { useState, useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { io } from "socket.io-client";
import {
  LayoutDashboard,
  ClipboardList,
  Truck,
  Users,
  FileText,
  Bell,
  Search,
  Menu,
  X,
  ChevronDown,
  LogOut,
  Warehouse,
  AlertTriangle,
  TrendingUp,
  TrendingDown,
  CheckCircle2,
  Clock,
  Package,
  ArrowRight
} from "lucide-react";

/* ═══════════════════════════════════════════════════════════════
   ICONS (preserved from original)
   ═══════════════════════════════════════════════════════════════ */

const IconClipboard = ({ className }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="9" y="3" width="6" height="4" rx="2"/><path d="M9 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2h-2"/><path d="M9 14l2 2 4-4"/></svg>
);
const IconUsers = ({ className }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
);
const IconPackage = ({ className }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m7.5 4.27 9 5.15"/><path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/><path d="m3.3 7 8.7 5 8.7-5"/><path d="M12 22V12"/></svg>
);
const IconAlert = ({ className }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
);
const IconTrendUp = ({ className }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="22 7 13.5 15.5 8.5 10.5 2 17"/><polyline points="16 7 22 7 22 13"/></svg>
);
const IconTrendDown = ({ className }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="22 17 13.5 8.5 8.5 13.5 2 7"/><polyline points="16 17 22 17 22 11"/></svg>
);
const IconAudit = ({ className }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
);
const IconDispatch = ({ className }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="1" y="3" width="15" height="13"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg>
);
const IconRoster = ({ className }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
);
/* ═══════════════════════════════════════════════════════════════
   SIDEBAR NAVIGATION
   ═══════════════════════════════════════════════════════════════ */

// const navItems = [
//   { label: "Dashboard", icon: LayoutDashboard, path: "/dashboard" },
//   { label: "Pick Lists", icon: ClipboardList, path: "/picklists" },
//   { label: "Delivery", icon: Truck, path: "/delivery" },
//   { label: "Workers", icon: Users, path: "/workers" },
//   { label: "Reports", icon: FileText, path: "/reports" },
// ];

// function Sidebar({ isOpen, onClose }) {
//   const navigate = useNavigate();
//   const location = useLocation();
//   const user = JSON.parse(localStorage.getItem("user") || "{}");

//   return (
//     <>
//       {/* Mobile overlay */}
//       {isOpen && (
//         <div 
//           className="fixed inset-0 bg-black/40 backdrop-blur-sm z-40 lg:hidden"
//           onClick={onClose}
//         />
//       )}

//       {/* Sidebar */}
//       <aside className={`
//         fixed top-0 left-0 z-50 h-full w-64 bg-white border-r border-gray-100 
//         flex flex-col transition-transform duration-300 ease-in-out
//         ${isOpen ? "translate-x-0" : "-translate-x-full lg:translate-x-0"}
//       `}>
//         {/* Logo */}
//         <div className="p-6 border-b border-gray-50">
//           <div className="flex items-center gap-3">
//             <div className="p-2.5 bg-blue-600 rounded-xl shadow-sm shadow-blue-200">
//               <Warehouse className="w-6 h-6 text-white" />
//             </div>
//             <div>
//               <h1 className="text-lg font-bold text-gray-900 tracking-tight">PickList</h1>
//               <p className="text-[10px] font-semibold text-gray-400 uppercase tracking-widest">Manager</p>
//             </div>
//           </div>
//         </div>

//         {/* Nav Links */}
//         <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
//           <p className="px-3 mb-2 text-[10px] font-bold text-gray-400 uppercase tracking-widest">
//             Main Menu
//           </p>
//           {navItems.map((item) => {
//             const isActive = location.pathname === item.path || location.pathname.startsWith(item.path + "/");
//             const Icon = item.icon;
//             return (
//               <button
//                 key={item.path}
//                 onClick={() => {
//                   navigate(item.path);
//                   onClose();
//                 }}
//                 className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-semibold transition-all duration-200 group ${
//                   isActive
//                     ? "bg-blue-50 text-blue-700 shadow-sm"
//                     : "text-gray-600 hover:bg-gray-50 hover:text-gray-900"
//                 }`}
//               >
//                 <Icon className={`w-5 h-5 transition-colors ${isActive ? "text-blue-600" : "text-gray-400 group-hover:text-gray-600"}`} />
//                 {item.label}
//                 {isActive && <div className="ml-auto w-1.5 h-1.5 rounded-full bg-blue-500" />}
//               </button>
//             );
//           })}
//         </nav>

//         {/* User Profile */}
//         <div className="p-4 border-t border-gray-50">
//           <div className="flex items-center gap-3 p-3 rounded-xl bg-gray-50/70 border border-gray-100">
//             <div className="w-9 h-9 rounded-full bg-blue-100 flex items-center justify-center text-blue-700 font-bold text-sm">
//               {(user.name || "U").charAt(0).toUpperCase()}
//             </div>
//             <div className="flex-1 min-w-0">
//               <p className="text-sm font-semibold text-gray-900 truncate">{user.name || "User"}</p>
//               <p className="text-xs text-gray-400 capitalize">{user.role || "Manager"}</p>
//             </div>
//             <button 
//               onClick={() => {
//                 localStorage.clear();
//                 navigate("/login");
//               }}
//               className="p-1.5 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors"
//               title="Logout"
//             >
//               <LogOut className="w-4 h-4" />
//             </button>
//           </div>
//         </div>
//       </aside>
//     </>
//   );
// }

/* ═══════════════════════════════════════════════════════════════
   TOP HEADER
   ═══════════════════════════════════════════════════════════════ */

// function TopHeader({ onMenuClick, alertCount }) {
//   const [showNotifications, setShowNotifications] = useState(false);
//   const user = JSON.parse(localStorage.getItem("user") || "{}");

//   return (
//     <header className="sticky top-0 z-30 bg-white/80 backdrop-blur-xl border-b border-gray-100">
//       <div className="flex items-center justify-between h-16 px-4 sm:px-6 lg:px-8">
//         <div className="flex items-center gap-4">
//           <button
//             onClick={onMenuClick}
//             className="lg:hidden p-2 -ml-2 text-gray-500 hover:text-gray-900 hover:bg-gray-50 rounded-lg transition-colors"
//           >
//             <Menu className="w-5 h-5" />
//           </button>
          
//           <div className="hidden sm:flex items-center gap-2 text-sm text-gray-400">
//             <span>Dashboard</span>
//             <ChevronDown className="w-3 h-3 rotate-[-90deg]" />
//             <span className="text-gray-900 font-medium">Overview</span>
//           </div>
//         </div>

//         <div className="flex items-center gap-3">
//           {/* Search */}
//           <div className="hidden md:flex items-center relative">
//             <Search className="absolute left-3 w-4 h-4 text-gray-400" />
//             <input
//               type="text"
//               placeholder="Search..."
//               className="pl-9 pr-4 py-2 bg-gray-50 border border-gray-200 rounded-xl text-sm text-gray-900 placeholder:text-gray-400 outline-none focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 w-64 transition-all"
//             />
//           </div>

//           {/* Notifications */}
//           <div className="relative">
//             <button
//               onClick={() => setShowNotifications(!showNotifications)}
//               className="relative p-2 text-gray-500 hover:text-gray-900 hover:bg-gray-50 rounded-xl transition-colors"
//             >
//               <Bell className="w-5 h-5" />
//               {alertCount > 0 && (
//                 <span className="absolute top-1.5 right-1.5 w-2.5 h-2.5 bg-red-500 rounded-full ring-2 ring-white" />
//               )}
//             </button>

//             {showNotifications && (
//               <div className="absolute right-0 mt-2 w-80 bg-white rounded-2xl shadow-xl border border-gray-100 overflow-hidden animate-in fade-in slide-in-from-top-2 duration-200">
//                 <div className="px-4 py-3 border-b border-gray-50 flex items-center justify-between">
//                   <h3 className="text-sm font-semibold text-gray-900">Notifications</h3>
//                   {alertCount > 0 && (
//                     <span className="text-xs font-medium text-red-600 bg-red-50 px-2 py-0.5 rounded-full">
//                       {alertCount} new
//                     </span>
//                   )}
//                 </div>
//                 <div className="max-h-64 overflow-y-auto">
//                   {alertCount === 0 ? (
//                     <div className="px-4 py-8 text-center">
//                       <Bell className="w-8 h-8 text-gray-300 mx-auto mb-2" />
//                       <p className="text-sm text-gray-400">No new notifications</p>
//                     </div>
//                   ) : (
//                     <div className="px-4 py-3 text-sm text-gray-500">
//                       {alertCount} shortage alert{alertCount !== 1 ? "s" : ""} active
//                     </div>
//                   )}
//                 </div>
//               </div>
//             )}
//           </div>

//           {/* Mobile user avatar */}
//           <div className="lg:hidden w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center text-blue-700 font-bold text-xs">
//             {(user.name || "U").charAt(0).toUpperCase()}
//           </div>
//         </div>
//       </div>
//     </header>
//   );
// }

/* ═══════════════════════════════════════════════════════════════
   DASHBOARD SUB-COMPONENTS (preserved from original)
   ═══════════════════════════════════════════════════════════════ */

function KPICard({ label, value, subtext, icon: Icon, trend, trendUp, accent }) {
  return (
    <div className="group relative bg-white rounded-2xl border border-slate-200/60 p-5 shadow-[0_1px_3px_0_rgba(0,0,0,0.04),0_1px_2px_-1px_rgba(0,0,0,0.04)] hover:shadow-[0_4px_12px_-2px_rgba(0,0,0,0.08)] transition-all duration-300 ease-out">
      <div className="flex items-start justify-between">
        <div className={`inline-flex items-center justify-center w-10 h-10 rounded-xl ${accent}`}>
          <Icon className="w-5 h-5" />
        </div>
        {trend && (
          <div className={`inline-flex items-center gap-1 text-xs font-semibold px-2 py-1 rounded-full ${trendUp ? "bg-emerald-50 text-emerald-700" : "bg-rose-50 text-rose-700"}`}>
            {trendUp ? <IconTrendUp className="w-3 h-3" /> : <IconTrendDown className="w-3 h-3" />}
            {trend}
          </div>
        )}
      </div>
      <div className="mt-4">
        <p className="text-xs font-medium text-slate-500 uppercase tracking-wider">{label}</p>
        <h2 className="text-2xl font-bold text-slate-900 mt-1 tracking-tight">{value}</h2>
        {subtext && <p className="text-sm text-slate-400 mt-1">{subtext}</p>}
      </div>
    </div>
  );
}

function BarChart() {
  const data = [40, 60, 80, 120, 90, 70, 50, 85, 95, 30, 60, 75];
  const labels = ["6am", "7am", "8am", "9am", "10am", "11am", "12pm", "1pm", "2pm", "3pm", "4pm", "5pm"];
  const [hovered, setHovered] = useState(null);

  return (
    <div className="bg-white rounded-2xl border border-slate-200/60 p-6 shadow-[0_1px_3px_0_rgba(0,0,0,0.04)]">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h3 className="text-base font-semibold text-slate-900">Picking Throughput</h3>
          <p className="text-sm text-slate-500 mt-0.5">Hourly volume across all zones</p>
        </div>
        <span className="text-xs font-medium text-slate-500 bg-slate-100 px-3 py-1.5 rounded-full">Last 12 Hours</span>
      </div>

      <div className="relative h-48 flex items-end gap-2 sm:gap-3 px-1">
        {data.map((h, i) => {
          const isActive = i === 3;
          const isHovered = hovered === i;
          return (
            <div
              key={i}
              className="flex-1 flex flex-col items-center gap-2 group"
              onMouseEnter={() => setHovered(i)}
              onMouseLeave={() => setHovered(null)}
            >
              <div className={`relative transition-all duration-200 ${isHovered ? "opacity-100 translate-y-0" : "opacity-0 translate-y-1 pointer-events-none"}`}>
                <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-2.5 py-1.5 bg-slate-900 text-white text-[11px] font-semibold rounded-lg whitespace-nowrap shadow-lg">
                  {h} picks
                  <div className="absolute top-full left-1/2 -translate-x-1/2 -mt-1 border-4 border-transparent border-t-slate-900" />
                </div>
              </div>

              <div
                className={`w-full max-w-[28px] rounded-t-lg transition-all duration-300 ease-out cursor-pointer
                  ${isActive ? "bg-blue-600" : "bg-slate-200 group-hover:bg-blue-400"}
                  ${isHovered ? "shadow-[0_0_12px_rgba(37,99,235,0.35)]" : ""}
                `}
                style={{ height: `${h * 1.4}px` }}
              />
            </div>
          );
        })}
      </div>

      <div className="flex justify-between mt-4 px-1">
        {labels.map((l, i) => (
          <span key={i} className={`text-[10px] font-medium flex-1 text-center ${i === 3 ? "text-blue-700 font-bold" : "text-slate-400"}`}>
            {l}
          </span>
        ))}
      </div>
    </div>
  );
}

function QuickLink({ icon: Icon, label, color, to }) {
  const navigate = useNavigate();
  return (
    <button
      onClick={() => navigate(to)}
      className="group flex flex-col items-center justify-center gap-3 p-4 rounded-xl border border-slate-200/60 bg-white hover:border-blue-200 hover:shadow-[0_4px_12px_-2px_rgba(37,99,235,0.1)] transition-all duration-200 active:scale-[0.98]"
    >
      <div className={`inline-flex items-center justify-center w-10 h-10 rounded-lg ${color} transition-transform duration-200 group-hover:scale-110`}>
        <Icon className="w-5 h-5" />
      </div>
      <span className="text-sm font-medium text-slate-700 group-hover:text-slate-900">{label}</span>
    </button>
  );
}

function ActivityItem({ title, subtitle, time, status, onClick }) {
  const statusColors = {
    completed: "bg-emerald-50 text-emerald-700 border-emerald-100",
    started: "bg-blue-50 text-blue-700 border-blue-100",
    warning: "bg-amber-50 text-amber-700 border-amber-100",
  };
  const statusLabel = {
    completed: "Completed",
    started: "In Progress",
    warning: "Shortage",
  };

  return (
    <div
      onClick={onClick}
      className="group flex items-center gap-4 p-4 hover:bg-gray-50 cursor-pointer rounded-xl transition-colors duration-200 border-b border-gray-50 last:border-0"
    >
      <div className={`w-10 h-10 rounded-full flex items-center justify-center shrink-0 ${
        status === "completed" ? "bg-emerald-50 text-emerald-600" :
        status === "warning" ? "bg-amber-50 text-amber-600" :
        "bg-blue-50 text-blue-600"
      }`}>
        {status === "completed" ? <CheckCircle2 className="w-5 h-5" /> :
         status === "warning" ? <AlertTriangle className="w-5 h-5" /> :
         <Clock className="w-5 h-5" />}
      </div>
      
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-0.5">
          <p className="text-sm font-semibold text-gray-900 truncate group-hover:text-blue-700 transition-colors">{title}</p>
          <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full border ${statusColors[status] || statusColors.started}`}>
            {statusLabel[status] || "In Progress"}
          </span>
        </div>
        <p className="text-xs text-gray-500 truncate">{subtitle}</p>
      </div>
      
      <div className="text-right shrink-0">
        <p className="text-xs text-gray-400 font-medium">{time}</p>
        <ArrowRight className="w-3.5 h-3.5 text-gray-300 group-hover:text-blue-500 group-hover:translate-x-0.5 transition-all mt-1 ml-auto" />
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   MAIN DASHBOARD PAGE
   ═══════════════════════════════════════════════════════════════ */

export default function Dashboard() {
  const navigate = useNavigate();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  
  const [stats, setStats] = useState({
    total: 0,
    workers: 0,
    pending: 0,
    shortage: 0,
  });

  const [alerts, setAlerts] = useState([]);
  const [toast, setToast] = useState(null);
  const [activities, setActivities] = useState([]);

  const token = localStorage.getItem("token");

  // Socket.io (preserved)
  useEffect(() => {
    const socket = io("https://pick-list.onrender.com");

    socket.on("shortage_alert", (payload) => {
      console.log("🚨 SHORTAGE ALERT:", payload);
      setAlerts((prev) => [payload, ...prev]);
      setActivities((prev) => [
        {
          pick_list_no: payload.pick_list_no,
          order_number: "Shortage Alert",
          status: "completed_with_shortage",
          createdAt: new Date(),
        },
        ...prev,
      ]);
      setStats((prev) => ({ ...prev, shortage: prev.shortage + 1 }));
      setToast(payload);
      setTimeout(() => setToast(null), 4000);
    });

    return () => socket.disconnect();
  }, []);

  // Fetch dashboard data (preserved)
  useEffect(() => {
    fetchDashboard();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const fetchDashboard = async () => {
    try {
      const pickRes = await fetch(
        "https://pick-list.onrender.com/api/picklist",
        { headers: { Authorization: `Bearer ${token}` } }
      );
      const picklists = await pickRes.json();

      const sorted = [...picklists]
        .sort((a, b) => {
          const dateA = new Date(a.createdAt || a.updatedAt || Date.now());
          const dateB = new Date(b.createdAt || b.updatedAt || Date.now());
          return dateB - dateA;
        })
        .slice(0, 5);

      setActivities(sorted);

      const userRes = await fetch(
        "https://pick-list.onrender.com/api/users"
      );
      const users = await userRes.json();

      const total = picklists.length;
      const pending = picklists.filter(
        (p) => p.status === "unassigned" || p.status === "assigned"
      ).length;
      const shortage = picklists.filter(
        (p) => p.status === "completed_with_shortage"
      ).length;
      const workers = users.users?.filter((u) => u.role === "worker").length || 0;

      setStats({ total, workers, pending, shortage });
    } catch (err) {
      console.error("❌ Dashboard error:", err);
    }
  };

  const getStatus = (item) => {
    if (item.status === "completed") return "completed";
    if (item.status === "assigned") return "started";
    if (item.status === "completed_with_shortage") return "warning";
    return "started";
  };

  const formatTime = (date) => {
    if (!date) return "—";
    const diff = Date.now() - new Date(date);
    const mins = Math.floor(diff / 60000);
    if (mins < 1) return "Just now";
    if (mins < 60) return `${mins}m ago`;
    const hrs = Math.floor(mins / 60);
    if (hrs < 24) return `${hrs}h ago`;
    const days = Math.floor(hrs / 24);
    return `${days}d ago`;
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC]">
      {/* Sidebar */}
      {/* <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} /> */}

      {/* Main Content */}
      <div className=" min-h-screen flex flex-col">
        {/* <TopHeader 
          onMenuClick={() => setSidebarOpen(true)} 
          alertCount={alerts.length} 
        /> */}

        <main className="flex-1 p-4 sm:p-6 lg:p-8">
          <div className="max-w-6xl mx-auto space-y-8">

            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div>
                <h1 className="text-2xl font-bold tracking-tight text-slate-900">Dashboard</h1>
                <p className="text-sm text-slate-500 mt-1">Real-time status of warehouse operations</p>
              </div>
              <div className="inline-flex items-center gap-2 bg-emerald-50 border border-emerald-100 text-emerald-700 px-4 py-2 rounded-full text-sm font-semibold shadow-sm self-start">
                <span className="relative flex h-2.5 w-2.5">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" />
                  <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500" />
                </span>
                Systems Operational
              </div>
            </div>

            {/* KPI Cards */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
              <KPICard
                label="Total Pick Lists"
                value={stats.total}
                subtext="All time"
                icon={IconClipboard}
                trend="LIVE"
                trendUp={true}
                accent="bg-blue-50 text-blue-600"
              />
              <KPICard
                label="Active Workers"
                value={stats.workers}
                subtext="Currently on shift"
                icon={IconUsers}
                trend="LIVE"
                trendUp={true}
                accent="bg-indigo-50 text-indigo-600"
              />
              <KPICard
                label="Pending Orders"
                value={stats.pending}
                subtext="Unassigned + Assigned"
                icon={IconPackage}
                trend="LIVE"
                trendUp={false}
                accent="bg-amber-50 text-amber-600"
              />
              <KPICard
                label="Shortage Alerts"
                value={stats.shortage}
                subtext="Needs attention"
                icon={IconAlert}
                accent="bg-red-50 text-red-600"
              />
            </div>

            {/* Main Grid */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              
              {/* Chart */}
              <div className="lg:col-span-2">
                <BarChart />
              </div>

              {/* Right Panel */}
              <div className="space-y-6">
                
                {/* Quick Links */}
                <div className="bg-white rounded-2xl border border-slate-200/60 p-5 shadow-[0_1px_3px_0_rgba(0,0,0,0.04)]">
                  <h3 className="text-base font-semibold text-slate-900 mb-5">Quick Actions</h3>
                  <div className="grid grid-cols-2 gap-3">
                    <QuickLink icon={IconAudit} label="Upload Picklist" color="bg-violet-50 text-violet-600" to="/picklists" />
                    <QuickLink icon={ClipboardList} label="View Picklists" color="bg-blue-50 text-blue-600" to="/picklists" />
                    <QuickLink icon={IconDispatch} label="Delivery Routes" color="bg-sky-50 text-sky-600" to="/delivery" />
                    <QuickLink icon={FileText} label="Download Reports" color="bg-orange-50 text-orange-600" to="/reports" />
                  </div>
                </div>

                {/* Shortage Alerts */}
                <div className="bg-white rounded-2xl border border-red-100 shadow-sm overflow-hidden">
                  <div className="px-5 py-4 bg-red-50/50 border-b border-red-100 flex items-center gap-2">
                    <AlertTriangle className="w-5 h-5 text-red-600" />
                    <h3 className="text-sm font-bold text-red-800 uppercase tracking-wider">Live Shortage Alerts</h3>
                    {alerts.length > 0 && (
                      <span className="ml-auto text-xs font-bold text-white bg-red-500 px-2 py-0.5 rounded-full">
                        {alerts.length}
                      </span>
                    )}
                  </div>
                  <div className="p-2 max-h-64 overflow-y-auto">
                    {alerts.length === 0 ? (
                      <div className="py-8 text-center">
                        <Package className="w-8 h-8 text-gray-300 mx-auto mb-2" />
                        <p className="text-sm text-gray-400">No shortage alerts</p>
                      </div>
                    ) : (
                      <div className="space-y-1">
                        {alerts.map((a, i) => (
                          <div key={i} className="flex items-center gap-3 p-3 bg-red-50/50 rounded-xl border border-red-100/50 hover:bg-red-50 transition-colors">
                            <div className="w-8 h-8 rounded-full bg-red-100 flex items-center justify-center shrink-0">
                              <AlertTriangle className="w-4 h-4 text-red-600" />
                            </div>
                            <div className="flex-1 min-w-0">
                              <p className="text-sm font-semibold text-red-900 truncate">{a.pick_list_no}</p>
                              <p className="text-xs text-red-600">{a.items_missing} items missing</p>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>

              </div>
            </div>

            {/* Recent Activity */}
            <div className="bg-white rounded-2xl border border-slate-200/60 shadow-[0_1px_3px_0_rgba(0,0,0,0.04)] overflow-hidden">
              <div className="px-6 py-5 border-b border-gray-50 flex items-center justify-between">
                <div>
                  <h3 className="text-base font-semibold text-slate-900">Recent Activity</h3>
                  <p className="text-sm text-slate-500 mt-0.5">Latest picklist operations</p>
                </div>
                <button 
                  onClick={() => navigate("/picklists")}
                  className="text-sm font-semibold text-blue-600 hover:text-blue-700 transition-colors"
                >
                  View All
                </button>
              </div>
              
              {activities.length === 0 ? (
                <div className="py-12 text-center">
                  <Clock className="w-10 h-10 text-gray-300 mx-auto mb-3" />
                  <p className="text-sm text-gray-400">No recent activity</p>
                </div>
              ) : (
                <div className="divide-y divide-gray-50">
                  {activities.map((item, i) => (
                    <ActivityItem
                      key={i}
                      title={`PickList ${item.pick_list_no}`}
                      subtitle={item.order_number || "No Order"}
                      time={formatTime(item.createdAt || item.updatedAt)}
                      status={getStatus(item)}
                      onClick={() => navigate(`/picklists/${item.pick_list_no}`)}
                    />
                  ))}
                </div>
              )}
            </div>

          </div>
        </main>
      </div>

      {/* Toast Notification */}
      {toast && (
        <div className="fixed top-20 right-6 z-50 bg-red-600 text-white px-5 py-4 rounded-2xl shadow-2xl shadow-red-200 animate-in slide-in-from-right-full fade-in duration-300 max-w-sm">
          <div className="flex items-start gap-3">
            <AlertTriangle className="w-5 h-5 shrink-0 mt-0.5" />
            <div>
              <p className="font-bold text-sm">Shortage Alert</p>
              <p className="text-sm text-red-100 mt-0.5">{toast.pick_list_no}</p>
              <p className="text-xs text-red-200 mt-1">{toast.items_missing} items missing</p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}