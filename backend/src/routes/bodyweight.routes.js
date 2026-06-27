const express = require('express');
const router = express.Router();
const bodyWeightController = require('../controllers/bodyweight.controller');
const authMiddleware = require('../middleware/auth.middleware');

router.use(authMiddleware);

router.post('/', bodyWeightController.logWeight);
router.get('/', bodyWeightController.getHistory);

module.exports = router;
