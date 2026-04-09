const express = require("express");
const router = express.Router();
const authenticateToken = require("../Middleware/authentication");

const {
  createPickList,
  assignPickList,
  deleteAllPickLists,
  deletePickListByNumber,
  updateScan,
  proceedWithShortage,
  getAllPickLists
} = require("../Controllers/pickListController");

const {
  downloadExcelReport,
  downloadCSVReport,
  downloadAllPicklistsExcel
} = require("../Controllers/reportController");

// core picklist operations
router.post("/", authenticateToken, createPickList);
router.get("/", authenticateToken, getAllPickLists);
router.patch("/:id/assign", authenticateToken, assignPickList);

// Updated: Scan one item at a time
router.patch("/:id/scan", authenticateToken, updateScan);

// New: Triggered when worker forces completion despite shortage
router.post("/:id/proceed", authenticateToken, proceedWithShortage);

// New: Global Master Report
router.get("/report/all/excel", authenticateToken, downloadAllPicklistsExcel);

// New: Reporting endpoints
router.get("/:id/report/excel", authenticateToken, downloadExcelReport);
router.get("/:id/report/csv", authenticateToken, downloadCSVReport);

// deletions
router.delete("/delete", deleteAllPickLists);
router.delete("/:pickListNumber", deletePickListByNumber);

module.exports = router;