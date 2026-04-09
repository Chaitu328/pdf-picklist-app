const PickList = require("../Models/pickListModel");

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

    res.status(201).json(newPickList);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// GET ALL PICKLISTS (WITH PJP PRIORITY LOGIC)
const getAllPickLists = async (req, res) => {
  try {
    const picklists = await PickList.find()
      .populate("clientId", "name email")
      .populate("workerId", "name email")
      .lean(); // Converts to plain JS array for sorting

    // PJP Logic: Identify current day and sort
    const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    const today = days[new Date().getDay()];

    picklists.sort((a, b) => {
      if (a.route_day === today && b.route_day !== today) return -1; // Move 'A' up
      if (b.route_day === today && a.route_day !== today) return 1;  // Move 'B' up
      return 0; // Keep original order for others
    });

    res.status(200).json(picklists);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// WORKER CLAIM PICKLIST
const assignPickList = async (req, res) => {
  try {
    const workerId = req.user.id;
    const picklist = await PickList.findOneAndUpdate(
      { _id: req.params.id, workerId: null },
      { workerId: workerId, status: "assigned" },
      { new: true }
    );

    if (!picklist) return res.status(400).json({ message: "Picklist already assigned or not found" });
    res.json(picklist);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// WORKER UPDATE SCANNED QTY (Processes ONE item at a time)
const updateScan = async (req, res) => {
  try {
    const { partno, unique_id, entry_method } = req.body;
    const picklist = await PickList.findById(req.params.id);

    if (!picklist) return res.status(404).json({ message: "Picklist not found" });

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

    // 3. Excess Validation Check
    if (part.allo_qty >= part.req_qty) {
      return res.status(400).json({ 
        message: "Quantity error. Allocated quantity exceeds required amount. Scan rejected." 
      });
    }

    // 4. Update data
    part.scanned_items.push({ unique_id: unique_id || null, entry_method });
    part.allo_qty += 1;

    // Update part status
    if (part.allo_qty === part.req_qty) {
      part.status = "completed";
    } else {
      part.status = "partial";
    }

    picklist.status = "processing";
    await picklist.save();

    res.json(picklist);
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

    // Trigger instant WebSocket Notification to Admin if there is a shortage
    if (unscannedCount > 0) {
      req.io.emit("shortage_alert", {
        message: "A worker proceeded with an incomplete picklist.",
        pick_list_no: picklist.pick_list_no,
        items_missing: unscannedCount
      });
    }

    res.json({ message: "Picklist finalized", picklist });
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
    
    const deletedItem = await PickList.findOneAndDelete({ pick_list_no: pickListNumber });
    if (!deletedItem) return res.status(404).json({ message: `PickList ${pickListNumber} not found.` });
    
    res.status(200).json({ message: `PickList ${pickListNumber} deleted.` });
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
  getAllPickLists
};