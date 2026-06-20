import { useEffect, useState, useMemo, useRef } from "react";
import {
  Users,
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
  Inbox
} from "lucide-react";

export default function Workers() {
  // ================= STATE =================
  const [workers, setWorkers] = useState([]);
  const [workersLoading, setWorkersLoading] = useState(true);

  const [selectedWorker, setSelectedWorker] = useState(null);
  const [selectedPicklistId, setSelectedPicklistId] = useState(null);
  const [picklistData, setPicklistData] = useState(null);
  const [picklistLoading, setPicklistLoading] = useState(false);

  const [showReupdate, setShowReupdate] = useState(false);
  const [selectedParts, setSelectedParts] = useState([]);
  const [note, setNote] = useState("");
  const [updating, setUpdating] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);

  const token = localStorage.getItem("token");
  const selectAllRef = useRef(null);

  // ================= FETCH WORKERS =================
  const fetchWorkers = async () => {
    try {
      setWorkersLoading(true);
      const res = await fetch("https://pick-list.onrender.com/api/workers", {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();
      setWorkers(data.workers || data || []);
    } catch (err) {
      console.error("Failed to fetch workers:", err);
    } finally {
      setWorkersLoading(false);
    }
  };

  useEffect(() => {
    fetchWorkers();
  }, []);

  // ================= FETCH PICKLIST =================
  const fetchPicklist = async (pickListNo) => {
    try {
      setPicklistLoading(true);
      const res = await fetch("https://pick-list.onrender.com/api/picklist", {
        headers: { Authorization: `Bearer ${token}` },
      });

      const response = await res.json();
      const all = response.picklists || response || [];

      const found = all.find(
        (p) =>
          p.pick_list_no?.toLowerCase()?.trim() ===
            pickListNo?.toLowerCase()?.trim() ||
          p._id === pickListNo
      );

      setSelectedPicklistId(pickListNo);
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
    setSelectedPicklistId(null);
    setPicklistData(null);
    setShowReupdate(false);
  };

  const goBackToPicklists = () => {
    setSelectedPicklistId(null);
    setPicklistData(null);
    setShowReupdate(false);
  };

  // ================= SELECTION LOGIC =================
  const parts = picklistData?.parts || [];
  
  const selectableParts = useMemo(
    () => parts.filter((p) => p.status !== "completed"),
    [parts]
  );

  const allSelectableSelected = useMemo(
    () => selectableParts.length > 0 && selectableParts.every((p) => selectedParts.includes(p.partno)),
    [selectableParts, selectedParts]
  );

  const someSelected = selectedParts.length > 0;

  useEffect(() => {
    if (selectAllRef.current) {
      selectAllRef.current.indeterminate = someSelected && !allSelectableSelected;
    }
  }, [someSelected, allSelectableSelected]);

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
      prev.includes(partno)
        ? prev.filter((p) => p !== partno)
        : [...prev, partno]
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
        `https://pick-list.onrender.com/api/picklist/${picklistData._id}/reupdate`,
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
      month: "short",
      day: "numeric",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const getStatusBadge = (status) => {
    const config = {
      completed: {
        class: "bg-emerald-50 text-emerald-700 border-emerald-200",
        icon: <CheckCircle2 className="w-3.5 h-3.5" />,
      },
      pending: {
        class: "bg-amber-50 text-amber-700 border-amber-200",
        icon: <Clock className="w-3.5 h-3.5" />,
      },
      reupdate_pending: {
        class: "bg-rose-50 text-rose-700 border-rose-200",
        icon: <AlertTriangle className="w-3.5 h-3.5" />,
      },
      reupdate_requested: {
        class: "bg-rose-50 text-rose-700 border-rose-200",
        icon: <AlertTriangle className="w-3.5 h-3.5" />,
      },
    };

    const cfg = config[status] || {
      class: "bg-gray-50 text-gray-600 border-gray-200",
      icon: <Info className="w-3.5 h-3.5" />,
    };

    return (
      <span
        className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium border ${cfg.class}`}
      >
        {cfg.icon}
        <span className="capitalize">{(status || "unknown").replace(/_/g, " ")}</span>
      </span>
    );
  };

  // ================= COUNTS =================
  const completedCount = parts.filter((p) => p.status === "completed").length;
  const pendingCount = parts.filter((p) => p.status !== "completed").length;

  // ================= RENDER =================
  return (
    <div className="min-h-screen bg-gray-50/50 p-4 md:p-8 font-sans">
      <div className="max-w-5xl mx-auto space-y-6">

        {/* ═══════════════════════════════════════
            STEP 1: WORKER LIST
        ═══════════════════════════════════════ */}
        {!selectedWorker && (
          <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center gap-3">
              <div className="p-2.5 bg-blue-50 rounded-xl">
                <Users className="w-6 h-6 text-blue-600" />
              </div>
              <div>
                <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Workers</h1>
                <p className="text-sm text-gray-500">Manage warehouse staff and assignments</p>
              </div>
            </div>

            {/* Workers Grid */}
            {workersLoading ? (
              <div className="space-y-3">
                {[1, 2, 3].map((i) => (
                  <div key={i} className="h-20 bg-white rounded-2xl border border-gray-100 animate-pulse" />
                ))}
              </div>
            ) : workers.length === 0 ? (
              <div className="bg-white rounded-2xl border border-gray-100 p-12 text-center">
                <Inbox className="w-10 h-10 text-gray-300 mx-auto mb-3" />
                <p className="text-sm text-gray-400 font-medium">No workers found</p>
              </div>
            ) : (
              <div className="space-y-3">
                {workers.map((w) => (
                  <div
                    key={w._id}
                    onClick={() => setSelectedWorker(w)}
                    className="group bg-white rounded-2xl border border-gray-100 p-5 cursor-pointer hover:shadow-md hover:border-gray-200 transition-all duration-200 flex items-center justify-between"
                  >
                    <div className="flex items-center gap-4">
                      <div className="w-10 h-10 rounded-full bg-gradient-to-br from-blue-100 to-blue-50 flex items-center justify-center text-blue-600 font-semibold text-sm border border-blue-100">
                        {w.email?.charAt(0).toUpperCase() || "?"}
                      </div>
                      <div>
                        <p className="font-semibold text-gray-900">{w.email}</p>
                        <p className="text-xs text-gray-500 capitalize mt-0.5">{w.role}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-3">
                      <div className="text-right">
                        <p className="text-lg font-bold text-gray-900">{w.involvedPicklists || 0}</p>
                        <p className="text-xs text-gray-400">picklists</p>
                      </div>
                      <ChevronRight className="w-5 h-5 text-gray-300 group-hover:text-gray-500 transition-colors" />
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* ═══════════════════════════════════════
            STEP 2: PICKLIST LIST
        ═══════════════════════════════════════ */}
        {selectedWorker && !selectedPicklistId && (
          <div className="space-y-6">
            {/* Back + Worker Info */}
            <button
              onClick={goBackToWorkers}
              className="group inline-flex items-center gap-2 text-sm font-medium text-gray-500 hover:text-gray-900 transition-colors"
            >
              <ArrowLeft className="w-4 h-4 transition-transform group-hover:-translate-x-0.5" />
              Back to Workers
            </button>

            <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 flex items-center gap-4">
              <div className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-100 to-blue-50 flex items-center justify-center text-blue-600 font-bold text-lg border border-blue-100">
                {selectedWorker.email?.charAt(0).toUpperCase()}
              </div>
              <div>
                <h2 className="text-lg font-bold text-gray-900">{selectedWorker.email}</h2>
                <p className="text-sm text-gray-500 capitalize">{selectedWorker.role} • {selectedWorker.involvedPicklists || 0} picklists</p>
              </div>
            </div>

            {/* Picklists */}
            <div className="space-y-3">
              <h3 className="text-sm font-semibold text-gray-500 uppercase tracking-wider px-1">Assigned Picklists</h3>
              
              {!selectedWorker.pickListNumbers || selectedWorker.pickListNumbers.length === 0 ? (
                <div className="bg-white rounded-2xl border border-gray-100 p-12 text-center">
                  <ClipboardList className="w-10 h-10 text-gray-300 mx-auto mb-3" />
                  <p className="text-sm text-gray-400 font-medium">No picklists assigned</p>
                </div>
              ) : (
                selectedWorker.pickListNumbers.map((pl, i) => (
                  <div
                    key={i}
                    onClick={() => fetchPicklist(pl)}
                    className="group bg-white rounded-2xl border border-gray-100 p-5 cursor-pointer hover:shadow-md hover:border-gray-200 transition-all duration-200 flex items-center justify-between"
                  >
                    <div className="flex items-center gap-4">
                      <div className="p-2.5 bg-gray-50 rounded-xl group-hover:bg-blue-50 transition-colors">
                        <Package className="w-5 h-5 text-gray-400 group-hover:text-blue-600 transition-colors" />
                      </div>
                      <div>
                        <p className="font-semibold text-gray-900 font-mono text-sm">{pl}</p>
                        <p className="text-xs text-gray-400 mt-0.5">Tap to view details</p>
                      </div>
                    </div>
                    <ChevronRight className="w-5 h-5 text-gray-300 group-hover:text-gray-500 transition-colors" />
                  </div>
                ))
              )}
            </div>
          </div>
        )}

        {/* ═══════════════════════════════════════
            STEP 3: PICKLIST DETAIL
        ═══════════════════════════════════════ */}
        {selectedPicklistId && (
          <div className="space-y-6">
            {/* Back */}
            <button
              onClick={goBackToPicklists}
              className="group inline-flex items-center gap-2 text-sm font-medium text-gray-500 hover:text-gray-900 transition-colors"
            >
              <ArrowLeft className="w-4 h-4 transition-transform group-hover:-translate-x-0.5" />
              Back to Picklists
            </button>

            {/* Loading */}
            {picklistLoading && (
              <div className="space-y-4 animate-pulse">
                <div className="h-32 bg-white rounded-2xl border border-gray-100" />
                <div className="h-20 bg-white rounded-2xl border border-gray-100" />
                <div className="h-64 bg-white rounded-2xl border border-gray-100" />
              </div>
            )}

            {/* Not Found */}
            {!picklistLoading && !picklistData && (
              <div className="bg-white rounded-2xl border border-gray-100 p-12 text-center">
                <Search className="w-10 h-10 text-gray-300 mx-auto mb-3" />
                <h3 className="text-lg font-semibold text-gray-900 mb-1">Picklist not found</h3>
                <p className="text-sm text-gray-500">The requested picklist could not be loaded.</p>
              </div>
            )}

            {/* Detail Content */}
            {!picklistLoading && picklistData && (
              <>
                {/* ─── HEADER CARD ─── */}
                <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 md:p-8">
                  <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                    <div className="space-y-3">
                      <div className="flex items-center gap-3 flex-wrap">
                        <div className="p-2.5 bg-blue-50 rounded-xl">
                          <ClipboardList className="w-6 h-6 text-blue-600" />
                        </div>
                        <div>
                          <h1 className="text-2xl font-bold text-gray-900 tracking-tight font-mono">
                            {picklistData.pick_list_no}
                          </h1>
                          <div className="flex items-center gap-3 mt-1 text-sm text-gray-500">
                            {picklistData.order_no && (
                              <span className="inline-flex items-center gap-1">
                                <Hash className="w-3.5 h-3.5" />
                                Order {picklistData.order_no}
                              </span>
                            )}
                            {picklistData.created_at && (
                              <span className="inline-flex items-center gap-1">
                                <Clock className="w-3.5 h-3.5" />
                                {formatDate(picklistData.created_at)}
                              </span>
                            )}
                          </div>
                        </div>
                      </div>
                      <div className="flex items-center gap-2">
                        {getStatusBadge(picklistData.status)}
                        {picklistData.assigned_to && (
                          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-gray-50 text-gray-600 border border-gray-200">
                            <User className="w-3 h-3" />
                            {picklistData.assigned_to}
                          </span>
                        )}
                      </div>
                    </div>

                    <button
                      onClick={() => setShowReupdate(!showReupdate)}
                      className={`inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-semibold transition-all duration-200 ${
                        showReupdate
                          ? "bg-gray-100 text-gray-700 hover:bg-gray-200"
                          : "bg-rose-600 text-white hover:bg-rose-700 shadow-sm hover:shadow-md active:scale-[0.98]"
                      }`}
                    >
                      {showReupdate ? (
                        <>
                          <X className="w-4 h-4" />
                          Close
                        </>
                      ) : (
                        <>
                          <RefreshCw className="w-4 h-4" />
                          Re-update / Reassign
                        </>
                      )}
                    </button>
                  </div>
                </div>

                {/* ─── RE-UPDATE ALERT ─── */}
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

                {/* ─── STATS CARDS ─── */}
                <div className="grid grid-cols-2 gap-4">
                  <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 text-center">
                    <p className="text-3xl font-bold text-emerald-600">{completedCount}</p>
                    <p className="text-xs font-medium text-gray-500 mt-1 uppercase tracking-wider">Completed</p>
                  </div>
                  <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 text-center">
                    <p className="text-3xl font-bold text-amber-600">{pendingCount}</p>
                    <p className="text-xs font-medium text-gray-500 mt-1 uppercase tracking-wider">Pending</p>
                  </div>
                </div>

                {/* ─── RE-UPDATE PANEL ─── */}
                {showReupdate && (
                  <div className="bg-white rounded-2xl border border-gray-100 shadow-lg p-6 space-y-5 animate-in slide-in-from-top-2 duration-200">
                    <div className="flex items-center justify-between">
                      <h3 className="font-semibold text-gray-900 flex items-center gap-2">
                        <RefreshCw className="w-4 h-4 text-rose-500" />
                        Re-update Parts
                      </h3>
                      {someSelected && (
                        <span className="px-2.5 py-1 bg-rose-50 text-rose-700 rounded-full text-xs font-semibold border border-rose-100">
                          {selectedParts.length} selected
                        </span>
                      )}
                    </div>

                    {/* Select All */}
                    <label className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl border border-gray-100 cursor-pointer hover:bg-gray-100 transition-colors">
                      <input
                        ref={selectAllRef}
                        type="checkbox"
                        checked={allSelectableSelected}
                        onChange={handleSelectAll}
                        className="w-4 h-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500/20 cursor-pointer"
                      />
                      <span className="text-sm font-medium text-gray-700">Select All Parts</span>
                    </label>

                    {/* Parts Grid */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 max-h-60 overflow-y-auto p-1">
                      {parts.map((p) => {
                        const isSelected = selectedParts.includes(p.partno);
                        const isCompleted = p.status === "completed";
                        return (
                          <label
                            key={p.partno}
                            className={`flex items-center gap-3 p-3 rounded-xl border cursor-pointer transition-all duration-150 ${
                              isCompleted
                                ? "bg-gray-50/50 border-gray-100 opacity-60 cursor-not-allowed"
                                : isSelected
                                ? "bg-blue-50/60 border-blue-200 shadow-sm"
                                : "bg-white border-gray-200 hover:border-gray-300 hover:shadow-sm"
                            }`}
                          >
                            <input
                              type="checkbox"
                              checked={isSelected}
                              disabled={isCompleted}
                              onChange={() => togglePart(p.partno, p.status)}
                              className={`w-4 h-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500/20 shrink-0 ${
                                isCompleted ? "cursor-not-allowed" : "cursor-pointer"
                              }`}
                            />
                            <div className="min-w-0">
                              <p className="text-sm font-semibold text-gray-900 font-mono truncate">{p.partno}</p>
                              <p className="text-xs text-gray-500 capitalize">{p.status.replace(/_/g, " ")}</p>
                            </div>
                            {isCompleted && (
                              <CheckCircle2 className="w-4 h-4 text-emerald-500 ml-auto shrink-0" />
                            )}
                          </label>
                        );
                      })}
                    </div>

                    {/* Note */}
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-gray-700">Re-update Note</label>
                      <input
                        type="text"
                        placeholder="Enter reason for re-update..."
                        value={note}
                        onChange={(e) => setNote(e.target.value)}
                        className="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all"
                      />
                      <p className="text-xs text-gray-400 flex items-center gap-1">
                        <Info className="w-3 h-3" />
                        Optional note for warehouse staff
                      </p>
                    </div>

                    {/* Actions */}
                    <div className="flex gap-3 pt-2">
                      <button
                        onClick={() => {
                          setShowReupdate(false);
                          setSelectedParts([]);
                          setNote("");
                        }}
                        className="flex-1 px-4 py-2.5 bg-white border border-gray-200 rounded-xl text-sm font-semibold text-gray-700 hover:bg-gray-50 transition-colors"
                      >
                        Cancel
                      </button>
                      <button
                        onClick={handleReupdateClick}
                        disabled={!someSelected || updating}
                        className={`flex-1 px-4 py-2.5 rounded-xl text-sm font-semibold transition-all duration-200 inline-flex items-center justify-center gap-2 ${
                          someSelected && !updating
                            ? "bg-rose-600 text-white hover:bg-rose-700 shadow-sm active:scale-[0.98]"
                            : "bg-gray-100 text-gray-400 cursor-not-allowed"
                        }`}
                      >
                        {updating && <Loader2 className="w-4 h-4 animate-spin" />}
                        Submit Re-update
                      </button>
                    </div>
                  </div>
                )}

                {/* ─── PARTS TABLE ─── */}
                <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
                  <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
                    <h2 className="text-base font-semibold text-gray-900 flex items-center gap-2">
                      <Package className="w-4 h-4 text-gray-400" />
                      Parts
                      <span className="px-2 py-0.5 bg-gray-100 text-gray-600 rounded-md text-xs font-medium">
                        {parts.length}
                      </span>
                    </h2>
                  </div>

                  {parts.length === 0 ? (
                    <div className="p-12 text-center">
                      <Package className="w-10 h-10 text-gray-200 mx-auto mb-3" />
                      <p className="text-sm text-gray-400 font-medium">No parts available</p>
                    </div>
                  ) : (
                    <div className="overflow-x-auto">
                      <table className="w-full text-sm text-left">
                        <thead className="bg-gray-50/80 text-gray-500 font-medium border-b border-gray-100">
                          <tr>
                            {showReupdate && (
                              <th className="px-6 py-4 w-12">
                                <input
                                  ref={selectAllRef}
                                  type="checkbox"
                                  checked={allSelectableSelected}
                                  onChange={handleSelectAll}
                                  className="w-4 h-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500/20 cursor-pointer"
                                />
                              </th>
                            )}
                            <th className="px-6 py-4">Part No</th>
                            <th className="px-6 py-4 hidden md:table-cell">Description</th>
                            <th className="px-6 py-4 text-right">Req Qty</th>
                            <th className="px-6 py-4 text-right">Allo Qty</th>
                            <th className="px-6 py-4">Status</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                          {parts.map((p, idx) => {
                            const isSelected = selectedParts.includes(p.partno);
                            const isCompleted = p.status === "completed";
                            const isReupdate = p.status?.includes("reupdate");

                            return (
                              <tr
                                key={idx}
                                className={`group transition-colors duration-150 ${
                                  isSelected
                                    ? "bg-blue-50/40"
                                    : isReupdate
                                    ? "bg-rose-50/30"
                                    : "hover:bg-gray-50/60"
                                }`}
                              >
                                {showReupdate && (
                                  <td className="px-6 py-4">
                                    <input
                                      type="checkbox"
                                      checked={isSelected}
                                      disabled={isCompleted}
                                      onChange={() => togglePart(p.partno, p.status)}
                                      className={`w-4 h-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500/20 ${
                                        isCompleted ? "opacity-40 cursor-not-allowed" : "cursor-pointer"
                                      }`}
                                    />
                                  </td>
                                )}
                                <td className="px-6 py-4">
                                  <span className="font-semibold text-gray-900 font-mono text-xs bg-gray-100 px-2 py-1 rounded-md">
                                    {p.partno}
                                  </span>
                                </td>
                                <td className="px-6 py-4 text-gray-600 hidden md:table-cell max-w-xs truncate">
                                  {p.description || "—"}
                                </td>
                                <td className="px-6 py-4 text-right font-medium text-gray-900">
                                  {p.req_qty}
                                </td>
                                <td className="px-6 py-4 text-right font-medium text-gray-900">
                                  {p.allo_qty}
                                </td>
                                <td className="px-6 py-4">
                                  {getStatusBadge(p.status)}
                                </td>
                              </tr>
                            );
                          })}
                        </tbody>
                      </table>
                    </div>
                  )}
                </div>
              </>
            )}
          </div>
        )}

        {/* ═══════════════════════════════════════
            CONFIRMATION MODAL
        ═══════════════════════════════════════ */}
        {showConfirm && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div
              className="absolute inset-0 bg-black/30 backdrop-blur-sm transition-opacity"
              onClick={() => setShowConfirm(false)}
            />
            <div className="relative bg-white rounded-2xl shadow-xl border border-gray-100 w-full max-w-md p-6 space-y-5 animate-in fade-in zoom-in-95 duration-200">
              <div className="flex items-start gap-4">
                <div className="p-3 bg-rose-50 rounded-xl shrink-0">
                  <AlertTriangle className="w-6 h-6 text-rose-600" />
                </div>
                <div className="space-y-1">
                  <h3 className="text-lg font-semibold text-gray-900">Confirm Re-update</h3>
                  <p className="text-sm text-gray-500 leading-relaxed">
                    You are about to request a re-update for{" "}
                    <span className="font-semibold text-gray-900">{selectedParts.length}</span>{" "}
                    selected {selectedParts.length === 1 ? "part" : "parts"}.
                  </p>
                  {note && (
                    <div className="mt-3 p-3 bg-gray-50 rounded-xl border border-gray-100">
                      <p className="text-xs font-medium text-gray-500 mb-1">Note:</p>
                      <p className="text-sm text-gray-700">{note}</p>
                    </div>
                  )}
                </div>
              </div>

              <div className="flex gap-3">
                <button
                  onClick={() => setShowConfirm(false)}
                  className="flex-1 px-4 py-2.5 bg-white border border-gray-200 rounded-xl text-sm font-semibold text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleConfirmReupdate}
                  disabled={updating}
                  className="flex-1 px-4 py-2.5 bg-rose-600 text-white rounded-xl text-sm font-semibold hover:bg-rose-700 transition-colors disabled:opacity-70 inline-flex items-center justify-center gap-2"
                >
                  {updating && <Loader2 className="w-4 h-4 animate-spin" />}
                  Confirm Re-update
                </button>
              </div>
            </div>
          </div>
        )}

      </div>
    </div>
  );
}