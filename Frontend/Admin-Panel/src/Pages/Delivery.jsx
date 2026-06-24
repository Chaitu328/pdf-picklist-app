import { useState, useEffect, useRef, useCallback } from "react";
import React from "react";
import {
  Search,
  ChevronDown,
  ChevronUp,
  MapPin,
  Building2,
  Calendar,
  Tag,
  Upload,
  FileSpreadsheet,
  Loader2,
  CheckCircle2,
  XCircle,
  X,
  RotateCcw,
  Truck,
  Route,
  AlertCircle,
  Inbox,
  Clock,
  Plus,
  Trash2,
  Hash
} from "lucide-react";

/* ═══════════════════════════════════════════════════════════════
   SHARED COMPONENTS
   ═══════════════════════════════════════════════════════════════ */

function Toast({ message, type, onClose }) {
  return (
    <div className="fixed top-6 right-6 z-50 animate-in fade-in slide-in-from-right-full duration-300">
      <div className={`flex items-center gap-3 px-5 py-4 rounded-xl shadow-xl border backdrop-blur-sm ${
        type === "success"
          ? "bg-white/95 border-green-200 text-green-800"
          : "bg-white/95 border-red-200 text-red-800"
      }`}>
        {type === "success" ? (
          <CheckCircle2 className="w-5 h-5 text-green-500 shrink-0" />
        ) : (
          <XCircle className="w-5 h-5 text-red-500 shrink-0" />
        )}
        <p className="text-sm font-semibold">{message}</p>
        <button
          onClick={onClose}
          className="ml-2 text-gray-400 hover:text-gray-600 transition-colors"
        >
          <X className="w-4 h-4" />
        </button>
      </div>
    </div>
  );
}

function SkeletonCard() {
  return (
    <div className="bg-white rounded-xl border border-gray-100 p-5 animate-pulse">
      <div className="flex items-center gap-3 mb-3">
        <div className="w-10 h-10 rounded-lg bg-gray-200" />
        <div className="space-y-2 flex-1">
          <div className="h-4 bg-gray-200 rounded w-1/3" />
          <div className="h-3 bg-gray-200 rounded w-1/4" />
        </div>
      </div>
    </div>
  );
}

function EmptyState({ icon: Icon, title, subtitle }) {
  return (
    <div className="flex flex-col items-center justify-center py-20 text-center">
      <div className="p-5 bg-gray-50 rounded-2xl mb-5">
        <Icon className="w-10 h-10 text-gray-300" />
      </div>
      <h3 className="text-base font-semibold text-gray-900">{title}</h3>
      <p className="text-sm text-gray-400 mt-1 max-w-xs">{subtitle}</p>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   FILTER BAR
   ═══════════════════════════════════════════════════════════════ */

function FilterBar({ search, setSearch, selectedDay, setSelectedDay, selectedType, setSelectedType, routes }) {
  const hasFilters = search || selectedDay !== "ALL" || selectedType !== "ALL";

  const resetFilters = () => {
    setSearch("");
    setSelectedDay("ALL");
    setSelectedType("ALL");
  };

  return (
    <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 flex flex-col lg:flex-row gap-3 items-stretch lg:items-center">
      {/* Search */}
      <div className="relative flex-1 min-w-[200px]">
        <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
        <input
          type="text"
          placeholder="Search company or city..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full pl-10 pr-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm text-gray-900 placeholder:text-gray-400 outline-none focus:border-purple-500 focus:ring-4 focus:ring-purple-500/10 transition-all"
        />
        {search && (
          <button
            onClick={() => setSearch("")}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
          >
            <X className="w-3.5 h-3.5" />
          </button>
        )}
      </div>

      {/* Day Selector */}
      <div className="relative min-w-[160px]">
        <Calendar className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
        <select
          value={selectedDay}
          onChange={(e) => setSelectedDay(e.target.value)}
          className="w-full pl-10 pr-9 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm text-gray-900 outline-none appearance-none focus:border-purple-500 focus:ring-4 focus:ring-purple-500/10 transition-all cursor-pointer"
        >
          <option value="ALL">All Days</option>
          {routes.map((g) => (
            <option key={g.day} value={g.day}>{g.day}</option>
          ))}
        </select>
        <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none" />
      </div>

      {/* Type Selector */}
      <div className="relative min-w-[160px]">
        <Tag className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
        <select
          value={selectedType}
          onChange={(e) => setSelectedType(e.target.value)}
          className="w-full pl-10 pr-9 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm text-gray-900 outline-none appearance-none focus:border-purple-500 focus:ring-4 focus:ring-purple-500/10 transition-all cursor-pointer"
        >
          <option value="ALL">All Types</option>
          <option value="LOCAL">LOCAL</option>
          <option value="TRANSPORT">TRANSPORT</option>
        </select>
        <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none" />
      </div>

      {/* Reset */}
      {hasFilters && (
        <button
          onClick={resetFilters}
          className="inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold text-gray-600 bg-gray-50 border border-gray-200 hover:bg-gray-100 hover:text-gray-900 transition-all shrink-0"
        >
          <RotateCcw className="w-3.5 h-3.5" />
          Reset
        </button>
      )}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   ROUTE CARD (individual item)
   ═══════════════════════════════════════════════════════════════ */

function RouteCard({ route, index, groupLabel, groupType = "day" }) {
  const badgeColor =
    groupType === "special"
      ? groupLabel === "LOCAL"
        ? "bg-emerald-50 text-emerald-700 border-emerald-100"
        : "bg-sky-50 text-sky-700 border-sky-100"
      : "bg-purple-50 text-purple-700 border-purple-100";

  const badgeIcon =
    groupType === "special"
      ? groupLabel === "LOCAL"
        ? Building2
        : Truck
      : Clock;

  const Icon = badgeIcon;

  return (
    <div className="group flex items-center gap-4 p-4 bg-white rounded-xl border border-gray-100 hover:border-purple-200 hover:shadow-md transition-all duration-200 cursor-default">
      <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-gray-50 text-gray-400 font-mono text-xs font-bold group-hover:bg-purple-50 group-hover:text-purple-600 transition-colors">
        {index}
      </div>

      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-0.5">
          <h4 className="text-sm font-bold text-gray-900 truncate">
            {route.companyName}
          </h4>
        </div>
        <div className="flex items-center gap-1.5 text-xs text-gray-500">
          <MapPin className="w-3 h-3 shrink-0" />
          <span className="truncate">{route.city}</span>
        </div>
      </div>

      <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-semibold border shrink-0 ${badgeColor}`}>
        <Icon className="w-3 h-3" />
        {groupLabel}
      </span>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   ACCORDION GROUP (day sections)
   ═══════════════════════════════════════════════════════════════ */

function AccordionGroup({ day, routes, filterFn }) {
  const [isOpen, setIsOpen] = useState(true);
  const filtered = routes.filter((r) => filterFn(r, day));

  if (filtered.length === 0) return null;

  return (
    <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="w-full flex items-center justify-between p-5 hover:bg-gray-50/50 transition-colors"
      >
        <div className="flex items-center gap-3">
          <div className="p-2 bg-purple-50 rounded-lg">
            <Calendar className="w-5 h-5 text-purple-600" />
          </div>
          <div className="text-left">
            <h3 className="text-sm font-bold text-gray-900">{day}</h3>
            <p className="text-xs text-gray-400 mt-0.5">{filtered.length} route{filtered.length !== 1 ? "s" : ""}</p>
          </div>
        </div>
        <div className={`p-1.5 rounded-lg bg-gray-50 text-gray-400 transition-transform duration-200 ${isOpen ? "rotate-180" : ""}`}>
          <ChevronDown className="w-4 h-4" />
        </div>
      </button>

      <div className={`grid transition-all duration-300 ease-in-out ${isOpen ? "grid-rows-[1fr] opacity-100" : "grid-rows-[0fr] opacity-0"}`}>
        <div className="overflow-hidden">
          <div className="p-5 pt-0 space-y-2">
            {filtered.map((r, i) => (
              <RouteCard
                key={r._id}
                route={r}
                index={i + 1}
                groupLabel={day}
                groupType="day"
              />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   SPECIAL GROUP SECTION
   ═══════════════════════════════════════════════════════════════ */

function SpecialGroupSection({ type, routes, filterFn }) {
  const filtered = routes.filter((r) => filterFn(r, "", type));

  if (filtered.length === 0) return null;

  const isLocal = type === "LOCAL";
  const accentColor = isLocal ? "emerald" : "sky";
  const Icon = isLocal ? Building2 : Truck;

  return (
    <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
      <div className={`p-5 border-b border-gray-50 bg-${accentColor}-50/30`}>
        <div className="flex items-center gap-3">
          <div className={`p-2 bg-${accentColor}-100 rounded-lg`}>
            <Icon className={`w-5 h-5 text-${accentColor}-600`} />
          </div>
          <div>
            <h3 className="text-sm font-bold text-gray-900 flex items-center gap-2">
              {type}
              <span className={`inline-flex items-center px-2 py-0.5 rounded-md bg-${accentColor}-100 text-${accentColor}-700 text-xs font-bold`}>
                {filtered.length}
              </span>
            </h3>
            <p className="text-xs text-gray-400 mt-0.5">
              {isLocal ? "Local delivery routes" : "Long-distance transport routes"}
            </p>
          </div>
        </div>
      </div>

      <div className="p-5 space-y-2">
        {filtered.map((r, i) => (
          <RouteCard
            key={r._id}
            route={r}
            index={i + 1}
            groupLabel={type}
            groupType="special"
          />
        ))}
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   UPLOAD TAB
   ═══════════════════════════════════════════════════════════════ */

function UploadTab({ onUploadSuccess }) {
  const [file, setFile] = useState(null);
  const [isDragOver, setIsDragOver] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  const [toast, setToast] = useState(null);
  const fileRef = useRef();
  const token = localStorage.getItem("token");

  /* ─── ADD ROUTE FORM STATE ─── */
  const [addRoutesForm, setAddRoutesForm] = useState([
    { networkCode: "", companyName: "", city: "", deliveryDay: "" },
  ]);
  const [addingRoutes, setAddingRoutes] = useState(false);

  const showToast = (message, type) => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 4000);
  };

  const handleDragOver = useCallback((e) => {
    e.preventDefault();
    setIsDragOver(true);
  }, []);

  const handleDragLeave = useCallback((e) => {
    e.preventDefault();
    setIsDragOver(false);
  }, []);

  const handleDrop = useCallback((e) => {
    e.preventDefault();
    setIsDragOver(false);
    const dropped = e.dataTransfer.files[0];
    if (dropped) setFile(dropped);
  }, []);

  const handleFileChange = (e) => {
    const selected = e.target.files[0];
    if (selected) setFile(selected);
  };

  const handleUpload = async () => {
    if (!file) {
      showToast("Please select a file first", "error");
      return;
    }

    try {
      setIsUploading(true);
      const formData = new FormData();
      formData.append("file", file);

      const res = await fetch(
        "http://localhost:3000/api/delivery-routes/import",
        {
          method: "POST",
          headers: { Authorization: `Bearer ${token}` },
          body: formData,
        }
      );

      const data = await res.json();

      if (!res.ok) {
        showToast(data.message || "Upload failed", "error");
        return;
      }

      showToast("Routes uploaded successfully!", "success");
      setFile(null);
      if (fileRef.current) fileRef.current.value = "";
      onUploadSuccess();

    } catch (err) {
      console.error(err);
      showToast("Server error during upload", "error");
    } finally {
      setIsUploading(false);
    }
  };

  /* ─── ADD ROUTE HANDLER ─── */
  const handleAddRoutes = async () => {
    const validRoutes = addRoutesForm.filter(
      (r) => r.networkCode.trim() && r.companyName.trim() && r.city.trim() && r.deliveryDay.trim()
    );

    if (validRoutes.length === 0) {
      showToast("Please fill in all fields", "error");
      return;
    }

    try {
      setAddingRoutes(true);
      const res = await fetch(
        "http://localhost:3000/api/delivery-routes",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({
            routes: validRoutes,
          }),
        }
      );

      const data = await res.json();
      console.log("ADD RESPONSE:", data);

      if (!res.ok) {
        showToast(data.message || "Failed to add routes", "error");
        return;
      }

      showToast("✅ Routes added successfully", "success");
      setAddRoutesForm([{ networkCode: "", companyName: "", city: "", deliveryDay: "" }]);
      onUploadSuccess();

    } catch (err) {
      console.error("❌ ADD ERROR:", err);
      showToast("Error adding routes", "error");
    } finally {
      setAddingRoutes(false);
    }
  };

  const updateAddRow = (idx, field, value) => {
    setAddRoutesForm((prev) =>
      prev.map((row, i) => (i === idx ? { ...row, [field]: value } : row))
    );
  };

  const addNewRow = () => {
    setAddRoutesForm((prev) => [
      ...prev,
      { networkCode: "", companyName: "", city: "", deliveryDay: "" },
    ]);
  };

  const removeAddRow = (idx) => {
    setAddRoutesForm((prev) => prev.filter((_, i) => i !== idx));
  };

  return (
    <div className="animate-in fade-in duration-300">
      {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}

      <div className="max-w-xl mx-auto space-y-6">
        <div className="text-center space-y-2 mb-8">
          <h2 className="text-xl font-bold text-gray-900">Upload Delivery Routes</h2>
          <p className="text-sm text-gray-500">Import route data from a spreadsheet file</p>
        </div>

        {/* Drop Zone */}
        <div
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onDrop={handleDrop}
          onClick={() => fileRef.current?.click()}
          className={`relative group cursor-pointer rounded-2xl border-2 border-dashed transition-all duration-200 ${
            isDragOver
              ? "border-purple-500 bg-purple-50 scale-[1.01]"
              : file
              ? "border-green-300 bg-green-50/50"
              : "border-gray-300 bg-gray-50/50 hover:border-purple-400 hover:bg-purple-50/30"
          } p-12 text-center`}
        >
          <input
            type="file"
            ref={fileRef}
            onChange={handleFileChange}
            accept=".csv,.xlsx,.xls"
            className="hidden"
          />

          <div className="flex flex-col items-center gap-4">
            <div className={`p-4 rounded-full transition-colors duration-200 ${
              file ? "bg-green-100 text-green-600" : "bg-purple-100 text-purple-600 group-hover:bg-purple-200"
            }`}>
              {file ? <FileSpreadsheet className="w-8 h-8" /> : <Upload className="w-8 h-8" />}
            </div>

            <div>
              {file ? (
                <div className="flex items-center gap-2 justify-center">
                  <FileSpreadsheet className="w-4 h-4 text-green-600" />
                  <span className="text-sm font-semibold text-gray-800">{file.name}</span>
                  <span className="text-xs text-gray-400">({(file.size / 1024).toFixed(1)} KB)</span>
                </div>
              ) : (
                <>
                  <p className="text-sm font-semibold text-gray-700">
                    Drop your file here, or <span className="text-purple-600 underline underline-offset-2">browse</span>
                  </p>
                  <p className="text-xs text-gray-400 mt-1">Supports: CSV, XLSX, XLS</p>
                </>
              )}
            </div>
          </div>

          {isUploading && (
            <div className="absolute inset-0 bg-white/80 backdrop-blur-sm rounded-2xl flex flex-col items-center justify-center gap-2">
              <Loader2 className="w-6 h-6 text-purple-600 animate-spin" />
              <span className="text-xs font-medium text-gray-600">Uploading...</span>
            </div>
          )}
        </div>

        {/* Actions */}
        <div className="flex gap-3 justify-center">
          {file && (
            <button
              onClick={() => { setFile(null); if (fileRef.current) fileRef.current.value = ""; }}
              className="px-5 py-2.5 rounded-xl text-sm font-semibold text-gray-600 bg-white border border-gray-200 shadow-sm hover:bg-gray-50 transition-all"
            >
              Remove
            </button>
          )}
          <button
            onClick={handleUpload}
            disabled={!file || isUploading}
            className="inline-flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-semibold text-white bg-purple-600 shadow-lg shadow-purple-200 hover:bg-purple-700 hover:shadow-purple-300 hover:-translate-y-0.5 active:translate-y-0 disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:translate-y-0 transition-all duration-200"
          >
            {isUploading ? (
              <>
                <Loader2 className="w-4 h-4 animate-spin" />
                Uploading...
              </>
            ) : (
              <>
                <Upload className="w-4 h-4" />
                Upload Routes
              </>
            )}
          </button>
        </div>

        {/* ─── ADD ROUTES MANUALLY SECTION ─── */}
        <div className="border-t border-gray-100 pt-8 space-y-5">
          <div className="text-center space-y-1">
            <h3 className="text-base font-bold text-gray-900">Or Add Routes Manually</h3>
            <p className="text-xs text-gray-500">Enter route details below</p>
          </div>

          <div className="space-y-3">
            {addRoutesForm.map((row, idx) => (
              <div key={idx} className="grid grid-cols-1 sm:grid-cols-2 gap-3 p-4 bg-white rounded-xl border border-gray-100 shadow-sm">
                <div className="relative">
                  <Hash className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-3.5 h-3.5" />
                  <input
                    type="text"
                    placeholder="Network Code"
                    value={row.networkCode}
                    onChange={(e) => updateAddRow(idx, "networkCode", e.target.value)}
                    className="w-full pl-9 pr-3 py-2.5 bg-gray-50 border border-gray-200 rounded-lg text-sm text-gray-900 placeholder:text-gray-400 outline-none focus:border-purple-500 focus:ring-2 focus:ring-purple-500/20 transition-all"
                  />
                </div>
                <div className="relative">
                  <Building2 className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-3.5 h-3.5" />
                  <input
                    type="text"
                    placeholder="Company Name"
                    value={row.companyName}
                    onChange={(e) => updateAddRow(idx, "companyName", e.target.value)}
                    className="w-full pl-9 pr-3 py-2.5 bg-gray-50 border border-gray-200 rounded-lg text-sm text-gray-900 placeholder:text-gray-400 outline-none focus:border-purple-500 focus:ring-2 focus:ring-purple-500/20 transition-all"
                  />
                </div>
                <div className="relative">
                  <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-3.5 h-3.5" />
                  <input
                    type="text"
                    placeholder="City"
                    value={row.city}
                    onChange={(e) => updateAddRow(idx, "city", e.target.value)}
                    className="w-full pl-9 pr-3 py-2.5 bg-gray-50 border border-gray-200 rounded-lg text-sm text-gray-900 placeholder:text-gray-400 outline-none focus:border-purple-500 focus:ring-2 focus:ring-purple-500/20 transition-all"
                  />
                </div>
                <div className="relative">
                  <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-3.5 h-3.5" />
                  <input
                    type="text"
                    placeholder="Delivery Day"
                    value={row.deliveryDay}
                    onChange={(e) => updateAddRow(idx, "deliveryDay", e.target.value)}
                    className="w-full pl-9 pr-3 py-2.5 bg-gray-50 border border-gray-200 rounded-lg text-sm text-gray-900 placeholder:text-gray-400 outline-none focus:border-purple-500 focus:ring-2 focus:ring-purple-500/20 transition-all"
                  />
                </div>
                {addRoutesForm.length > 1 && (
                  <div className="sm:col-span-2 flex justify-end">
                    <button
                      onClick={() => removeAddRow(idx)}
                      className="text-xs font-semibold text-red-500 hover:text-red-600 transition-colors"
                    >
                      Remove row
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>

          <div className="flex flex-col sm:flex-row gap-3 justify-center">
            <button
              onClick={addNewRow}
              className="inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl text-sm font-semibold text-purple-700 bg-purple-50 border border-purple-200 hover:bg-purple-100 transition-all"
            >
              <Plus className="w-4 h-4" />
              Add Row
            </button>
            <button
              onClick={handleAddRoutes}
              disabled={addingRoutes}
              className="inline-flex items-center justify-center gap-2 px-6 py-2.5 rounded-xl text-sm font-semibold text-white bg-purple-600 shadow-lg shadow-purple-200 hover:bg-purple-700 hover:shadow-purple-300 hover:-translate-y-0.5 active:translate-y-0 disabled:opacity-60 disabled:cursor-not-allowed disabled:hover:translate-y-0 transition-all duration-200"
            >
              {addingRoutes ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin" />
                  Saving...
                </>
              ) : (
                <>
                  <CheckCircle2 className="w-4 h-4" />
                  Submit Routes
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   MAIN PAGE
   ═══════════════════════════════════════════════════════════════ */

export default function Delivery() {
  const [activeTab, setActiveTab] = useState("list");

  const [routes, setRoutes] = useState([]);
  const [specialRoutes, setSpecialRoutes] = useState([]);
  const [loading, setLoading] = useState(false);

  // ✅ FILTER STATES (preserved)
  const [search, setSearch] = useState("");
  const [selectedDay, setSelectedDay] = useState("ALL");
  const [selectedType, setSelectedType] = useState("ALL");
  const [allRoutes, setAllRoutes] = useState([]);

  /* ─── DELETE STATE ─── */
  const [deleteIds, setDeleteIds] = useState("");
  const [deleting, setDeleting] = useState(false);
  const [toast, setToast] = useState(null);

  const token = localStorage.getItem("token");

  const showToast = (message, type) => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 4000);
  };

  // ================= FETCH (preserved logic) =================
  const fetchRoutes = async () => {
    try {
      setLoading(true);
      const res = await fetch(
        "http://localhost:3000/api/delivery-routes",
        { headers: { Authorization: `Bearer ${token}` } }
      );
      const data = await res.json();
      setRoutes(data.grouped || []);
      setAllRoutes(Array.isArray(data) ? data : data.routes || []);
      setSpecialRoutes(data.specialGroups || []);
    } catch (err) {
      console.error("❌ Fetch error:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (activeTab === "list") fetchRoutes();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeTab]);

  // ================= FILTER LOGIC (preserved) =================
  const filterRoute = (r, day, type = "") => {
    const matchesSearch =
      r.companyName.toLowerCase().includes(search.toLowerCase()) ||
      r.city.toLowerCase().includes(search.toLowerCase());

    const matchesDay = selectedDay === "ALL" || selectedDay === day;
    const matchesType = selectedType === "ALL" || selectedType === type;

    return matchesSearch && matchesDay && matchesType;
  };

  // ================= HANDLERS =================
  const handleUploadSuccess = () => {
    setActiveTab("list");
    fetchRoutes();
  };

  /* ─── DELETE HANDLER ─── */
const handleDeleteRoutes = async () => {
  try {
    if (!deleteIds.trim()) {
      showToast("Enter company name", "error");
      return;
    }

    setDeleting(true);

    // 1. Fetch routes
    const resGet = await fetch(
      "http://localhost:3000/api/delivery-routes",
      {
        headers: { Authorization: `Bearer ${token}` },
      }
    );

    const data = await resGet.json();

    // 🔥 FIX: flatten data correctly
    let routes = [];

    if (data.grouped) {
      routes = data.grouped.flatMap((g) => g.routes);
    } else if (data.routes) {
      routes = data.routes;
    } else if (Array.isArray(data)) {
      routes = data;
    }

    console.log("ALL ROUTES:", routes);

    // 2. Match company
    const searchText = deleteIds.toLowerCase().trim();

    const matches = routes.filter((r) =>
      r.companyName?.toLowerCase().includes(searchText)
    );

    console.log("MATCHES:", matches);

    if (matches.length === 0) {
      showToast("Company not found", "error");
      return;
    }

    // 3. Extract IDs
    const ids = matches.map((r) => r._id);

    console.log("DELETING IDS:", ids);

    // 4. Delete API
    const res = await fetch(
      "http://localhost:3000/api/delivery-routes",
      {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ ids }),
      }
    );

    const result = await res.json();

    if (!res.ok) {
      showToast(result.message || "Delete failed", "error");
      return;
    }

    showToast(`🗑️ Deleted ${ids.length} route(s)`, "success");
    setDeleteIds("");
    fetchRoutes();

  } catch (err) {
    console.error(err);
    showToast("Error deleting route", "error");
  } finally {
    setDeleting(false);
  }
};
  const hasAnyResults = () => {
    const dayHas = routes.some((g) => g.routes.some((r) => filterRoute(r, g.day)));
    const specialHas = specialRoutes.some((g) => g.routes.some((r) => filterRoute(r, "", g.type)));
    return dayHas || specialHas;
  };

  return (
    <div className="min-h-screen bg-gray-50/50">
      {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}

      <div className="max-w-6xl mx-auto px-4 sm:px-6 py-8 space-y-4">

        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-purple-600 rounded-xl shadow-sm">
              <Route className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Delivery Routes</h1>
              <p className="text-sm text-gray-500 mt-0.5">Manage and organize delivery schedules</p>
            </div>
          </div>

          {/* Tabs */}
          <div className="bg-white p-1 rounded-xl border border-gray-200 shadow-sm inline-flex self-start sm:self-auto">
            <button
              onClick={() => setActiveTab("list")}
              className={`relative px-5 py-2.5 rounded-lg text-sm font-semibold transition-all duration-200 ${
                activeTab === "list"
                  ? "bg-purple-600 text-white shadow-md"
                  : "text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              }`}
            >
              All Routes
            </button>
            <button
              onClick={() => setActiveTab("upload")}
              className={`relative px-5 py-2.5 rounded-lg text-sm font-semibold transition-all duration-200 ${
                activeTab === "upload"
                  ? "bg-purple-600 text-white shadow-md"
                  : "text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              }`}
            >
              Upload Routes
            </button>
          </div>
        </div>

        {/* ================= LIST TAB ================= */}
        {activeTab === "list" && (
          <div className="space-y-6 animate-in fade-in duration-300">
            {/* Filter Bar */}
            <FilterBar
              search={search}
              setSearch={setSearch}
              selectedDay={selectedDay}
              setSelectedDay={setSelectedDay}
              selectedType={selectedType}
              setSelectedType={setSelectedType}
              routes={routes}
            />

            {/* ─── DELETE ROUTES SECTION ─── */}
            <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 flex flex-col sm:flex-row gap-3 items-stretch sm:items-center">
              <div className="relative flex-1">
                <Hash className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
                <input
                  type="text"
                  placeholder="Enter IDs to delete (comma separated)..."
                  value={deleteIds}
                  onChange={(e) => setDeleteIds(e.target.value)}
                  className="w-full pl-10 pr-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-sm text-gray-900 placeholder:text-gray-400 outline-none focus:border-red-500 focus:ring-4 focus:ring-red-500/10 transition-all"
                />
                {deleteIds && (
                  <button
                    onClick={() => setDeleteIds("")}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  >
                    <X className="w-3.5 h-3.5" />
                  </button>
                )}
              </div>
              <button
                onClick={handleDeleteRoutes}
                disabled={!deleteIds.trim() || deleting}
                className={`inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl text-sm font-semibold transition-all duration-200 shrink-0 ${
                  deleteIds.trim() && !deleting
                    ? "bg-red-600 text-white hover:bg-red-700 shadow-lg shadow-red-200 hover:shadow-red-300 hover:-translate-y-0.5 active:translate-y-0"
                    : "bg-gray-100 text-gray-400 cursor-not-allowed"
                }`}
              >
                {deleting ? (
                  <>
                    <Loader2 className="w-4 h-4 animate-spin" />
                    Deleting...
                  </>
                ) : (
                  <>
                    <Trash2 className="w-4 h-4" />
                    Delete Selected
                  </>
                )}
              </button>
            </div>

            {/* Content */}
            {loading ? (
              <div className="space-y-4">
                <SkeletonCard />
                <SkeletonCard />
                <SkeletonCard />
              </div>
            ) : !hasAnyResults() ? (
              <EmptyState
                icon={Inbox}
                title="No routes found"
                subtitle={search || selectedDay !== "ALL" || selectedType !== "ALL"
                  ? "Try adjusting your filters to see more results."
                  : "Upload route data to get started with delivery management."}
              />
            ) : (
              <div className="space-y-6">
                {/* Day Groups */}
                {routes.map((group) => (
                  <AccordionGroup
                    key={group.day}
                    day={group.day}
                    routes={group.routes}
                    filterFn={filterRoute}
                  />
                ))}

                {/* Special Groups */}
                {specialRoutes.map((group) => (
                  <SpecialGroupSection
                    key={group.type}
                    type={group.type}
                    routes={group.routes}
                    filterFn={filterRoute}
                  />
                ))}
              </div>
            )}
          </div>
        )}

        {/* ================= UPLOAD TAB ================= */}
        {activeTab === "upload" && (
          <UploadTab onUploadSuccess={handleUploadSuccess} />
        )}

      </div>
    </div>
  );
}