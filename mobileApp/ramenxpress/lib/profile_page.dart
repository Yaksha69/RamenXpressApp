import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'edit_profile_page.dart';
import 'delivery_addresses_page.dart';
import 'payment_methods_page.dart';
import 'notifications_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                child: Row(
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Header
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final customer = authProvider.customer;
                      if (customer == null) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                          ),
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.onSurface.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: customer.profileImage != null
                                  ? NetworkImage(customer.profileImage!)
                                  : const AssetImage('assets/adminPIC.png') as ImageProvider,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.fullName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    customer.email,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    customer.phoneNumber,
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const EditProfilePage(),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: colorScheme.primary),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Edit Profile',
                                      style: TextStyle(color: colorScheme.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Account Settings Section
                  _buildSection(
                    'Account Settings',
                    [
                      _buildMenuItem(
                        Icons.person_outline,
                        'Personal Information',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          );
                        },
                        colorScheme: colorScheme,
                      ),
                      _buildMenuItem(
                        Icons.location_on_outlined,
                        'Delivery Addresses',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DeliveryAddressesPage(),
                            ),
                          );
                        },
                        colorScheme: colorScheme,
                      ),
                      _buildMenuItem(
                        Icons.credit_card_outlined,
                        'Payment Methods',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentMethodsPage(),
                            ),
                          );
                        },
                        colorScheme: colorScheme,
                      ),
                    ],
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 24),

                  // Preferences Section
                  _buildSection(
                    'Preferences',
                    [
                      _buildMenuItem(
                        Icons.notifications_outlined,
                        'Notifications',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsPage(),
                            ),
                          );
                        },
                        colorScheme: colorScheme,
                      ),
                      _buildMenuItem(
                        Icons.language_outlined,
                        'Language',
                        () {},
                        colorScheme: colorScheme,
                      ),
                      _buildMenuItem(
                        Icons.dark_mode_outlined,
                        'Dark Mode',
                        () {},
                        colorScheme: colorScheme,
                      ),
                    ],
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 24),

                  // Support Section
                  _buildSection(
                    'Support',
                    [
                      _buildMenuItem(
                        Icons.help_outline,
                        'Help Center',
                        () {},
                        colorScheme: colorScheme,
                      ),
                      _buildMenuItem(
                        Icons.info_outline,
                        'About',
                        () {},
                        colorScheme: colorScheme,
                      ),
                      _buildMenuItem(
                        Icons.privacy_tip_outlined,
                        'Privacy Policy',
                        () {},
                        colorScheme: colorScheme,
                      ),
                    ],
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Logout', style: TextStyle(color: colorScheme.onSurface)),
                                      content: Text('Are you sure you want to logout?', style: TextStyle(color: colorScheme.onSurface)),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await authProvider.logout();
                                            if (context.mounted) {
                                              Navigator.pushReplacementNamed(context, '/login');
                                            }
                                          },
                                          child: Text(
                                            'Logout',
                                            style: TextStyle(color: colorScheme.primary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                                  ),
                                )
                              : Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 3,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/home');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/payment');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/order-history');
                break;
              case 3:
                // Already on profile page
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withOpacity(0.7),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          backgroundColor: colorScheme.surface,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items, {required ColorScheme colorScheme}) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Divider(height: 1, color: colorScheme.onSurface.withOpacity(0.1)),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    required ColorScheme colorScheme,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface,
              ),
          ],
        ),
      ),
    );
  }
} 