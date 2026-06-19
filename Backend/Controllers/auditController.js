const User = require("../Models/userModel");
const UserAudit = require("../Models/userAuditModel");
const RouteAudit = require("../Models/routeAuditModel");
const PicklistAudit = require("../Models/picklistAuditModel");
const { getDateKey } = require("../Services/userAuditService");

const isManager = (req) => req.user?.role === "manager";

const mapUserRecord = (user) => ({
  userId: user._id,
  name: user.name,
  email: user.email,
  role: user.role,
  registeredAt: user.timestamp
});

const mapLoginRecord = (user, date, loginDetails) => ({
  userId: user._id,
  name: user.name,
  email: user.email,
  role: user.role,
  loginDetails: {
    [date]: loginDetails || {
      loginCount: 0,
      logoutCount: 0,
      loginTimings: [],
      logoutTimings: []
    }
  }
});

const getUserEvents = async (req, res) => {
  try {
    if (!isManager(req)) {
      return res.status(403).json({ message: "Only manager can access user audit details" });
    }

    const requestedDate = req.query.date || getDateKey();
    const [registeredUsers, managerAudit, workerAudit] = await Promise.all([
      User.find().select("name email role timestamp").lean(),
      UserAudit.findOne({ role: "manager" }).populate("users.userId", "name email role").lean(),
      UserAudit.findOne({ role: "worker" }).populate("users.userId", "name email role").lean()
    ]);

    const managersRegistered = registeredUsers
      .filter((user) => getDateKey(new Date(user.timestamp)) === requestedDate)
      .filter((user) => user.role === "manager")
      .map(mapUserRecord);
    const workersRegistered = registeredUsers
      .filter((user) => getDateKey(new Date(user.timestamp)) === requestedDate)
      .filter((user) => user.role === "worker")
      .map(mapUserRecord);

    const buildRoleLoginResponse = (auditDoc) => {
      if (!auditDoc?.users?.length) return [];

      return auditDoc.users
        .filter((entry) => entry.userId)
        .map((entry) => mapLoginRecord(entry.userId, requestedDate, entry.loginDetails?.[requestedDate]))
        .filter((entry) => {
          const currentDay = entry.loginDetails[requestedDate];
          return currentDay.loginCount > 0 || currentDay.logoutCount > 0;
        });
    };

    return res.status(200).json({
      date: requestedDate,
      registration: {
        managers: managersRegistered,
        workers: workersRegistered
      },
      login: {
        managers: buildRoleLoginResponse(managerAudit),
        workers: buildRoleLoginResponse(workerAudit)
      }
    });
  } catch (error) {
    return res.status(500).json({ message: "Server error", error: error.message });
  }
};

const getRouteEvents = async (req, res) => {
  try {
    if (!isManager(req)) {
      return res.status(403).json({ message: "Only manager can access route audit details" });
    }

    const requestedDate = req.query.date || getDateKey();
    const routeEvents = await RouteAudit.find({ actionDate: requestedDate })
      .populate("actorId", "name email role")
      .sort({ createdAt: -1 })
      .lean();

    const managersMap = new Map();

    routeEvents.forEach((event) => {
      if (!event.actorId) return;

      const managerId = String(event.actorId._id);
      if (!managersMap.has(managerId)) {
        managersMap.set(managerId, {
          managerId: event.actorId._id,
          name: event.actorId.name,
          email: event.actorId.email,
          role: event.actorId.role,
          createdRoutes: [],
          deletedRoutes: []
        });
      }

      const managerRow = managersMap.get(managerId);
      const routeRow = {
        routeId: event.routeId,
        networkCode: event.routeDetails?.networkCode || "",
        companyName: event.routeDetails?.companyName || "",
        city: event.routeDetails?.city || "",
        deliveryDay: event.routeDetails?.deliveryDay || "",
        date: event.actionDate,
        time: event.actionTime,
        source: event.source
      };

      if (event.action === "created") {
        managerRow.createdRoutes.push(routeRow);
      }

      if (event.action === "deleted") {
        managerRow.deletedRoutes.push(routeRow);
      }
    });

    return res.status(200).json({
      date: requestedDate,
      managers: Array.from(managersMap.values())
    });
  } catch (error) {
    return res.status(500).json({ message: "Server error", error: error.message });
  }
};

const buildLatestPicklistAuditMap = async (picklistIds = []) => {
  const normalizedIds = [...new Set(picklistIds.filter(Boolean).map((id) => String(id)))];
  if (!normalizedIds.length) return new Map();

  const audits = await PicklistAudit.find({
    "picklistSnapshot.picklistId": { $in: normalizedIds }
  })
    .sort({ createdAt: -1 })
    .lean();

  const latestMap = new Map();
  audits.forEach((audit) => {
    const picklistId = audit?.picklistSnapshot?.picklistId;
    if (picklistId && !latestMap.has(picklistId)) {
      latestMap.set(picklistId, audit);
    }
  });

  return latestMap;
};

const getPreferredSnapshot = (event, latestMap) => {
  const picklistId = event?.picklistSnapshot?.picklistId;
  const latestEvent = picklistId ? latestMap.get(picklistId) : null;
  return {
    latestEvent,
    snapshot: latestEvent?.picklistSnapshot || event?.picklistSnapshot
  };
};

const buildPartUpdateStatus = (selectedPart, latestSnapshot) => {
  const latestPart = latestSnapshot?.parts?.find((part) => part.partno === selectedPart.partno);
  if (!latestPart) {
    return "not available";
  }

  if (latestPart.status === "reupdated") {
    return "updated";
  }

  if (latestPart.status === "reupdate_pending") {
    return "not updated yet";
  }

  return latestPart.status || "not available";
};

const getManagerProgressEvents = async (req, res) => {
  try {
    if (!isManager(req)) {
      return res.status(403).json({ message: "Only manager can access manager progress audit details" });
    }

    const requestedDate = req.query.date || getDateKey();
    const events = await PicklistAudit.find({
      eventDate: requestedDate,
      eventType: { $in: ["picklist_created", "picklist_deleted", "picklist_reupdate_requested"] }
    })
      .sort({ createdAt: -1 })
      .lean();

    const latestMap = await buildLatestPicklistAuditMap(
      events.map((event) => event?.picklistSnapshot?.picklistId)
    );

    const managersMap = new Map();

    events.forEach((event) => {
      const managerId = String(event.actor?.userId || "");
      if (!managerId) return;

      if (!managersMap.has(managerId)) {
        managersMap.set(managerId, {
          managerId: event.actor.userId,
          name: event.actor.name,
          email: event.actor.email,
          role: event.actor.role,
          createdPicklists: [],
          deletedPicklists: [],
          reupdateRequests: []
        });
      }

      const managerRow = managersMap.get(managerId);
      const { snapshot, latestEvent } = getPreferredSnapshot(event, latestMap);
      const currentWorker = latestEvent?.assignedWorker?.userId ? latestEvent.assignedWorker : event.assignedWorker;

      if (event.eventType === "picklist_created") {
        managerRow.createdPicklists.push({
          picklistId: event.picklistSnapshot.picklistId,
          pick_list_no: event.picklistSnapshot.pick_list_no,
          status: snapshot?.status || event.picklistSnapshot.status,
          partCount: snapshot?.partCount || event.picklistSnapshot.partCount,
          workDone: Boolean(snapshot?.workDone),
          qrScannedCount: Number(snapshot?.qrScannedCount || 0),
          manualEnteredCount: Number(snapshot?.manualEnteredCount || 0),
          workerAssigned: Boolean(snapshot?.workerAssigned),
          worker: currentWorker?.userId ? currentWorker : null,
          createdAt: {
            date: event.eventDate,
            time: event.eventTime
          }
        });
      }

      if (event.eventType === "picklist_deleted") {
        managerRow.deletedPicklists.push({
          pick_list_no: event.picklistSnapshot.pick_list_no,
          status: event.picklistSnapshot.status,
          partCount: event.picklistSnapshot.partCount,
          workDone: Boolean(event.picklistSnapshot.workDone),
          qrScannedCount: Number(event.picklistSnapshot.qrScannedCount || 0),
          manualEnteredCount: Number(event.picklistSnapshot.manualEnteredCount || 0),
          workerAssigned: Boolean(event.picklistSnapshot.workerAssigned),
          worker: event.assignedWorker?.userId ? event.assignedWorker : null,
          parts: event.picklistSnapshot.parts || [],
          deletedAt: {
            date: event.eventDate,
            time: event.eventTime
          }
        });
      }

      if (event.eventType === "picklist_reupdate_requested") {
        managerRow.reupdateRequests.push({
          picklistId: event.picklistSnapshot.picklistId,
          pick_list_no: event.picklistSnapshot.pick_list_no,
          worker: event.assignedWorker?.userId ? event.assignedWorker : null,
          picklistStatusAtRequest: event.picklistSnapshot.status,
          currentPicklistStatus: snapshot?.status || event.picklistSnapshot.status,
          selectedParts: (event.selectedReupdateParts || []).map((part) => ({
            partno: part.partno,
            description: part.description,
            statusAtRequest: part.statusAtRequest,
            afterReupdateStatus: buildPartUpdateStatus(part, snapshot)
          })),
          requestedAt: {
            date: event.eventDate,
            time: event.eventTime
          }
        });
      }
    });

    return res.status(200).json({
      date: requestedDate,
      managers: Array.from(managersMap.values())
    });
  } catch (error) {
    return res.status(500).json({ message: "Server error", error: error.message });
  }
};

const getWorkerProgressEvents = async (req, res) => {
  try {
    if (!isManager(req)) {
      return res.status(403).json({ message: "Only manager can access worker progress audit details" });
    }

    const requestedDate = req.query.date || getDateKey();
    const events = await PicklistAudit.find({
      eventDate: requestedDate,
      eventType: {
        $in: [
          "picklist_accepted",
          "picklist_worked",
          "picklist_reupdate_requested",
          "picklist_reupdated",
          "picklist_deleted"
        ]
      }
    })
      .sort({ createdAt: -1 })
      .lean();

    const latestMap = await buildLatestPicklistAuditMap(
      events.map((event) => event?.picklistSnapshot?.picklistId)
    );

    const workersMap = new Map();

    const ensureWorkerRow = (worker) => {
      const workerId = String(worker?.userId || "");
      if (!workerId) return null;

      if (!workersMap.has(workerId)) {
        workersMap.set(workerId, {
          workerId: worker.userId,
          name: worker.name,
          email: worker.email,
          role: worker.role,
          acceptedPicklists: [],
          workedPicklists: [],
          reassignedPicklists: [],
          reupdatedPicklists: [],
          deletedRelatedPicklists: []
        });
      }

      return workersMap.get(workerId);
    };

    const workedMap = new Map();
    const reupdatedMap = new Map();

    events.forEach((event) => {
      const { snapshot, latestEvent } = getPreferredSnapshot(event, latestMap);

      if (event.eventType === "picklist_accepted") {
        const workerRow = ensureWorkerRow(event.actor);
        if (!workerRow) return;

        workerRow.acceptedPicklists.push({
          picklistId: event.picklistSnapshot.picklistId,
          pick_list_no: event.picklistSnapshot.pick_list_no,
          createdByManager: event.creatorManager?.userId ? event.creatorManager : null,
          status: snapshot?.status || event.picklistSnapshot.status,
          partCount: snapshot?.partCount || event.picklistSnapshot.partCount,
          acceptedAt: {
            date: event.eventDate,
            time: event.eventTime
          }
        });
      }

      if (event.eventType === "picklist_worked") {
        const workerRow = ensureWorkerRow(event.actor);
        if (!workerRow) return;

        const key = `${String(event.actor.userId)}__${event.picklistSnapshot.picklistId}`;
        if (!workedMap.has(key)) {
          workedMap.set(key, {
            workerRow,
            data: {
              picklistId: event.picklistSnapshot.picklistId,
              pick_list_no: event.picklistSnapshot.pick_list_no,
              status: snapshot?.status || event.picklistSnapshot.status,
              qrScannedCount: 0,
              manualEnteredCount: 0,
              workedAt: []
            }
          });
        }

        const workedEntry = workedMap.get(key);
        workedEntry.data.status = snapshot?.status || workedEntry.data.status;
        workedEntry.data.qrScannedCount += Number(event.actionSummary?.qrCount || 0);
        workedEntry.data.manualEnteredCount += Number(event.actionSummary?.manualCount || 0);
        workedEntry.data.workedAt.push({
          date: event.eventDate,
          time: event.eventTime
        });
      }

      if (event.eventType === "picklist_reupdate_requested" && event.assignedWorker?.userId) {
        const workerRow = ensureWorkerRow(event.assignedWorker);
        if (!workerRow) return;

        workerRow.reassignedPicklists.push({
          picklistId: event.picklistSnapshot.picklistId,
          pick_list_no: event.picklistSnapshot.pick_list_no,
          reassignedByManager: event.actor,
          managerDetails: event.actor,
          status: snapshot?.status || event.picklistSnapshot.status,
          selectedParts: event.selectedReupdateParts || [],
          reassignedAt: {
            date: event.eventDate,
            time: event.eventTime
          }
        });
      }

      if (event.eventType === "picklist_reupdated") {
        const workerRow = ensureWorkerRow(event.actor);
        if (!workerRow) return;

        const key = `${String(event.actor.userId)}__${event.picklistSnapshot.picklistId}`;
        if (!reupdatedMap.has(key)) {
          reupdatedMap.set(key, {
            workerRow,
            data: {
              picklistId: event.picklistSnapshot.picklistId,
              pick_list_no: event.picklistSnapshot.pick_list_no,
              statusAfterReupdate: snapshot?.status || event.picklistSnapshot.status,
              reupdatedPartCount: 0,
              reupdatedAt: []
            }
          });
        }

        const reupdatedEntry = reupdatedMap.get(key);
        reupdatedEntry.data.statusAfterReupdate = snapshot?.status || reupdatedEntry.data.statusAfterReupdate;
        reupdatedEntry.data.reupdatedPartCount += Number(event.actionSummary?.reupdatedPartCount || 0);
        reupdatedEntry.data.reupdatedAt.push({
          date: event.eventDate,
          time: event.eventTime
        });
      }

      if (event.eventType === "picklist_deleted" && event.assignedWorker?.userId) {
        const workerRow = ensureWorkerRow(event.assignedWorker);
        if (!workerRow) return;

        workerRow.deletedRelatedPicklists.push({
          pick_list_no: event.picklistSnapshot.pick_list_no,
          deletedByManager: event.actor,
          statusAtDeletion: event.picklistSnapshot.status,
          parts: event.picklistSnapshot.parts || [],
          workDone: Boolean(event.picklistSnapshot.workDone),
          qrScannedCount: Number(event.picklistSnapshot.qrScannedCount || 0),
          manualEnteredCount: Number(event.picklistSnapshot.manualEnteredCount || 0),
          deletedAt: {
            date: event.eventDate,
            time: event.eventTime
          }
        });
      }
    });

    workedMap.forEach(({ workerRow, data }) => {
      workerRow.workedPicklists.push(data);
    });

    reupdatedMap.forEach(({ workerRow, data }) => {
      workerRow.reupdatedPicklists.push(data);
    });

    return res.status(200).json({
      date: requestedDate,
      workers: Array.from(workersMap.values())
    });
  } catch (error) {
    return res.status(500).json({ message: "Server error", error: error.message });
  }
};

module.exports = {
  getUserEvents,
  getRouteEvents,
  getManagerProgressEvents,
  getWorkerProgressEvents
};
