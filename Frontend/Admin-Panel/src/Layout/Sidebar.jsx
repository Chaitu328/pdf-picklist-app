import { NavLink } from "react-router-dom";
import {
  Warehouse,
  LayoutDashboard,
  ClipboardList,
  Users,
  Package,
  Plus,
  HelpCircle,
  LogOut,
  FileText,
  Truck,
  MessageCircle,
  ClipboardCheck
} from "lucide-react";
import { useNavigate } from "react-router-dom";

export default function Sidebar() {
  const navigate = useNavigate();

const handleLogout = () => {
  console.log("🚪 Logging out");

  // ✅ remove auth data
  localStorage.removeItem("token");
  localStorage.removeItem("user");

  // optional: clear everything
  // localStorage.clear();

  // ✅ redirect to login
  navigate("/login");
};
  return (
    <aside className="fixed left-0 top-0 h-screen w-64 bg-[#F8FAFC] border-r border-slate-200/80 flex flex-col justify-between select-none z-50">
      
      {/* ─── TOP SECTION ─── */}
      <div className="px-4 pt-6">
        
        {/* Logo */}
        <div className="flex items-center gap-3 px-2 mb-8">
          <div className="w-9 h-9 bg-blue-700 rounded-xl flex items-center justify-center shadow-sm shadow-blue-200/50 ring-1 ring-blue-600/20">
            <Warehouse className="w-5 h-5 text-white" strokeWidth={2} />
          </div>
          <div className="flex flex-col">
            <span className="text-lg font-bold text-slate-900 tracking-tight leading-none">
              PDF-PickList
            </span>
            <span className="text-[10px] font-semibold text-slate-400 uppercase tracking-widest mt-1.5">
              Warehouse Ops
            </span>
          </div>
        </div>

        {/* Navigation */}
        <nav className="space-y-1">
          
          {/* Dashboard */}
          <NavLink
            to="/"
            className={({ isActive }) =>
              `group flex items-center gap-0 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200 ${
                isActive
                  ? "bg-blue-50/80 text-blue-700 font-semibold"
                  : "text-slate-600 hover:bg-slate-100 hover:text-slate-900"
              }`
            }
          >
            {({ isActive }) => (
              <>
                <div className={`h-5 w-[3px] rounded-r-full mr-3 transition-colors duration-200 ${isActive ? "bg-blue-600" : "bg-transparent"}`} />
                <LayoutDashboard className={`w-[18px] h-[18px] flex-shrink-0 mr-3 transition-colors duration-200 ${isActive ? "text-blue-600" : "text-slate-400 group-hover:text-slate-600"}`} />
                <span>Dashboard</span>
              </>
            )}
          </NavLink>

          {/* Pick Lists */}
          <NavLink
            to="/picklists"
            className={({ isActive }) =>
              `group flex items-center gap-0 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200 ${
                isActive
                  ? "bg-blue-50/80 text-blue-700 font-semibold"
                  : "text-slate-600 hover:bg-slate-100 hover:text-slate-900"
              }`
            }
          >
            {({ isActive }) => (
              <>
                <div className={`h-5 w-[3px] rounded-r-full mr-3 transition-colors duration-200 ${isActive ? "bg-blue-600" : "bg-transparent"}`} />
                <ClipboardList className={`w-[18px] h-[18px] flex-shrink-0 mr-3 transition-colors duration-200 ${isActive ? "text-blue-600" : "text-slate-400 group-hover:text-slate-600"}`} />
                <span>Pick Lists</span>
              </>
            )}
          </NavLink>

          {/* Workers */}
          <NavLink
  to="/workers"
  className={({ isActive }) =>
    `group flex items-center px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200 ${
      isActive
        ? "bg-blue-50 text-blue-600"
        : "text-slate-600 hover:bg-slate-100 hover:text-slate-900"
    }`
  }
>
  <div className="h-5 w-[3px] rounded-r-full mr-3 bg-transparent" />

  <Users className="w-[18px] h-[18px] flex-shrink-0 mr-3 transition-colors duration-200" />

  <span>Workers</span>
</NavLink>

          {/* Delivery */}
          <NavLink
  to="/delivery"
  className={({ isActive }) =>
    `group flex items-center gap-0 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200 ${
      isActive
        ? "bg-blue-50/80 text-blue-700 font-semibold"
        : "text-slate-600 hover:bg-slate-100 hover:text-slate-900"
    }`
  }
>
  {({ isActive }) => (
    <>
      <div
        className={`h-5 w-[3px] rounded-r-full mr-3 transition-colors duration-200 ${
          isActive ? "bg-blue-600" : "bg-transparent"
        }`}
      />
      <Truck
        className={`w-[18px] h-[18px] flex-shrink-0 mr-3 transition-colors duration-200 ${
          isActive
            ? "text-blue-600"
            : "text-slate-400 group-hover:text-slate-600"
        }`}
      />
      <span>Delivery</span>
    </>
  )}
</NavLink>

        {/* Reports */}
<NavLink
  to="/reports"
  className={({ isActive }) =>
    `group flex items-center gap-0 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200 ${
      isActive
        ? "bg-blue-50/80 text-blue-700 font-semibold"
        : "text-slate-600 hover:bg-slate-100 hover:text-slate-900"
    }`
  }
>
  {({ isActive }) => (
    <>
      <div
        className={`h-5 w-[3px] rounded-r-full mr-3 transition-colors duration-200 ${
          isActive ? "bg-blue-600" : "bg-transparent"
        }`}
      />
      <FileText
        className={`w-[18px] h-[18px] flex-shrink-0 mr-3 transition-colors duration-200 ${
          isActive
            ? "text-blue-600"
            : "text-slate-400 group-hover:text-slate-600"
        }`}
      />
      <span>Reports</span>
    </>
  )}
</NavLink>

<NavLink
  to="/audit"
  className={({ isActive }) =>
    `group flex items-center gap-0 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200 ${
      isActive
        ? "bg-blue-50/80 text-blue-700 font-semibold"
        : "text-slate-600 hover:bg-slate-100 hover:text-slate-900"
    }`
  }
>
  {({ isActive }) => (
    <>
      <div
        className={`h-5 w-[3px] rounded-r-full mr-3 transition-colors duration-200 ${
          isActive ? "bg-blue-600" : "bg-transparent"
        }`}
      />
      <ClipboardCheck
        className={`w-[18px] h-[18px] flex-shrink-0 mr-3 transition-colors duration-200 ${
          isActive
            ? "text-blue-600"
            : "text-slate-400 group-hover:text-slate-600"
        }`}
      />
      <span>Audit</span>
    </>
  )}
</NavLink>

        </nav>
      </div>

      {/* ─── BOTTOM SECTION ─── */}
      <div className="p-4 border-t border-slate-200/80 space-y-3">
        
        {/* CTA */}
          {/* <button className="w-full flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-semibold py-2.5 px-4 rounded-xl shadow-sm shadow-blue-200/50 hover:shadow-md hover:shadow-blue-200/60 transition-all duration-200 active:scale-[0.98]">
            <Plus className="w-4 h-4" strokeWidth={2.5} />
            Create New Pick List
          </button> */}

        {/* Secondary Actions */}
        <div className="pt-1 space-y-0.5">
         <a
  href="mailto:support@yourcompany.com"
  className="group flex items-center px-3 py-2.5 rounded-lg text-sm font-medium text-slate-600 hover:bg-blue-50 hover:text-blue-600 transition-all"
>
  <div className="h-5 w-[3px] rounded-r-full mr-3 bg-transparent" />

  <span className="mr-3"><MessageCircle className="w-[18px] h-[18px] flex-shrink-0 mr-3 text-slate-400 group-hover:text-blue-500 transition-colors duration-200"/></span>

  <span>Support</span>
</a>
          
         <button
  onClick={handleLogout}
  className="group w-full flex items-center gap-0 px-3 py-2 text-sm font-medium text-slate-500 hover:text-red-600 hover:bg-red-50 rounded-lg transition-all duration-200"
>
  <div className="h-5 w-[3px] rounded-r-full mr-3 bg-transparent" />
  <LogOut className="w-[18px] h-[18px] flex-shrink-0 mr-3 text-slate-400 group-hover:text-red-500 transition-colors duration-200" />
  Sign Out
</button>
        </div>

      </div>
    </aside>
  );
}