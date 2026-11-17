const express = require('express');
const router = express.Router();
const { resolveLegacyIds } = require('../middleware/resolveLegacyIds');
const authController = require('../controllers/authController');
const { authenticateToken } = require('../middleware/authMiddleware');
const compatController = require('../controllers/compatController');
const rateLimit = require('express-rate-limit');

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // Limit each IP to 10 requests per windowMs
  message: 'Too many login attempts, please try again later.'
});

router.post('/signup', authController.signup);
router.post('/register', authController.signup); // Alias route for backwards compatibility
router.post('/login', loginLimiter, authController.login);
router.post('/update_user_profile', authenticateToken, authController.updateUserProfile);
router.post('/change_password', authenticateToken, authController.changePassword);
router.post('/update_password', authenticateToken, authController.changePassword);

router.post('/save_language_preference', authenticateToken, compatController.languagePreference);

module.exports = router;
