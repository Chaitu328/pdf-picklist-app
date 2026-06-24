import { useState, useEffect, useRef, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { 
  Upload, 
  FileText, 
  Calendar, 
  Hash, 
  Package, 
  Send, 
  Trash2, 
  CheckCircle2, 
  XCircle, 
  Loader2,
  ClipboardList,
  AlertCircle,
  X,
  Search,
  RefreshCw,
  ChevronRight,
  Warehouse
} from "lucide-react";
import { parsePDF } from "../utils/pdfParser";

/* ═══════════════════════════════════════════════════════════════
   SHARED COMPONENTS (from existing UI — unchanged)
   ═══════════════════════════════════════════════════════════════ */

function Toast({ message, type, onClose }) {
  return (
    <div className={`fixed top-6 right-6 z-50 flex items-center gap-3 px-5 py-4 rounded-xl shadow-lg border animate-in slide-in-from-right-full fade-in duration-300 ${
      type === "success" 
        ? "bg-white border-green-200 text-green-800" 
        : "bg-white border-red-200 text-red-800"
    }`}>
      {type === "success" ? (
        <CheckCircle2 className="w-5 h-5 text-green-500 shrink-0" />
      ) : (
        <XCircle className="w-5 h-5 text-red-500 shrink-0" />
      )}
      <p className="text-sm font-medium">{message}</p>
      <button 
        onClick={onClose}
        className="ml-2 text-gray-400 hover:text-gray-600 transition-colors"
      >
        <X className="w-4 h-4" />
      </button>
    </div>
  );
}

function LoadingSpinner({ text }) {
  return (
    <div className="flex flex-col items-center justify-center gap-3 py-12">
      <Loader2 className="w-8 h-8 text-purple-600 animate-spin" />
      <p className="text-sm text-gray-500 font-medium">{text}</p>
    </div>
  );
}

function UploadBox({ onFileSelect, fileName, isLoading }) {
  const [isDragOver, setIsDragOver] = useState(false);
  const inputRef = useRef(null);

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
    const file = e.dataTransfer.files[0];
    if (file && file.type === "application/pdf") {
      onFileSelect(file);
    }
  }, [onFileSelect]);

  const handleChange = (e) => {
    const file = e.target.files[0];
    if (file) onFileSelect(file);
  };

  return (
    <div
      onDragOver={handleDragOver}
      onDragLeave={handleDragLeave}
      onDrop={handleDrop}
      onClick={() => inputRef.current?.click()}
      className={`relative group cursor-pointer rounded-2xl border-2 border-dashed transition-all duration-200 ${
        isDragOver
          ? "border-purple-500 bg-purple-50 scale-[1.01]"
          : fileName
          ? "border-green-300 bg-green-50/50"
          : "border-gray-300 bg-gray-50/50 hover:border-purple-400 hover:bg-purple-50/30"
      } p-10 text-center`}
    >
      <input
        ref={inputRef}
        type="file"
        accept="application/pdf"
        onChange={handleChange}
        className="hidden"
      />

      <div className="flex flex-col items-center gap-3">
        <div className={`p-4 rounded-full transition-colors duration-200 ${
          fileName ? "bg-green-100 text-green-600" : "bg-purple-100 text-purple-600 group-hover:bg-purple-200"
        }`}>
          {fileName ? <FileText className="w-8 h-8" /> : <Upload className="w-8 h-8" />}
        </div>

        <div>
          {fileName ? (
            <div className="flex items-center gap-2">
              <FileText className="w-4 h-4 text-green-600" />
              <span className="text-sm font-semibold text-gray-800">{fileName}</span>
            </div>
          ) : (
            <>
              <p className="text-sm font-semibold text-gray-700">
                Drop your PDF here, or <span className="text-purple-600 underline underline-offset-2">browse</span>
              </p>
              <p className="text-xs text-gray-400 mt-1">Supports: PDF pick lists only</p>
            </>
          )}
        </div>
      </div>

      {isLoading && (
        <div className="absolute inset-0 bg-white/80 backdrop-blur-sm rounded-2xl flex flex-col items-center justify-center gap-2">
          <Loader2 className="w-6 h-6 text-purple-600 animate-spin" />
          <span className="text-xs font-medium text-gray-600">Extracting data...</span>
        </div>
      )}
    </div>
  );
}

function HeaderCard({ data }) {
  const items = [
    { label: "Pick List No", value: data?.pickListNo || "—", icon: ClipboardList },
    { label: "Order No", value: data?.orderNo || "—", icon: Hash },
    { label: "Pick List Date", value: data?.pickListDate || "—", icon: Calendar },
    { label: "Order Date", value: data?.orderDate || "—", icon: Package },
  ];

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      {items.map((item, idx) => (
        <div 
          key={idx} 
          className="bg-white rounded-xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow duration-200 p-5 flex items-start gap-4"
        >
          <div className="p-2.5 bg-purple-50 rounded-lg text-purple-600 shrink-0">
            <item.icon className="w-5 h-5" />
          </div>
          <div className="min-w-0">
            <p className="text-xs font-medium text-gray-400 uppercase tracking-wider mb-0.5">
              {item.label}
            </p>
            <p className="text-sm font-bold text-gray-900 truncate" title={item.value}>
              {item.value}
            </p>
          </div>
        </div>
      ))}
    </div>
  );
}

function PartsTable({ parts }) {
  if (!parts || parts.length === 0) {
    return (
      <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-12 text-center">
        <div className="inline-flex p-4 bg-gray-50 rounded-full mb-3">
          <AlertCircle className="w-8 h-8 text-gray-300" />
        </div>
        <h3 className="text-sm font-semibold text-gray-900">No parts extracted</h3>
        <p className="text-xs text-gray-400 mt-1">Upload a PDF to see extracted parts here</p>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full text-sm text-left">
          <thead className="bg-gray-50 text-gray-500 font-semibold text-xs uppercase tracking-wider sticky top-0 z-10">
            <tr>
              <th className="px-6 py-4 w-16">ID</th>
              <th className="px-6 py-4">Part Number</th>
              <th className="px-6 py-4">Description</th>
              <th className="px-6 py-4 w-24 text-right">Qty</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {parts.map((item, index) => (
              <tr 
                key={index} 
                className={`group transition-colors duration-150 hover:bg-purple-50/40 ${
                  index % 2 === 0 ? "bg-white" : "bg-gray-50/30"
                }`}
              >
                <td className="px-6 py-3.5 text-gray-400 font-mono text-xs">
                  {index + 1}
                </td>
                <td className="px-6 py-3.5">
                  <span className="inline-flex items-center px-2.5 py-1 rounded-md bg-purple-50 text-purple-700 font-mono text-xs font-semibold border border-purple-100">
                    {item.partno}
                  </span>
                </td>
                <td className="px-6 py-3.5 text-gray-700 font-medium">
                  {item.description}
                </td>
                <td className="px-6 py-3.5 text-right">
                  <span className="inline-flex items-center justify-center min-w-[2rem] px-2 py-1 rounded-md bg-gray-100 text-gray-700 font-bold text-xs">
                    {item.req_qty}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <div className="bg-gray-50 px-6 py-3 border-t border-gray-100 flex justify-between items-center">
        <span className="text-xs text-gray-400">
          Showing {parts.length} part{parts.length !== 1 ? "s" : ""}
        </span>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   STATUS BADGE (helper for table)
   ═══════════════════════════════════════════════════════════════ */

function StatusBadge({ status }) {
  const styles = {
    active: "bg-green-50 text-green-700 border-green-100",
    pending: "bg-amber-50 text-amber-700 border-amber-100",
    completed: "bg-blue-50 text-blue-700 border-blue-100",
    cancelled: "bg-red-50 text-red-700 border-red-100",
  };
  const style = styles[status?.toLowerCase()] || styles.active;
  
  return (
    <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold border capitalize ${style}`}>
      {status || "Active"}
    </span>
  );
}

/* ═══════════════════════════════════════════════════════════════
   TAB 1: ALL PICKLISTS
   ═══════════════════════════════════════════════════════════════ */

function AllPicklists({ refreshKey, showToast }) {
  const navigate = useNavigate();
  const [picklists, setPicklists] = useState([]);
  const [loading, setLoading] = useState(false);
  const [search, setSearch] = useState("");

  const fetchPicklists = async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem("token");
      if (!token) {
        showToast("Authentication required. Please login.", "error");
        setLoading(false);
        return;
      }

      const res = await fetch("http://localhost:3000/api/picklist", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      const data = await res.json();

      if (!res.ok) {
        showToast(data.message || "Failed to load picklists", "error");
        return;
      }

      setPicklists(Array.isArray(data) ? data : data.picklists || []);
    } catch (err) {
      console.error(err);
      showToast("Server error while fetching picklists", "error");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPicklists();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [refreshKey]);

  const filtered = picklists.filter((p) => {
    const term = search.toLowerCase();
    return (
      (p.pick_list_no || "").toLowerCase().includes(term) ||
      (p.order_number || "").toLowerCase().includes(term)
    );
  });

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Toolbar */}
      <div className="flex flex-col sm:flex-row gap-3 justify-between items-start sm:items-center">
        <div className="relative w-full sm:max-w-sm">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            type="text"
            placeholder="Search by pick list or order number..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 bg-white border border-gray-200 rounded-xl text-sm text-gray-900 placeholder:text-gray-400 outline-none focus:border-purple-500 focus:ring-4 focus:ring-purple-500/10 transition-all"
          />
        </div>

        <button
          onClick={fetchPicklists}
          disabled={loading}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-white border border-gray-200 rounded-xl text-sm font-semibold text-gray-700 shadow-sm hover:bg-gray-50 hover:text-gray-900 disabled:opacity-50 transition-all"
        >
          <RefreshCw className={`w-4 h-4 ${loading ? "animate-spin" : ""}`} />
          Refresh
        </button>
      </div>

      {/* Table */}
      {loading && picklists.length === 0 ? (
        <LoadingSpinner text="Loading picklists..." />
      ) : filtered.length === 0 ? (
        <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-16 text-center">
          <div className="inline-flex p-4 bg-gray-50 rounded-full mb-4">
            <ClipboardList className="w-10 h-10 text-gray-300" />
          </div>
          <h3 className="text-base font-semibold text-gray-900">
            {search ? "No matching picklists" : "No picklists found"}
          </h3>
          <p className="text-sm text-gray-400 mt-1 max-w-xs mx-auto">
            {search 
              ? "Try adjusting your search terms." 
              : "Upload a new picklist to get started."}
          </p>
        </div>
      ) : (
        <div className="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm text-left">
              <thead className="bg-gray-50 text-gray-500 font-semibold text-xs uppercase tracking-wider sticky top-0 z-10">
                <tr>
                  <th className="px-6 py-4">Pick List No</th>
                  <th className="px-6 py-4">Order No</th>
                  <th className="px-6 py-4">Date</th>
                  <th className="px-6 py-4">Total Parts</th>
                  <th className="px-6 py-4">Status</th>
                  <th className="px-6 py-4 w-16"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {filtered.map((item) => (
                  <tr
                    key={item._id || item.id}
                    onClick={() => navigate(`/picklists/${item._id || item.id}`)}
                    className="group bg-white hover:bg-purple-50/40 transition-colors duration-150 cursor-pointer"
                  >
                    <td className="px-6 py-4">
                      <span className="font-mono text-xs font-semibold text-purple-700 bg-purple-50 px-2 py-1 rounded-md border border-purple-100">
                        {item.pick_list_no || "—"}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-gray-700 font-medium">
                      {item.order_number || "—"}
                    </td>
                    <td className="px-6 py-4 text-gray-500 whitespace-nowrap">
                      {item.picklist_date || "—"}
                    </td>
                    <td className="px-6 py-4">
                      <span className="inline-flex items-center justify-center min-w-[2rem] px-2 py-1 rounded-md bg-gray-100 text-gray-700 font-bold text-xs">
                        {item.parts?.length || 0}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <StatusBadge status={item.status} />
                    </td>
                    <td className="px-6 py-4 text-right">
                      <ChevronRight className="w-4 h-4 text-gray-300 group-hover:text-purple-500 transition-colors inline-block" />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div className="bg-gray-50 px-6 py-3 border-t border-gray-100 flex justify-between items-center">
            <span className="text-xs text-gray-400">
              {filtered.length} picklist{filtered.length !== 1 ? "s" : ""}
            </span>
          </div>
        </div>
      )}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   TAB 2: UPLOAD PICKLIST (existing UI — unchanged logic)
   ═══════════════════════════════════════════════════════════════ */

function UploadPicklist({ onSubmitSuccess, showToast }) {
  const [parsedData, setParsedData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [fileName, setFileName] = useState("");

  const handlePdfUpload = async (file) => {
    if (!file) return;
    setFileName(file.name);
    setLoading(true);

    try {
      const data = await parsePDF(file);
      setParsedData(data);
    } catch (err) {
      console.error("PDF Error:", err);
      showToast("Failed to parse PDF. Please check the file format.", "error");
      setParsedData(null);
    } finally {
      setLoading(false);
    }
  };

 const navigate = useNavigate();

const handleSubmit = async () => {
  if (!parsedData || parsedData.parts.length === 0) {
    showToast("No data to submit", "error");
    return;
  }

  try {
    const token = localStorage.getItem("token");

    const payload = {
      pick_list_no: parsedData.pickListNo,
      order_number: parsedData.orderNo,
      picklist_date: parsedData.pickListDate,
      route_day: "Any",
      parts: parsedData.parts,
    };

    const res = await fetch(
      "http://localhost:3000/api/picklist",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(payload),
      }
    );

    const data = await res.json();

    if (!res.ok) {
      showToast(data.message || "Error creating picklist", "error");
      return;
    }

    showToast("Picklist created!", "success");

    // 🔥 REDIRECT HERE (IMPORTANT)
    navigate(`/picklists/${payload.pick_list_no}`);

  } catch (err) {
    console.error(err);
    showToast("Something went wrong", "error");
  }
};

  const handleClear = () => {
    setParsedData(null);
    setFileName("");
    showToast("Data cleared", "success");
  };

  const hasData = parsedData && parsedData.parts && parsedData.parts.length > 0;

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      {/* Upload Section */}
      <section>
        <UploadBox 
          onFileSelect={handlePdfUpload} 
          fileName={fileName}
          isLoading={loading}
        />
      </section>

      {/* Metadata Header */}
      {parsedData && (
        <section className="animate-in fade-in slide-in-from-bottom-4 duration-500">
          <HeaderCard data={parsedData} />
        </section>
      )}

      {/* Table Section */}
      <section className="space-y-4">
        <div className="flex items-center justify-between">
          <h2 className="text-sm font-bold text-gray-900 uppercase tracking-wider">
            Extracted Parts
          </h2>
          {hasData && (
            <span className="text-xs font-medium text-purple-600 bg-purple-50 px-2.5 py-1 rounded-full border border-purple-100">
              {parsedData.parts.length} items ready
            </span>
          )}
        </div>
        
        <PartsTable parts={parsedData?.parts} />
      </section>

      {/* Action Buttons */}
      <section className="flex flex-col sm:flex-row items-center justify-end gap-3 pt-4 pb-12">
        <button
          onClick={handleClear}
          disabled={!hasData && !fileName}
          className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl text-sm font-semibold text-gray-600 bg-white border border-gray-200 shadow-sm hover:bg-gray-50 hover:text-gray-900 disabled:opacity-40 disabled:cursor-not-allowed transition-all duration-200"
        >
          <Trash2 className="w-4 h-4" />
          Clear / Reset
        </button>
        
        <button
          onClick={handleSubmit}
          disabled={!hasData}
          className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-6 py-2.5 rounded-xl text-sm font-semibold text-white bg-purple-600 shadow-lg shadow-purple-200 hover:bg-purple-700 hover:shadow-purple-300 hover:-translate-y-0.5 active:translate-y-0 disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:translate-y-0 transition-all duration-200"
        >
          <Send className="w-4 h-4" />
          Submit Picklist
        </button>
      </section>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   MAIN LAYOUT
   ═══════════════════════════════════════════════════════════════ */

export default function PickListManager() {
  const [activeTab, setActiveTab] = useState("all"); // "all" | "upload"
  const [refreshKey, setRefreshKey] = useState(0);
  const [toast, setToast] = useState(null);

  const showToast = (message, type) => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 4000);
  };

  const handleUploadSuccess = () => {
    showToast("Picklist created successfully!", "success");
    setActiveTab("all");
    setRefreshKey((k) => k + 1);
  };

  return (
    <div className="min-h-screen bg-gray-50/50">
      {/* Toast */}
      {toast && (
        <Toast 
          message={toast.message} 
          type={toast.type} 
          onClose={() => setToast(null)} 
        />
      )}

      <div className="max-w-6xl mx-auto px-4 sm:px-6 py-8 space-y-6">
        
        {/* Header + Tabs */}
        <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-purple-600 rounded-xl shadow-sm">
              <Warehouse className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-gray-900 tracking-tight">
                PickList Manager
              </h1>
              <p className="text-sm text-gray-500 mt-0.5">
                Warehouse picklist extraction & management
              </p>
            </div>
          </div>

          {/* Tabs */}
          <div className="bg-white p-1 rounded-xl border border-gray-200 shadow-sm inline-flex self-start lg:self-auto">
            <button
              onClick={() => setActiveTab("all")}
              className={`relative px-5 py-2.5 rounded-lg text-sm font-semibold transition-all duration-200 ${
                activeTab === "all"
                  ? "bg-purple-600 text-white shadow-md"
                  : "text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              }`}
            >
              All Picklists
            </button>
            <button
              onClick={() => setActiveTab("upload")}
              className={`relative px-5 py-2.5 rounded-lg text-sm font-semibold transition-all duration-200 ${
                activeTab === "upload"
                  ? "bg-purple-600 text-white shadow-md"
                  : "text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              }`}
            >
              Upload Picklist
            </button>
          </div>
        </div>

        {/* Tab Content */}
        {activeTab === "all" ? (
          <AllPicklists 
            refreshKey={refreshKey} 
            showToast={showToast} 
          />
        ) : (
          <UploadPicklist 
            onSubmitSuccess={handleUploadSuccess} 
            showToast={showToast} 
          />
        )}

      </div>
    </div>
  );
}