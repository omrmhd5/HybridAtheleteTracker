const foodService = require('../services/food.service');

exports.logMeal = async (req, res, next) => {
  try {
    const meal = await foodService.logMeal(req.user.userId, req.body);
    res.status(201).json({ success: true, data: meal });
  } catch (error) {
    next(error);
  }
};

exports.getLogs = async (req, res, next) => {
  try {
    const logs = await foodService.getLogs(req.user.userId, req.query);
    res.status(200).json({ success: true, data: logs });
  } catch (error) {
    next(error);
  }
};

exports.updateMeal = async (req, res, next) => {
  try {
    const meal = await foodService.updateMeal(req.user.userId, req.params.id, req.body);
    res.status(200).json({ success: true, data: meal });
  } catch (error) {
    if (error.message === 'Meal log not found') {
      return res.status(404).json({ success: false, error: error.message });
    }
    next(error);
  }
};

exports.deleteMeal = async (req, res, next) => {
  try {
    await foodService.deleteMeal(req.user.userId, req.params.id);
    res.status(200).json({ success: true, data: {} });
  } catch (error) {
    if (error.message === 'Meal log not found') {
      return res.status(404).json({ success: false, error: error.message });
    }
    next(error);
  }
};
