const InwardReceipt = require("../Models/InwardReceiptModel");

exports.createInward = async (req, res) => {
  try {
    const inward = await InwardReceipt.create({
      ...req.body,
    });

    res.status(201).json(inward);
  } catch (error) {
    res.status(500).json({
      message: "Failed to create inward",
      error: error.message,
    });
  }
};


exports.getAllInward = async (req, res) => {
  try {
    const inwards = await InwardReceipt.find()
      .populate("workerId", "name email");

    res.json(inwards);
  } catch (error) {
    res.status(500).json({
      message: "Failed to fetch inward",
    });
  }
};


exports.assignInward = async (req, res) => {
  try {
    const inward = await InwardReceipt.findById(req.params.id);

    if (!inward) {
      return res.status(404).json({
        message: "Inward not found",
      });
    }

    inward.workerId = req.user.id;
    inward.status = "assigned";

    await inward.save();

    res.json(inward);
  } catch (error) {
    res.status(500).json({
      message: "Assignment failed",
    });
  }
};

exports.scanInwardPart = async (req, res) => {
  try {
    const { partno, qr_code, entry_method } = req.body;

    const inward = await InwardReceipt.findById(req.params.id);

    if (!inward) {
      return res.status(404).json({
        message: "Inward not found",
      });
    }

    const part = inward.parts.find(
      (p) => p.partno === partno
    );

    if (!part) {
      return res.status(404).json({
        message: "Part not found",
      });
    }

    part.received_qty += 1;

    part.scanned_items.push({
      qr_code,
      entry_method,
    });

    if (
      part.received_qty < part.expected_qty
    ) {
      part.status = "partial";
    }

    if (
      part.received_qty === part.expected_qty
    ) {
      part.status = "received";
    }

    if (
      part.received_qty > part.expected_qty
    ) {
      part.status = "excess";
    }

    inward.status = "processing";

    await inward.save();

    res.json(inward);

  } catch (error) {
    res.status(500).json({
      message: "Scan failed",
    });
  }
};

exports.completeInward = async (req, res) => {
  try {
    const inward = await InwardReceipt.findById(req.params.id);

    let hasShortage = false;

    inward.parts.forEach((part) => {

      if (
        part.received_qty < part.expected_qty
      ) {
        part.status = "shortage";
        hasShortage = true;
      }
    });

    inward.status = hasShortage
      ? "completed_with_shortage"
      : "completed";

    await inward.save();

    res.json({
      message: "Inward completed",
      inward,
    });

  } catch (error) {
    res.status(500).json({
      message: "Completion failed",
    });
  }
};
