const User = require("../Models/userModel");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const { recordUserSessionEvent } = require("../Services/userAuditService");

// REGISTER
const registerUser = async (req, res) => {
  const { name, email, password, role } = req.body;

  try {

    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }

    // hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = await User.create({
      name,
      email,
      password: hashedPassword,
      role
    });

    const token = jwt.sign(
      { id: newUser._id, role: newUser.role },
      process.env.JWT_SECRET_KEY,
      { expiresIn: "7d" }
    );

    res.status(201).json({
      message: "User registered successfully",
      token,
      user: {
        name: newUser.name,
        id: newUser._id,
        email: newUser.email,
        role: newUser.role
      }
    });

  } catch (error) {
    res.status(500).json({ message: "Server error", error });
  }
};

// LOGIN
const loginUser = async (req, res) => {
  const { email, password } = req.body;
  console.log("[AUDIT DEBUG] loginUser entry:", { email });

  try {

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET_KEY,
      { expiresIn: "7d" }
    );

    console.log("[AUDIT DEBUG] before recordUserSessionEvent:", {
      userId: user._id,
      role: user.role,
      eventType: "login"
    });
    await recordUserSessionEvent({
      userId: user._id,
      role: user.role,
      eventType: "login"
    });

    res.status(200).json({
      message: "Login successful",
      token,
      user: {
        id: user._id,
        email: user.email,
        role: user.role
      }
    });

  } catch (error) {
    res.status(500).json({ message: "Server error", error });
  }
};

//get all users (for admin use only)
const getAllUsers = async (req, res) => {
  try {

    const users = await User.find().select("-password");

    res.status(200).json({ users });

  } catch (error) {
    res.status(500).json({ message: "Server error", error });
  }
};


module.exports = { registerUser, loginUser , getAllUsers };
