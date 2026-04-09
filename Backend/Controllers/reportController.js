const PickList = require("../Models/pickListModel");
const ExcelJS = require("exceljs");
const { Parser } = require("json2csv");

// Helper to format data
const formatReportData = (picklist) => {
  const data = [];
  picklist.parts.forEach(part => {
    if (part.scanned_items.length === 0) {
      data.push({
        PickListNo: picklist.pick_list_no,
        OrderNo: picklist.order_number,
        Worker: picklist.workerId ? picklist.workerId.name : "Unassigned",
        PartNo: part.partno,
        Required: part.req_qty,
        Allocated: part.allo_qty,
        Status: part.status,
        Unique_ID: "None",
        Method: "None",
        Time: "N/A"
      });
    } else {
      part.scanned_items.forEach(scan => {
        data.push({
          PickListNo: picklist.pick_list_no,
          OrderNo: picklist.order_number,
          Worker: picklist.workerId ? picklist.workerId.name : "Unassigned",
          PartNo: part.partno,
          Required: part.req_qty,
          Allocated: part.allo_qty,
          Status: part.status,
          Unique_ID: scan.unique_id || "N/A (Manual)",
          Method: scan.entry_method,
          Time: scan.scannedAt.toISOString()
        });
      });
    }
  });
  return data;
};

const downloadExcelReport = async (req, res) => {
  try {
    const picklist = await PickList.findById(req.params.id).populate("workerId", "name");
    if (!picklist) return res.status(404).json({ message: "Picklist not found" });

    const data = formatReportData(picklist);
    
    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet("Scan History");
    
    worksheet.columns = [
      { header: "PickList No", key: "PickListNo", width: 15 },
      { header: "Order No", key: "OrderNo", width: 15 },
      { header: "Worker", key: "Worker", width: 20 },
      { header: "Part No", key: "PartNo", width: 15 },
      { header: "Req Qty", key: "Required", width: 10 },
      { header: "Alloc Qty", key: "Allocated", width: 10 },
      { header: "Status", key: "Status", width: 15 },
      { header: "Unique ID", key: "Unique_ID", width: 25 },
      { header: "Method", key: "Method", width: 15 },
      { header: "Time Scanned", key: "Time", width: 25 }
    ];

    worksheet.addRows(data);

    res.setHeader("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
    res.setHeader("Content-Disposition", `attachment; filename=Report-${picklist.pick_list_no}.xlsx`);
    
    await workbook.xlsx.write(res);
    res.end();
  } catch (error) {
    res.status(500).json({ message: "Error generating Excel", error: error.message });
  }
};

const downloadCSVReport = async (req, res) => {
  try {
    const picklist = await PickList.findById(req.params.id).populate("workerId", "name");
    if (!picklist) return res.status(404).json({ message: "Picklist not found" });

    const data = formatReportData(picklist);
    const json2csvParser = new Parser();
    const csv = json2csvParser.parse(data);

    res.setHeader("Content-Type", "text/csv");
    res.setHeader("Content-Disposition", `attachment; filename=Report-${picklist.pick_list_no}.csv`);
    res.status(200).send(csv);
  } catch (error) {
    res.status(500).json({ message: "Error generating CSV", error: error.message });
  }
};

// NEW: Generate a structured, readable master report of ALL picklists
const downloadAllPicklistsExcel = async (req, res) => {
  try {
    // Fetch all picklists
    const picklists = await PickList.find().populate("workerId", "name");
    
    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet("Full Warehouse History");

    // Define column widths for the entire sheet
    worksheet.columns = [
      { width: 20 }, // Part No
      { width: 15 }, // Req Qty
      { width: 15 }, // Alloc Qty
      { width: 15 }, // Part Status
      { width: 30 }, // Unique ID
      { width: 15 }, // Method
      { width: 25 }  // Time Scanned
    ];

    picklists.forEach(picklist => {
      // 1. Create a Master Header Row for the specific Picklist
      const workerName = picklist.workerId ? picklist.workerId.name : "Unassigned";
      const headerRow = worksheet.addRow([
        `Picklist: ${picklist.pick_list_no}`, 
        `Order: ${picklist.order_number}`, 
        `Worker: ${workerName}`,
        `Status: ${picklist.status}`
      ]);
      
      // Style the Header Row (Bold text, dark blue background, white text)
      headerRow.font = { bold: true, color: { argb: 'FFFFFFFF' } };
      headerRow.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF0070C0' } }; 

      // 2. Create Column Headers for the parts table
      const colHeaders = worksheet.addRow([
        "Part No", "Req Qty", "Alloc Qty", "Part Status", "Unique ID", "Entry Method", "Time Scanned"
      ]);
      colHeaders.font = { bold: true, underline: true };

      // 3. Add the individual data rows for this picklist
      picklist.parts.forEach(part => {
        if (part.scanned_items.length === 0) {
          worksheet.addRow([
            part.partno, part.req_qty, part.allo_qty, part.status, "None", "None", "N/A"
          ]);
        } else {
          part.scanned_items.forEach(scan => {
            worksheet.addRow([
              part.partno, part.req_qty, part.allo_qty, part.status, 
              scan.unique_id || "N/A (Manual)", 
              scan.entry_method, 
              scan.scannedAt ? scan.scannedAt.toISOString() : "N/A"
            ]);
          });
        }
      });

      // 4. Add an empty row at the bottom to separate it from the next picklist
      worksheet.addRow([]);
    });

    // Explicitly set the MIME type for Excel
    res.setHeader(
      "Content-Type",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    );

    // Force the filename with double-quotes for maximum compatibility
    res.setHeader(
      "Content-Disposition",
      'attachment; filename="Global-Warehouse-Report.xlsx"'
    );
    
    
    await workbook.xlsx.write(res);
    res.end();
  } catch (error) {
    res.status(500).json({ message: "Error generating Global Excel", error: error.message });
  }
};

module.exports = { downloadExcelReport, downloadCSVReport, downloadAllPicklistsExcel };