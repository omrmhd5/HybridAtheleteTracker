const mongoose = require('mongoose');

const setSchema = new mongoose.Schema({
  reps: { type: Number, required: true },
  weight: { type: Number, required: true }
}, { _id: false });

const exerciseSchema = new mongoose.Schema({
  name: { type: String, required: true },
  sets: [setSchema]
}, { _id: false });

const liftingSessionSchema = new mongoose.Schema({
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
  sessionName: {
    type: String,
    trim: true
  },
  exercises: [exerciseSchema],
  voiceTranscript: {
    type: String,
    trim: true
  },
  notes: {
    type: String,
    trim: true
  }
}, { timestamps: true });

module.exports = mongoose.model('LiftingSession', liftingSessionSchema);
