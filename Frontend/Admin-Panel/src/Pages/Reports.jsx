import { useState, useRef } from "react";
import { useNavigate } from "react-router-dom";
import {
  Search,
  FileSpreadsheet,
  Download,
  Loader2,
  CheckCircle2,
  XCircle,
  X,
  FileX,
  ArrowLeft,
  ClipboardList,
  Hash,
  Package,
  AlertCircle,
  TrendingUp
} from "lucide-react";

/* ─── Toast ─── */
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

/* ─── Status Badge ─── */
function StatusBadge({ status }) {
  const normalized = (status || "pending").toLowerCase();
  const styles = {
    completed: "bg-emerald-50 text-emerald-700 border-emerald-100",
    complete: "bg-emerald-50 text-emerald-700 border-emerald-100",
    pending: "bg-amber-50 text-amber-700 border-amber-100",
    processing: "bg-blue-50 text-blue-700 border-blue-100",
    cancelled: "bg-red-50 text-red-700 border-red-100",
    default: "bg-gray-50 text-gray-600 border-gray-100",
  };
  const style = styles[normalized] || styles.default;
  return (
    <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold border capitalize ${style}`}>
      <div className={`w-1.5 h-1.5 rounded-full ${
        normalized === "completed" || normalized === "complete" ? "bg-emerald-500" :
        normalized === "pending" ? "bg-amber-500" :
        normalized === "processing" ? "bg-blue-500" :
        "bg-gray-400"
      }`} />
      {status || "Pending"}
    </span>
  );
}

/* ─── Skeleton Result ─── */
function SkeletonResult() {
  return (
    <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 animate-pulse">
      <div className="flex items-start justify-between">
        <div className="space-y-3 flex-1">
          <div className="h-5 bg-gray-200 rounded-lg w-1/3" />
          <div className="h-4 bg-gray-200 rounded-lg w-1/4" />
          <div className="h-4 bg-gray-200 rounded-lg w-1/5" />
        </div>
        <div className="h-10 w-36 bg-gray-200 rounded-xl" />
      </div>
    </div>
  );
}

/* ─── Empty Search State ─── */
function EmptySearchState() {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-center animate-in fade-in duration-500">
      <div className="p-5 bg-gray-50 rounded-2xl mb-4">
        <Search className="w-10 h-10 text-gray-300" />
      </div>
      <h3 className="text-base font-semibold text-gray-900">Search for a picklist</h3>
      <p className="text-sm text-gray-400 mt-1 max-w-xs">
        Enter a PickList number or ID above to find and download reports.
      </p>
    </div>
  );
}

/* ─── Not Found State ─── */
function NotFoundState({ searchTerm, onClear }) {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-center animate-in fade-in zoom-in-95 duration-300">
      <div className="p-5 bg-red-50 rounded-2xl mb-4">
        <FileX className="w-10 h-10 text-red-400" />
      </div>
      <h3 className="text-base font-semibold text-gray-900">No picklist found</h3>
      <p className="text-sm text-gray-400 mt-1 max-w-xs">
        We couldn't find a picklist matching "<span className="font-medium text-gray-600">{searchTerm}</span>".
      </p>
      <button
        onClick={onClear}
        className="mt-4 inline-flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-semibold text-gray-600 bg-gray-50 border border-gray-200 hover:bg-gray-100 transition-all"
      >
        <X className="w-3.5 h-3.5" />
        Clear Search
      </button>
    </div>
  );
}

/* ─── Main Component ─── */
export default function PickListDownload() {
  const navigate = useNavigate();
  const [searchId, setSearchId] = useState("");
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);
  const [downloading, setDownloading] = useState(false);
  const [hasSearched, setHasSearched] = useState(false);
  const [toast, setToast] = useState(null);
  const inputRef = useRef(null);

  const token = localStorage.getItem("token");

  const showToast = (message, type) => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 4000);
  };

  // 🔍 SEARCH PICKLIST (preserved logic)
  const handleSearch = async () => {
    if (!searchId.trim()) {
      showToast("Enter PickList No or ID", "error");
      inputRef.current?.focus();
      return;
    }

    setLoading(true);
    setHasSearched(true);
    setResult(null);

    try {
      const res = await fetch(
        "http://localhost:3000/api/picklist",
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      const data = await res.json();

      const found = data.find(
        (p) =>
          p.pick_list_no?.toLowerCase() === searchId.toLowerCase() ||
          p._id === searchId
      );

      if (!found) {
        setResult(null);
        showToast("Picklist not found", "error");
        return;
      }

      setResult(found);
    } catch (err) {
      console.error("❌ Search error:", err);
      showToast("Error fetching data. Please try again.", "error");
      setResult(null);
    } finally {
      setLoading(false);
    }
  };

  // Handle Enter key
  const handleKeyDown = (e) => {
    if (e.key === "Enter") handleSearch();
  };

  // 📥 DOWNLOAD EXCEL (preserved logic)
  const handleDownloadExcel = async (picklistId) => {
    setDownloading(true);
    try {
      const res = await fetch(
        `http://localhost:3000/api/picklist/${picklistId}/report/excel`,
        {
          method: "GET",
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      if (!res.ok) {
        throw new Error("Download failed");
      }

      const blob = await res.blob();
      const url = window.URL.createObjectURL(blob);

      const a = document.createElement("a");
      a.href = url;
      a.download = `PickList-${picklistId}.xlsx`;
      document.body.appendChild(a);
      a.click();
      a.remove();
      window.URL.revokeObjectURL(url);

      showToast("Excel downloaded successfully!", "success");
    } catch (err) {
      console.error("❌ Download error:", err);
      showToast("Failed to download Excel", "error");
    } finally {
      setDownloading(false);
    }
  };

  const clearSearch = () => {
    setSearchId("");
    setResult(null);
    setHasSearched(false);
    inputRef.current?.focus();
  };

  return (
    <div className="min-h-screen bg-gray-50/50">
      {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}

      <div className="max-w-3xl mx-auto px-4 sm:px-6 py-8 space-y-8">

        {/* Header */}
        <div className="text-center space-y-3">
          <div className="inline-flex p-3 bg-blue-50 rounded-2xl mb-2">
            <TrendingUp className="w-8 h-8 text-blue-600" />
          </div>
          <h1 className="text-3xl font-bold text-gray-900 tracking-tight">Reports</h1>
          <p className="text-sm text-gray-500 max-w-md mx-auto">
            Search and download picklist reports in Excel format for warehouse operations and inventory tracking.
          </p>
        </div>

        {/* Search Card */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 sm:p-8">
          <div className="flex flex-col sm:flex-row gap-3">
            <div className="relative flex-1">
              <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                ref={inputRef}
                type="text"
                placeholder="Enter PickList No or ID..."
                value={searchId}
                onChange={(e) => setSearchId(e.target.value)}
                onKeyDown={handleKeyDown}
                className="w-full pl-11 pr-10 py-3 bg-gray-50 border border-gray-200 rounded-xl text-sm text-gray-900 placeholder:text-gray-400 outline-none focus:border-blue-500 focus:ring-4 focus:ring-blue-500/10 transition-all"
              />
              {searchId && (
                <button
                  onClick={() => setSearchId("")}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
                >
                  <X className="w-4 h-4" />
                </button>
              )}
            </div>

            <button
              onClick={handleSearch}
              disabled={loading}
              className="inline-flex items-center justify-center gap-2 px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-semibold shadow-lg shadow-blue-200 hover:shadow-blue-300 hover:-translate-y-0.5 active:translate-y-0 disabled:opacity-60 disabled:cursor-not-allowed disabled:hover:translate-y-0 transition-all duration-200 shrink-0"
            >
              {loading ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin" />
                  Searching...
                </>
              ) : (
                <>
                  <Search className="w-4 h-4" />
                  Search
                </>
              )}
            </button>
          </div>

          {/* Recent searches hint */}
          <div className="mt-4 flex items-center gap-2 text-xs text-gray-400">
            <AlertCircle className="w-3.5 h-3.5" />
            <span>Press Enter to search instantly</span>
          </div>
        </div>

        {/* Results Area */}
        <div className="min-h-[200px]">
          {!hasSearched && !loading && <EmptySearchState />}

          {loading && <SkeletonResult />}

          {hasSearched && !loading && !result && (
            <NotFoundState searchTerm={searchId} onClear={clearSearch} />
          )}

          {result && !loading && (
            <div className="animate-in fade-in slide-in-from-bottom-4 duration-500 space-y-6">
              
              {/* Result Card */}
              <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
                <div className="p-6 sm:p-8">
                  <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
                    
                    {/* Info */}
                    <div className="space-y-5 flex-1">
                      <div className="flex items-center gap-3">
                        <div className="p-2.5 bg-blue-50 rounded-xl">
                          <ClipboardList className="w-6 h-6 text-blue-600" />
                        </div>
                        <div>
                          <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">PickList Report</p>
                          <h2 className="text-2xl font-bold text-gray-900 tracking-tight mt-0.5">
                            {result.pick_list_no}
                          </h2>
                        </div>
                      </div>

                      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                        <div className="flex items-center gap-3 p-3.5 bg-gray-50/70 rounded-xl border border-gray-100">
                          <div className="p-1.5 bg-white rounded-lg shadow-sm">
                            <Hash className="w-4 h-4 text-gray-500" />
                          </div>
                          <div>
                            <p className="text-[11px] font-medium text-gray-400 uppercase tracking-wider">Order No</p>
                            <p className="text-sm font-bold text-gray-900 mt-0.5">{result.order_number || "—"}</p>
                          </div>
                        </div>

                        <div className="flex items-center gap-3 p-3.5 bg-gray-50/70 rounded-xl border border-gray-100">
                          <div className="p-1.5 bg-white rounded-lg shadow-sm">
                            <Package className="w-4 h-4 text-gray-500" />
                          </div>
                          <div>
                            <p className="text-[11px] font-medium text-gray-400 uppercase tracking-wider">Total Parts</p>
                            <p className="text-sm font-bold text-gray-900 mt-0.5">{result.parts?.length || 0}</p>
                          </div>
                        </div>

                        <div className="flex items-center gap-3 p-3.5 bg-gray-50/70 rounded-xl border border-gray-100">
                          <div className="p-1.5 bg-white rounded-lg shadow-sm">
                            <FileSpreadsheet className="w-4 h-4 text-gray-500" />
                          </div>
                          <div>
                            <p className="text-[11px] font-medium text-gray-400 uppercase tracking-wider">Format</p>
                            <p className="text-sm font-bold text-gray-900 mt-0.5">Excel (.xlsx)</p>
                          </div>
                        </div>
                      </div>
                    </div>

                    {/* Actions */}
                    <div className="flex flex-col items-start lg:items-end gap-3 shrink-0">
                      <StatusBadge status={result.status} />
                      {(() => {
                        const isCompleted = ["completed", "reupdate_completed"].includes(result?.status);
                        return isCompleted ? (
                          <button
                            onClick={() => handleDownloadExcel(result._id)}
                            disabled={downloading}
                            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-semibold text-white bg-emerald-600 hover:bg-emerald-700 shadow-lg shadow-emerald-200 hover:shadow-emerald-300 hover:-translate-y-0.5 active:translate-y-0 disabled:opacity-60 disabled:cursor-not-allowed disabled:hover:translate-y-0 transition-all duration-200"
                          >
                            {downloading ? (
                              <>
                                <Loader2 className="w-4 h-4 animate-spin" />
                                Downloading...
                              </>
                            ) : (
                              <>
                                <Download className="w-4 h-4" />
                                Download Excel
                              </>
                            )}
                          </button>
                        ) : null;
                      })()}
                    </div>
                  </div>
                </div>

                {/* Parts Preview */}
                {(() => {
                  const isCompleted = ["completed", "reupdate_completed"].includes(result?.status);
                  return isCompleted ? (
                    result.parts && result.parts.length > 0 && (
                      <div className="border-t border-gray-100">
                        <div className="px-6 sm:px-8 py-4 bg-gray-50/50 border-b border-gray-100 flex items-center justify-between">
                          <h3 className="text-xs font-bold text-gray-500 uppercase tracking-wider">Parts Preview</h3>
                          <span className="text-xs text-gray-400">{result.parts.length} items</span>
                        </div>
                        <div className="overflow-x-auto">
                          <table className="w-full text-sm text-left">
                            <thead className="bg-gray-50 text-gray-500 font-semibold text-xs uppercase tracking-wider">
                              <tr>
                                <th className="px-6 sm:px-8 py-3 w-12">#</th>
                                <th className="px-6 sm:px-8 py-3">Part Number</th>
                                <th className="px-6 sm:px-8 py-3">Description</th>
                                <th className="px-6 sm:px-8 py-3 w-20 text-right">Qty</th>
                              </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-100">
                              {result.parts.slice(0, 5).map((part, idx) => (
                                <tr key={idx} className="hover:bg-gray-50/50 transition-colors">
                                  <td className="px-6 sm:px-8 py-3 text-gray-400 font-mono text-xs">{idx + 1}</td>
                                  <td className="px-6 sm:px-8 py-3">
                                    <span className="inline-flex items-center px-2 py-0.5 rounded-md bg-blue-50 text-blue-700 font-mono text-[11px] font-semibold border border-blue-100">
                                      {part.partno}
                                    </span>
                                  </td>
                                  <td className="px-6 sm:px-8 py-3 text-gray-700 font-medium truncate max-w-[200px]">
                                    {part.description}
                                  </td>
                                  <td className="px-6 sm:px-8 py-3 text-right">
                                    <span className="inline-flex items-center justify-center min-w-[2rem] px-2 py-0.5 rounded-md bg-gray-100 text-gray-700 font-bold text-xs">
                                      {part.req_qty}
                                    </span>
                                  </td>
                                </tr>
                              ))}
                            </tbody>
                          </table>
                        </div>
                        {result.parts.length > 5 && (
                          <div className="px-6 sm:px-8 py-3 bg-gray-50/30 border-t border-gray-100 text-center">
                            <span className="text-xs text-gray-400">
                              + {result.parts.length - 5} more items in the full report
                            </span>
                          </div>
                        )}
                      </div>
                    )
                  ) : (
                    <div className="border-t border-gray-100">
                      <div className="px-6 sm:px-8 py-8">
                        <div className="flex items-start gap-3 p-4 bg-amber-50 border border-amber-200 rounded-xl">
                          <AlertCircle className="w-5 h-5 text-amber-600 shrink-0 mt-0.5" />
                          <p className="text-sm text-amber-800 font-medium">
                            Picklist is not completed yet. Please complete or reupdate to view details.
                          </p>
                        </div>
                      </div>
                    </div>
                  );
                })()}

              </div>

              {/* Search Again */}
              <div className="text-center">
                <button
                  onClick={clearSearch}
                  className="inline-flex items-center gap-2 text-sm font-medium text-gray-500 hover:text-gray-700 transition-colors"
                >
                  <Search className="w-4 h-4" />
                  Search another picklist
                </button>
              </div>
            </div>
          )}
        </div>

      </div>
    </div>
  );
}