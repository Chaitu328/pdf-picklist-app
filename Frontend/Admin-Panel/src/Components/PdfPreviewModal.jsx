import {
  FileText,
  X,
  Building2,
  Calendar,
  User,
  Package,
  MapPin,
  AlertTriangle,
  Clock,
  UserCheck,
  Download,
  ChevronRight,
} from "lucide-react";

export default function PdfPreviewModal({ onClose }) {
  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-in fade-in duration-200">
      {/* MODAL */}
      <div className="bg-white w-full max-w-[960px] rounded-2xl shadow-2xl shadow-black/20 overflow-hidden flex flex-col max-h-[90vh]">
        
        {/* HEADER */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-white">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-lg bg-blue-50 flex items-center justify-center">
              <FileText className="w-5 h-5 text-blue-600" />
            </div>
            <div>
              <h2 className="text-sm font-bold text-slate-900">PDF Pick List Preview</h2>
              <p className="text-xs text-slate-500 mt-0.5">Review before downloading or printing</p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="p-2 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-lg transition-all duration-200"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* BODY - A4 PREVIEW AREA */}
        <div className="flex-1 overflow-y-auto bg-[#F1F5F9] p-6 sm:p-8 flex justify-center">
          {/* A4 SHEET */}
          <div className="bg-white w-full max-w-[700px] p-10 sm:p-12 shadow-[0_4px_24px_-4px_rgba(0,0,0,0.08)] rounded-sm ring-1 ring-slate-900/5">
            
            {/* TOP HEADER */}
            <div className="flex justify-between items-start">
              <div>
                <div className="flex items-center gap-2 mb-3">
                  <div className="w-8 h-8 rounded-lg bg-blue-700 flex items-center justify-center">
                    <Building2 className="w-4 h-4 text-white" />
                  </div>
                  <h2 className="text-lg font-bold text-slate-900 tracking-tight">LogiTrack</h2>
                </div>
                <h1 className="text-2xl sm:text-3xl font-extrabold text-slate-900 tracking-tight mt-1">
                  Warehouse Pick List
                </h1>
              </div>

              <div className="text-right space-y-4">
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">
                    Generated Date
                  </p>
                  <div className="flex items-center justify-end gap-1.5 text-sm text-slate-700 font-medium">
                    <Calendar className="w-3.5 h-3.5 text-slate-400" />
                    October 24, 2023 • 14:32 PM
                  </div>
                </div>

                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">
                    Admin Name
                  </p>
                  <div className="flex items-center justify-end gap-1.5 text-sm text-slate-700 font-medium">
                    <User className="w-3.5 h-3.5 text-slate-400" />
                    Alex Rivera <span className="text-slate-400 font-normal">(ID: 4492)</span>
                  </div>
                </div>
              </div>
            </div>

            <div className="h-px bg-slate-200 my-8" />

            {/* CARDS */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-5 mb-8">
              
              {/* Order Details */}
              <div className="bg-slate-50/80 border border-slate-100 rounded-xl p-5">
                <div className="flex items-center gap-2 mb-4">
                  <Package className="w-3.5 h-3.5 text-slate-400" />
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">
                    Order Details
                  </p>
                </div>
                <div className="space-y-3">
                  <div className="flex justify-between items-baseline">
                    <span className="text-sm text-slate-500">Pick List ID</span>
                    <span className="text-sm font-semibold text-slate-900">PL-2023-90210</span>
                  </div>
                  <div className="flex justify-between items-baseline">
                    <span className="text-sm text-slate-500">Origin Warehouse</span>
                    <span className="text-sm font-semibold text-slate-900">North Hub WH-A2</span>
                  </div>
                  <div className="flex justify-between items-baseline">
                    <span className="text-sm text-slate-500">Priority Level</span>
                    <span className="inline-flex items-center gap-1 text-xs font-bold text-red-600 bg-red-50 px-2 py-0.5 rounded-full border border-red-100">
                      <AlertTriangle className="w-3 h-3" />
                      CRITICAL
                    </span>
                  </div>
                </div>
              </div>

              {/* Assignment */}
              <div className="bg-slate-50/80 border border-slate-100 rounded-xl p-5">
                <div className="flex items-center gap-2 mb-4">
                  <UserCheck className="w-3.5 h-3.5 text-slate-400" />
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">
                    Assignment
                  </p>
                </div>
                <div className="space-y-3">
                  <div className="flex justify-between items-baseline">
                    <span className="text-sm text-slate-500">Worker Name</span>
                    <span className="text-sm font-semibold text-slate-900">James Miller</span>
                  </div>
                  <div className="flex justify-between items-baseline">
                    <span className="text-sm text-slate-500">Worker Zone</span>
                    <span className="text-sm font-semibold text-slate-900">Zone D (Electronics)</span>
                  </div>
                  <div className="flex justify-between items-baseline">
                    <span className="text-sm text-slate-500">Est. Pick Time</span>
                    <span className="inline-flex items-center gap-1 text-sm font-semibold text-slate-900">
                      <Clock className="w-3.5 h-3.5 text-slate-400" />
                      45 Minutes
                    </span>
                  </div>
                </div>
              </div>

            </div>

            {/* TABLE */}
            <div>
              <div className="flex items-center gap-2 mb-4">
                <Package className="w-3.5 h-3.5 text-slate-400" />
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">
                  Items to Pick
                </p>
              </div>

              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-slate-200">
                    <th className="text-left py-3 text-[10px] font-bold text-slate-400 uppercase tracking-wider w-[35%]">
                      SKU / Item
                    </th>
                    <th className="text-center py-3 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
                      Location
                    </th>
                    <th className="text-center py-3 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
                      Qty
                    </th>
                    <th className="text-center py-3 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
                      Picked
                    </th>
                    <th className="text-left py-3 text-[10px] font-bold text-slate-400 uppercase tracking-wider pl-4">
                      Note
                    </th>
                  </tr>
                </thead>

                <tbody className="divide-y divide-slate-100">
                  {[
                    {
                      name: "CPU-AMD-RYZEN9",
                      desc: "AMD Ryzen 9 5900X Processor",
                      loc: "D-12-04-A",
                      qty: 12,
                      note: "Fragile handling",
                    },
                    {
                      name: "GPU-NV-3080-TI",
                      desc: "NVIDIA RTX 3080 Ti",
                      loc: "D-12-04-B",
                      qty: 8,
                    },
                    {
                      name: "RAM-COR-32GB-D4",
                      desc: "Corsair 32GB DDR4",
                      loc: "D-09-01-F",
                      qty: 24,
                    },
                  ].map((item, i) => (
                    <tr
                      key={i}
                      className="group transition-colors duration-150 hover:bg-slate-50/50"
                    >
                      <td className="py-4">
                        <p className="font-semibold text-slate-900">{item.name}</p>
                        <p className="text-xs text-slate-500 mt-0.5">{item.desc}</p>
                      </td>

                      <td className="py-4 text-center">
                        <span className="inline-flex items-center gap-1 text-xs font-medium text-slate-600 bg-slate-100 px-2 py-1 rounded">
                          <MapPin className="w-3 h-3" />
                          {item.loc}
                        </span>
                      </td>

                      <td className="py-4 text-center font-semibold text-slate-900">
                        {item.qty}
                      </td>

                      <td className="py-4 text-center">
                        <div className="w-14 h-7 border-2 border-slate-300 rounded bg-white mx-auto flex items-center justify-center group-hover:border-slate-400 transition-colors" />
                      </td>

                      <td className="py-4 pl-4">
                        <span className="text-xs text-slate-400 italic">
                          {item.note || "—"}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

          </div>
        </div>

        {/* FOOTER */}
        <div className="flex items-center justify-end gap-3 px-6 py-4 border-t border-slate-100 bg-white">
          <button
            onClick={onClose}
            className="inline-flex items-center gap-2 px-5 py-2.5 bg-white border border-slate-200 text-slate-700 text-sm font-medium rounded-xl hover:bg-slate-50 hover:border-slate-300 transition-all duration-200"
          >
            Cancel
          </button>

          <button className="inline-flex items-center gap-2 px-5 py-2.5 bg-blue-600 text-white text-sm font-medium rounded-xl hover:bg-blue-700 transition-all duration-200 shadow-sm shadow-blue-200 active:scale-[0.98]">
            <Download className="w-4 h-4" />
            Download PDF
          </button>
        </div>

      </div>
    </div>
  );
}