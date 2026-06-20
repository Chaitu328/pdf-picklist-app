import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import {
  Trash2,
  AlertCircle,
  ClipboardList,
  Hash,
  Package,
  ArrowLeft,
  Loader2,
  X,
  FileX,
  CheckCircle2,
  Clock,
  AlertTriangle,
  ChevronRight,
  Boxes
} from "lucide-react";

/* ─── Confirmation Modal ─── */
function ConfirmModal({ isOpen, title, message, onConfirm, onCancel, isLoading }) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 animate-in fade-in duration-200">
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" onClick={onCancel} />
      <div className="relative bg-white rounded-2xl shadow-2xl border border-gray-100 w-full max-w-md p-6 animate-in zoom-in-95 duration-200">
        <div className="flex items-start gap-4">
          <div className="p-3 bg-red-50 rounded-xl shrink-0">
            <AlertTriangle className="w-6 h-6 text-red-600" />
          </div>
          <div className="flex-1">
            <h3 className="text-lg font-bold text-gray-900">{title}</h3>
            <p className="text-sm text-gray-500 mt-1 leading-relaxed">{message}</p>
          </div>
        </div>

        <div className="flex gap-3 justify-end mt-6">
          <button
            onClick={onCancel}
            disabled={isLoading}
            className="px-4 py-2.5 rounded-xl text-sm font-semibold text-gray-600 bg-gray-50 border border-gray-200 hover:bg-gray-100 transition-all disabled:opacity-50"
          >
            Cancel
          </button>
          <button
            onClick={onConfirm}
            disabled={isLoading}
            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-semibold text-white bg-red-600 hover:bg-red-700 shadow-lg shadow-red-200 hover:shadow-red-300 hover:-translate-y-0.5 active:translate-y-0 disabled:opacity-60 disabled:hover:translate-y-0 transition-all duration-200"
          >
            {isLoading ? (
              <>
                <Loader2 className="w-4 h-4 animate-spin" />
                Deleting...
              </>
            ) : (
              <>
                <Trash2 className="w-4 h-4" />
                Delete
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  );
}

/* ─── Status Badge ─── */
function StatusBadge({ status, size = "md" }) {
  const normalized = (status || "pending").toLowerCase();
  
  const styles = {
    completed: "bg-emerald-50 text-emerald-700 border-emerald-100",
    complete: "bg-emerald-50 text-emerald-700 border-emerald-100",
    pending: "bg-amber-50 text-amber-700 border-amber-100",
    processing: "bg-blue-50 text-blue-700 border-blue-100",
    cancelled: "bg-red-50 text-red-700 border-red-100",
    default: "bg-gray-50 text-gray-600 border-gray-100",
  };

  const icons = {
    completed: CheckCircle2,
    complete: CheckCircle2,
    pending: Clock,
    processing: Loader2,
    cancelled: AlertCircle,
    default: AlertCircle,
  };

  const style = styles[normalized] || styles.default;
  const Icon = icons[normalized] || icons.default;

  const sizeClasses = size === "sm" 
    ? "px-2 py-0.5 text-[11px] gap-1" 
    : "px-2.5 py-1 text-xs gap-1.5";

  return (
    <span className={`inline-flex items-center rounded-full font-semibold border ${sizeClasses} ${style}`}>
      <Icon className={`${size === "sm" ? "w-3 h-3" : "w-3.5 h-3.5"} ${normalized === "processing" ? "animate-spin" : ""}`} />
      <span className="capitalize">{status || "Pending"}</span>
    </span>
  );
}

/* ─── Skeleton Loading State ─── */
function SkeletonHeader() {
  return (
    <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 animate-pulse">
      <div className="flex items-start justify-between">
        <div className="space-y-3 flex-1">
          <div className="h-6 bg-gray-200 rounded-lg w-1/3" />
          <div className="h-4 bg-gray-200 rounded-lg w-1/4" />
          <div className="h-4 bg-gray-200 rounded-lg w-1/5" />
        </div>
        <div className="h-10 w-28 bg-gray-200 rounded-xl" />
      </div>
    </div>
  );
}

function SkeletonTable() {
  return (
    <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden animate-pulse">
      <div className="p-4 bg-gray-50 border-b border-gray-100 flex gap-4">
        {[1, 2, 3, 4, 5, 6].map((i) => (
          <div key={i} className="h-4 bg-gray-200 rounded flex-1" />
        ))}
      </div>
      {[1, 2, 3, 4, 5].map((i) => (
        <div key={i} className="p-4 border-b border-gray-50 flex gap-4 items-center">
          <div className="h-4 bg-gray-200 rounded w-8" />
          <div className="h-4 bg-gray-200 rounded w-24" />
          <div className="h-4 bg-gray-200 rounded flex-1" />
          <div className="h-4 bg-gray-200 rounded w-16" />
          <div className="h-4 bg-gray-200 rounded w-16" />
          <div className="h-4 bg-gray-200 rounded w-20" />
        </div>
      ))}
    </div>
  );
}

/* ─── Empty State ─── */
function NotFoundState({ onBack }) {
  return (
    <div className="min-h-[60vh] flex flex-col items-center justify-center text-center px-4">
      <div className="p-6 bg-red-50 rounded-2xl mb-6">
        <FileX className="w-12 h-12 text-red-400" />
      </div>
      <h2 className="text-xl font-bold text-gray-900">Picklist Not Found</h2>
      <p className="text-sm text-gray-500 mt-2 max-w-sm">
        The picklist you're looking for doesn't exist or may have been deleted.
      </p>
      <button
        onClick={onBack}
        className="mt-6 inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-semibold text-purple-700 bg-purple-50 border border-purple-100 hover:bg-purple-100 transition-all"
      >
        <ArrowLeft className="w-4 h-4" />
        Back to Picklists
      </button>
    </div>
  );
}

/* ─── Main Component ─── */
export default function PickListDetail() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [isDeleting, setIsDeleting] = useState(false);

  const token = localStorage.getItem("token");

  useEffect(() => {
    fetchPicklist();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const fetchPicklist = async () => {
    try {
      setLoading(true);
      const res = await fetch(
        "https://pick-list.onrender.com/api/picklist",
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      const all = await res.json();
      const found = all.find(
        (p) =>
          p.pick_list_no?.toLowerCase() === id?.toLowerCase() ||
          p._id === id
      );

      setData(found);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    setIsDeleting(true);
    try {
      const deleteId = data._id;

      const res = await fetch(
        `https://pick-list.onrender.com/api/picklist/${deleteId}`,
        {
          method: "DELETE",
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      const result = await res.json();

      if (!res.ok) {
        alert(result.message || "Delete failed");
        setIsDeleting(false);
        return;
      }

      setShowDeleteModal(false);
      navigate("/picklists");

    } catch (err) {
      console.error("❌ Delete error:", err);
      alert("Something went wrong");
      setIsDeleting(false);
    }
  };

  // ✅ LOADING
  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50/50">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 py-8 space-y-6">
          <div className="flex items-center gap-2 text-sm text-gray-400 mb-4">
            <ArrowLeft className="w-4 h-4" />
            <span>Picklists</span>
            <ChevronRight className="w-3 h-3" />
            <span className="text-gray-300">Loading...</span>
          </div>
          <SkeletonHeader />
          <SkeletonTable />
        </div>
      </div>
    );
  }

  // ❌ NOT FOUND
  if (!data) {
    return (
      <div className="min-h-screen bg-gray-50/50">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 py-8">
          <NotFoundState onBack={() => navigate("/picklists")} />
        </div>
      </div>
    );
  }

  const completedParts = data.parts?.filter((p) => 
    (p.status || "").toLowerCase() === "completed"
  ).length || 0;

  const totalParts = data.parts?.length || 0;

  return (
    <div className="min-h-screen bg-gray-50/50">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 py-8 space-y-6">

        {/* Breadcrumb */}
        <button
          onClick={() => navigate("/picklists")}
          className="inline-flex items-center gap-2 text-sm text-gray-500 hover:text-purple-600 transition-colors group"
        >
          <ArrowLeft className="w-4 h-4 group-hover:-translate-x-0.5 transition-transform" />
          Back to Picklists
        </button>

        {/* Header Card */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 sm:p-8">
          <div className="flex flex-col lg:flex-row lg:items-start justify-between gap-6">
            
            {/* Left: Info */}
            <div className="space-y-5 flex-1">
              <div className="flex items-center gap-3">
                <div className="p-2.5 bg-purple-50 rounded-xl">
                  <ClipboardList className="w-6 h-6 text-purple-600" />
                </div>
                <div>
                  <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">
                    Pick List Detail
                  </p>
                  <h1 className="text-2xl sm:text-3xl font-bold text-gray-900 tracking-tight mt-0.5">
                    {data.pick_list_no}
                  </h1>
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div className="flex items-center gap-3 p-4 bg-gray-50/70 rounded-xl border border-gray-100">
                  <div className="p-2 bg-white rounded-lg shadow-sm">
                    <Hash className="w-4 h-4 text-gray-500" />
                  </div>
                  <div>
                    <p className="text-xs font-medium text-gray-400 uppercase tracking-wider">Order No</p>
                    <p className="text-sm font-bold text-gray-900 mt-0.5">{data.order_number || "—"}</p>
                  </div>
                </div>

                <div className="flex items-center gap-3 p-4 bg-gray-50/70 rounded-xl border border-gray-100">
                  <div className="p-2 bg-white rounded-lg shadow-sm">
                    <Package className="w-4 h-4 text-gray-500" />
                  </div>
                  <div>
                    <p className="text-xs font-medium text-gray-400 uppercase tracking-wider">Total Parts</p>
                    <p className="text-sm font-bold text-gray-900 mt-0.5">{totalParts}</p>
                  </div>
                </div>

                <div className="flex items-center gap-3 p-4 bg-gray-50/70 rounded-xl border border-gray-100">
                  <div className="p-2 bg-white rounded-lg shadow-sm">
                    <Boxes className="w-4 h-4 text-gray-500" />
                  </div>
                  <div>
                    <p className="text-xs font-medium text-gray-400 uppercase tracking-wider">Completed</p>
                    <p className="text-sm font-bold text-gray-900 mt-0.5">
                      {completedParts} <span className="text-gray-400 font-normal">/ {totalParts}</span>
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Right: Actions */}
            <div className="flex flex-col items-start lg:items-end gap-3 shrink-0">
              <StatusBadge status={data.status} />
              <button
                onClick={() => setShowDeleteModal(true)}
                className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold text-red-700 bg-red-50 border border-red-100 hover:bg-red-100 hover:border-red-200 transition-all duration-200"
              >
                <Trash2 className="w-4 h-4" />
                Delete Picklist
              </button>
            </div>
          </div>
        </div>

        {/* Parts Table */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
          <div className="px-6 py-5 border-b border-gray-100 flex items-center justify-between">
            <h2 className="text-sm font-bold text-gray-900 uppercase tracking-wider">
              Parts List
            </h2>
            <span className="text-xs font-medium text-gray-400">
              {totalParts} item{totalParts !== 1 ? "s" : ""}
            </span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-sm text-left">
              <thead className="bg-gray-50 text-gray-500 font-semibold text-xs uppercase tracking-wider sticky top-0 z-10">
                <tr>
                  <th className="px-6 py-4 w-14">ID</th>
                  <th className="px-6 py-4">Part Number</th>
                  <th className="px-6 py-4">Description</th>
                  <th className="px-6 py-4 w-24 text-right">Req Qty</th>
                  <th className="px-6 py-4 w-24 text-right">Allo Qty</th>
                  <th className="px-6 py-4 w-28">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {data.parts?.map((part, index) => (
                  <tr
                    key={index}
                    className="group bg-white hover:bg-purple-50/30 transition-colors duration-150"
                  >
                    <td className="px-6 py-4 text-gray-400 font-mono text-xs">
                      {index + 1}
                    </td>
                    <td className="px-6 py-4">
                      <span className="inline-flex items-center px-2.5 py-1 rounded-md bg-purple-50 text-purple-700 font-mono text-xs font-semibold border border-purple-100">
                        {part.partno}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-gray-700 font-medium">
                      {part.description}
                    </td>
                    <td className="px-6 py-4 text-right">
                      <span className="inline-flex items-center justify-center min-w-[2.5rem] px-2 py-1 rounded-md bg-gray-100 text-gray-700 font-bold text-xs">
                        {part.req_qty}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <span className={`inline-flex items-center justify-center min-w-[2.5rem] px-2 py-1 rounded-md text-xs font-bold ${
                        (part.allo_qty || 0) >= (part.req_qty || 0)
                          ? "bg-emerald-50 text-emerald-700"
                          : "bg-amber-50 text-amber-700"
                      }`}>
                        {part.allo_qty || 0}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <StatusBadge status={part.status} size="sm" />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {totalParts === 0 && (
            <div className="py-16 text-center">
              <div className="inline-flex p-4 bg-gray-50 rounded-full mb-3">
                <Package className="w-8 h-8 text-gray-300" />
              </div>
              <h3 className="text-sm font-semibold text-gray-900">No parts in this picklist</h3>
            </div>
          )}
        </div>

      </div>

      {/* Delete Confirmation Modal */}
      <ConfirmModal
        isOpen={showDeleteModal}
        title="Delete Picklist"
        message={`Are you sure you want to delete picklist "${data.pick_list_no}"? This action cannot be undone and will remove all associated parts.`}
        onConfirm={handleDelete}
        onCancel={() => setShowDeleteModal(false)}
        isLoading={isDeleting}
      />
    </div>
  );
}