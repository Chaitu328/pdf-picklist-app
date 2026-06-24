const PickList = require("../Models/pickListModel");
const { recordPicklistAuditEvent } = require("../Services/picklistAuditService");

// MANAGER CREATES PICKLIST
const createPickList = async (req, res) => {
  try {
    const { pick_list_no, order_number, picklist_date, route_day, parts } = req.body;
    const clientId = req.user.id;

    if (!order_number) {
      return res.status(400).json({ message: "Order Number is mandatory." });
    }

    const existing = await PickList.findOne({ pick_list_no });
    if (existing) {
      return res.status(400).json({ message: "Picklist already exists" });
    }

    const newPickList = await PickList.create({
      pick_list_no,
      order_number,
      picklist_date: picklist_date || "Not provided",
      route_day: route_day || "Any",
      clientId,
      parts
    });
    await recordPicklistAuditEvent({
  eventType: "picklist_created",
  actorId: req.user.id,
  picklist: newPickList
});

    res.status(201).json(newPickList);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// GET ALL PICKLISTS (WITH PJP PRIORITY LOGIC AND DYNAMIC TRANSLATION)
const getAllPickLists = async (req, res) => {
  try {
    const picklists = await PickList.find()
      .populate("clientId", "name email")
      .populate("workerId", "name email")
      .populate("workerIds", "name email")
      .lean(); // Converts to plain JS array for sorting

    // PJP Logic: Identify current day and sort
    const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    const today = days[new Date().getDay()];

    picklists.sort((a, b) => {
      if (a.route_day === today && b.route_day !== today) return -1; // Move 'A' up
      if (b.route_day === today && a.route_day !== today) return 1;  // Move 'B' up
      return 0; // Keep original order for others
    });

    const userId = req.user.id;
    const userRole = req.user.role;

    const transformed = picklists.map(picklist => {
      const workerIds = picklist.workerIds || [];
      const isAssignedToMe = workerIds.some(w => w._id.toString() === userId);
      const workerCount = workerIds.length;

      if (userRole === "worker") {
        if (isAssignedToMe) {
          // Worker is assigned, return worker's own info in workerId
          const myInfo = workerIds.find(w => w._id.toString() === userId);
          return {
            ...picklist,
            workerId: myInfo
          };
        } else {
          // Worker is not assigned
          if (workerCount < 3) {
            // Available for claim
            return {
              ...picklist,
              workerId: null,
              status: "unassigned"
            };
          } else {
            // Full, not available to this worker
            return {
              ...picklist,
              workerId: null,
              status: picklist.status === "unassigned" ? "assigned" : picklist.status
            };
          }
        }
      } else {
        // Manager role: combine names and emails of all assigned workers
        if (workerIds.length > 0) {
          const names = workerIds.map(w => w.name).join(", ");
          const emails = workerIds.map(w => w.email).join(", ");
          return {
            ...picklist,
            workerId: {
              _id: workerIds[0]._id,
              name: names,
              email: emails
            }
          };
        } else {
          return {
            ...picklist,
            workerId: null
          };
        }
      }
    });

    res.status(200).json(transformed);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// WORKER CLAIM PICKLIST (Up to 3 workers)
const assignPickList = async (req, res) => {
  try {
    const workerId = req.user.id;
    const picklist = await PickList.findById(req.params.id);

    if (!picklist) {
      return res.status(404).json({ message: "Picklist not found" });
    }

    if (!picklist.workerIds) {
      picklist.workerIds = [];
    }

    // Limit to 3 workers
    if (picklist.workerIds.length >= 3) {
      return res.status(400).json({ message: "Limit reached. This picklist already has 3 workers assigned." });
    }

    // Check if worker already assigned
    const alreadyAssigned = picklist.workerIds.some(id => id.toString() === workerId);
    if (alreadyAssigned) {
      return res.status(400).json({ message: "Worker already assigned to this picklist" });
    }

    picklist.workerIds.push(workerId);

    // Set workerId for backward compatibility
    if (!picklist.workerId) {
      picklist.workerId = workerId;
    }

    picklist.status = "assigned";
    await picklist.save();
    await recordPicklistAuditEvent({
  eventType: "picklist_accepted",
  actorId: workerId,
  picklist
});

    const populatedPicklist = await PickList.findById(picklist._id)
      .populate("clientId", "name email")
      .populate("workerId", "name email")
      .populate("workerIds", "name email");

    const myInfo = populatedPicklist.workerIds.find(w => w._id.toString() === workerId);
    const transformed = {
      ...populatedPicklist.toObject(),
      workerId: myInfo
    };

    res.json(transformed);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// WORKER UPDATE SCANNED QTY (Processes ONE or multiple items at a time)
const updateScan = async (req, res) => {
  try {
    const { partno, unique_id, entry_method, quantity } = req.body;
    const picklist = await PickList.findById(req.params.id);

    if (!picklist) return res.status(404).json({ message: "Picklist not found" });

    // Validate that the worker is assigned to this picklist
    const isAssigned = picklist.workerIds && picklist.workerIds.some(id => id.toString() === req.user.id);
    if (!isAssigned && picklist.workerId?.toString() !== req.user.id) {
      return res.status(403).json({ message: "You are not assigned to this picklist." });
    }

    // 1. Duplicate Check: Ensure Unique ID hasn't been scanned already across all parts
    if (entry_method === "QR" && unique_id) {
      for (const part of picklist.parts) {
        const isDuplicate = part.scanned_items.some(item => item.unique_id === unique_id);
        if (isDuplicate) {
          return res.status(400).json({ message: "Duplicate scan rejected. This Unique ID was already counted." });
        }
      }
    }

    // 2. Find target part
    const part = picklist.parts.find(p => p.partno === partno);
    if (!part) return res.status(404).json({ message: "Part not found in this picklist" });

    const qtyToAdd = quantity ? Number(quantity) : 1;

    // 4. Update data (records workerId for the scan)
    if (entry_method === "Manual") {
      for (let i = 0; i < qtyToAdd; i++) {
        part.scanned_items.push({ 
          unique_id: null, 
          entry_method,
          workerId: req.user.id
        });
      }
    } else {
      part.scanned_items.push({ 
        unique_id: unique_id || null, 
        entry_method,
        workerId: req.user.id
      });
    }
    part.allo_qty += qtyToAdd;

    // Update part status
    if (part.allo_qty === part.req_qty) {
      part.status = "completed";
    } else if (part.allo_qty > part.req_qty) {
      part.status = "excess";
    } else {
      part.status = "partial";
    }

    picklist.status = "processing";
    await picklist.save();
    await recordPicklistAuditEvent({
  eventType: "picklist_worked",
  actorId: req.user.id,
  picklist,
  actionSummary: {
    qrCount: entry_method === "QR" ? qtyToAdd : 0,
    manualCount: entry_method === "Manual" ? qtyToAdd : 0
  }
});

    const populatedPicklist = await PickList.findById(picklist._id)
      .populate("clientId", "name email")
      .populate("workerId", "name email")
      .populate("workerIds", "name email");

    const myInfo = populatedPicklist.workerIds.find(w => w._id.toString() === req.user.id);
    const transformed = {
      ...populatedPicklist.toObject(),
      workerId: myInfo
    };

    res.json(transformed);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// WORKER PROCEEDS WITH INCOMPLETE SCAN (Triggers Notification)
const proceedWithShortage = async (req, res) => {
  try {
    const picklist = await PickList.findById(req.params.id);
    if (!picklist) return res.status(404).json({ message: "Picklist not found" });

    let unscannedCount = 0;
    picklist.parts.forEach(part => {
      if (part.allo_qty < part.req_qty) {
        part.status = "shortage";
        unscannedCount += (part.req_qty - part.allo_qty);
      }
    });

    picklist.status = unscannedCount > 0 ? "completed_with_shortage" : "completed";
    await picklist.save();
    await recordPicklistAuditEvent({
  eventType: "picklist_worked",
  actorId: req.user.id,
  picklist
});

    // Trigger instant WebSocket Notification to Admin if there is a shortage
    if (unscannedCount > 0) {
      req.io.emit("shortage_alert", {
        message: "A worker proceeded with an incomplete picklist.",
        pick_list_no: picklist.pick_list_no,
        items_missing: unscannedCount
      });
    }

    const populatedPicklist = await PickList.findById(picklist._id)
      .populate("clientId", "name email")
      .populate("workerId", "name email")
      .populate("workerIds", "name email");

    const myInfo = populatedPicklist.workerIds.find(w => w._id.toString() === req.user.id);
    const transformed = {
      ...populatedPicklist.toObject(),
      workerId: myInfo
    };

    res.json({ message: "Picklist finalized", picklist: transformed });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// GET ADMIN SUMMARY OF ALL PICKLISTS (For Browser Admin Dashboard / Postman check)
const getAdminSummary = async (req, res) => {
  try {
    if (req.user.role !== "manager") {
      return res.status(403).json({ message: "Access denied. Managers only." });
    }

    const picklists = await PickList.find()
      .populate("clientId", "name email")
      .populate("workerIds", "name email")
      .lean();

    const summary = picklists.map(pl => {
      const partsSummary = pl.parts.map(part => {
        // Group scans by worker
        const workerScans = {};
        part.scanned_items.forEach(item => {
          const wId = item.workerId ? item.workerId.toString() : "unassigned";
          if (!workerScans[wId]) {
            workerScans[wId] = {
              workerId: wId,
              name: "Unknown Worker",
              email: "Unknown",
              count: 0
            };
          }
          workerScans[wId].count += 1;
        });

        // Resolve names/emails from workerIds
        Object.keys(workerScans).forEach(wId => {
          const workerInfo = pl.workerIds.find(w => w._id.toString() === wId);
          if (workerInfo) {
            workerScans[wId].name = workerInfo.name;
            workerScans[wId].email = workerInfo.email;
          } else if (wId === "unassigned") {
            workerScans[wId].name = "Manual / Unassigned";
            workerScans[wId].email = "";
          }
        });

        return {
          partno: part.partno,
          description: part.description,
          req_qty: part.req_qty,
          allo_qty: part.allo_qty,
          status: part.status,
          scansByWorker: Object.values(workerScans)
        };
      });

      return {
        _id: pl._id,
        pick_list_no: pl.pick_list_no,
        order_number: pl.order_number,
        picklist_date: pl.picklist_date,
        route_day: pl.route_day,
        status: pl.status,
        workers: (pl.workerIds || []).map(w => ({ name: w.name, email: w.email })),
        parts: partsSummary
      };
    });

    res.status(200).json(summary);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// DELETE ALL
const deleteAllPickLists = async (req, res) => {
  try {
    const result = await PickList.deleteMany({});
    res.status(200).json({ message: "All picklists deleted", deletedCount: result.deletedCount });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// DELETE BY NUMBER
const deletePickListByNumber = async (req, res) => {
  try {
    const { pickListNumber } = req.params;
    if (!pickListNumber) return res.status(400).json({ message: "PickList number required." });
     const picklist = await PickList.findOne({ pick_list_no: pickListNumber });

await recordPicklistAuditEvent({
  eventType: "picklist_deleted",
  actorId: req.user.id,
  picklist
});
    const deletedItem = await PickList.findOneAndDelete({ pick_list_no: pickListNumber });
    if (!deletedItem) return res.status(404).json({ message: `PickList ${pickListNumber} not found.` });
    
    res.status(200).json({ message: `PickList ${pickListNumber} deleted.` });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// WORKER SET DIRECT PART QUANTITY (Manual Sync/Save)
const setPartQuantity = async (req, res) => {
  try {
    const { partno, quantity } = req.body;
    const picklist = await PickList.findById(req.params.id);

    if (!picklist) return res.status(404).json({ message: "Picklist not found" });

    // Validate that the worker is assigned to this picklist
    const isAssigned = picklist.workerIds && picklist.workerIds.some(id => id.toString() === req.user.id);
    if (!isAssigned && picklist.workerId?.toString() !== req.user.id) {
      return res.status(403).json({ message: "You are not assigned to this picklist." });
    }

    // Find target part
    const part = picklist.parts.find(p => p.partno === partno);
    if (!part) return res.status(404).json({ message: "Part not found in this picklist" });

    const targetQty = Number(quantity);
    if (isNaN(targetQty) || targetQty < 0) {
      return res.status(400).json({ message: "Invalid quantity value." });
    }

    const diff = targetQty - part.allo_qty;
    if (diff > 0) {
      for (let i = 0; i < diff; i++) {
        part.scanned_items.push({ 
          unique_id: null, 
          entry_method: "Manual",
          workerId: req.user.id
        });
      }
    } else if (diff < 0) {
      const toRemove = Math.abs(diff);
      for (let i = 0; i < toRemove; i++) {
        part.scanned_items.pop();
      }
    }
    part.allo_qty = targetQty;

    // Update part status
    if (part.allo_qty === part.req_qty) {
      part.status = "completed";
    } else if (part.allo_qty > part.req_qty) {
      part.status = "excess";
    } else if (part.allo_qty === 0) {
      part.status = "pending";
    } else {
      part.status = "partial";
    }

    picklist.status = "processing";
    await picklist.save();

    const populatedPicklist = await PickList.findById(picklist._id)
      .populate("clientId", "name email")
      .populate("workerId", "name email")
      .populate("workerIds", "name email");

    const myInfo = populatedPicklist.workerIds.find(w => w._id.toString() === req.user.id);
    const transformed = {
      ...populatedPicklist.toObject(),
      workerId: myInfo
    };

    res.json(transformed);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

module.exports = {
  createPickList,
  assignPickList,
  deletePickListByNumber,
  deleteAllPickLists,
  updateScan,
  proceedWithShortage,
  getAllPickLists,
  getAdminSummary,
  setPartQuantity
};