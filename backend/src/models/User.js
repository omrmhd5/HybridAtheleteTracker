const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  passwordHash: {
    type: String,
    required: true
  },
  unitPreference: {
    type: String,
    enum: ['kg', 'lbs'],
    default: 'kg'
  },
  dailyProteinGoal: {
    type: Number,
    default: 150
  }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
