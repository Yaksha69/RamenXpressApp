# RamenXpress Mobile App

A modern Flutter mobile app for ordering delicious ramen with full customer authentication and profile management.

## Features

### Authentication
- **Customer Registration**: Create new accounts with email, password, first name, last name, and phone number
- **Customer Login**: Secure login with email and password
- **Profile Management**: View and edit personal information
- **Secure Logout**: Proper token management and session cleanup

### Profile Features
- View customer information (name, email, phone)
- Edit profile details (first name, last name, phone number)
- Profile image support (with fallback to default image)
- Real-time data synchronization with backend

### Technical Features
- JWT token-based authentication
- Secure token storage using SharedPreferences
- API integration with backend services
- State management using Provider pattern
- Form validation and error handling
- Loading states and user feedback

## Setup Instructions

### Prerequisites
- Flutter SDK (3.2.3 or higher)
- Android Studio / VS Code
- Backend server running on port 3000

### Installation

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure Backend URL**
   - Open `lib/services/api_service.dart`
   - Update the `baseUrl` based on your setup:
     - Android Emulator: `http://10.0.2.2:3000`
     - iOS Simulator: `http://localhost:3000`
     - Physical Device: `http://YOUR_IP_ADDRESS:3000`

3. **Start Backend Server**
   ```bash
   cd backend
   npm start
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

## Testing the Authentication

### 1. Customer Registration
1. Open the app
2. Tap "Sign Up" on the login screen
3. Fill in the registration form:
   - First Name: `John`
   - Last Name: `Doe`
   - Email: `john.doe@example.com`
   - Phone Number: `1234567890`
   - Password: `password123`
   - Confirm Password: `password123`
4. Tap "Sign Up"
5. You should be redirected to the home page

### 2. Customer Login
1. If you have an existing account, enter your credentials:
   - Email: `john.doe@example.com`
   - Password: `password123`
2. Tap "Sign In"
3. You should be redirected to the home page

### 3. Menu Integration
1. After login, you should see the menu page with real data from the backend
2. Test the search functionality by typing in the search bar
3. Test category filtering by tapping different category chips
4. Tap on a menu item to see the customization modal
5. Add add-ons and add items to cart
6. Verify that items appear in the cart

### 4. Profile Management
1. Navigate to the Profile tab
2. View your customer information
3. Tap "Edit Profile" to modify your details
4. Save changes and verify they persist

### 5. Logout
1. Go to the Profile tab
2. Tap "Logout"
3. Confirm the logout action
4. You should be redirected to the login screen

## API Endpoints Used

The app integrates with the following backend endpoints:

- `POST /api/v1/customer/register` - Customer registration
- `POST /api/v1/customer/login` - Customer login
- `GET /api/v1/customer/profile` - Get customer profile
- `PUT /api/v1/customer/profile` - Update customer profile
- `PUT /api/v1/customer/change-password` - Change password
- `POST /api/v1/customer/logout` - Customer logout

## Backend Response Structure

The backend returns customer data in this format:
```json
{
  "message": "Login successful",
  "token": "jwt_token_here",
  "customer": {
    "id": "customer_id",
    "email": "customer@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phoneNumber": "1234567890",
    "profileImage": "/uploads/profile-image.jpg",
    "isActive": true,
    "emailVerified": false,
    "phoneVerified": false,
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

## File Structure

```
lib/
├── main.dart                 # App entry point with auth wrapper
├── login_page.dart          # Login screen with form validation
├── signup_page.dart         # Registration screen
├── profile_page.dart        # Profile display and management
├── edit_profile_page.dart   # Profile editing interface
├── models/
│   └── customer.dart        # Customer data model
├── providers/
│   └── auth_provider.dart   # Authentication state management
└── services/
    └── api_service.dart     # API communication layer
```

## Error Handling

The app includes comprehensive error handling:
- Network connectivity issues
- Invalid credentials
- Server errors
- Form validation errors
- Loading states for better UX

## Security Features

- JWT token storage in secure SharedPreferences
- Automatic token cleanup on logout
- Password validation (minimum 6 characters)
- Email format validation
- Phone number validation

## Troubleshooting

### Common Issues

1. **Connection Error**: Make sure the backend server is running and the URL is correct
2. **Registration Fails**: Check if the email is already registered
3. **Login Fails**: Verify credentials and check if the account exists
4. **Profile Not Loading**: Ensure the JWT token is valid and not expired

### CORS Issues
If you encounter CORS errors, the backend is configured for `http://127.0.0.1:5500`. For mobile testing, you may need to update the CORS configuration in `backend/server.js`:

```javascript
app.use(cors({
    origin: ['http://127.0.0.1:5500', 'http://localhost:3000'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
```

### Debug Mode

Run the app in debug mode to see detailed logs:
```bash
flutter run --debug
```

## Future Enhancements

- Password reset functionality
- Email verification
- Social media login integration
- Biometric authentication
- Push notifications
- Offline mode support
