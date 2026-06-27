const express = require('express');
const router = express.Router();
const cardioController = require('../controllers/cardio.controller');
const authMiddleware = require('../middleware/auth.middleware');

router.use(authMiddleware);

router.post('/', cardioController.logSession);
router.get('/', cardioController.getSessions);
router.put('/:id', cardioController.updateSession);
router.delete('/:id', cardioController.deleteSession);

module.exports = router;
