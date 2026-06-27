const bodyWeightService = require('../services/bodyweight.service');

exports.logWeight = async (req, res, next) => {
  try {
    const log = await bodyWeightService.logWeight(req.user.userId, req.body);
    res.status(201).json({ success: true, data: log });
  } catch (error) {
    next(error);
  }
};

exports.getHistory = async (req, res, next) => {
  try {
    const history = await bodyWeightService.getHistory(req.user.userId, req.query);
    res.status(200).json({ success: true, data: history });
  } catch (error) {
    next(error);
  }
};
