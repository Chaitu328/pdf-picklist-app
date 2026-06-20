const ExcelJS = require("exceljs");
const DeliveryRoute = require("../Models/deliveryRouteModel");
const mongoose = require("mongoose");
const { recordRouteAuditEvents } = require("../Services/routeAuditService");

const WEEKDAYS = [
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday"
];

const SPECIAL_ROUTE_TYPES = ["LOCAL", "TRANSPORT"];

const normalizeText = (value) => (value ?? "").toString().trim();

const normalizeDeliveryDays = (value) => {
  const raw = normalizeText(value);
  if (!raw) return [];

  return raw
    .split("&")
    .map((day) => day.trim())
    .filter(Boolean)
    .map((day) => {
      const match = WEEKDAYS.find((item) => item.toLowerCase() === day.toLowerCase());
      return match || day.toUpperCase();
    });
};

const normalizeRouteType = (value) => normalizeText(value).toUpperCase();

const getDisplayDayOrder = () => {
  const todayIndex = new Date().getDay();
  const startIndex = (todayIndex + 3) % 7;
  return WEEKDAYS.slice(startIndex).concat(WEEKDAYS.slice(0, startIndex));
};

const hasRequiredDisplayFields = (route) => {
  return Boolean(normalizeText(route.networkCode) && normalizeText(route.deliveryDay));
};

const parseDeliveryRoutesFromWorkbook = async (buffer) => {
  const workbook = new ExcelJS.Workbook();
  await workbook.xlsx.load(buffer);

  const worksheet = workbook.worksheets[0];
  if (!worksheet) {
    return [];
  }

  const importedRows = [];

  worksheet.eachRow((row, rowNumber) => {
    if (rowNumber === 1) return;

    const networkCode = normalizeText(row.getCell(1).value);
    const companyName = normalizeText(row.getCell(2).value);
    const city = normalizeText(row.getCell(3).value);
    const deliveryDay = normalizeText(row.getCell(4).value);

    importedRows.push({
      networkCode,
      companyName,
      city,
      deliveryDay
    });
  });

  return importedRows;
};

const normalizeRoutePayload = (route = {}) => ({
  networkCode: normalizeText(route.networkCode),
  companyName: normalizeText(route.companyName),
  city: normalizeText(route.city),
  deliveryDay: normalizeText(route.deliveryDay)
});

const isManager = (req) => req.user?.role === "manager";

const addDeliveryRoutes = async (req, res) => {
  try {
    if (!isManager(req)) {
      return res.status(403).json({ message: "Only manager can add delivery routes" });
    }

    const { routes } = req.body || {};
    if (!Array.isArray(routes) || routes.length === 0) {
      return res.status(400).json({ message: "routes array is required and must contain at least one item." });
    }

    const normalizedRoutes = routes.map(normalizeRoutePayload);
    const invalidIndexes = [];

    normalizedRoutes.forEach((route, index) => {
      if (!route.networkCode) invalidIndexes.push(index);
    });

    if (invalidIndexes.length > 0) {
      return res.status(400).json({
        message: "networkCode is required for each route.",
        invalidIndexes
      });
    }

    const docs = await DeliveryRoute.insertMany(normalizedRoutes, { ordered: true });
    await recordRouteAuditEvents({
      actorId: req.user.id,
      action: "created",
      routes: docs,
      source: "manual"
    });

    return res.status(201).json({
      message: "Delivery routes added successfully",
      createdCount: docs.length,
      routes: docs
    });
  } catch (error) {
    return res.status(500).json({ message: "Server error", error: error.message });
  }
};

const deleteDeliveryRoutes = async (req, res) => {
  try {
    if (!isManager(req)) {
      return res.status(403).json({ message: "Only manager can delete delivery routes" });
    }

    const { ids } = req.body || {};
    if (!Array.isArray(ids) || ids.length === 0) {
      return res.status(400).json({ message: "ids array is required and must contain at least one _id." });
    }

    const normalizedIds = [...new Set(ids.map((id) => String(id).trim()))];
    const invalidIds = normalizedIds.filter((id) => !mongoose.Types.ObjectId.isValid(id));

    if (invalidIds.length > 0) {
      return res.status(400).json({
        message: "Some ids are invalid ObjectId values.",
        invalidIds
      });
    }

    const existing = await DeliveryRoute.find({ _id: { $in: normalizedIds } })
      .select("networkCode companyName city deliveryDay")
      .lean();
    const existingIds = new Set(existing.map((item) => String(item._id)));
    const notFoundIds = normalizedIds.filter((id) => !existingIds.has(id));

    const result = await DeliveryRoute.deleteMany({ _id: { $in: normalizedIds } });
    await recordRouteAuditEvents({
      actorId: req.user.id,
      action: "deleted",
      routes: existing,
      source: "manual"
    });

    return res.status(200).json({
      message: "Delivery routes delete operation completed",
      requestedCount: normalizedIds.length,
      deletedCount: result.deletedCount,
      notFoundIds
    });
  } catch (error) {
    return res.status(500).json({ message: "Server error", error: error.message });
  }
};

const importDeliveryRoutes = async (req, res) => {
  try {
    if (!isManager(req)) {
      return res.status(403).json({ message: "Only manager can import delivery routes" });
    }

    if (!Buffer.isBuffer(req.body)) {
      return res.status(400).json({
        message: "Excel file must be sent as raw binary body with the Excel MIME type."
      });
    }

    const rows = await parseDeliveryRoutesFromWorkbook(req.body);
    if (!rows.length) {
      return res.status(400).json({ message: "No delivery route rows found in workbook." });
    }

    const docs = await DeliveryRoute.insertMany(rows, { ordered: false });
    await recordRouteAuditEvents({
      actorId: req.user.id,
      action: "created",
      routes: docs,
      source: "import"
    });

    res.status(201).json({
      message: "Delivery routes imported successfully",
      importedCount: docs.length
    });
  } catch (error) {
    const duplicateKeyError = error && error.code === 11000;
    if (duplicateKeyError) {
      return res.status(409).json({
        message: "Duplicate records found while importing.",
        error: error.message
      });
    }

    res.status(500).json({ message: "Server error", error: error.message });
  }
};

const getDeliveryRoutesGroupedByDay = async (req, res) => {
  try {
    const routes = await DeliveryRoute.find().lean();
    const dayOrder = getDisplayDayOrder();

    const grouped = dayOrder.map((day) => ({
      day,
      routes: []
    }));

    const specialGroups = SPECIAL_ROUTE_TYPES.map((type) => ({
      type,
      routes: []
    }));

    const incompleteRoutes = [];

    routes.forEach((route) => {
      if (!hasRequiredDisplayFields(route)) {
        incompleteRoutes.push(route);
        return;
      }

      const routeType = normalizeRouteType(route.deliveryDay);

      if (SPECIAL_ROUTE_TYPES.includes(routeType)) {
        const targetGroup = specialGroups.find((group) => group.type === routeType);
        if (targetGroup) {
          targetGroup.routes.push(route);
        }
        return;
      }

      const normalizedDeliveryDays = normalizeDeliveryDays(route.deliveryDay);
      const matchedDays = normalizedDeliveryDays.filter((day) => dayOrder.includes(day));

      if (!matchedDays.length) {
        incompleteRoutes.push(route);
        return;
      }

      matchedDays.forEach((day) => {
        const targetGroup = grouped.find((group) => group.day === day);
        if (targetGroup) {
          targetGroup.routes.push(route);
        }
      });
    });

    grouped.forEach((group) => {
      group.routes.sort((a, b) => {
        const networkA = normalizeText(a.networkCode);
        const networkB = normalizeText(b.networkCode);
        if (networkA !== networkB) return networkA.localeCompare(networkB);
        return normalizeText(a.companyName).localeCompare(normalizeText(b.companyName));
      });
    });

    specialGroups.forEach((group) => {
      group.routes.sort((a, b) => {
        const networkA = normalizeText(a.networkCode);
        const networkB = normalizeText(b.networkCode);
        if (networkA !== networkB) return networkA.localeCompare(networkB);
        return normalizeText(a.companyName).localeCompare(normalizeText(b.companyName));
      });
    });

    res.status(200).json({
      dayOrder,
      grouped,
      specialGroups,
      incompleteRoutes
    });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

module.exports = {
  importDeliveryRoutes,
  getDeliveryRoutesGroupedByDay,
  addDeliveryRoutes,
  deleteDeliveryRoutes
};
