const mongoose = require('mongoose');

const cardioLogSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  date: {
    type: Date,
    required: true,
    default: Date.now
  },
  type: {
    type: String,
    enum: ['run', 'cycle', 'swim', 'other'],
    required: true
  },
  durationMinutes: {
    type: Number,
    required: true
  },
  distance: {
    type: Number,
    default: 0
  },
  avgHeartRate: {
    type: Number
  },
  notes: {
    type: String,
    trim: true
  }
}, { timestamps: true });

module.exports = mongoose.model('CardioLog', cardioLogSchema);
