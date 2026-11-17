const express = require('express');
const router = express.Router();
const { authenticateToken, requireRole } = require('../middleware/authMiddleware');
const adminController = require('../controllers/adminController');

router.post('/admin/create_user', authenticateToken, requireRole('admin'), adminController.createUser);
router.get('/admin/users', authenticateToken, requireRole('admin'), adminController.listUsers);

module.exports = router;
