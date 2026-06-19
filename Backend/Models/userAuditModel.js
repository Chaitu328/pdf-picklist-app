const mongoose = require("mongoose");

const DailyLoginSchema = new mongoose.Schema(
  {
    loginCount: {
      type: Number,
      default: 0
    },
    logoutCount: {
      type: Number,
      default: 0
    },
    loginTimings: {
      type: [String],
      default: []
    },
    logoutTimings: {
      type: [String],
      default: []
    }
  },
  { _id: false }
);

const UserLoginDetailsSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    loginDetails: {
      type: Map,
      of: DailyLoginSchema,
      default: {}
    }
  },
  { _id: false }
);

const UserAuditSchema = new mongoose.Schema(
  {
    role: {
      type: String,
      enum: ["manager", "worker"],
      required: true,
      unique: true
    },
    users: {
      type: [UserLoginDetailsSchema],
      default: []
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model("UserAudit", UserAuditSchema);
