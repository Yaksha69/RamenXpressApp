// API Configuration
const API_BASE_URL = 'http://localhost:3000/api/v1/mobile-orders';

// WebSocket (socket.io) setup
const socket = io('http://localhost:3000', {
    transports: ['websocket'],
    withCredentials: true
});
// Join admin room for real-time order updates
socket.emit('join-admin');
// Listen for real-time order updates
socket.on('orderStatusUpdated', (data) => {
    console.log('Order status updated:', data);
    loadOrders(); // Refresh the order list
});
socket.on('paymentStatusUpdated', (data) => {
    console.log('Payment status updated:', data);
    loadOrders();
});
socket.on('orderCancelled', (data) => {
    console.log('Order cancelled:', data);
    loadOrders();
});

// Authentication token (should be set after login)
let authToken = localStorage.getItem('authToken');

// Sidebar Toggle Functionality
document.addEventListener('DOMContentLoaded', function() {
    const sidebar = document.querySelector('.sidebar');
    const sidebarToggle = document.getElementById('sidebarToggle');
    const closeSidebar = document.getElementById('closeSidebar');

    // Toggle sidebar on button click
    sidebarToggle.addEventListener('click', function() {
        sidebar.classList.add('show');
    });

    // Close sidebar on close button click
    closeSidebar.addEventListener('click', function() {
        sidebar.classList.remove('show');
    });

    // Close sidebar when clicking outside on mobile
    document.addEventListener('click', function(event) {
        if (window.innerWidth <= 768 && 
            !sidebar.contains(event.target) && 
            !sidebarToggle.contains(event.target) && 
            sidebar.classList.contains('show')) {
            sidebar.classList.remove('show');
        }
    });

    // Handle window resize
    window.addEventListener('resize', function() {
        if (window.innerWidth > 768) {
            sidebar.classList.remove('show');
        }
    });
});

// API Functions
async function fetchOrders(filters = {}) {
    try {
        const queryParams = new URLSearchParams();
        
        if (filters.startDate && filters.endDate) {
            queryParams.append('startDate', filters.startDate);
            queryParams.append('endDate', filters.endDate);
        }
        if (filters.status && filters.status !== 'all') {
            queryParams.append('status', filters.status);
        }
        if (filters.paymentMethod && filters.paymentMethod !== 'all') {
            queryParams.append('paymentMethod', filters.paymentMethod);
        }
        if (filters.page) {
            queryParams.append('page', filters.page);
        }
        if (filters.limit) {
            queryParams.append('limit', filters.limit);
        }

        const response = await fetch(`${API_BASE_URL}/orders?${queryParams}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${authToken}`
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Error fetching orders:', error);
        throw error;
    }
}

async function fetchOrderDetails(orderId) {
    try {
        const response = await fetch(`${API_BASE_URL}/orders/${orderId}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${authToken}`
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Error fetching order details:', error);
        throw error;
    }
}

async function updateOrderStatus(orderId, status) {
    try {
        const response = await fetch(`${API_BASE_URL}/orders/${orderId}/status`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${authToken}`
            },
            body: JSON.stringify({ status })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Error updating order status:', error);
        throw error;
    }
}

async function updatePaymentStatus(orderId, paymentStatus) {
    try {
        const response = await fetch(`${API_BASE_URL}/orders/${orderId}/payment-status`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${authToken}`
            },
            body: JSON.stringify({ paymentStatus })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Error updating payment status:', error);
        throw error;
    }
}

async function cancelOrder(orderId, reason) {
    try {
        const response = await fetch(`${API_BASE_URL}/orders/${orderId}/cancel`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${authToken}`
            },
            body: JSON.stringify({ reason })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Error cancelling order:', error);
        throw error;
    }
}

// Global variables
let orders = [];
let selectedOrder = null;
let currentPage = 1;
const ORDERS_PER_PAGE = 10;

// Mobile Order Specific Functions
function initializeMobileOrder() {
    console.log('Mobile Order initialized');
    loadOrders();
}

// Load orders from API
async function loadOrders() {
    try {
        showLoading(true);
        const filters = getCurrentFilters();
        filters.page = currentPage;
        filters.limit = ORDERS_PER_PAGE;
        
        const data = await fetchOrders(filters);
        orders = data.orders || [];
        
        renderOrdersTable();
        renderPagination(data.pagination);
    } catch (error) {
        console.error('Error loading orders:', error);
        Swal.fire({
            icon: 'error',
            title: 'Error',
            text: 'Failed to load orders. Please try again.'
        });
    } finally {
        showLoading(false);
    }
}

function getCurrentFilters() {
    const dateVal = document.getElementById('filterDate').value;
    const statusVal = document.getElementById('filterOrderStatus').value;
    const paymentVal = document.getElementById('filterPaymentMethod').value;
    
    const filters = {};
    
    if (dateVal && dateVal.includes(' - ')) {
        const [start, end] = dateVal.split(' - ');
        filters.startDate = start;
        filters.endDate = end;
    }
    
    if (statusVal && statusVal !== 'all') {
        filters.status = statusVal;
    }
    
    if (paymentVal && paymentVal !== 'all') {
        filters.paymentMethod = paymentVal;
    }
    
    return filters;
}

function showLoading(show) {
    const tbody = document.getElementById('ordersTableBody');
    if (show) {
        tbody.innerHTML = `
            <tr>
                <td colspan="7" class="text-center py-4">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </td>
            </tr>
        `;
    }
}

function renderOrdersTable() {
    const tbody = document.getElementById('ordersTableBody');
    tbody.innerHTML = '';
    
    if (orders.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="7" class="text-center py-4">
                    <i class="fas fa-inbox fa-2x text-muted mb-2"></i>
                    <p class="text-muted">No orders found</p>
                </td>
            </tr>
        `;
        return;
    }
    
    orders.forEach((order) => {
        const tr = document.createElement('tr');
        const hasNotes = order.notes && order.notes.trim().length > 0;
        const notesIndicator = hasNotes ? ' <i class="fas fa-sticky-note text-warning" title="Has notes"></i>' : '';
        
        tr.innerHTML = `
            <td>#${order.orderId}</td>
            <td>${order.customerId ? `${order.customerId.firstName} ${order.customerId.lastName}` : 'Guest'}${notesIndicator}</td>
            <td>${formatDateTime(order.orderDate)}</td>
            <td>₱${order.total.toFixed(2)}</td>
            <td><span class="badge ${getPaymentStatusClass(order.paymentStatus || 'Pending')}">${order.paymentStatus || 'Pending'}</span></td>
            <td><span class="badge rounded-pill ${getDeliveryStatusClass(order.status)}">${capitalize(order.status)}</span></td>
            <td><button class="btn btn-outline-primary btn-sm" data-order-id="${order.orderId}" data-bs-toggle="modal" data-bs-target="#orderDetailsModal"><i class="fa fa-eye"></i> View</button></td>
        `;
        tbody.appendChild(tr);
    });
    
    attachViewHandlers();
}

function attachViewHandlers() {
    document.querySelectorAll('button[data-bs-target="#orderDetailsModal"]').forEach(btn => {
        btn.onclick = async function() {
            const orderId = this.getAttribute('data-order-id');
            try {
                showLoading(true);
                const data = await fetchOrderDetails(orderId);
                selectedOrder = data.order;
                populateOrderModal(selectedOrder);
            } catch (error) {
                console.error('Error loading order details:', error);
                Swal.fire({
                    icon: 'error',
                    title: 'Error',
                    text: 'Failed to load order details.'
                });
            } finally {
                showLoading(false);
            }
        };
    });
}

function populateOrderModal(order) {
    // Set modal title
    document.getElementById('orderDetailsModalLabel').textContent = `Order Details - #${order.orderId}`;
    
    // Order Summary
    document.getElementById('modalOrderId').textContent = `#${order.orderId}`;
    document.getElementById('modalOrderDate').textContent = formatDateTime(order.orderDate);
    
    if (order.customerId) {
        document.getElementById('modalCustomerName').textContent = `${order.customerId.firstName} ${order.customerId.lastName}`;
        document.getElementById('modalCustomerEmail').textContent = order.customerId.email || 'N/A';
        document.getElementById('modalCustomerPhone').textContent = order.customerId.phoneNumber || 'N/A';
    } else {
        document.getElementById('modalCustomerName').textContent = 'Guest Customer';
        document.getElementById('modalCustomerEmail').textContent = 'N/A';
        document.getElementById('modalCustomerPhone').textContent = 'N/A';
    }
    
    // Delivery address
    if (order.deliveryAddress) {
        const address = order.deliveryAddress;
        document.getElementById('modalCustomerAddress').textContent = 
            `${address.street}, ${address.city}, ${address.state} ${address.zipCode}`;
    } else {
        document.getElementById('modalCustomerAddress').textContent = 'Pick up order';
    }
    
    // Payment method
    document.getElementById('modalPaymentMethod').textContent = formatPaymentMethod(order.paymentMethod);
    
    // Payment status
    const paymentStatus = order.paymentStatus || 'Pending';
    document.getElementById('modalPaymentStatus').textContent = paymentStatus;
    document.getElementById('modalPaymentStatus').className = `badge ${getPaymentStatusClass(paymentStatus)} px-3 py-2`;
    
    // Delivery status
    document.getElementById('modalDeliveryStatusBadge').textContent = capitalize(order.status);
    document.getElementById('modalDeliveryStatusBadge').className = `badge rounded-pill ${getDeliveryStatusClass(order.status)} px-3 py-2`;
    document.getElementById('modalDeliveryStatusSelect').value = order.status;
    
    // Notes
    const notesElement = document.getElementById('modalOrderNotes');
    if (order.notes && order.notes.trim().length > 0) {
        notesElement.innerHTML = `<span class="text-dark">${order.notes}</span>`;
    } else {
        notesElement.innerHTML = `<span class="text-muted">No notes available</span>`;
    }
    
    // Order Items
    const itemsTbody = document.getElementById('modalOrderItems');
    itemsTbody.innerHTML = '';
    order.items.forEach(item => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${item.name}</td>
            <td>₱${item.price.toFixed(2)}</td>
            <td>${item.quantity}</td>
            <td>₱${item.total.toFixed(2)}</td>
        `;
        itemsTbody.appendChild(tr);
    });
    
    document.getElementById('modalOrderTotal').textContent = `₱${order.total.toFixed(2)}`;
}

function getDeliveryStatusClass(status) {
    switch (status) {
        case 'pending': return 'bg-warning-subtle text-warning-emphasis';
        case 'confirmed': return 'bg-info-subtle text-info-emphasis';
        case 'preparing': return 'bg-primary-subtle text-primary-emphasis';
        case 'ready': return 'bg-success-subtle text-success-emphasis';
        case 'delivered': return 'bg-success-subtle text-success-emphasis';
        case 'cancelled': return 'bg-danger-subtle text-danger-emphasis';
        default: return 'bg-secondary';
    }
}

function getPaymentStatusClass(status) {
    switch (status) {
        case 'Paid': return 'bg-success';
        case 'Pending': return 'bg-warning';
        case 'Refunded': return 'bg-info';
        case 'Failed': return 'bg-danger';
        default: return 'bg-secondary';
    }
}

function capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}

function formatPaymentMethod(method) {
    switch (method.toLowerCase()) {
        case 'gcash': return 'GCash';
        case 'paymaya': return 'PayMaya';
        case 'cash': return 'Cash on Delivery';
        default: return capitalize(method);
    }
}

function formatDateTime(dateString) {
    const date = new Date(dateString);
    return date.toLocaleString('en-US', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
    });
}

function renderPagination(pagination) {
    const paginationElement = document.querySelector('.pagination');
    if (!paginationElement || !pagination) return;
    
    paginationElement.innerHTML = '';
    
    // Previous button
    const prevClass = pagination.currentPage === 1 ? 'disabled' : '';
    paginationElement.innerHTML += `<li class="page-item ${prevClass}"><a class="page-link" href="#" id="prevPageBtn">Previous</a></li>`;
    
    // Page numbers
    for (let i = 1; i <= pagination.totalPages; i++) {
        const activeClass = i === pagination.currentPage ? 'active' : '';
        paginationElement.innerHTML += `<li class="page-item ${activeClass}"><a class="page-link" href="#" data-page="${i}">${i}</a></li>`;
    }
    
    // Next button
    const nextClass = pagination.currentPage === pagination.totalPages ? 'disabled' : '';
    paginationElement.innerHTML += `<li class="page-item ${nextClass}"><a class="page-link" href="#" id="nextPageBtn">Next</a></li>`;
    
    // Add event listeners
    document.getElementById('prevPageBtn')?.addEventListener('click', function(e) {
        e.preventDefault();
        if (pagination.currentPage > 1) {
            currentPage = pagination.currentPage - 1;
            loadOrders();
        }
    });
    
    document.getElementById('nextPageBtn')?.addEventListener('click', function(e) {
        e.preventDefault();
        if (pagination.currentPage < pagination.totalPages) {
            currentPage = pagination.currentPage + 1;
            loadOrders();
        }
    });
    
    document.querySelectorAll('.page-link[data-page]').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            currentPage = parseInt(this.getAttribute('data-page'));
            loadOrders();
        });
    });
}

// Call initialization function
initializeMobileOrder();

// Event Listeners
document.addEventListener('DOMContentLoaded', function() {
    // Filter apply button
    document.getElementById('filterApplyBtn').addEventListener('click', function(e) {
        e.preventDefault();
        currentPage = 1;
        loadOrders();
    });
    
    // Delivery status change handler
    document.getElementById('modalDeliveryStatusSelect').addEventListener('change', async function(e) {
        const newStatus = e.target.value;
        
        if (!selectedOrder) return;
        
        try {
            // Check if it's a COD order being delivered
            if (
                selectedOrder.paymentMethod.toLowerCase().includes('cash') &&
                newStatus === 'delivered' &&
                selectedOrder.paymentStatus !== 'Paid'
            ) {
                const result = await Swal.fire({
                    title: 'Mark as Paid?',
                    text: 'This is a COD order. Mark payment as received?',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Yes, mark as paid',
                    cancelButtonText: 'No, just update delivery'
                });
                
                if (result.isConfirmed) {
                    // Update both status and payment
                    await updateOrderStatus(selectedOrder.orderId, newStatus);
                    await updatePaymentStatus(selectedOrder.orderId, 'Paid');
                    selectedOrder.status = newStatus;
                    selectedOrder.paymentStatus = 'Paid';
                } else {
                    // Update only status
                    await updateOrderStatus(selectedOrder.orderId, newStatus);
                    selectedOrder.status = newStatus;
                }
            } else {
                // Regular status update
                await updateOrderStatus(selectedOrder.orderId, newStatus);
                selectedOrder.status = newStatus;
            }
            
            // Refresh the orders list
            loadOrders();
            populateOrderModal(selectedOrder);
            
            Swal.fire('Updated!', 'Order status updated successfully.', 'success');
        } catch (error) {
            console.error('Error updating order status:', error);
            Swal.fire('Error!', 'Failed to update order status.', 'error');
        }
    });
    
    // Payment status dropdown
    document.querySelectorAll('#modalUpdatePaymentStatusBtn + .dropdown-menu .dropdown-item').forEach(item => {
        item.addEventListener('click', async function(e) {
            e.preventDefault();
            const newStatus = this.getAttribute('data-status');
            
            if (!selectedOrder) return;
            
            try {
                const result = await Swal.fire({
                    title: 'Confirm Payment Status Change',
                    text: `Are you sure you want to change payment status to ${newStatus}?`,
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Yes, update it!'
                });
                
                if (result.isConfirmed) {
                    await updatePaymentStatus(selectedOrder.orderId, newStatus);
                    selectedOrder.paymentStatus = newStatus;
                    
                    // Refresh the orders list
                    loadOrders();
                    populateOrderModal(selectedOrder);
                    
                    Swal.fire({
                        position: 'center',
                        icon: 'success',
                        title: `Payment status updated to: ${newStatus}`,
                        showConfirmButton: false,
                        timer: 1500
                    });
                }
            } catch (error) {
                console.error('Error updating payment status:', error);
                Swal.fire('Error!', 'Failed to update payment status.', 'error');
            }
        });
    });
    
    // Cancel Order
    document.getElementById('modalCancelOrderBtn').addEventListener('click', async function() {
        if (!selectedOrder) return;
        
        try {
            const result = await Swal.fire({
                title: 'Are you sure?',
                text: "You want to cancel this order?",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes, cancel it!',
                input: 'text',
                inputLabel: 'Cancellation reason (optional)',
                inputPlaceholder: 'Enter reason for cancellation...'
            });
            
            if (result.isConfirmed) {
                await cancelOrder(selectedOrder.orderId, result.value || 'Cancelled by cashier');
                selectedOrder.status = 'cancelled';
                
                // Refresh the orders list
                loadOrders();
                populateOrderModal(selectedOrder);
                
                Swal.fire('Cancelled!', 'The order has been cancelled.', 'success');
                
                // Close modal
                const modal = bootstrap.Modal.getInstance(document.getElementById('orderDetailsModal'));
                modal.hide();
            }
        } catch (error) {
            console.error('Error cancelling order:', error);
            Swal.fire('Error!', 'Failed to cancel order.', 'error');
        }
    });
    
    // Close Modal
    document.getElementById('modalCloseBtn').addEventListener('click', function() {
        const modal = bootstrap.Modal.getInstance(document.getElementById('orderDetailsModal'));
        modal.hide();
    });
    
    // Date range picker
    $(function() {
        $('#filterDate').daterangepicker({
            autoUpdateInput: false,
            locale: {
                cancelLabel: 'Clear'
            }
        });

        $('#filterDate').on('apply.daterangepicker', function(ev, picker) {
            $(this).val(picker.startDate.format('YYYY-MM-DD') + ' - ' + picker.endDate.format('YYYY-MM-DD'));
        });

        $('#filterDate').on('cancel.daterangepicker', function(ev, picker) {
            $(this).val('');
        });
    });
});
