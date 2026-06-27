const liftingService = require('../services/lifting.service');

exports.logSession = async (req, res, next) => {
  try {
    const session = await liftingService.logSession(req.user.userId, req.body);
    res.status(201).json({ success: true, data: session });
  } catch (error) {
    next(error);
  }
};

exports.getSessions = async (req, res, next) => {
  try {
    const sessions = await liftingService.getSessions(req.user.userId, req.query);
    res.status(200).json({ success: true, data: sessions });
  } catch (error) {
    next(error);
  }
};

exports.getSessionById = async (req, res, next) => {
  try {
    const session = await liftingService.getSessionById(req.user.userId, req.params.id);
    res.status(200).json({ success: true, data: session });
  } catch (error) {
    if (error.message === 'Session not found') {
      return res.status(404).json({ success: false, error: error.message });
    }
    next(error);
  }
};

exports.updateSession = async (req, res, next) => {
  try {
    const session = await liftingService.updateSession(req.user.userId, req.params.id, req.body);
    res.status(200).json({ success: true, data: session });
  } catch (error) {
    if (error.message === 'Session not found') {
      return res.status(404).json({ success: false, error: error.message });
    }
    next(error);
  }
};

exports.deleteSession = async (req, res, next) => {
  try {
    await liftingService.deleteSession(req.user.userId, req.params.id);
    res.status(200).json({ success: true, data: {} });
  } catch (error) {
    if (error.message === 'Session not found') {
      return res.status(404).json({ success: false, error: error.message });
    }
    next(error);
  }
};
