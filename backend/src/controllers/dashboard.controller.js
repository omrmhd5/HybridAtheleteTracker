const dashboardService = require('../services/dashboard.service');

exports.getWeeklySummary = async (req, res, next) => {
  try {
    const summary = await dashboardService.getWeeklySummary(req.user.userId);
    res.status(200).json({ success: true, data: summary });
  } catch (error) {
    next(error);
  }
};
