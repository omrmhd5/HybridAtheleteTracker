const express = require('express');
const router = express.Router();
const tipsController = require('../controllers/tips.controller');
const authMiddleware = require('../middleware/auth.middleware');

router.use(authMiddleware);

router.get('/weekly', tipsController.getWeeklyTip);
router.get('/history', tipsController.getTipHistory);
router.post('/chat', tipsController.chat);

module.exports = router;
