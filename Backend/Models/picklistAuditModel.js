const mongoose = require("mongoose");

const UserSnapshotSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      default: null
    },
    name: {
      type: String,
      default: ""
    },
    email: {
      type: String,
      default: ""
    },
    role: {
      type: String,
      default: ""
    }
  },
  { _id: false }
);

const PartSnapshotSchema = new mongoose.Schema(
  {
    partno: {
      type: String,
      default: ""
    },
    description: {
      type: String,
      default: ""
    },
    req_qty: {
      type: Number,
      default: 0
    },
    allo_qty: {
      type: Number,
      default: 0
    },
    status: {
      type: String,
      default: ""
    },
    scanned: {
      type: Boolean,
      default: false
    },
    qrCount: {
      type: Number,
      default: 0
    },
    manualCount: {
      type: Number,
      default: 0
    }
  },
  { _id: false }
);

const PicklistSnapshotSchema = new mongoose.Schema(
  {
    picklistId: {
      type: String,
      default: null
    },
    pick_list_no: {
      type: String,
      default: ""
    },
    order_number: {
      type: String,
      default: ""
    },
    status: {
      type: String,
      default: ""
    },
    partCount: {
      type: Number,
      default: 0
    },
    workDone: {
      type: Boolean,
      default: false
    },
    qrScannedCount: {
      type: Number,
      default: 0
    },
    manualEnteredCount: {
      type: Number,
      default: 0
    },
    workerAssigned: {
      type: Boolean,
      default: false
    },
    parts: {
      type: [PartSnapshotSchema],
      default: []
    }
  },
  { _id: false }
);

const SelectedPartSchema = new mongoose.Schema(
  {
    partno: {
      type: String,
      default: ""
    },
    description: {
      type: String,
      default: ""
    },
    statusAtRequest: {
      type: String,
      default: ""
    }
  },
  { _id: false }
);

const PicklistAuditSchema = new mongoose.Schema(
  {
    eventType: {
      type: String,
      enum: [
        "picklist_created",
        "picklist_accepted",
        "picklist_worked",
        "picklist_reupdate_requested",
        "picklist_reupdated",
        "picklist_deleted"
      ],
      required: true
    },
    eventDate: {
      type: String,
      required: true,
      index: true
    },
    eventTime: {
      type: String,
      required: true
    },
    actor: {
      type: UserSnapshotSchema,
      required: true
    },
    creatorManager: {
      type: UserSnapshotSchema,
      default: () => ({})
    },
    assignedWorker: {
      type: UserSnapshotSchema,
      default: () => ({})
    },
    picklistSnapshot: {
      type: PicklistSnapshotSchema,
      required: true
    },
    actionSummary: {
      qrCount: {
        type: Number,
        default: 0
      },
      manualCount: {
        type: Number,
        default: 0
      },
      reupdatedPartCount: {
        type: Number,
        default: 0
      }
    },
    selectedReupdateParts: {
      type: [SelectedPartSchema],
      default: []
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model("PicklistAudit", PicklistAuditSchema);
