export default function Filters() {
  return (
    <div className="flex gap-3">

      <input
        placeholder="Search..."
        className="border px-3 py-2 rounded"
      />

      <select className="border px-3 py-2 rounded">
        <option>Status</option>
      </select>

    </div>
  );
}