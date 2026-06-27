const express = require('express');
const router = express.Router();
const foodController = require('../controllers/food.controller');
const authMiddleware = require('../middleware/auth.middleware');

router.use(authMiddleware);

router.post('/', foodController.logMeal);
router.get('/', foodController.getLogs);
router.put('/:id', foodController.updateMeal);
router.delete('/:id', foodController.deleteMeal);

module.exports = router;
