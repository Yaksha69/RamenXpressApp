// API endpoint
const API_URL = 'http://localhost:3000/api/v1';

// Handle login form submission
async function handleLogin(event) {
    event.preventDefault();
    
    // Get form values
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const role = document.querySelector('input[name="role"]:checked').value;
    
    // Show error message element
    const errorMessage = document.getElementById('errorMessage');
    errorMessage.style.display = 'none';
    
    try {
        console.log('Attempting login with:', { username, role });
        
        // Make API request
        const response = await fetch(`${API_URL}/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ username, password }),
            credentials: 'include' // Important for cookies
        });
        
        const data = await response.json();
        console.log('Login response:', data);
        
        if (!response.ok) {
            throw new Error(data.message || 'Login failed');
        }
        
        // Check if user role matches selected role
        // Backend returns user data in 'customer' property
        if (!data.customer) {
            throw new Error('Invalid response format: missing customer data');
        }
        
        if (data.customer.role !== role) {
            throw new Error(`Invalid role selected. Expected: ${role}, Got: ${data.customer.role}`);
        }

        // Store the token in localStorage
        if (data.token) {
            localStorage.setItem('authToken', data.token);
            // Also store user info
            localStorage.setItem('userRole', data.customer.role);
            localStorage.setItem('username', data.customer.username);
            localStorage.setItem('userId', data.customer.id);
            
            console.log('Login successful, stored data:', {
                role: data.customer.role,
                username: data.customer.username,
                userId: data.customer.id
            });
        } else {
            throw new Error('No authentication token received');
        }
        
        // Redirect based on role
        if (role === 'admin') {
            window.location.href = './html/dashboard.html';
        } else if (role === 'cashier') {
            window.location.href = './html/POS.html';
        } else {
            // Default fallback
            window.location.href = './html/POS.html';
        }
        
    } catch (error) {
        console.error('Login error:', error);
        errorMessage.textContent = error.message || 'Failed to connect to server';
        errorMessage.style.display = 'block';
    }
    
    return false;
}

// Add active class to role selector buttons
document.querySelectorAll('.role-selector .btn').forEach(button => {
    button.addEventListener('click', function() {
        document.querySelectorAll('.role-selector .btn').forEach(btn => {
            btn.classList.remove('active');
        });
        this.classList.add('active');
    });
}); 