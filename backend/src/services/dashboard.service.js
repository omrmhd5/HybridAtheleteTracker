const LiftingSession = require('../models/LiftingSession');
const FoodLog = require('../models/FoodLog');
const CardioLog = require('../models/CardioLog');
const BodyWeight = require('../models/BodyWeight');

class DashboardService {
  async getWeeklySummary(userId) {
    const now = new Date();
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(now.getDate() - 7);

    const [lifting, food, cardio, weight] = await Promise.all([
      LiftingSession.find({ userId, date: { $gte: sevenDaysAgo } }),
      FoodLog.find({ userId, date: { $gte: sevenDaysAgo } }),
      CardioLog.find({ userId, date: { $gte: sevenDaysAgo } }),
      BodyWeight.find({ userId, date: { $gte: sevenDaysAgo } }).sort({ date: 1 })
    ]);

    // Calculate lifting volume
    let totalVolume = 0;
    lifting.forEach(session => {
      session.exercises.forEach(ex => {
        ex.sets.forEach(set => {
          totalVolume += (set.weight * set.reps);
        });
      });
    });

    // Calculate cardio
    let totalCardioMinutes = 0;
    let totalCardioDistance = 0;
    cardio.forEach(session => {
      totalCardioMinutes += session.durationMinutes;
      totalCardioDistance += (session.distance || 0);
    });

    // Food goals
    const daysGoalMet = food.filter(f => f.proteinGoalMet).length;

    return {
      lifting: {
        sessionsCount: lifting.length,
        totalVolume
      },
      cardio: {
        sessionsCount: cardio.length,
        totalMinutes: totalCardioMinutes,
        totalDistance: totalCardioDistance
      },
      food: {
        logsCount: food.length,
        daysGoalMet
      },
      weight: {
        trend: weight.map(w => ({ date: w.date, weight: w.weight, unit: w.unit }))
      }
    };
  }
}

module.exports = new DashboardService();
