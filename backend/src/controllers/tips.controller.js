const tipsService = require('../services/tips.service');

exports.getWeeklyTip = async (req, res, next) => {
  try {
    console.log('--- BACKEND: Received request for AI Weekly Tip ---');
    const tip = await tipsService.getWeeklyTip(req.user.userId);
    res.status(200).json({ success: true, data: tip });
  } catch (error) {
    next(error);
  }
};

exports.chat = async (req, res, next) => {
  try {
    console.log('--- BACKEND: Received request for AI Chat ---');
    const { message, history } = req.body;
    const responseText = await tipsService.chatWithCoach(req.user.userId, message, history);
    res.status(200).json({ success: true, data: { text: responseText } });
  } catch (error) {
    next(error);
  }
};

exports.getTipHistory = async (req, res, next) => {
  try {
    const history = await tipsService.getTipHistory(req.user.userId);
    res.status(200).json({ success: true, data: history });
  } catch (error) {
    next(error);
  }
};
