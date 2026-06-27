const mongoose = require('mongoose');

const bodyWeightSchema = new mongoose.Schema({
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
  weight: {
    type: Number,
    required: true
  },
  unit: {
    type: String,
    enum: ['kg', 'lbs'],
    required: true
  }
}, { timestamps: true });

module.exports = mongoose.model('BodyWeight', bodyWeightSchema);
