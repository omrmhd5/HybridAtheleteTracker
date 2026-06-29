const { supabaseAdmin } = require('../config/supabase');
const { bodyWeightToApi, bodyWeightToRow } = require('../utils/mappers');

const TABLE = 'body_weights';

class BodyWeightService {
  async logWeight(userId, data) {
    const { data: row, error } = await supabaseAdmin
      .from(TABLE)
      .insert({ user_id: userId, ...bodyWeightToRow(data) })
      .select('*')
      .single();
    if (error) throw new Error(error.message);
    return bodyWeightToApi(row);
  }

  async getHistory(userId, query) {
    let q = supabaseAdmin.from(TABLE).select('*').eq('user_id', userId);
    if (query.from) q = q.gte('date', new Date(query.from).toISOString());
    if (query.to) q = q.lte('date', new Date(query.to).toISOString());
    const { data, error } = await q.order('date', { ascending: false });
    if (error) throw new Error(error.message);
    return data.map(bodyWeightToApi);
  }
}

module.exports = new BodyWeightService();
