const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const { verifyCustomerToken } = require('../middleware/AuthMiddleware');
const {
  registerCustomer,
  loginCustomer,
  getCustomerProfile,
  updateCustomerProfile,
  changePassword,
  uploadProfileImage,
  logoutCustomer
} = require('../controllers/CustomerController');

// Configure multer for profile image upload
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'profile-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  },
  fileFilter: function (req, file, cb) {
    const filetypes = /jpeg|jpg|png|gif/;
    const mimetype = filetypes.test(file.mimetype);
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());

    if (mimetype && extname) {
      return cb(null, true);
    }
    cb(new Error('Only image files are allowed!'));
  }
});

// Public routes (no authentication required)
router.post('/register', registerCustomer);
router.post('/login', loginCustomer);

// Protected routes (authentication required)
router.get('/profile', verifyCustomerToken, getCustomerProfile);
router.put('/profile', verifyCustomerToken, updateCustomerProfile);
router.put('/change-password', verifyCustomerToken, changePassword);
router.post('/upload-profile-image', verifyCustomerToken, upload.single('profileImage'), uploadProfileImage);
router.post('/logout', verifyCustomerToken, logoutCustomer);

module.exports = router; 