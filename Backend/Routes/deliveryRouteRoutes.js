const express = require("express");
const router = express.Router();
const authenticateToken = require("../Middleware/authentication");
const {
  importDeliveryRoutes,
  getDeliveryRoutesGroupedByDay,
  addDeliveryRoutes,
  deleteDeliveryRoutes
} = require("../Controllers/deliveryRouteController");

router.post(
  "/import",
  authenticateToken,
  express.raw({
    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    limit: "15mb"
  }),
  importDeliveryRoutes
);

router.get("/", authenticateToken, getDeliveryRoutesGroupedByDay);
router.post("/", authenticateToken, addDeliveryRoutes);
router.delete("/", authenticateToken, deleteDeliveryRoutes);

module.exports = router;
