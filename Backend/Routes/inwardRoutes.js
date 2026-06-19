const express = require("express");
const router = express.Router();

const {
  createInward,
  getAllInward,
  assignInward,
  scanInwardPart,
  completeInward,
} = require("../controllers/inwardController");

const authenticateToken = require("../Middleware/authentication");

router.post("/", authenticateToken, createInward);

router.get("/", authenticateToken, getAllInward);

router.patch("/:id/assign", authenticateToken, assignInward);

router.patch("/:id/scan", authenticateToken, scanInwardPart);

router.post("/:id/complete", authenticateToken, completeInward);

module.exports = router;