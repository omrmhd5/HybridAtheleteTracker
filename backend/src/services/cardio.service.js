const { supabaseAdmin } = require('../config/supabase');
const { cardioToApi, cardioToRow } = require('../utils/mappers');

const TABLE = 'cardio_logs';

class CardioService {
  async logSession(userId, sessionData) {
    const { data, error } = await supabaseAdmin
      .from(TABLE)
      .insert({ user_id: userId, ...cardioToRow(sessionData) })
      .select('*')
      .single();
    if (error) throw new Error(error.message);
    return cardioToApi(data);
  }

  async getSessions(userId, query) {
    let q = supabaseAdmin.from(TABLE).select('*').eq('user_id', userId);
    if (query.from) q = q.gte('date', new Date(query.from).toISOString());
    if (query.to) q = q.lte('date', new Date(query.to).toISOString());
    const { data, error } = await q.order('date', { ascending: false });
    if (error) throw new Error(error.message);
    return data.map(cardioToApi);
  }

  async updateSession(userId, sessionId, updateData) {
    const { data, error } = await supabaseAdmin
      .from(TABLE)
      .update({ ...cardioToRow(updateData), updated_at: new Date().toISOString() })
      .eq('id', sessionId)
      .eq('user_id', userId)
      .select('*')
      .single();
    if (error || !data) throw new Error('Session not found');
    return cardioToApi(data);
  }

  async deleteSession(userId, sessionId) {
    const { data, error } = await supabaseAdmin
      .from(TABLE)
      .delete()
      .eq('id', sessionId)
      .eq('user_id', userId)
      .select('*')
      .single();
    if (error || !data) throw new Error('Session not found');
    return cardioToApi(data);
  }
}

module.exports = new CardioService();
