const express = require("express");
const router = express.Router();
const authenticateToken = require("../Middleware/authentication");
const {
  getUserEvents,
  getRouteEvents,
  getManagerProgressEvents,
  getWorkerProgressEvents
} = require("../Controllers/auditController");

router.get("/user-events", authenticateToken, getUserEvents);
router.get("/route-events", authenticateToken, getRouteEvents);
router.get("/manager-progress", authenticateToken, getManagerProgressEvents);
router.get("/worker-progress", authenticateToken, getWorkerProgressEvents);

module.exports = router;
