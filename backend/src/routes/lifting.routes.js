const express = require('express');
const router = express.Router();
const liftingController = require('../controllers/lifting.controller');
const authMiddleware = require('../middleware/auth.middleware');

router.use(authMiddleware);

router.post('/', liftingController.logSession);
router.get('/', liftingController.getSessions);
router.get('/:id', liftingController.getSessionById);
router.put('/:id', liftingController.updateSession);
router.delete('/:id', liftingController.deleteSession);

module.exports = router;
