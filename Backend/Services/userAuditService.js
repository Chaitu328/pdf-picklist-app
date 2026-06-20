const UserAudit = require("../Models/userAuditModel");

const AUDIT_TIMEZONE = "Asia/Kolkata";

const getDateKey = (date = new Date()) =>
  new Intl.DateTimeFormat("en-CA", {
    timeZone: AUDIT_TIMEZONE,
    year: "numeric",
    month: "2-digit",
    day: "2-digit"
  }).format(date);

const getTimeKey = (date = new Date()) =>
  new Intl.DateTimeFormat("en-GB", {
    timeZone: AUDIT_TIMEZONE,
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false
  }).format(date);

const ensureRoleDocument = async (role) => {
  let auditDoc = await UserAudit.findOne({ role });
  if (!auditDoc) {
    auditDoc = await UserAudit.create({ role, users: [] });
  }
  return auditDoc;
};

const recordUserSessionEvent = async ({ userId, role, eventType, at = new Date() }) => {
  if (!userId || !role || !["login", "logout"].includes(eventType)) {
    return;
  }

  try {
    const auditDoc = await ensureRoleDocument(role);
    const dateKey = getDateKey(at);
    const timeKey = getTimeKey(at);

    let userEntry = auditDoc.users.find((entry) => String(entry.userId) === String(userId));
    if (!userEntry) {
      auditDoc.users.push({
        userId,
        loginDetails: {}
      });
      userEntry = auditDoc.users[auditDoc.users.length - 1];
    }

    const loginDetails = userEntry.loginDetails instanceof Map
      ? userEntry.loginDetails
      : new Map(Object.entries(userEntry.loginDetails || {}));
    const dayEntry = loginDetails.get(dateKey) || {
      loginCount: 0,
      logoutCount: 0,
      loginTimings: [],
      logoutTimings: []
    };

    if (eventType === "login") {
      dayEntry.loginCount += 1;
      dayEntry.loginTimings.push(timeKey);
    } else {
      dayEntry.logoutCount += 1;
      dayEntry.logoutTimings.push(timeKey);
    }

    loginDetails.set(dateKey, dayEntry);
    userEntry.loginDetails = loginDetails;
    auditDoc.markModified("users");
    await auditDoc.save();
  } catch (error) {
    console.error("User audit write failed:", error.message);
  }
};

module.exports = {
  getDateKey,
  getTimeKey,
  recordUserSessionEvent
};
