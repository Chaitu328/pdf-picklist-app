import {
  Search,
  Bell,
  HelpCircle,
  ChevronDown,
  X,
  Loader2,
  Inbox,
  ArrowRight,
  LogOut,
  Mail,
  ClipboardList,
  Truck,
  Clock,
  CheckCircle2,
  AlertTriangle,
  RotateCcw,
  Send,
  RefreshCw,
  Package,
} from "lucide-react";
import { useEffect, useState, useRef, useCallback } from "react";
import { useNavigate } from "react-router-dom";

/* ═══════════════════════════════════════════════════════════════
   CONSTANTS & CONFIG
   ═══════════════════════════════════════════════════════════════ */

const API_BASE = "https://pick-list.onrender.com/api";
const ROUTES = {
  workers: "/app/workers",
  picklists: "/app/picklists",
  delivery: "/app/delivery",
};

/* ═══════════════════════════════════════════════════════════════
   HELPER: Search Type Detection
   ═══════════════════════════════════════════════════════════════ */

function detectSearchType(query) {
  const value = query.trim().toLowerCase();

  if (/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(value)) {
    return "workers";
  }

  if (/^pl-?\d+$/i.test(value) || /^\d+$/.test(value)) {
    return "picklists";
  }

  return "delivery";
}

/* ═══════════════════════════════════════════════════════════════
   HELPER: User Initials
   ═══════════════════════════════════════════════════════════════ */

function getInitials(name) {
  if (!name || typeof name !== "string") return "U";
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);
}

/* ═══════════════════════════════════════════════════════════════
   STATUS CONFIG (for badges)
   ═══════════════════════════════════════════════════════════════ */

const STATUS_CONFIG = {
  not_assigned:      { color: "gray",    label: "Not Assigned",      icon: Clock,           desc: "Created by manager, awaiting assignment" },
  assigned:          { color: "blue",    label: "Assigned",          icon: Package,         desc: "Accepted by worker" },
  scanning_completed:{ color: "indigo",  label: "Scanning Completed", icon: CheckCircle2,    desc: "Initial submission completed" },
  reupdate_requested:{ color: "yellow",  label: "Correction Needed", icon: AlertTriangle,   desc: "Manager requested changes" },
  reupdate_completed:{ color: "teal",    label: "Corrected",         icon: RotateCcw,       desc: "Worker resubmitted after correction" },
  shortage:          { color: "red",     label: "Shortage",          icon: AlertTriangle,   desc: "0 / less than half / half qty" },
  completed:         { color: "green",   label: "Completed",         icon: CheckCircle2,    desc: "Full quantity fulfilled" },
  reupdated:         { color: "emerald", label: "Re-updated",        icon: RefreshCw,       desc: "Full qty after correction" },
};

const COLOR_MAP = {
  gray:    "bg-gray-100 text-gray-700 border-gray-200",
  blue:    "bg-blue-50 text-blue-700 border-blue-200",
  indigo:  "bg-indigo-50 text-indigo-700 border-indigo-200",
  yellow:  "bg-amber-50 text-amber-700 border-amber-200",
  teal:    "bg-teal-50 text-teal-700 border-teal-200",
  red:     "bg-red-50 text-red-700 border-red-200",
  green:   "bg-green-50 text-green-700 border-green-200",
  emerald: "bg-emerald-50 text-emerald-700 border-emerald-200",
};

/* ═══════════════════════════════════════════════════════════════
   SUB-COMPONENT: Status Badge
   ═══════════════════════════════════════════════════════════════ */

function StatusBadge({ statusKey }) {
  const config = STATUS_CONFIG[statusKey] || STATUS_CONFIG.not_assigned;
  const colorClass = COLOR_MAP[config.color] || COLOR_MAP.gray;
  const Icon = config.icon;

  return (
    <div className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-[11px] font-semibold border ${colorClass}`}>
      <Icon className="w-3 h-3" />
      {config.label}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   SUB-COMPONENT: Notification Dropdown
   ═══════════════════════════════════════════════════════════════ */

function NotificationDropdown({ picklists, loading, onNavigate, onClose }) {
  const dropdownRef = useRef(null);

  useEffect(() => {
    function handleClickOutside(e) {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
        onClose();
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [onClose]);

  return (
    <div
      ref={dropdownRef}
      className="absolute right-0 mt-3 w-80 bg-white/80 backdrop-blur-xl rounded-2xl shadow-[0_8px_30px_rgba(0,0,0,0.08)] border border-white/60 overflow-hidden animate-[fadeIn_0.2s_ease-out,slideDown_0.2s_ease-out] origin-top-right"
    >
      {/* Header */}
      <div className="px-5 py-3.5 border-b border-slate-100/80 flex items-center justify-between bg-slate-50/40">
        <div className="flex items-center gap-2">
          <Bell className="w-4 h-4 text-slate-500" />
          <h3 className="text-sm font-bold text-slate-800">Unassigned Picklists</h3>
        </div>
        {picklists.length > 0 && (
          <span className="px-2 py-0.5 bg-red-50 text-red-600 text-[10px] font-bold rounded-full border border-red-100">
            {picklists.length}
          </span>
        )}
      </div>

      {/* Content */}
      <div className="max-h-80 overflow-y-auto">
        {loading ? (
          <div className="flex items-center justify-center py-10">
            <Loader2 className="w-5 h-5 text-slate-400 animate-spin" />
          </div>
        ) : picklists.length === 0 ? (
          <div className="flex flex-col items-center py-10 text-center px-6">
            <div className="p-3.5 bg-emerald-50 rounded-2xl mb-3 shadow-sm">
              <Inbox className="w-6 h-6 text-emerald-500" />
            </div>
            <p className="text-sm font-semibold text-slate-700">All caught up!</p>
            <p className="text-xs text-slate-400 mt-1 leading-relaxed">No unassigned picklists waiting for action</p>
          </div>
        ) : (
          <div className="divide-y divide-slate-50">
            {picklists.map((p) => (
              <button
                key={p._id}
                onClick={() => onNavigate(p.pick_list_no)}
                className="w-full text-left px-5 py-3.5 hover:bg-slate-50/80 transition-all duration-200 group flex items-center justify-between"
              >
                <div>
                  <p className="text-sm font-bold text-slate-800 group-hover:text-blue-600 transition-colors">
                    {p.pick_list_no}
                  </p>
                  <p className="text-xs text-slate-400 mt-0.5 capitalize">
                    {p.status?.replace(/_/g, " ") || "unknown"}
                  </p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-300 group-hover:text-blue-500 group-hover:translate-x-1 transition-all duration-200" />
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   SUB-COMPONENT: User Dropdown
   ═══════════════════════════════════════════════════════════════ */

function UserDropdown({ user, onLogout, onClose }) {
  const dropdownRef = useRef(null);

  useEffect(() => {
    function handleClickOutside(e) {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
        onClose();
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [onClose]);

  return (
    <div
      ref={dropdownRef}
      className="absolute right-0 mt-2 w-56 bg-white/80 backdrop-blur-xl rounded-2xl shadow-[0_8px_30px_rgba(0,0,0,0.08)] border border-white/60 overflow-hidden animate-[fadeIn_0.2s_ease-out,slideDown_0.2s_ease-out] origin-top-right py-1"
    >
      {/* User info */}
      <div className="px-4 py-3.5 border-b border-slate-100/80">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-full bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center text-white font-bold text-xs shadow-sm">
            {getInitials(user?.name)}
          </div>
          <div className="min-w-0">
            <p className="text-sm font-bold text-slate-800 truncate">{user?.name || "Admin"}</p>
            <p className="text-[11px] text-slate-400 capitalize font-medium truncate">{user?.role || "Admin"}</p>
          </div>
        </div>
      </div>

      {/* Actions */}
      <button
        onClick={onLogout}
        className="w-full flex items-center gap-2.5 px-4 py-2.5 text-sm text-red-600 hover:bg-red-50 transition-colors duration-200"
      >
        <LogOut className="w-4 h-4" />
        Sign out
      </button>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   SUB-COMPONENT: Help Modal
   ═══════════════════════════════════════════════════════════════ */

function HelpModal({ onClose }) {
  const modalRef = useRef(null);

  useEffect(() => {
    function handleClickOutside(e) {
      if (modalRef.current && !modalRef.current.contains(e.target)) {
        onClose();
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [onClose]);

  useEffect(() => {
    function handleEscape(e) {
      if (e.key === "Escape") onClose();
    }
    document.addEventListener("keydown", handleEscape);
    return () => document.removeEventListener("keydown", handleEscape);
  }, [onClose]);

  const searchTips = [
    { icon: Mail,          label: "Email",          example: "john@company.com",  route: "Workers",   color: "bg-blue-50 text-blue-600 border-blue-100" },
    { icon: ClipboardList, label: "Picklist",       example: "PL-1901, 1901",     route: "Picklists", color: "bg-purple-50 text-purple-600 border-purple-100" },
    { icon: Truck,         label: "Company / City", example: "Acme Corp, London", route: "Delivery",  color: "bg-emerald-50 text-emerald-600 border-emerald-100" },
  ];

  const statusFlows = [
    {
      title: "Assignment Flow",
      icon: Send,
      items: ["not_assigned", "assigned", "scanning_completed"],
    },
    {
      title: "Correction Flow",
      icon: RotateCcw,
      items: ["reupdate_requested", "reupdate_completed"],
    },
    {
      title: "Final Status (Submit)",
      icon: CheckCircle2,
      items: ["shortage", "completed"],
    },
    {
      title: "Final Status (Re-submit)",
      icon: RefreshCw,
      items: ["shortage", "reupdated"],
    },
  ];

  return (
    <div className="fixed inset-0 bg-black/40 backdrop-blur-sm flex items-center justify-center z-50 animate-[fadeIn_0.2s_ease-out]">
      <div
        ref={modalRef}
        className="bg-white/80 backdrop-blur-xl rounded-3xl shadow-[0_20px_60px_rgba(0,0,0,0.12)] w-full max-w-2xl mx-4 overflow-hidden animate-[scaleIn_0.25s_ease-out] border border-white/60"
      >
        {/* Header */}
        <div className="px-6 py-5 border-b border-slate-100/80 flex items-center justify-between bg-white">
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-blue-50 rounded-xl shadow-sm">
              <HelpCircle className="w-5 h-5 text-blue-600" />
            </div>
            <div>
              <h2 className="text-lg font-bold text-slate-900">Search Guide</h2>
              <p className="text-xs text-slate-400 mt-0.5">How to use global search & understand picklist status</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 hover:bg-slate-100 rounded-xl transition-colors duration-200 text-slate-400 hover:text-slate-600"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

<div className="p-6 space-y-8 max-h-[70vh] overflow-y-auto no-scrollbar bg-white">
          {/* ─── Search Tips ─── */}
          <section>
            <h3 className="text-sm font-bold text-slate-800 mb-4 flex items-center gap-2">
              <Search className="w-4 h-4 text-slate-400" />
              Search Tips
            </h3>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              {searchTips.map((tip) => (
                <div
                  key={tip.label}
                  className="flex flex-col gap-3 p-4 rounded-2xl bg-white shadow-xl border border-slate-100 hover:border-slate-200 hover:shadow-sm transition-all duration-200"
                >
                  <div className={`p-2.5 rounded-xl w-fit ${tip.color}`}>
                    <tip.icon className="w-4 h-4" />
                  </div>
                  <div>
                    <p className="text-sm font-bold text-slate-800">{tip.label}</p>
                    <p className="text-[11px] text-slate-400 mt-1">{tip.example}</p>
                  </div>
                  <div className="mt-auto">
                    <span className={`inline-flex items-center px-2 py-0.5 rounded-md text-[10px] font-bold border ${tip.color}`}>
                      → {tip.route}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </section>

          {/* ─── Status Guide ─── */}
          <section>
            <h3 className="text-sm font-bold text-slate-800 mb-4 flex items-center gap-2">
              <ClipboardList className="w-4 h-4 text-slate-400" />
              Picklist Status Guide
            </h3>
            <div className="space-y-4">
              {statusFlows.map((flow) => {
                const FlowIcon = flow.icon;
                return (
                  <div key={flow.title} className="rounded-2xl bg-white shadow-xl border border-slate-100 overflow-hidden">
                    {/* Flow Header */}
                    <div className="px-5 py-3 bg-slate-50/80 border-b border-slate-100/60 flex items-center gap-2">
                      <FlowIcon className="w-4 h-4 text-slate-500" />
                      <span className="text-xs font-bold text-slate-700 uppercase tracking-wide">{flow.title}</span>
                    </div>
                    {/* Flow Items */}
                    <div className="p-5 space-y-3">
                      {flow.items.map((statusKey) => {
                        const config = STATUS_CONFIG[statusKey];
                        if (!config) return null;
                        return (
                          <div key={statusKey} className="flex items-start gap-3">
                            <StatusBadge statusKey={statusKey} />
                            <p className="text-xs text-slate-500 mt-0.5 leading-relaxed">{config.desc}</p>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                );
              })}
            </div>
          </section>

        </div>

        {/* Footer */}
        <div className="px-6 py-4 bg-white border-t border-slate-100/80 flex items-center justify-between">
          <p className="text-xs text-slate-400">Press <kbd className="px-1.5 py-0.5 bg-white border border-slate-200 rounded-md text-[10px] font-mono shadow-sm">Enter</kbd> to search</p>
          <p className="text-xs text-slate-400">Press <kbd className="px-1.5 py-0.5 bg-white border border-slate-200 rounded-md text-[10px] font-mono shadow-sm">Esc</kbd> to close</p>
        </div>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   MAIN COMPONENT: Header
   ═══════════════════════════════════════════════════════════════ */

export default function Header() {
  const navigate = useNavigate();
  const token = localStorage.getItem("token");

  /* ─── State ─── */
  const [user, setUser] = useState(null);
  const [query, setQuery] = useState("");

  const [unassignedPicklists, setUnassignedPicklists] = useState([]);
  const [notifLoading, setNotifLoading] = useState(false);

  const [showNotif, setShowNotif] = useState(false);
  const [showUserMenu, setShowUserMenu] = useState(false);
  const [showHelp, setShowHelp] = useState(false);

  /* ─── Load user from localStorage ─── */
  useEffect(() => {
    try {
      const storedUser = localStorage.getItem("user");
      if (storedUser) {
        setUser(JSON.parse(storedUser));
      }
    } catch (err) {
      console.error("Failed to parse user from localStorage:", err);
    }
  }, []);

  /* ─── Fetch unassigned picklists ─── */
  useEffect(() => {
    if (!token) return;

    const fetchPicklists = async () => {
      setNotifLoading(true);
      try {
        const res = await fetch(`${API_BASE}/picklist`, {
          headers: { Authorization: `Bearer ${token}` },
        });

        if (!res.ok) throw new Error(`HTTP ${res.status}`);

        const data = await res.json();
        const pending = data.filter(
          (p) =>
            p.status === "pending" ||
            p.status === "unassigned" ||
            !p.workerId
        );
        setUnassignedPicklists(pending);
      } catch (err) {
        console.error("Failed to fetch picklists:", err);
        setUnassignedPicklists([]);
      } finally {
        setNotifLoading(false);
      }
    };

    fetchPicklists();
  }, [token]);

  /* ─── Search handler ─── */
  const handleSearch = useCallback(() => {
    const trimmed = query.trim();
    if (!trimmed) return;

    const type = detectSearchType(trimmed);
    const encoded = encodeURIComponent(trimmed);
    const path = ROUTES[type];

    navigate(`${path}?search=${encoded}`);
    setQuery("");
  }, [query, navigate]);

  /* ─── Keyboard shortcut: Ctrl/Cmd + K to focus search ─── */
  const inputRef = useRef(null);
  useEffect(() => {
    const handleKeyDown = (e) => {
      if ((e.metaKey || e.ctrlKey) && e.key === "k") {
        e.preventDefault();
        inputRef.current?.focus();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, []);

  /* ─── Navigate to picklist from notification ─── */
  const handleNotifNavigate = useCallback(
    (pickListNo) => {
      setShowNotif(false);
      navigate(`/picklists/${pickListNo}`);
    },
    [navigate]
  );

  /* ─── Logout ─── */
  const handleLogout = useCallback(() => {
    localStorage.removeItem("token");
    localStorage.removeItem("user");
    window.location.href = "/login";
  }, []);

  /* ─── Toggle helpers ─── */
  const toggleNotif = useCallback(() => {
    setShowNotif((prev) => !prev);
    setShowUserMenu(false);
  }, []);

  const toggleUserMenu = useCallback(() => {
    setShowUserMenu((prev) => !prev);
    setShowNotif(false);
  }, []);

  /* ═══════════════════════════════════════════════════════════════
     RENDER
     ═══════════════════════════════════════════════════════════════ */
  return (
    <>
      <header className="fixed top-0 left-0 lg:left-64 right-0 h-16 bg-white/70 backdrop-blur-xl border-b border-white/40 shadow-[0_2px_20px_rgba(0,0,0,0.03)] flex items-center justify-between px-4 sm:px-6 z-40 animate-[fadeIn_0.4s_ease-out]">

        {/* ─── SEARCH ─── */}
        <div className="w-full max-w-md">
          <div className="relative group">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 group-focus-within:text-blue-500 transition-colors duration-200" />
            <input
              ref={inputRef}
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && handleSearch()}
              placeholder="Search email, picklist, company..."
              autoComplete="off"
              spellCheck="false"
              className="w-full pl-10 pr-24 py-2.5 bg-white/60 border border-slate-200/70 rounded-xl text-sm text-slate-900 placeholder:text-slate-400 outline-none focus:border-blue-400/60 focus:ring-[3px] focus:ring-blue-500/10 focus:bg-white/90 focus:shadow-[0_0_20px_rgba(59,130,246,0.06)] transition-all duration-200"
            />
            {/* Keyboard hint */}
            {/* <div className="absolute right-3 top-1/2 -translate-y-1/2 hidden sm:flex items-center gap-0.5 px-1.5 py-0.5 rounded-md bg-slate-100/70 border border-slate-200/50">
              <kbd className="text-[10px] font-mono font-semibold text-slate-400">⌘</kbd>
              <kbd className="text-[10px] font-mono font-semibold text-slate-400">K</kbd>
            </div> */}
            {/* Clear button */}
            {query && (
              <button
                onClick={() => setQuery("")}
                className="absolute right-14 top-1/2 -translate-y-1/2 p-1 hover:bg-slate-200/60 rounded-full text-slate-400 hover:text-slate-600 transition-all duration-200"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            )}
          </div>
        </div>

        {/* ─── RIGHT ACTIONS ─── */}
        <div className="flex items-center gap-0.5 sm:gap-1 ml-4">

          {/* Help */}
          <button
            onClick={() => setShowHelp(true)}
            className="relative p-2.5 text-slate-500 hover:text-blue-600 hover:bg-blue-50/60 rounded-xl transition-all duration-200 hover:scale-105 active:scale-95 group"
            title="Search help"
          >
            <HelpCircle className="w-[18px] h-[18px]" />
          </button>

          {/* Notifications */}
          <div className="relative">
            <button
              onClick={toggleNotif}
              className={`relative p-2.5 rounded-xl transition-all duration-200 hover:scale-105 active:scale-95 ${
                showNotif
                  ? "bg-slate-100 text-slate-800"
                  : "text-slate-500 hover:text-slate-700 hover:bg-slate-100/60"
              }`}
              title="Unassigned picklists"
            >
              <Bell className="w-[18px] h-[18px]" />
              {unassignedPicklists.length > 0 && (
                <>
                  <span className="absolute top-1.5 right-1.5 min-w-[18px] h-[18px] flex items-center justify-center bg-red-500 text-white text-[10px] font-bold rounded-full px-1 shadow-sm">
                    {unassignedPicklists.length > 99 ? "99+" : unassignedPicklists.length}
                  </span>
                  <span className="absolute top-1.5 right-1.5 min-w-[18px] h-[18px] bg-red-500 rounded-full animate-[ping_1.5s_ease-in-out_infinite] opacity-30" />
                </>
              )}
            </button>

            {showNotif && (
              <NotificationDropdown
                picklists={unassignedPicklists}
                loading={notifLoading}
                onNavigate={handleNotifNavigate}
                onClose={() => setShowNotif(false)}
              />
            )}
          </div>

          {/* Divider */}
          <div className="h-6 w-px bg-slate-200/60 mx-1.5 hidden sm:block" />

          {/* User */}
          <div className="relative">
            <button
              onClick={toggleUserMenu}
              className={`flex items-center gap-2.5 pl-2 pr-2 py-1.5 rounded-xl transition-all duration-200 ${
                showUserMenu ? "bg-slate-100" : "hover:bg-slate-50"
              }`}
            >
              <div className="text-right hidden md:block">
                <p className="text-sm font-bold text-slate-800 leading-tight">
                  {user?.name || "Admin"}
                </p>
                <p className="text-[11px] text-slate-400 capitalize font-medium leading-tight">
                  {user?.role || "Admin"}
                </p>
              </div>
              <div className="w-8 h-8 rounded-full bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center text-white font-bold text-[11px] shadow-[0_2px_8px_rgba(59,130,246,0.25)]">
                {getInitials(user?.name)}
              </div>
              <ChevronDown
                className={`w-3.5 h-3.5 text-slate-400 transition-transform duration-200 ${
                  showUserMenu ? "rotate-180" : ""
                }`}
              />
            </button>

            {showUserMenu && (
              <UserDropdown
                user={user}
                onLogout={handleLogout}
                onClose={() => setShowUserMenu(false)}
              />
            )}
          </div>

        </div>
      </header>

      {/* ─── HELP MODAL ─── */}
      {showHelp && <HelpModal onClose={() => setShowHelp(false)} />}
    </>
  );
}