const { supabaseAdmin, supabaseAnon } = require('../config/supabase');
const { profileToApi, profileUpdateToRow } = require('../utils/mappers');

class AuthService {
  async register(userData) {
    const { name, username, email, password, unitPreference, dailyProteinGoal } = userData;

    // Create the Supabase Auth user (email confirmation disabled so signup
    // logs in immediately).
    const { data: created, error: createError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true
    });

    if (createError) {
      if (/already|exists|registered|duplicate/i.test(createError.message)) {
        throw new Error('User with this email or username already exists');
      }
      throw new Error(createError.message);
    }

    const userId = created.user.id;

    // Create the profile row. If it fails, roll back the auth user so the
    // email/username isn't left orphaned.
    const { error: profileError } = await supabaseAdmin.from('profiles').insert({
      id: userId,
      name,
      username,
      email,
      unit_preference: unitPreference || 'kg',
      daily_protein_goal: dailyProteinGoal != null ? dailyProteinGoal : 150
    });

    if (profileError) {
      await supabaseAdmin.auth.admin.deleteUser(userId);
      if (profileError.code === '23505' || /duplicate|unique/i.test(profileError.message)) {
        throw new Error('User with this email or username already exists');
      }
      throw new Error(profileError.message);
    }

    return this.signIn(email, password);
  }

  async login(email, password) {
    return this.signIn(email, password);
  }

  async signIn(email, password) {
    const { data, error } = await supabaseAnon.auth.signInWithPassword({ email, password });
    if (error || !data || !data.session) {
      throw new Error('Invalid email or password');
    }
    return {
      token: data.session.access_token,
      refreshToken: data.session.refresh_token
    };
  }

  async refresh(refreshToken) {
    if (!refreshToken) {
      throw new Error('Invalid or expired token');
    }
    const { data, error } = await supabaseAnon.auth.refreshSession({ refresh_token: refreshToken });
    if (error || !data || !data.session) {
      throw new Error('Invalid or expired token');
    }
    return {
      token: data.session.access_token,
      refreshToken: data.session.refresh_token
    };
  }

  async getProfile(userId) {
    const { data, error } = await supabaseAdmin
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single();

    if (error || !data) {
      throw new Error('User not found');
    }
    return profileToApi(data);
  }

  async updateProfile(userId, updateData) {
    const row = profileUpdateToRow(updateData);
    const { data, error } = await supabaseAdmin
      .from('profiles')
      .update(row)
      .eq('id', userId)
      .select('*')
      .single();

    if (error || !data) {
      throw new Error('User not found');
    }
    return profileToApi(data);
  }
}

module.exports = new AuthService();
