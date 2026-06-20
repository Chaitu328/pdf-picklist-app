const mongoose = require("mongoose");

// Schema to track individual scanned/entered items
const ScannedItemSchema = new mongoose.Schema({
  unique_id: {
    type: String,
    default: null // Will be null if entered manually
  },
  entry_method: {
    type: String,
    enum: ["QR", "Manual"],
    required: true
  },
  workerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    default: null
  },
  scannedAt: {
    type: Date,
    default: Date.now
  }
});

const PartSchema = new mongoose.Schema({
  partno: {
    type: String,
    required: true
  },
  description: {
    type: String
  },
  req_qty: {
    type: Number,
    required: true
  },
  allo_qty: {
    type: Number,
    default: 0
  },
  status: {
    type: String,
    enum: ["pending", "partial", "shortage", "excess", "completed"],
    default: "pending"
  },
  scanned_items: [ScannedItemSchema] // Granular tracking array
});

const PickListSchema = new mongoose.Schema({
  pick_list_no: {
    type: String,
    required: true,
    unique: true
  },
  order_number: {
    type: String,
    required: true
  },
  picklist_date: {
    type: String,
    default: "Not provided"
  },
  route_day: {
    type: String,
    enum: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "Any"],
    default: "Any" // Used for PJP priority logic
  },
  clientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  workerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    default: null
  },
  workerIds: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User"
    }
  ],
  status: {
    type: String,
    enum: ["unassigned", "assigned", "processing", "completed", "completed_with_shortage"],
    default: "unassigned"
  },
  parts: [PartSchema],
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model("PickList", PickListSchema);