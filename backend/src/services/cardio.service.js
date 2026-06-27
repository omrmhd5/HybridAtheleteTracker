const CardioLog = require('../models/CardioLog');

class CardioService {
  async logSession(userId, sessionData) {
    const session = new CardioLog({
      userId,
      ...sessionData
    });
    return await session.save();
  }

  async getSessions(userId, query) {
    const filter = { userId };
    
    if (query.from || query.to) {
      filter.date = {};
      if (query.from) filter.date.$gte = new Date(query.from);
      if (query.to) filter.date.$lte = new Date(query.to);
    }

    return await CardioLog.find(filter).sort({ date: -1 });
  }

  async updateSession(userId, sessionId, updateData) {
    const session = await CardioLog.findOneAndUpdate(
      { _id: sessionId, userId },
      updateData,
      { new: true }
    );
    if (!session) throw new Error('Session not found');
    return session;
  }

  async deleteSession(userId, sessionId) {
    const session = await CardioLog.findOneAndDelete({ _id: sessionId, userId });
    if (!session) throw new Error('Session not found');
    return session;
  }
}

module.exports = new CardioService();
