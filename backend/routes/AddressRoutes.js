const express = require('express');
const router = express.Router();
const { 
  getCustomerAddresses,
  getAddressById,
  createAddress,
  updateAddress,
  deleteAddress,
  setDefaultAddress
} = require('../controllers/AddressController');
const { verifyCustomerToken } = require('../middleware/AuthMiddleware');

// Apply customer authentication middleware to all routes
router.use(verifyCustomerToken);

// Get all addresses for the authenticated customer
router.get('/', getCustomerAddresses);

// Create new address
router.post('/', createAddress);

// Get single address
router.get('/:addressId', getAddressById);

// Update address
router.put('/:addressId', updateAddress);

// Delete address (soft delete)
router.delete('/:addressId', deleteAddress);

// Set default address
router.patch('/:addressId/default', setDefaultAddress);

module.exports = router; 