const Address = require('../models/Address');

// Get all addresses for the authenticated customer
const getCustomerAddresses = async (req, res) => {
  try {
    const customerId = req.customerId;
    
    const addresses = await Address.find({ 
      customerId, 
      isActive: true 
    }).sort({ isDefault: -1, createdAt: -1 });

    const formattedAddresses = addresses.map(address => address.getFormattedAddress());

    res.status(200).json({
      success: true,
      data: formattedAddresses
    });
  } catch (error) {
    console.error('Error getting customer addresses:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

// Get a specific address by ID
const getAddressById = async (req, res) => {
  try {
    const { addressId } = req.params;
    const customerId = req.customerId;

    const address = await Address.findOne({ 
      _id: addressId, 
      customerId, 
      isActive: true 
    });

    if (!address) {
      return res.status(404).json({ 
        success: false,
        message: 'Address not found' 
      });
    }

    res.status(200).json({
      success: true,
      data: address.getFormattedAddress()
    });
  } catch (error) {
    console.error('Error getting address:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

// Create a new address
const createAddress = async (req, res) => {
  try {
    const customerId = req.customerId;
    const {
      label,
      recipientName,
      phoneNumber,
      street,
      city,
      state,
      zipCode,
      country = 'Philippines',
      isDefault = false
    } = req.body;

    // Validate required fields
    if (!label || !recipientName || !phoneNumber || !street || !city || !state || !zipCode) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required except country'
      });
    }

    // Validate label enum
    const validLabels = ['Home', 'Work', 'School', 'Other'];
    if (!validLabels.includes(label)) {
      return res.status(400).json({
        success: false,
        message: 'Label must be one of: Home, Work, School, Other'
      });
    }

    const address = new Address({
      customerId,
      label,
      recipientName,
      phoneNumber,
      street,
      city,
      state,
      zipCode,
      country,
      isDefault
    });

    await address.save();

    res.status(201).json({
      success: true,
      message: 'Address created successfully',
      data: address.getFormattedAddress()
    });
  } catch (error) {
    console.error('Error creating address:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

// Update an address
const updateAddress = async (req, res) => {
  try {
    const { addressId } = req.params;
    const customerId = req.customerId;
    const {
      label,
      recipientName,
      phoneNumber,
      street,
      city,
      state,
      zipCode,
      country,
      isDefault
    } = req.body;

    const address = await Address.findOne({ 
      _id: addressId, 
      customerId, 
      isActive: true 
    });

    if (!address) {
      return res.status(404).json({ 
        success: false,
        message: 'Address not found' 
      });
    }

    // Update fields if provided
    if (label) {
      const validLabels = ['Home', 'Work', 'School', 'Other'];
      if (!validLabels.includes(label)) {
        return res.status(400).json({
          success: false,
          message: 'Label must be one of: Home, Work, School, Other'
        });
      }
      address.label = label;
    }
    if (recipientName) address.recipientName = recipientName;
    if (phoneNumber) address.phoneNumber = phoneNumber;
    if (street) address.street = street;
    if (city) address.city = city;
    if (state) address.state = state;
    if (zipCode) address.zipCode = zipCode;
    if (country) address.country = country;
    if (isDefault !== undefined) address.isDefault = isDefault;

    await address.save();

    res.status(200).json({
      success: true,
      message: 'Address updated successfully',
      data: address.getFormattedAddress()
    });
  } catch (error) {
    console.error('Error updating address:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

// Delete an address (soft delete)
const deleteAddress = async (req, res) => {
  try {
    const { addressId } = req.params;
    const customerId = req.customerId;

    const address = await Address.findOne({ 
      _id: addressId, 
      customerId, 
      isActive: true 
    });

    if (!address) {
      return res.status(404).json({ 
        success: false,
        message: 'Address not found' 
      });
    }

    // Soft delete by setting isActive to false
    address.isActive = false;
    await address.save();

    res.status(200).json({
      success: true,
      message: 'Address deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting address:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

// Set default address
const setDefaultAddress = async (req, res) => {
  try {
    const { addressId } = req.params;
    const customerId = req.customerId;

    const address = await Address.findOne({ 
      _id: addressId, 
      customerId, 
      isActive: true 
    });

    if (!address) {
      return res.status(404).json({ 
        success: false,
        message: 'Address not found' 
      });
    }

    // Set this address as default (the pre-save hook will handle the rest)
    address.isDefault = true;
    await address.save();

    res.status(200).json({
      success: true,
      message: 'Default address set successfully',
      data: address.getFormattedAddress()
    });
  } catch (error) {
    console.error('Error setting default address:', error);
    res.status(500).json({ 
      success: false,
      message: 'Server error', 
      error: error.message 
    });
  }
};

module.exports = {
  getCustomerAddresses,
  getAddressById,
  createAddress,
  updateAddress,
  deleteAddress,
  setDefaultAddress
}; 