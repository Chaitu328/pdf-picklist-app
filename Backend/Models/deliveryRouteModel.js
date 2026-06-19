const mongoose = require("mongoose");

const DeliveryRouteSchema = new mongoose.Schema({
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
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

DeliveryRouteSchema.pre("save", function (next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model("DeliveryRoute", DeliveryRouteSchema);
