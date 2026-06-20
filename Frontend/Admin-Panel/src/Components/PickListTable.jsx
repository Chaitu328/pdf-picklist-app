import { useNavigate } from "react-router-dom";
import {
  Eye,
  ChevronRight,
  Package,
  AlertCircle,
  CheckCircle2,
  Clock,
  User,
  Inbox,
} from "lucide-react";

export default function PickListTable({
  data = [],
  selectable = false,
  selected = [],
  onSelect,
}) {
  const navigate = useNavigate();

  const toggleSelect = (id) => {
    if (!onSelect) return;
    if (selected.includes(id)) {
      onSelect(selected.filter((i) => i !== id));
    } else {
      onSelect([...selected, id]);
    }
  };

  const toggleAll = () => {
    if (!onSelect) return;
    if (selected.length === data.length) {
      onSelect([]);
    } else {
      onSelect(data.map((d) => d._id));
    }
  };

  const statusConfig = (status) => {
    switch (status) {
      case "IN_PROGRESS":
        return {
          class: "bg-amber-50 text-amber-700 border-amber-200",
          icon: <Clock className="w-3 h-3 mr-1.5" />,
          label: "In Progress",
        };
      case "PENDING":
        return {
          class: "bg-blue-50 text-blue-700 border-blue-200",
          icon: <AlertCircle className="w-3 h-3 mr-1.5" />,
          label: "Pending",
        };
      case "COMPLETED":
        return {
          class: "bg-emerald-50 text-emerald-700 border-emerald-200",
          icon: <CheckCircle2 className="w-3 h-3 mr-1.5" />,
          label: "Completed",
        };
      default:
        return {
          class: "bg-slate-100 text-slate-700 border-slate-200",
          icon: null,
          label: status,
        };
    }
  };

  const getAvatarColor = (name) => {
    if (!name) return "bg-slate-100 text-slate-500";
    const colors = [
      "bg-blue-100 text-blue-700",
      "bg-emerald-100 text-emerald-700",
      "bg-violet-100 text-violet-700",
      "bg-amber-100 text-amber-700",
      "bg-rose-100 text-rose-700",
      "bg-cyan-100 text-cyan-700",
    ];
    let hash = 0;
    for (let i = 0; i < name.length; i++)
      hash = name.charCodeAt(i) + ((hash << 5) - hash);
    return colors[Math.abs(hash) % colors.length];
  };

  const getInitials = (name) => {
    if (!name) return "-";
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2);
  };

  if (data.length === 0) {
    return (
      <div className="bg-white rounded-2xl border border-slate-200/60 shadow-[0_1px_3px_0_rgba(0,0,0,0.04)] p-12 flex flex-col items-center justify-center text-center">
        <div className="w-14 h-14 rounded-2xl bg-slate-50 flex items-center justify-center mb-4">
          <Inbox className="w-7 h-7 text-slate-300" />
        </div>
        <h3 className="text-sm font-semibold text-slate-900">No pick lists found</h3>
        <p className="text-sm text-slate-500 mt-1">
          There are no pick lists to display at the moment.
        </p>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-2xl border border-slate-200/60 shadow-[0_1px_3px_0_rgba(0,0,0,0.04)] overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full text-sm text-left">
          <thead className="bg-slate-50 text-slate-500 text-xs font-semibold uppercase tracking-wider">
            <tr>
              {selectable && (
                <th className="px-5 py-3.5 w-12">
                  <input
                    type="checkbox"
                    checked={selected.length === data.length && data.length > 0}
                    onChange={toggleAll}
                    className="w-4 h-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500/20 accent-blue-600 cursor-pointer"
                  />
                </th>
              )}
              <th className="px-5 py-3.5">Pick List</th>
              <th className="px-5 py-3.5">Order</th>
              <th className="px-5 py-3.5">Client</th>
              <th className="px-5 py-3.5">Worker</th>
              <th className="px-5 py-3.5">Status</th>
              <th className="px-5 py-3.5 w-20"></th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {data.map((item) => {
              const isSelected = selected.includes(item._id);
              const status = statusConfig(item.status);
              const workerName = item.workerId?.name;
              return (
                <tr
                  key={item._id}
                  className={`group transition-colors duration-150 ${
                    isSelected
                      ? "bg-blue-50/50"
                      : "hover:bg-slate-50/80"
                  }`}
                >
                  {selectable && (
                    <td className="px-5 py-4">
                      <input
                        type="checkbox"
                        checked={isSelected}
                        onChange={() => toggleSelect(item._id)}
                        className="w-4 h-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500/20 accent-blue-600 cursor-pointer"
                      />
                    </td>
                  )}
                  <td className="px-5 py-4">
                    <button
                      onClick={() => navigate(`/picklists/${item._id}`)}
                      className="text-sm font-semibold text-blue-700 hover:text-blue-800 hover:underline underline-offset-4 transition-colors"
                    >
                      {item.pick_list_no}
                    </button>
                  </td>
                  <td className="px-5 py-4 text-slate-600 font-medium">
                    {item.order_number}
                  </td>
                  <td className="px-5 py-4 text-slate-700 font-medium">
                    {item.clientId?.name || (
                      <span className="text-slate-400 italic">—</span>
                    )}
                  </td>
                  <td className="px-5 py-4">
                    <div className="flex items-center gap-2.5">
                      <div
                        className={`w-7 h-7 rounded-full flex items-center justify-center text-[10px] font-bold flex-shrink-0 ${getAvatarColor(
                          workerName
                        )}`}
                      >
                        {workerName ? (
                          getInitials(workerName)
                        ) : (
                          <User className="w-3 h-3" />
                        )}
                      </div>
                      <span className="text-slate-700 font-medium">
                        {workerName || (
                          <span className="text-slate-400 italic">Unassigned</span>
                        )}
                      </span>
                    </div>
                  </td>
                  <td className="px-5 py-4">
                    <span
                      className={`inline-flex items-center px-2.5 py-1 text-xs font-semibold rounded-full border ${status.class}`}
                    >
                      {status.icon}
                      {status.label}
                    </span>
                  </td>
                  <td className="px-5 py-4">
                    <button
                      onClick={() => navigate(`/picklists/${item._id}`)}
                      className="inline-flex items-center justify-center gap-1 p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-all duration-200 opacity-0 group-hover:opacity-100 focus:opacity-100"
                      title="View details"
                    >
                      <Eye className="w-4 h-4" />
                      <ChevronRight className="w-3 h-3 -ml-1" />
                    </button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}