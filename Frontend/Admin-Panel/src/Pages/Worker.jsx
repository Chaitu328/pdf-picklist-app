import { useEffect, useState, useMemo } from "react";
import {
  ArrowLeft,
  ClipboardList,
  Package,
  AlertTriangle,
  CheckCircle2,
  Clock,
  Loader2,
  RefreshCw,
  ChevronRight,
  Hash,
  Search,
  X,
  Info,
  User,
  Inbox,
  PlayCircle,
  CheckSquare,
  AlertOctagon,
  RotateCcw,
  ScanLine,
  TrendingUp,
  Filter,
  ArrowUpDown,
  ChevronDown,
  BarChart3,
  Users,
  Warehouse,
  Activity,
  Box,
  CircleDashed,
  AlertCircle,
  Minus,
  Calendar,
  Tag,
  Mail,
  Briefcase,
  ArrowUpRight,
  Percent
} from "lucide-react";

export default function Workers() {
  // ================= STATE =================
  const [picklists, setPicklists] = useState([]);
  const [loading, setLoading] = useState(true);

  const [selectedWorker, setSelectedWorker] = useState(null);
  const [selectedPicklist, setSelectedPicklist] = useState(null);
  const [picklistData, setPicklistData] = useState(null);
  const [picklistLoading, setPicklistLoading] = useState(false);

  const [showReupdate, setShowReupdate] = useState(false);
  const [selectedParts, setSelectedParts] = useState([]);
  const [note, setNote] = useState("");
  const [updating, setUpdating] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);

  const [searchQuery, setSearchQuery] = useState("");
  const [filterStatus, setFilterStatus] = useState("all");
  const [sortBy, setSortBy] = useState("active-desc");

  const token = localStorage.getItem("token");

  // ================= FETCH DATA =================
  const fetchData = async () => {
    try {
      setLoading(true);
      const res = await fetch("http://localhost:3000/api/picklist/admin/summary", {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();
      setPicklists(data.picklists || data.workers || data || []);
    } catch (err) {
      console.error("Failed to fetch picklists:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  // ================= DERIVE WORKERS FROM PICKLISTS =================
  const workers = useMemo(() => {
    const workerMap = new Map();

    picklists.forEach((picklist) => {
      const workerList = picklist.workers || [];

      workerList.forEach((worker) => {
        const id = worker._id || worker.email || worker.name;
        if (!workerMap.has(id)) {
          workerMap.set(id, {
            _id: id,
            name: worker.name || worker.email?.split("@")[0] || "Unknown",
            email: worker.email || "—",
            role: worker.role || "worker",
            picklists: [],
          });
        }
        workerMap.get(id).picklists.push(picklist);
      });
    });

    return Array.from(workerMap.values());
  }, [picklists]);

  // ================= WORKER STATS =================
  const getWorkerStats = (worker) => {
    const pls = worker.picklists;
    const totalPicklists = pls.length;
    const activePicklists = pls.filter((p) => p.status === "processing").length;
    const completedPicklists = pls.filter((p) => p.status === "completed").length;

    const totalParts = pls.reduce((sum, p) => sum + (p.parts?.length || 0), 0);
    const completedParts = pls.reduce(
      (sum, p) => sum + (p.parts?.filter((pt) => pt.status === "completed").length || 0),
      0
    );
    const completionPct = totalParts > 0 ? Math.round((completedParts / totalParts) * 100) : 0;

    const pendingReupdates = pls.filter(
      (p) => p.status === "reupdate_requested" || p.reupdate_status
    ).length;

    return {
      totalPicklists,
      activePicklists,
      completedPicklists,
      totalParts,
      completedParts,
      completionPct,
      pendingReupdates,
    };
  };

  // ================= FILTER & SORT WORKERS =================
  const filteredWorkers = useMemo(() => {
    let result = [...workers];

    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase().trim();
      result = result.filter(
        (w) =>
          w.name?.toLowerCase().includes(q) ||
          w.email?.toLowerCase().includes(q)
      );
    }

    if (filterStatus !== "all") {
      result = result.filter((w) =>
        w.picklists.some((p) => p.status === filterStatus)
      );
    }

    switch (sortBy) {
      case "active-desc":
        result.sort((a, b) => getWorkerStats(b).activePicklists - getWorkerStats(a).activePicklists);
        break;
      case "active-asc":
        result.sort((a, b) => getWorkerStats(a).activePicklists - getWorkerStats(b).activePicklists);
        break;
      case "completion-desc":
        result.sort((a, b) => getWorkerStats(b).completionPct - getWorkerStats(a).completionPct);
        break;
      case "completion-asc":
        result.sort((a, b) => getWorkerStats(a).completionPct - getWorkerStats(b).completionPct);
        break;
      case "name-asc":
        result.sort((a, b) => (a.name || "").localeCompare(b.name || ""));
        break;
      default:
        break;
    }

    return result;
  }, [workers, searchQuery, filterStatus, sortBy]);

  // ================= GLOBAL STATS =================
  const globalStats = useMemo(() => {
    const totalWorkers = workers.length;
   const activeWorkers = workers.filter((w) =>
  w.picklists.some((p) =>
    ["assigned", "processing"].includes(p.status)
  )
).length;
    const totalPicklists = picklists.length;
    const pendingReupdates = picklists.filter(
      (p) => p.status === "reupdate_requested" || p.reupdate_status
    ).length;
    return { totalWorkers, activeWorkers, totalPicklists, pendingReupdates };
  }, [workers, picklists]);

  // ================= FETCH PICKLIST DETAIL =================
  const fetchPicklistDetail = async (pickListNo) => {
    try {
      setPicklistLoading(true);
      const res = await fetch("http://localhost:3000/api/picklist", {
        headers: { Authorization: `Bearer ${token}` },
      });
      const response = await res.json();
      const all = response.picklists || response || [];
      const found = all.find(
        (p) =>
          p.pick_list_no?.toLowerCase()?.trim() === pickListNo?.toLowerCase()?.trim() ||
          p._id === pickListNo
      );
      setSelectedPicklist(pickListNo);
      setPicklistData(found || null);
      setSelectedParts([]);
      setNote("");
      setShowReupdate(false);
    } catch (err) {
      console.error("Failed to fetch picklist:", err);
      setPicklistData(null);
    } finally {
      setPicklistLoading(false);
    }
  };

  // ================= NAVIGATION =================
  const goBackToWorkers = () => {
    setSelectedWorker(null);
    setSelectedPicklist(null);
    setPicklistData(null);
    setShowReupdate(false);
    setSelectedParts([]);
    setNote("");
  };

  const goBackToWorkerDetail = () => {
    setSelectedPicklist(null);
    setPicklistData(null);
    setShowReupdate(false);
    setSelectedParts([]);
    setNote("");
  };

  // ================= SELECTION LOGIC =================
  const parts = picklistData?.parts || [];
  const selectableParts = useMemo(() => parts.filter((p) => p.status !== "completed"), [parts]);
  const allSelectableSelected = useMemo(
    () => selectableParts.length > 0 && selectableParts.every((p) => selectedParts.includes(p.partno)),
    [selectableParts, selectedParts]
  );
  const someSelected = selectedParts.length > 0;

  const handleSelectAll = () => {
    if (allSelectableSelected) {
      setSelectedParts([]);
    } else {
      setSelectedParts(selectableParts.map((p) => p.partno));
    }
  };

  const togglePart = (partno, status) => {
    if (status === "completed") return;
    setSelectedParts((prev) =>
      prev.includes(partno) ? prev.filter((p) => p !== partno) : [...prev, partno]
    );
  };

  // ================= RE-UPDATE =================
  const handleReupdateClick = () => {
    if (selectedParts.length === 0) return;
    setShowConfirm(true);
  };

  const handleConfirmReupdate = async () => {
    try {
      setUpdating(true);
      const res = await fetch(
        `http://localhost:3000/api/picklist/${picklistData._id}/reupdate`,
        {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({
            partnos: selectedParts,
            note: note || "Recheck selected parts",
          }),
        }
      );
      const data = await res.json();
      if (!res.ok) {
        alert(data.message || "Failed to request re-update");
        return;
      }
      setPicklistData(data.picklist);
      setShowReupdate(false);
      setSelectedParts([]);
      setNote("");
      setShowConfirm(false);
      fetchData();
    } catch (err) {
      console.error(err);
      alert("Error sending re-update request");
    } finally {
      setUpdating(false);
    }
  };

  // ================= HELPERS =================
  const formatDate = (dateStr) => {
    if (!dateStr) return "—";
    return new Date(dateStr).toLocaleString("en-US", {
      month: "short", day: "numeric", year: "numeric",
      hour: "2-digit", minute: "2-digit",
    });
  };

  const formatDateShort = (dateStr) => {
    if (!dateStr) return "—";
    return new Date(dateStr).toLocaleDateString("en-US", { month: "short", day: "numeric" });
  };

  const getStatusConfig = (status) => {
    const configs = {
      processing: {
        class: "bg-blue-50 text-blue-700 border-blue-200",
        icon: <PlayCircle className="w-3.5 h-3.5" />,
        dot: "bg-blue-500",
        label: "Processing",
      },
      completed: {
        class: "bg-emerald-50 text-emerald-700 border-emerald-200",
        icon: <CheckCircle2 className="w-3.5 h-3.5" />,
        dot: "bg-emerald-500",
        label: "Completed",
      },
      shortage: {
        class: "bg-red-50 text-red-700 border-red-200",
        icon: <AlertOctagon className="w-3.5 h-3.5" />,
        dot: "bg-red-500",
        label: "Shortage",
      },
      reupdated: {
        class: "bg-purple-50 text-purple-700 border-purple-200",
        icon: <RotateCcw className="w-3.5 h-3.5" />,
        dot: "bg-purple-500",
        label: "Re-updated",
      },
      reupdate_requested: {
        class: "bg-orange-50 text-orange-700 border-orange-200",
        icon: <AlertTriangle className="w-3.5 h-3.5" />,
        dot: "bg-orange-500",
        label: "Re-update Requested",
      },
      pending: {
        class: "bg-amber-50 text-amber-700 border-amber-200",
        icon: <Clock className="w-3.5 h-3.5" />,
        dot: "bg-amber-500",
        label: "Pending",
      },
    };
    return (
      configs[status] || {
        class: "bg-slate-50 text-slate-600 border-slate-200",
        icon: <Info className="w-3.5 h-3.5" />,
        dot: "bg-slate-400",
        label: (status || "unknown").replace(/_/g, " "),
      }
    );
  };

  const getStatusBadge = (status) => {
    const cfg = getStatusConfig(status);
    return (
      <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium border ${cfg.class}`}>
        {cfg.icon}
        <span className="capitalize">{cfg.label}</span>
      </span>
    );
  };

  const getProgressColor = (completed, total) => {
    const pct = total > 0 ? (completed / total) * 100 : 0;
    if (pct === 100) return "bg-emerald-500";
    if (pct >= 75) return "bg-blue-500";
    if (pct >= 50) return "bg-amber-500";
    if (pct >= 25) return "bg-orange-500";
    return "bg-red-500";
  };

  const getInitials = (name) => {
    if (!name) return "?";
    return name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2);
  };

  const getAvatarColor = (name) => {
    const colors = [
      "bg-blue-100 text-blue-700 border-blue-200",
      "bg-emerald-100 text-emerald-700 border-emerald-200",
      "bg-amber-100 text-amber-700 border-amber-200",
      "bg-rose-100 text-rose-700 border-rose-200",
      "bg-purple-100 text-purple-700 border-purple-200",
      "bg-cyan-100 text-cyan-700 border-cyan-200",
      "bg-indigo-100 text-indigo-700 border-indigo-200",
      "bg-teal-100 text-teal-700 border-teal-200",
    ];
    let hash = 0;
    for (let i = 0; i < (name || "").length; i++) {
      hash = name.charCodeAt(i) + ((hash << 5) - hash);
    }
    return colors[Math.abs(hash) % colors.length];
  };

  // ================= RENDER =================
  return (
    <div className="min-h-screen  font-sans">
      {/* ═══════════════════════════════════════
          WORKERS DASHBOARD
      ═══════════════════════════════════════ */}
      {!selectedWorker && (
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {/* ─── PAGE HEADER ─── */}
          <div className="mb-8">
            <div className="flex items-center gap-3 mb-2">
              <div className="p-2.5 bg-white rounded-xl border border-slate-200 shadow-sm">
                <Users className="w-6 h-6 text-slate-700" />
              </div>
              <div>
                <h1 className="text-2xl font-bold text-slate-900 tracking-tight">
                  Workers
                </h1>
                <p className="text-sm text-slate-500 mt-0.5">
                  Monitor warehouse staff assignments and picklist progress
                </p>
              </div>
            </div>
          </div>

          {/* ─── GLOBAL STATS ─── */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
            <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm hover:shadow-md transition-shadow">
              <div className="flex items-center justify-between mb-3">
                <div className="p-2 bg-slate-100 rounded-lg">
                  <Users className="w-5 h-5 text-slate-600" />
                </div>
                <span className="text-xs font-medium text-slate-400 uppercase tracking-wider">Total</span>
              </div>
              <p className="text-3xl font-bold text-slate-900">
                {loading ? <span className="inline-block w-8 h-8 bg-slate-100 rounded animate-pulse" /> : globalStats.totalWorkers}
              </p>
              <p className="text-xs text-slate-400 mt-1">Warehouse workers</p>
            </div>

            <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm hover:shadow-md transition-shadow">
              <div className="flex items-center justify-between mb-3">
                <div className="p-2 bg-blue-50 rounded-lg">
                  <Activity className="w-5 h-5 text-blue-600" />
                </div>
                <span className="text-xs font-medium text-blue-500 uppercase tracking-wider">Active</span>
              </div>
              <p className="text-3xl font-bold text-slate-900">
                {loading ? <span className="inline-block w-8 h-8 bg-slate-100 rounded animate-pulse" /> : globalStats.activeWorkers}
              </p>
              <p className="text-xs text-slate-400 mt-1">Currently working</p>
            </div>

            <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm hover:shadow-md transition-shadow">
              <div className="flex items-center justify-between mb-3">
                <div className="p-2 bg-emerald-50 rounded-lg">
                  <ClipboardList className="w-5 h-5 text-emerald-600" />
                </div>
                <span className="text-xs font-medium text-emerald-500 uppercase tracking-wider">Picklists</span>
              </div>
              <p className="text-3xl font-bold text-slate-900">
                {loading ? <span className="inline-block w-8 h-8 bg-slate-100 rounded animate-pulse" /> : globalStats.totalPicklists}
              </p>
              <p className="text-xs text-slate-400 mt-1">Total assigned</p>
            </div>

            <div className="bg-white rounded-2xl border border-slate-200 p-5 shadow-sm hover:shadow-md transition-shadow">
              <div className="flex items-center justify-between mb-3">
                <div className="p-2 bg-orange-50 rounded-lg">
                  <AlertTriangle className="w-5 h-5 text-orange-600" />
                </div>
                <span className="text-xs font-medium text-orange-500 uppercase tracking-wider">Re-updates</span>
              </div>
              <p className="text-3xl font-bold text-slate-900">
                {loading ? <span className="inline-block w-8 h-8 bg-slate-100 rounded animate-pulse" /> : globalStats.pendingReupdates}
              </p>
              <p className="text-xs text-slate-400 mt-1">Pending requests</p>
            </div>
          </div>

          {/* ─── TOOLBAR ─── */}
          <div className="flex flex-col sm:flex-row gap-3 mb-6">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
              <input
                type="text"
                placeholder="Search workers by name or email..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-slate-200 focus:border-slate-300 transition-all"
              />
              {searchQuery && (
                <button onClick={() => setSearchQuery("")} className="absolute right-3 top-1/2 -translate-y-1/2">
                  <X className="w-4 h-4 text-slate-400 hover:text-slate-600" />
                </button>
              )}
            </div>

            <div className="relative">
              <Filter className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
              <select
                value={filterStatus}
                onChange={(e) => setFilterStatus(e.target.value)}
                className="pl-10 pr-8 py-2.5 bg-white border border-slate-200 rounded-xl text-sm text-slate-700 focus:outline-none focus:ring-2 focus:ring-slate-200 focus:border-slate-300 transition-all appearance-none cursor-pointer min-w-[160px]"
              >
                <option value="all">All Status</option>
                <option value="processing">Processing</option>
                <option value="completed">Completed</option>
                <option value="shortage">Shortage</option>
                <option value="reupdated">Re-updated</option>
                <option value="reupdate_requested">Re-update Requested</option>
                <option value="pending">Pending</option>
              </select>
              <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 pointer-events-none" />
            </div>

            <div className="relative">
              <ArrowUpDown className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value)}
                className="pl-10 pr-8 py-2.5 bg-white border border-slate-200 rounded-xl text-sm text-slate-700 focus:outline-none focus:ring-2 focus:ring-slate-200 focus:border-slate-300 transition-all appearance-none cursor-pointer min-w-[180px]"
              >
                <option value="active-desc">Most Active First</option>
                <option value="active-asc">Least Active First</option>
                <option value="completion-desc">Highest Completion</option>
                <option value="completion-asc">Lowest Completion</option>
                <option value="name-asc">Name A-Z</option>
              </select>
              <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 pointer-events-none" />
            </div>
          </div>

          {/* ─── WORKER CARDS GRID ─── */}
          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
              {[1, 2, 3, 4, 5, 6].map((i) => (
                <div key={i} className="bg-white rounded-2xl border border-slate-200 p-5 h-56 animate-pulse">
                  <div className="flex items-center gap-3 mb-4">
                    <div className="w-12 h-12 bg-slate-100 rounded-full" />
                    <div className="flex-1">
                      <div className="h-4 bg-slate-100 rounded w-2/3 mb-2" />
                      <div className="h-3 bg-slate-100 rounded w-1/2" />
                    </div>
                  </div>
                  <div className="h-2 bg-slate-100 rounded w-full mb-4" />
                  <div className="grid grid-cols-3 gap-2">
                    <div className="h-8 bg-slate-100 rounded" />
                    <div className="h-8 bg-slate-100 rounded" />
                    <div className="h-8 bg-slate-100 rounded" />
                  </div>
                </div>
              ))}
            </div>
          ) : filteredWorkers.length === 0 ? (
            <div className="bg-white rounded-2xl border border-slate-200 p-16 text-center">
              <div className="w-16 h-16 bg-slate-50 rounded-2xl flex items-center justify-center mx-auto mb-4">
                <Inbox className="w-8 h-8 text-slate-300" />
              </div>
              <h3 className="text-lg font-semibold text-slate-900 mb-1">No workers found</h3>
              <p className="text-sm text-slate-400 max-w-sm mx-auto">
                {searchQuery || filterStatus !== "all"
                  ? "Try adjusting your filters or search query."
                  : "There are no workers with assigned picklists yet."}
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
              {filteredWorkers.map((worker) => {
                const stats = getWorkerStats(worker);
                const avatarColor = getAvatarColor(worker.name);
                const hasReupdates = stats.pendingReupdates > 0;

                return (
                  <div
                    key={worker._id}
                    onClick={() => setSelectedWorker(worker)}
                    className="group bg-white rounded-[20px] border border-slate-200 p-5 cursor-pointer hover:shadow-lg hover:border-slate-300 transition-all duration-200"
                  >
                    {/* Worker Header */}
                    <div className="flex items-center gap-3 mb-4">
                      <div className={`w-12 h-12 rounded-full flex items-center justify-center text-sm font-bold border-2 ${avatarColor}`}>
                        {getInitials(worker.name)}
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="font-semibold text-slate-900 truncate">{worker.name}</p>
                        <p className="text-xs text-slate-400 truncate flex items-center gap-1">
                          <Mail className="w-3 h-3" />
                          {worker.email}
                        </p>
                      </div>
                      {hasReupdates && (
                        <div className="p-1.5 bg-orange-50 rounded-lg">
                          <AlertTriangle className="w-4 h-4 text-orange-500" />
                        </div>
                      )}
                    </div>

                    {/* Completion Progress */}
                    <div className="mb-4">
                      <div className="flex items-center justify-between text-xs mb-1.5">
                        <span className="text-slate-500 font-medium">Overall Completion</span>
                        <span className="text-slate-700 font-semibold">{stats.completionPct}%</span>
                      </div>
                      <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
                        <div
                          className={`h-full rounded-full transition-all duration-500 ${getProgressColor(stats.completedParts, stats.totalParts)}`}
                          style={{ width: `${stats.completionPct}%` }}
                        />
                      </div>
                    </div>

                    {/* Stats Row */}
                    <div className="grid grid-cols-3 gap-2 pt-3 border-t border-slate-100">
                      <div className="text-center">
                        <p className="text-lg font-bold text-slate-900">{stats.totalPicklists}</p>
                        <p className="text-[10px] text-slate-400 uppercase tracking-wider font-medium">Picklists</p>
                      </div>
                      <div className="text-center">
                        <p className="text-lg font-bold text-blue-600">{stats.activePicklists}</p>
                        <p className="text-[10px] text-slate-400 uppercase tracking-wider font-medium">Active</p>
                      </div>
                      <div className="text-center">
                        <p className="text-lg font-bold text-emerald-600">{stats.completedPicklists}</p>
                        <p className="text-[10px] text-slate-400 uppercase tracking-wider font-medium">Done</p>
                      </div>
                    </div>

                    {/* Parts Summary */}
                    <div className="flex items-center justify-between mt-3 pt-3 border-t border-slate-100">
                      <div className="flex items-center gap-1.5">
                        <Box className="w-3.5 h-3.5 text-slate-400" />
                        <span className="text-xs text-slate-500">{stats.totalParts} parts</span>
                      </div>
                      <div className="flex items-center gap-1.5">
                        <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500" />
                        <span className="text-xs text-slate-500">{stats.completedParts} done</span>
                      </div>
                      <div className="flex items-center gap-1.5">
                        <ArrowUpRight className="w-3.5 h-3.5 text-slate-400 group-hover:text-slate-600 transition-colors" />
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      )}

      {/* ═══════════════════════════════════════
          WORKER DETAIL VIEW
      ═══════════════════════════════════════ */}
      {selectedWorker && !selectedPicklist && (
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {/* Back */}
          <button
            onClick={goBackToWorkers}
            className="group inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-900 transition-colors mb-6"
          >
            <ArrowLeft className="w-4 h-4 transition-transform group-hover:-translate-x-0.5" />
            Back to Workers
          </button>

          {/* Worker Profile Card */}
          <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 md:p-8 mb-6">
            <div className="flex flex-col sm:flex-row sm:items-center gap-4">
              <div className={`w-16 h-16 rounded-2xl flex items-center justify-center text-xl font-bold border-2 ${getAvatarColor(selectedWorker.name)}`}>
                {getInitials(selectedWorker.name)}
              </div>
              <div className="flex-1">
                <h1 className="text-2xl font-bold text-slate-900 tracking-tight">{selectedWorker.name}</h1>
                <div className="flex flex-wrap items-center gap-3 mt-1 text-sm text-slate-500">
                  <span className="inline-flex items-center gap-1">
                    <Mail className="w-3.5 h-3.5" />
                    {selectedWorker.email}
                  </span>
                  <span className="inline-flex items-center gap-1">
                    <Briefcase className="w-3.5 h-3.5" />
                    {selectedWorker.role}
                  </span>
                </div>
              </div>
              <div className="flex items-center gap-2">
                {getWorkerStats(selectedWorker).pendingReupdates > 0 && (
                  <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium bg-orange-50 text-orange-700 border border-orange-200">
                    <AlertTriangle className="w-3.5 h-3.5" />
                    {getWorkerStats(selectedWorker).pendingReupdates} re-update{getWorkerStats(selectedWorker).pendingReupdates > 1 ? "s" : ""}
                  </span>
                )}
              </div>
            </div>
          </div>

          {/* Worker Stats */}
          {(() => {
            const stats = getWorkerStats(selectedWorker);
            return (
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-6">
                <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-5 text-center">
                  <p className="text-2xl font-bold text-slate-900">{stats.totalPicklists}</p>
                  <p className="text-xs font-medium text-slate-500 mt-1 uppercase tracking-wider">Total Picklists</p>
                </div>
                <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-5 text-center">
                  <p className="text-2xl font-bold text-blue-600">{stats.activePicklists}</p>
                  <p className="text-xs font-medium text-slate-500 mt-1 uppercase tracking-wider">Active</p>
                </div>
                <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-5 text-center">
                  <p className="text-2xl font-bold text-emerald-600">{stats.completedPicklists}</p>
                  <p className="text-xs font-medium text-slate-500 mt-1 uppercase tracking-wider">Completed</p>
                </div>
                <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-5 text-center">
                  <p className="text-2xl font-bold text-slate-900">{stats.completionPct}%</p>
                  <p className="text-xs font-medium text-slate-500 mt-1 uppercase tracking-wider">Completion</p>
                </div>
              </div>
            );
          })()}

          {/* Assigned Picklists */}
          <div className="space-y-4">
            <h3 className="text-sm font-semibold text-slate-500 uppercase tracking-wider px-1">
              Assigned Picklists
            </h3>

            {selectedWorker.picklists.length === 0 ? (
              <div className="bg-white rounded-2xl border border-slate-200 p-12 text-center">
                <div className="w-16 h-16 bg-slate-50 rounded-2xl flex items-center justify-center mx-auto mb-4">
                  <ClipboardList className="w-8 h-8 text-slate-300" />
                </div>
                <p className="text-sm text-slate-400 font-medium">No picklists assigned</p>
              </div>
            ) : (
              selectedWorker.picklists.map((picklist) => {
                const totalParts = picklist.parts?.length || 0;
                const completedParts = picklist.parts?.filter((p) => p.status === "completed").length || 0;
                const pendingParts = totalParts - completedParts;
                const progressPct = totalParts > 0 ? Math.round((completedParts / totalParts) * 100) : 0;
                const statusCfg = getStatusConfig(picklist.status);
                const hasReupdate = picklist.status === "reupdate_requested" || picklist.reupdate_status;

                return (
                  <div
                    key={picklist._id || picklist.pick_list_no}
                    onClick={() => {
                      setPicklistData(picklist);
                      setSelectedPicklist(picklist.pick_list_no);
                    }}
                    className="group bg-white rounded-2xl border border-slate-200 p-5 cursor-pointer hover:shadow-lg hover:border-slate-300 transition-all duration-200"
                  >
                    <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                      <div className="flex items-center gap-3">
                        <div className="p-2.5 bg-slate-50 rounded-xl group-hover:bg-blue-50 transition-colors">
                          <ClipboardList className="w-5 h-5 text-slate-500 group-hover:text-blue-600 transition-colors" />
                        </div>
                        <div>
                          <div className="flex items-center gap-2 flex-wrap">
                            <p className="font-semibold text-slate-900 font-mono text-sm">
                              {picklist.pick_list_no}
                            </p>
                            {hasReupdate && (
                              <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-medium bg-orange-50 text-orange-700 border border-orange-200">
                                <AlertTriangle className="w-3 h-3" />
                                Re-update
                              </span>
                            )}
                          </div>
                          <p className="text-xs text-slate-400 mt-0.5">
                            {picklist.order_number ? `Order ${picklist.order_number}` : "No order"}
                            {picklist.created_at && ` • ${formatDateShort(picklist.created_at)}`}
                          </p>
                        </div>
                      </div>

                      <div className="flex items-center gap-3">
                        {getStatusBadge(picklist.status)}
                        <ChevronRight className="w-5 h-5 text-slate-300 group-hover:text-slate-500 transition-colors" />
                      </div>
                    </div>

                    {/* Progress */}
                    <div className="mt-4">
                      <div className="flex items-center justify-between text-xs mb-1.5">
                        <span className="text-slate-500 font-medium">
                          {completedParts} / {totalParts} parts completed
                        </span>
                        <span className="text-slate-700 font-semibold">{progressPct}%</span>
                      </div>
                      <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
                        <div
                          className={`h-full rounded-full transition-all duration-500 ${getProgressColor(completedParts, totalParts)}`}
                          style={{ width: `${progressPct}%` }}
                        />
                      </div>
                    </div>

                    {/* Parts Summary */}
                    <div className="flex items-center gap-4 mt-3 pt-3 border-t border-slate-100">
                      <div className="flex items-center gap-1.5">
                        <Box className="w-3.5 h-3.5 text-slate-400" />
                        <span className="text-xs text-slate-500">{totalParts} total</span>
                      </div>
                      <div className="flex items-center gap-1.5">
                        <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500" />
                        <span className="text-xs text-slate-500">{completedParts} done</span>
                      </div>
                      <div className="flex items-center gap-1.5">
                        <Clock className="w-3.5 h-3.5 text-amber-500" />
                        <span className="text-xs text-slate-500">{pendingParts} pending</span>
                      </div>
                    </div>
                  </div>
                );
              })
            )}
          </div>
        </div>
      )}

      {/* ═══════════════════════════════════════
          PICKLIST DETAIL VIEW
      ═══════════════════════════════════════ */}
      {selectedPicklist && (
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {/* Breadcrumb */}
          <div className="flex items-center gap-2 mb-6">
            <button
              onClick={goBackToWorkers}
              className="text-sm font-medium text-slate-500 hover:text-slate-900 transition-colors"
            >
              Workers
            </button>
            <ChevronRight className="w-4 h-4 text-slate-300" />
            <button
              onClick={goBackToWorkerDetail}
              className="text-sm font-medium text-slate-500 hover:text-slate-900 transition-colors"
            >
              {selectedWorker?.name}
            </button>
            <ChevronRight className="w-4 h-4 text-slate-300" />
            <span className="text-sm font-semibold text-slate-900">{selectedPicklist}</span>
          </div>

          {/* Loading */}
          {picklistLoading && (
            <div className="space-y-4 animate-pulse">
              <div className="h-32 bg-white rounded-2xl border border-slate-200" />
              <div className="h-20 bg-white rounded-2xl border border-slate-200" />
              <div className="h-64 bg-white rounded-2xl border border-slate-200" />
            </div>
          )}

          {/* Not Found */}
          {!picklistLoading && !picklistData && (
            <div className="bg-white rounded-2xl border border-slate-200 p-16 text-center">
              <div className="w-16 h-16 bg-slate-50 rounded-2xl flex items-center justify-center mx-auto mb-4">
                <Search className="w-8 h-8 text-slate-300" />
              </div>
              <h3 className="text-lg font-semibold text-slate-900 mb-1">Picklist not found</h3>
              <p className="text-sm text-slate-400">The requested picklist could not be loaded.</p>
            </div>
          )}

          {/* Detail Content */}
          {!picklistLoading && picklistData && (
            <div className="space-y-6">
              {/* Header Card */}
              <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 md:p-8">
                <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                  <div className="space-y-3">
                    <div className="flex items-center gap-3 flex-wrap">
                      <div className="p-2.5 bg-slate-50 rounded-xl">
                        <ClipboardList className="w-6 h-6 text-slate-700" />
                      </div>
                      <div>
                        <h1 className="text-2xl font-bold text-slate-900 tracking-tight font-mono">
                          {picklistData.pick_list_no}
                        </h1>
                        <div className="flex items-center gap-3 mt-1 text-sm text-slate-500">
                          {picklistData.order_number && (
                            <span className="inline-flex items-center gap-1">
                              <Hash className="w-3.5 h-3.5" />
                              Order {picklistData.order_number}
                            </span>
                          )}
                          {picklistData.created_at && (
                            <span className="inline-flex items-center gap-1">
                              <Calendar className="w-3.5 h-3.5" />
                              {formatDateShort(picklistData.created_at)}
                            </span>
                          )}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-2 flex-wrap">
                      {getStatusBadge(picklistData.status)}
                      {picklistData.workers?.length > 0 && (
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-slate-50 text-slate-600 border border-slate-200">
                          <User className="w-3 h-3" />
                          {picklistData.workers.map((w) => w.name).join(", ")}
                        </span>
                      )}
                    </div>
                  </div>

                  <button
                    onClick={() => setShowReupdate(!showReupdate)}
                    className={`inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-semibold transition-all duration-200 ${
                      showReupdate
                        ? "bg-slate-100 text-slate-700 hover:bg-slate-200"
                        : "bg-slate-900 text-white hover:bg-slate-800 shadow-sm active:scale-[0.98]"
                    }`}
                  >
                    {showReupdate ? (
                      <><X className="w-4 h-4" /> Close</>
                    ) : (
                      <><RefreshCw className="w-4 h-4" /> Re-update / Reassign</>
                    )}
                  </button>
                </div>
              </div>

              {/* Re-update Alert */}
              {(picklistData.status === "reupdate_requested" || picklistData.reupdate_status) && (
                <div className="bg-amber-50 border border-amber-200 rounded-2xl p-5">
                  <div className="flex items-start gap-3">
                    <div className="p-2 bg-amber-100 rounded-lg shrink-0">
                      <AlertTriangle className="w-5 h-5 text-amber-700" />
                    </div>
                    <div className="space-y-1">
                      <h3 className="font-semibold text-amber-900">Re-update Requested</h3>
                      {picklistData.reupdate_note && (
                        <p className="text-sm text-amber-800 leading-relaxed">
                          <span className="font-medium">Note:</span> {picklistData.reupdate_note}
                        </p>
                      )}
                      {picklistData.reupdate_requested_at && (
                        <p className="text-xs text-amber-700/80 flex items-center gap-1.5">
                          <Clock className="w-3.5 h-3.5" />
                          Requested {formatDate(picklistData.reupdate_requested_at)}
                        </p>
                      )}
                    </div>
                  </div>
                </div>
              )}

              {/* Stats Cards */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 text-center">
                  <p className="text-3xl font-bold text-slate-900">{parts.length}</p>
                  <p className="text-xs font-medium text-slate-500 mt-1 uppercase tracking-wider">Total Parts</p>
                </div>
                <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 text-center">
                  <p className="text-3xl font-bold text-emerald-600">
                    {parts.filter((p) => p.status === "completed").length}
                  </p>
                  <p className="text-xs font-medium text-slate-500 mt-1 uppercase tracking-wider">Completed</p>
                </div>
                <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 text-center">
                  <p className="text-3xl font-bold text-amber-600">
                    {parts.filter((p) => p.status !== "completed").length}
                  </p>
                  <p className="text-xs font-medium text-slate-500 mt-1 uppercase tracking-wider">Pending</p>
                </div>
              </div>

              {/* Re-update Panel */}
              {showReupdate && (
                <div className="bg-white rounded-2xl border border-slate-200 shadow-lg p-6 space-y-5">
                  <div className="flex items-center justify-between">
                    <h3 className="font-semibold text-slate-900 flex items-center gap-2">
                      <RefreshCw className="w-4 h-4 text-slate-700" />
                      Re-update Parts
                    </h3>
                    {someSelected && (
                      <span className="px-2.5 py-1 bg-slate-100 text-slate-700 rounded-full text-xs font-semibold border border-slate-200">
                        {selectedParts.length} selected
                      </span>
                    )}
                  </div>

                  <label className="flex items-center gap-3 p-3 bg-slate-50 rounded-xl border border-slate-100 cursor-pointer hover:bg-slate-100 transition-colors">
                    <input
                      type="checkbox"
                      checked={allSelectableSelected}
                      onChange={handleSelectAll}
                      className="w-4 h-4 rounded border-slate-300 text-slate-900 focus:ring-slate-500/20 cursor-pointer"
                    />
                    <span className="text-sm font-medium text-slate-700">Select All Parts</span>
                  </label>

                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 max-h-60 overflow-y-auto p-1">
                    {parts.map((p) => {
                      const isSelected = selectedParts.includes(p.partno);
                      const isCompleted = p.status === "completed";
                      return (
                        <label
                          key={p.partno}
                          className={`flex items-center gap-3 p-3 rounded-xl border cursor-pointer transition-all duration-150 ${
                            isCompleted
                              ? "bg-slate-50/50 border-slate-100 opacity-60 cursor-not-allowed"
                              : isSelected
                              ? "bg-blue-50/60 border-blue-200 shadow-sm"
                              : "bg-white border-slate-200 hover:border-slate-300 hover:shadow-sm"
                          }`}
                        >
                          <input
                            type="checkbox"
                            checked={isSelected}
                            disabled={isCompleted}
                            onChange={() => togglePart(p.partno, p.status)}
                            className={`w-4 h-4 rounded border-slate-300 text-slate-900 focus:ring-slate-500/20 shrink-0 ${
                              isCompleted ? "cursor-not-allowed" : "cursor-pointer"
                            }`}
                          />
                          <div className="min-w-0">
                            <p className="text-sm font-semibold text-slate-900 font-mono truncate">{p.partno}</p>
                            <p className="text-xs text-slate-500 capitalize">{p.status?.replace(/_/g, " ")}</p>
                          </div>
                          {isCompleted && <CheckCircle2 className="w-4 h-4 text-emerald-500 ml-auto shrink-0" />}
                        </label>
                      );
                    })}
                  </div>

                  <div className="space-y-2">
                    <label className="text-sm font-medium text-slate-700">Re-update Note</label>
                    <input
                      type="text"
                      placeholder="Enter reason for re-update..."
                      value={note}
                      onChange={(e) => setNote(e.target.value)}
                      className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-sm text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-slate-200 focus:border-slate-300 transition-all"
                    />
                    <p className="text-xs text-slate-400 flex items-center gap-1">
                      <Info className="w-3 h-3" />
                      Optional note for warehouse staff
                    </p>
                  </div>

                  <div className="flex gap-3 pt-2">
                    <button
                      onClick={() => { setShowReupdate(false); setSelectedParts([]); setNote(""); }}
                      className="flex-1 px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-semibold text-slate-700 hover:bg-slate-50 transition-colors"
                    >
                      Cancel
                    </button>
                    <button
                      onClick={handleReupdateClick}
                      disabled={!someSelected || updating}
                      className={`flex-1 px-4 py-2.5 rounded-xl text-sm font-semibold transition-all duration-200 inline-flex items-center justify-center gap-2 ${
                        someSelected && !updating
                          ? "bg-slate-900 text-white hover:bg-slate-800 shadow-sm active:scale-[0.98]"
                          : "bg-slate-100 text-slate-400 cursor-not-allowed"
                      }`}
                    >
                      {updating && <Loader2 className="w-4 h-4 animate-spin" />}
                      Submit Re-update
                    </button>
                  </div>
                </div>
              )}

              {/* Parts Table */}
              <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
                <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between">
                  <h2 className="text-base font-semibold text-slate-900 flex items-center gap-2">
                    <Package className="w-4 h-4 text-slate-400" />
                    Parts
                    <span className="px-2 py-0.5 bg-slate-100 text-slate-600 rounded-md text-xs font-medium">
                      {parts.length}
                    </span>
                  </h2>
                </div>

                {parts.length === 0 ? (
                  <div className="p-12 text-center">
                    <div className="w-16 h-16 bg-slate-50 rounded-2xl flex items-center justify-center mx-auto mb-4">
                      <Package className="w-8 h-8 text-slate-300" />
                    </div>
                    <p className="text-sm text-slate-400 font-medium">No parts available</p>
                  </div>
                ) : (
                  <div className="overflow-x-auto">
                    <table className="w-full text-sm text-left">
                      <thead className="bg-slate-50/80 text-slate-500 font-medium border-b border-slate-100">
                        <tr>
                          {showReupdate && (
                            <th className="px-6 py-4 w-12">
                              <input
                                type="checkbox"
                                checked={allSelectableSelected}
                                onChange={handleSelectAll}
                                className="w-4 h-4 rounded border-slate-300 text-slate-900 focus:ring-slate-500/20 cursor-pointer"
                              />
                            </th>
                          )}
                          <th className="px-6 py-4">Part No</th>
                          <th className="px-6 py-4 hidden md:table-cell">Description</th>
                          <th className="px-6 py-4 text-right">Req Qty</th>
                          <th className="px-6 py-4 text-right">Allo Qty</th>
                          <th className="px-6 py-4">Status</th>
                          <th className="px-6 py-4 hidden lg:table-cell">Scanned By</th>
                          <th className="px-6 py-4 text-right hidden lg:table-cell">Scans</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-100">
                        {parts.map((p, idx) => {
                          const isSelected = selectedParts.includes(p.partno);
                          const isCompleted = p.status === "completed";
                          const isReupdate = p.status?.includes("reupdate");
                          const scanInfo = picklistData.scansByWorker?.find((s) => s.partno === p.partno);
                          const scannedBy = scanInfo?.worker || "—";
                          const scanCount = scanInfo?.scanCount || 0;

                          return (
                            <tr
                              key={idx}
                              className={`group transition-colors duration-150 ${
                                isSelected ? "bg-blue-50/40" : isReupdate ? "bg-amber-50/30" : "hover:bg-slate-50/60"
                              }`}
                            >
                              {showReupdate && (
                                <td className="px-6 py-4">
                                  <input
                                    type="checkbox"
                                    checked={isSelected}
                                    disabled={isCompleted}
                                    onChange={() => togglePart(p.partno, p.status)}
                                    className={`w-4 h-4 rounded border-slate-300 text-slate-900 focus:ring-slate-500/20 ${
                                      isCompleted ? "opacity-40 cursor-not-allowed" : "cursor-pointer"
                                    }`}
                                  />
                                </td>
                              )}
                              <td className="px-6 py-4">
                                <span className="font-semibold text-slate-900 font-mono text-xs bg-slate-100 px-2 py-1 rounded-md">
                                  {p.partno}
                                </span>
                              </td>
                              <td className="px-6 py-4 text-slate-600 hidden md:table-cell max-w-xs truncate">
                                {p.description || "—"}
                              </td>
                              <td className="px-6 py-4 text-right font-medium text-slate-900">{p.req_qty}</td>
                              <td className="px-6 py-4 text-right font-medium text-slate-900">{p.allo_qty}</td>
                              <td className="px-6 py-4">{getStatusBadge(p.status)}</td>
                              <td className="px-6 py-4 hidden lg:table-cell">
                                <span className="text-xs text-slate-500">{scannedBy}</span>
                              </td>
                              <td className="px-6 py-4 text-right hidden lg:table-cell">
                                <span className="inline-flex items-center gap-1 text-xs font-medium text-slate-600 bg-slate-50 px-2 py-0.5 rounded-md">
                                  <ScanLine className="w-3 h-3" />
                                  {scanCount}
                                </span>
                              </td>
                            </tr>
                          );
                        })}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      )}

      {/* ═══════════════════════════════════════
          CONFIRMATION MODAL
      ═══════════════════════════════════════ */}
      {showConfirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-black/30 backdrop-blur-sm transition-opacity" onClick={() => setShowConfirm(false)} />
          <div className="relative bg-white rounded-2xl shadow-xl border border-slate-200 w-full max-w-md p-6 space-y-5">
            <div className="flex items-start gap-4">
              <div className="p-3 bg-amber-50 rounded-xl shrink-0">
                <AlertTriangle className="w-6 h-6 text-amber-600" />
              </div>
              <div className="space-y-1">
                <h3 className="text-lg font-semibold text-slate-900">Confirm Re-update</h3>
                <p className="text-sm text-slate-500 leading-relaxed">
                  You are about to request a re-update for{" "}
                  <span className="font-semibold text-slate-900">{selectedParts.length}</span>{" "}
                  selected {selectedParts.length === 1 ? "part" : "parts"}.
                </p>
                {note && (
                  <div className="mt-3 p-3 bg-slate-50 rounded-xl border border-slate-100">
                    <p className="text-xs font-medium text-slate-500 mb-1">Note:</p>
                    <p className="text-sm text-slate-700">{note}</p>
                  </div>
                )}
              </div>
            </div>
            <div className="flex gap-3">
              <button
                onClick={() => setShowConfirm(false)}
                className="flex-1 px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-semibold text-slate-700 hover:bg-slate-50 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleConfirmReupdate}
                disabled={updating}
                className="flex-1 px-4 py-2.5 bg-slate-900 text-white rounded-xl text-sm font-semibold hover:bg-slate-800 transition-colors disabled:opacity-70 inline-flex items-center justify-center gap-2"
              >
                {updating && <Loader2 className="w-4 h-4 animate-spin" />}
                Confirm Re-update
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
