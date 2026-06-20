const mongoose = require("mongoose");

const partSchema = new mongoose.Schema({
  partno: String,

  description: String,

  expected_qty: Number,

  received_qty: {
    type: Number,
    default: 0,
  },

  location: {
    rack: String,
    bin: String,
  },

  status: {
    type: String,
    enum: [
      "pending",
      "partial",
      "received",
      "shortage",
      "excess"
    ],
    default: "pending",
  },

  scanned_items: [
    {
      qr_code: String,

      scannedAt: {
        type: Date,
        default: Date.now,
      },
    },
  ],
});

const boxSchema = new mongoose.Schema({
  box_no: String,

  parts: [partSchema],
});

const inwardReceiptSchema = new mongoose.Schema(
  {
    truck_no: String,

    supplier_name: String,

    invoice_no: String,

    inward_date: String,

    workerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },

    status: {
      type: String,
      enum: [
        "unassigned",
        "assigned",
        "processing",
        "completed",
        "completed_with_shortage",
      ],
      default: "unassigned",
    },

    boxes: [boxSchema],
  },
  { timestamps: true }
);

module.exports = mongoose.model(
  "InwardReceipt",
  inwardReceiptSchema
);