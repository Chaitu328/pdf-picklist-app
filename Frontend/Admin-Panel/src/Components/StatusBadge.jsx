// src/components/StatusBadge.jsx
export default function StatusBadge({ status }) {
  const colors = {
    unassigned: "bg-gray-200 text-gray-700",
    assigned: "bg-blue-100 text-blue-700",
    processing: "bg-yellow-100 text-yellow-700",
    completed: "bg-green-100 text-green-700",
    completed_with_shortage: "bg-red-100 text-red-700",
  };

  return (
    <span className={`px-2 py-1 rounded text-xs ${colors[status]}`}>
      {status}
    </span>
  );
}