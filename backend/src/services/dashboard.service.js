const { supabaseAdmin } = require('../config/supabase');

class DashboardService {
  async getWeeklySummary(userId) {
    const now = new Date();
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(now.getDate() - 7);
    const since = sevenDaysAgo.toISOString();

    const [liftingRes, foodRes, cardioRes, weightRes] = await Promise.all([
      supabaseAdmin.from('lifting_sessions').select('exercises').eq('user_id', userId).gte('date', since),
      supabaseAdmin.from('food_logs').select('protein_goal_met').eq('user_id', userId).gte('date', since),
      supabaseAdmin.from('cardio_logs').select('duration_minutes, distance').eq('user_id', userId).gte('date', since),
      supabaseAdmin.from('body_weights').select('date, weight, unit').eq('user_id', userId).gte('date', since).order('date', { ascending: true })
    ]);

    for (const res of [liftingRes, foodRes, cardioRes, weightRes]) {
      if (res.error) throw new Error(res.error.message);
    }

    const lifting = liftingRes.data || [];
    const food = foodRes.data || [];
    const cardio = cardioRes.data || [];
    const weight = weightRes.data || [];

    // Lifting volume = sum(weight * reps) across all sets.
    let totalVolume = 0;
    lifting.forEach((session) => {
      (session.exercises || []).forEach((ex) => {
        (ex.sets || []).forEach((set) => {
          totalVolume += (Number(set.weight) || 0) * (Number(set.reps) || 0);
        });
      });
    });

    let totalCardioMinutes = 0;
    let totalCardioDistance = 0;
    cardio.forEach((session) => {
      totalCardioMinutes += Number(session.duration_minutes) || 0;
      totalCardioDistance += Number(session.distance) || 0;
    });

    const daysGoalMet = food.filter((f) => f.protein_goal_met).length;

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
        trend: weight.map((w) => ({
          date: new Date(w.date).toISOString(),
          weight: Number(w.weight),
          unit: w.unit
        }))
      }
    };
  }
}

module.exports = new DashboardService();
