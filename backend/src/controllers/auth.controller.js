const authService = require('../services/auth.service');

exports.register = async (req, res, next) => {
  try {
    const tokens = await authService.register(req.body);
    res.status(201).json({ success: true, data: tokens });
  } catch (error) {
    if (error.message.includes('already exists')) {
      return res.status(400).json({ success: false, error: error.message });
    }
    next(error);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, error: 'Email and password are required' });
    }
    const tokens = await authService.login(email, password);
    res.status(200).json({ success: true, data: tokens });
  } catch (error) {
    if (error.message.includes('Invalid')) {
      return res.status(401).json({ success: false, error: error.message });
    }
    next(error);
  }
};

exports.refresh = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    const tokens = await authService.refresh(refreshToken);
    res.status(200).json({ success: true, data: tokens });
  } catch (error) {
    return res.status(401).json({ success: false, error: error.message });
  }
};

exports.getProfile = async (req, res, next) => {
  try {
    const user = await authService.getProfile(req.user.userId);
    res.status(200).json({ success: true, data: user });
  } catch (error) {
    next(error);
  }
};

exports.updateProfile = async (req, res, next) => {
  try {
    const user = await authService.updateProfile(req.user.userId, req.body);
    res.status(200).json({ success: true, data: user });
  } catch (error) {
    next(error);
  }
};
