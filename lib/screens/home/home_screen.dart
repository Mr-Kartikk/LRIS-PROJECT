import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lris/providers/notification_provider.dart';
import 'package:lris/providers/claim_provider.dart'; // ADD THIS IMPORT
import 'package:lris/screens/notifications/notification_screen.dart';
import 'package:lris/screens/items/potential_matches_screen.dart';
import 'package:lris/screens/claims/claims_on_my_items_screen.dart'; // ADD THIS IMPORT
import 'package:lris/profile/profile_screen.dart';
import 'package:lris/providers/item_provider.dart';
import 'package:lris/screens/items/lost_items_screen.dart';
import 'package:lris/screens/items/found_items_screen.dart';
import 'package:lris/screens/items/add_lost_item.dart';
import 'package:lris/screens/items/add_found_item.dart';
import 'package:lris/screens/items/my_items_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const LostItemsScreen(),
    const FoundItemsScreen(),
    const MyItemsScreen(),
    const ProfileScreen(),
  ];

  final List<String> _appBarTitles = [
    'Lost & Found',
    'Lost Items',
    'Found Items',
    'My Items',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadNotificationCount();
      _loadClaimCount();
      _fetchInitialData();
    });
  }

  Future<void> _loadNotificationCount() async {
    try {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      await notificationProvider.refreshUnreadCount();

      // Set up periodic refresh (every 30 seconds)
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) _loadNotificationCount();
      });
    } catch (e) {
      print('Error loading notification count: $e');
    }
  }

  Future<void> _loadClaimCount() async {
    try {
      final claimProvider = Provider.of<ClaimProvider>(
        context,
        listen: false,
      );
      await claimProvider.fetchClaimsOnMyItems();

      // Set up periodic refresh (every 30 seconds)
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) _loadClaimCount();
      });
    } catch (e) {
      print('Error loading claim count: $e');
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      await Future.wait([
        itemProvider.fetchAllLostItems(),
        itemProvider.fetchAllFoundItems(),
        itemProvider.fetchMyItems(),
      ]);
    } catch (e) {
      print('Error fetching initial data: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _refreshData() async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    final claimProvider = Provider.of<ClaimProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      itemProvider.fetchAllLostItems(),
      itemProvider.fetchAllFoundItems(),
      itemProvider.fetchMyItems(),
      notificationProvider.refreshUnreadCount(),
      claimProvider.fetchClaimsOnMyItems(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);
    final claimProvider = Provider.of<ClaimProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        actions: [
          // 🔥 CLAIMS BUTTON - This is what you were missing!
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.handshake),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClaimsOnMyItemsScreen(),
                    ),
                  ).then((_) {
                    if (mounted) {
                      claimProvider.fetchClaimsOnMyItems();
                    }
                  });
                },
                tooltip: 'Claims on my items',
              ),
              if (claimProvider.claimsOnMyItems.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        claimProvider.claimsOnMyItems.length > 99
                            ? '99+'
                            : '${claimProvider.claimsOnMyItems.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // 🔥 Potential Matches Button with Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.emoji_events),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PotentialMatchesScreen(),
                    ),
                  );
                },
                tooltip: 'Potential matches',
              ),
              if (itemProvider.potentialMatches.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        itemProvider.potentialMatches.length > 99
                            ? '99+'
                            : '${itemProvider.potentialMatches.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Notification Bell with Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  ).then((_) {
                    if (mounted) {
                      notificationProvider.refreshUnreadCount();
                    }
                  });
                },
                tooltip: 'Notifications',
              ),
              if (notificationProvider.unreadCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        notificationProvider.unreadCount > 99
                            ? '99+'
                            : '${notificationProvider.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Search button (only on home screen)
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(context),
              tooltip: 'Search',
            ),
          // Chat button
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () => Navigator.pushNamed(context, '/chat'),
              tooltip: 'Chat with assistant',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _screens[_selectedIndex],
      ),
      floatingActionButton: _selectedIndex == 1 || _selectedIndex == 2
          ? FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddLostItemScreen(),
              ),
            ).then((_) {
              if (mounted) {
                itemProvider.fetchAllLostItems();
              }
            });
          } else if (_selectedIndex == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddFoundItemScreen(),
              ),
            ).then((_) {
              if (mounted) {
                itemProvider.fetchAllFoundItems();
              }
            });
          }
        },
        backgroundColor: Colors.blue,
        tooltip: 'Add item',
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Lost',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.find_in_page),
            label: 'Found',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Items'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search for items...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.pop(context);
                  Provider.of<ItemProvider>(context, listen: false)
                      .searchItems(value);
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: const Text('Lost Items'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                  child: const Text('Found Items'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}