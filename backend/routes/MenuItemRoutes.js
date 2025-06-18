const express = require('express');
const router = express.Router();
const MenuItemController = require('../controllers/MenuItemController');
const { verifyToken, isAdmin } = require('../middleware/AuthMiddleware');

// Public routes
router.get('/', MenuItemController.getAllMenuItems);
router.get('/:id', MenuItemController.getMenuItemById);

// Protected routes (admin only)
router.post('/', verifyToken, isAdmin, MenuItemController.createMenuItem);
router.put('/:id', verifyToken, isAdmin, MenuItemController.updateMenuItem);
router.delete('/:id', verifyToken, isAdmin, MenuItemController.deleteMenuItem);

module.exports = router; 