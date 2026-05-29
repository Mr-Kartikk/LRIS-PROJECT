import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lris/providers/auth_provider.dart';
import 'package:lris/providers/item_provider.dart';
import 'package:lris/screens/items/add_lost_item.dart';
import 'package:lris/screens/items/add_found_item.dart';
import 'package:lris/screens/items/lost_items_screen.dart';
import 'package:lris/screens/items/found_items_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue[100],
                        child: Icon(Icons.person, size: 30, color: Colors.blue),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              authProvider.user?.fullName ?? 'User',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Help others find what they lost or report items you found',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 25),

          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),

          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.2,
            children: [
              _buildActionCard(
                icon: Icons.inventory,
                title: 'Report Lost',
                color: Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddLostItemScreen(),
                    ),
                  ).then((_) {
                    itemProvider.fetchAllLostItems();
                  });
                },
              ),
              _buildActionCard(
                icon: Icons.find_in_page,
                title: 'Report Found',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddFoundItemScreen(),
                    ),
                  ).then((_) {
                    itemProvider.fetchAllFoundItems();
                  });
                },
              ),
              _buildActionCard(
                icon: Icons.search,
                title: 'Search Lost',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LostItemsScreen()),
                  );
                },
              ),
              _buildActionCard(
                icon: Icons.search,
                title: 'Search Found',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FoundItemsScreen()),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 25),

          // Recent Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // View all activity
                },
                child: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 10),

          Card(
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.inventory, color: Colors.red),
                    title: Text('Mobile Phone'),
                    subtitle: Text('Lost yesterday at Mall'),
                    trailing: Chip(
                      label: Text('Pending'),
                      backgroundColor: Colors.orange[100],
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.find_in_page, color: Colors.green),
                    title: Text('Wallet'),
                    subtitle: Text('Found at Park'),
                    trailing: Chip(
                      label: Text('Pending'),
                      backgroundColor: Colors.orange[100],
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Keys'),
                    subtitle: Text('Returned to owner'),
                    trailing: Chip(
                      label: Text('Resolved'),
                      backgroundColor: Colors.green[100],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 25),

          // Statistics
          Text(
            'Statistics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Lost Items',
                  count: '5',
                  color: Colors.red,
                  icon: Icons.inventory,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  title: 'Found Items',
                  count: '3',
                  color: Colors.green,
                  icon: Icons.find_in_page,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                Spacer(),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
