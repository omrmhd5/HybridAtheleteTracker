const BodyWeight = require('../models/BodyWeight');

class BodyWeightService {
  async logWeight(userId, data) {
    const log = new BodyWeight({
      userId,
      ...data
    });
    return await log.save();
  }

  async getHistory(userId, query) {
    const filter = { userId };
    
    if (query.from || query.to) {
      filter.date = {};
      if (query.from) filter.date.$gte = new Date(query.from);
      if (query.to) filter.date.$lte = new Date(query.to);
    }

    return await BodyWeight.find(filter).sort({ date: -1 });
  }
}

module.exports = new BodyWeightService();
