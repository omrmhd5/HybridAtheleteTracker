const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const env = require('../config/env');

class AuthService {
  async register(userData) {
    const { name, username, email, password, unitPreference, dailyProteinGoal } = userData;

    // Check if user exists
    const existingUser = await User.findOne({ $or: [{ email }, { username }] });
    if (existingUser) {
      throw new Error('User with this email or username already exists');
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const user = new User({
      name,
      username,
      email,
      passwordHash,
      unitPreference,
      dailyProteinGoal
    });

    await user.save();
    return this.generateToken(user._id);
  }

  async login(email, password) {
    const user = await User.findOne({ email });
    if (!user) {
      throw new Error('Invalid email or password');
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      throw new Error('Invalid email or password');
    }

    return this.generateToken(user._id);
  }

  async getProfile(userId) {
    const user = await User.findById(userId).select('-passwordHash');
    if (!user) {
      throw new Error('User not found');
    }
    return user;
  }

  async updateProfile(userId, updateData) {
    // Only allow updating certain fields
    const allowedUpdates = {};
    if (updateData.name) allowedUpdates.name = updateData.name;
    if (updateData.unitPreference) allowedUpdates.unitPreference = updateData.unitPreference;
    if (updateData.dailyProteinGoal) allowedUpdates.dailyProteinGoal = updateData.dailyProteinGoal;

    const user = await User.findByIdAndUpdate(userId, allowedUpdates, { new: true }).select('-passwordHash');
    return user;
  }

  generateToken(userId) {
    return jwt.sign({ userId }, env.JWT_SECRET, { expiresIn: env.JWT_EXPIRES_IN });
  }
}

module.exports = new AuthService();
