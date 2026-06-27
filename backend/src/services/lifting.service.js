const LiftingSession = require('../models/LiftingSession');

class LiftingService {
  async logSession(userId, sessionData) {
    const session = new LiftingSession({
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

    return await LiftingSession.find(filter).sort({ date: -1 });
  }

  async getSessionById(userId, sessionId) {
    const session = await LiftingSession.findOne({ _id: sessionId, userId });
    if (!session) throw new Error('Session not found');
    return session;
  }

  async updateSession(userId, sessionId, updateData) {
    const session = await LiftingSession.findOneAndUpdate(
      { _id: sessionId, userId },
      updateData,
      { new: true }
    );
    if (!session) throw new Error('Session not found');
    return session;
  }

  async deleteSession(userId, sessionId) {
    const session = await LiftingSession.findOneAndDelete({ _id: sessionId, userId });
    if (!session) throw new Error('Session not found');
    return session;
  }
}

module.exports = new LiftingService();
