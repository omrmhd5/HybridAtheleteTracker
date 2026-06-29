const { supabaseAdmin } = require('../config/supabase');
const { foodToApi, foodToRow } = require('../utils/mappers');

const TABLE = 'food_logs';

class FoodService {
  async logMeal(userId, mealData) {
    // Daily protein goal from the user's profile.
    const { data: profile } = await supabaseAdmin
      .from('profiles')
      .select('daily_protein_goal')
      .eq('id', userId)
      .single();
    const dailyGoal = (profile && profile.daily_protein_goal) || 150;

    // Today's window (based on the meal's date, defaulting to now).
    const startOfDay = new Date(mealData.date || Date.now());
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(startOfDay);
    endOfDay.setHours(23, 59, 59, 999);

    const { data: todaysLogs, error: fetchError } = await supabaseAdmin
      .from(TABLE)
      .select('protein')
      .eq('user_id', userId)
      .gte('date', startOfDay.toISOString())
      .lte('date', endOfDay.toISOString());
    if (fetchError) throw new Error(fetchError.message);

    const currentTotalProtein = (todaysLogs || []).reduce((acc, log) => acc + (log.protein || 0), 0);
    const newTotalProtein = currentTotalProtein + (mealData.protein || 0);
    const goalMet = newTotalProtein >= dailyGoal;

    const { data: meal, error: insertError } = await supabaseAdmin
      .from(TABLE)
      .insert({ user_id: userId, ...foodToRow(mealData), protein_goal_met: goalMet })
      .select('*')
      .single();
    if (insertError) throw new Error(insertError.message);

    // If this meal flipped the day over the goal, back-fill the day's rows.
    if (goalMet && currentTotalProtein < dailyGoal) {
      const { error: updateError } = await supabaseAdmin
        .from(TABLE)
        .update({ protein_goal_met: true })
        .eq('user_id', userId)
        .gte('date', startOfDay.toISOString())
        .lte('date', endOfDay.toISOString());
      if (updateError) throw new Error(updateError.message);
    }

    return foodToApi(meal);
  }

  async getLogs(userId, query) {
    let q = supabaseAdmin.from(TABLE).select('*').eq('user_id', userId);

    if (query.date) {
      const start = new Date(query.date);
      start.setHours(0, 0, 0, 0);
      const end = new Date(start);
      end.setHours(23, 59, 59, 999);
      q = q.gte('date', start.toISOString()).lte('date', end.toISOString());
    } else {
      if (query.from) q = q.gte('date', new Date(query.from).toISOString());
      if (query.to) q = q.lte('date', new Date(query.to).toISOString());
    }

    const { data, error } = await q.order('date', { ascending: false });
    if (error) throw new Error(error.message);
    return data.map(foodToApi);
  }

  async updateMeal(userId, mealId, updateData) {
    const { data, error } = await supabaseAdmin
      .from(TABLE)
      .update({ ...foodToRow(updateData), updated_at: new Date().toISOString() })
      .eq('id', mealId)
      .eq('user_id', userId)
      .select('*')
      .single();
    if (error || !data) throw new Error('Meal log not found');
    return foodToApi(data);
  }

  async deleteMeal(userId, mealId) {
    const { data, error } = await supabaseAdmin
      .from(TABLE)
      .delete()
      .eq('id', mealId)
      .eq('user_id', userId)
      .select('*')
      .single();
    if (error || !data) throw new Error('Meal log not found');
    return foodToApi(data);
  }
}

module.exports = new FoodService();
