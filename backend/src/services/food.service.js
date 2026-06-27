const FoodLog = require('../models/FoodLog');
const User = require('../models/User');

class FoodService {
  async logMeal(userId, mealData) {
    // Determine if protein goal is met for the day
    const user = await User.findById(userId);
    const dailyGoal = user.dailyProteinGoal || 150;

    // Get today's logs to calculate total protein
    const startOfDay = new Date(mealData.date || Date.now());
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(startOfDay);
    endOfDay.setHours(23, 59, 59, 999);

    const todaysLogs = await FoodLog.find({
      userId,
      date: { $gte: startOfDay, $lte: endOfDay }
    });

    const currentTotalProtein = todaysLogs.reduce((acc, log) => acc + log.protein, 0);
    const newTotalProtein = currentTotalProtein + (mealData.protein || 0);

    const meal = new FoodLog({
      userId,
      ...mealData,
      proteinGoalMet: newTotalProtein >= dailyGoal
    });
    
    await meal.save();

    // If goal met with this meal, update previous logs for today
    if (newTotalProtein >= dailyGoal && currentTotalProtein < dailyGoal) {
      await FoodLog.updateMany(
        { userId, date: { $gte: startOfDay, $lte: endOfDay } },
        { proteinGoalMet: true }
      );
    }

    return meal;
  }

  async getLogs(userId, query) {
    const filter = { userId };
    
    if (query.date) {
      const date = new Date(query.date);
      date.setHours(0, 0, 0, 0);
      const nextDay = new Date(date);
      nextDay.setHours(23, 59, 59, 999);
      
      filter.date = { $gte: date, $lte: nextDay };
    } else if (query.from || query.to) {
      filter.date = {};
      if (query.from) filter.date.$gte = new Date(query.from);
      if (query.to) filter.date.$lte = new Date(query.to);
    }

    return await FoodLog.find(filter).sort({ date: -1 });
  }

  async updateMeal(userId, mealId, updateData) {
    const meal = await FoodLog.findOneAndUpdate(
      { _id: mealId, userId },
      updateData,
      { new: true }
    );
    if (!meal) throw new Error('Meal log not found');
    return meal;
  }

  async deleteMeal(userId, mealId) {
    const meal = await FoodLog.findOneAndDelete({ _id: mealId, userId });
    if (!meal) throw new Error('Meal log not found');
    return meal;
  }
}

module.exports = new FoodService();
