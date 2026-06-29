const { supabaseAdmin } = require('../config/supabase');

const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, error: 'Authentication required' });
    }

    const token = authHeader.split(' ')[1];
    const { data, error } = await supabaseAdmin.auth.getUser(token);

    if (error || !data || !data.user) {
      return res.status(401).json({ success: false, error: 'Invalid or expired token' });
    }

    req.user = { userId: data.user.id }; // same shape every controller already uses
    next();
  } catch (error) {
    return res.status(401).json({ success: false, error: 'Invalid or expired token' });
  }
};

module.exports = authMiddleware;
