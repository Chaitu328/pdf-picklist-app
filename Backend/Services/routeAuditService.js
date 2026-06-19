const RouteAudit = require("../Models/routeAuditModel");
const { getDateKey, getTimeKey } = require("./userAuditService");

const normalizeRouteDetails = (route = {}) => ({
  networkCode: (route.networkCode ?? "").toString().trim(),
  companyName: (route.companyName ?? "").toString().trim(),
  city: (route.city ?? "").toString().trim(),
  deliveryDay: (route.deliveryDay ?? "").toString().trim()
});

const recordRouteAuditEvents = async ({
  actorId,
  action,
  routes = [],
  source = "manual",
  at = new Date()
}) => {
  if (!actorId || !["created", "deleted"].includes(action) || !Array.isArray(routes) || routes.length === 0) {
    return;
  }

  try {
    const actionDate = getDateKey(at);
    const actionTime = getTimeKey(at);

    const docs = routes.map((route) => ({
      action,
      actorId,
      routeId: route._id || null,
      routeDetails: normalizeRouteDetails(route),
      actionDate,
      actionTime,
      source
    }));

    await RouteAudit.insertMany(docs, { ordered: true });
  } catch (error) {
    console.error("Route audit write failed:", error.message);
  }
};

module.exports = {
  recordRouteAuditEvents
};
