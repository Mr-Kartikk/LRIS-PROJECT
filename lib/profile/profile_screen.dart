import 'package:flutter/material.dart';
import 'package:lris/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.person, size: 60, color: Colors.blue),
                  ),
                  SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'User',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    user?.phoneNumber ?? 'Phone number not available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  if (user?.email != null && user!.email!.isNotEmpty)
                    Text(
                      user.email!,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text(
                        user?.isVerified == true ? 'Verified' : 'Not Verified',
                        style: TextStyle(
                          color: user?.isVerified == true
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Menu Items
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(),
                      ),
                    );
                  },
                ),
                Divider(height: 0),
                _buildMenuItem(
                  icon: Icons.lock,
                  title: 'Change Password',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                Divider(height: 0),
                _buildMenuItem(
                  icon: Icons.inventory,
                  title: 'My Lost Items',
                  onTap: () {
                    // Navigate to my lost items
                  },
                ),
                Divider(height: 0),
                _buildMenuItem(
                  icon: Icons.find_in_page,
                  title: 'My Found Items',
                  onTap: () {
                    // Navigate to my found items
                  },
                ),
                Divider(height: 0),
                _buildMenuItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {
                    // Navigate to notifications
                  },
                ),
                Divider(height: 0),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    // Navigate to help
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showLogoutDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
