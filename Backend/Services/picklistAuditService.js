const PicklistAudit = require("../Models/picklistAuditModel");
const User = require("../Models/userModel");
const { getDateKey, getTimeKey } = require("./userAuditService");

const buildUserSnapshot = (user) => ({
  userId: user?._id || user?.userId || null,
  name: user?.name || "",
  email: user?.email || "",
  role: user?.role || ""
});

const buildPartSnapshot = (part) => {
  const scannedItems = Array.isArray(part?.scanned_items) ? part.scanned_items : [];
  const qrCount = scannedItems.filter((item) => item.entry_method === "QR").length;
  const manualCount = scannedItems.filter((item) => item.entry_method === "Manual").length;

  return {
    partno: part?.partno || "",
    description: part?.description || "",
    req_qty: Number(part?.req_qty || 0),
    allo_qty: Number(part?.allo_qty || 0),
    status: part?.status || "",
    scanned: scannedItems.length > 0 || Number(part?.allo_qty || 0) > 0,
    qrCount,
    manualCount
  };
};

const buildPicklistSnapshot = (picklist) => {
  const parts = Array.isArray(picklist?.parts) ? picklist.parts.map(buildPartSnapshot) : [];
  const qrScannedCount = parts.filter((part) => Number(part.qrCount || 0) > 0).length;
  const manualEnteredCount = parts.filter((part) => Number(part.manualCount || 0) > 0).length;

  return {
    picklistId: picklist?._id ? String(picklist._id) : picklist?.picklistId || null,
    pick_list_no: picklist?.pick_list_no || "",
    order_number: picklist?.order_number || "",
    status: picklist?.status || "",
    partCount: parts.length,
    workDone: parts.some((part) => part.scanned),
    qrScannedCount,
    manualEnteredCount,
    workerAssigned: Boolean(picklist?.workerId),
    parts
  };
};

const buildSelectedReupdateParts = (parts = []) =>
  parts.map((part) => ({
    partno: part?.partno || "",
    description: part?.description || "",
    statusAtRequest: part?.status || ""
  }));

const loadUsersByIds = async (ids = []) => {
  const normalizedIds = [...new Set(ids.filter(Boolean).map((id) => String(id)))];
  if (!normalizedIds.length) return new Map();

  const users = await User.find({ _id: { $in: normalizedIds } }).select("name email role").lean();
  return new Map(users.map((user) => [String(user._id), user]));
};

const recordPicklistAuditEvent = async ({
  eventType,
  actorId,
  picklist,
  actionSummary = {},
  selectedReupdateParts = [],
  at = new Date()
}) => {
  if (!eventType || !actorId || !picklist) {
    return;
  }

  try {
    const userMap = await loadUsersByIds([
      actorId,
      picklist.clientId,
      picklist.workerId
    ]);

    const actor = userMap.get(String(actorId));
    if (!actor) {
      return;
    }

    const creatorManager = picklist.clientId ? userMap.get(String(picklist.clientId)) : null;
    const assignedWorker = picklist.workerId ? userMap.get(String(picklist.workerId)) : null;

    await PicklistAudit.create({
      eventType,
      eventDate: getDateKey(at),
      eventTime: getTimeKey(at),
      actor: buildUserSnapshot({ ...actor, _id: actorId }),
      creatorManager: buildUserSnapshot(creatorManager),
      assignedWorker: buildUserSnapshot(assignedWorker),
      picklistSnapshot: buildPicklistSnapshot(picklist),
      actionSummary: {
        qrCount: Number(actionSummary.qrCount || 0),
        manualCount: Number(actionSummary.manualCount || 0),
        reupdatedPartCount: Number(actionSummary.reupdatedPartCount || 0)
      },
      selectedReupdateParts: buildSelectedReupdateParts(selectedReupdateParts)
    });
  } catch (error) {
    console.error("Picklist audit write failed:", error.message);
  }
};

module.exports = {
  buildPicklistSnapshot,
  recordPicklistAuditEvent
};
