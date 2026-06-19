const mongoose = require("mongoose");

const RouteAuditSchema = new mongoose.Schema(
  {
    action: {
      type: String,
      enum: ["created", "deleted"],
      required: true
    },
    actorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    routeId: {
      type: mongoose.Schema.Types.ObjectId,
      default: null
    },
    routeDetails: {
      networkCode: {
        type: String,
        default: ""
      },
      companyName: {
        type: String,
        default: ""
      },
      city: {
        type: String,
        default: ""
      },
      deliveryDay: {
        type: String,
        default: ""
      }
    },
    actionDate: {
      type: String,
      required: true
    },
    actionTime: {
      type: String,
      required: true
    },
    source: {
      type: String,
      enum: ["manual", "import"],
      default: "manual"
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model("RouteAudit", RouteAuditSchema);
