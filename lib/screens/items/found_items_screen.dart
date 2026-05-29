import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lris/models/found_item.dart';
import 'package:lris/providers/item_provider.dart';
import 'package:lris/providers/auth_provider.dart';
import 'package:lris/widgets/item_card.dart';
import 'package:lris/widgets/loading_shimmer.dart';
import 'package:lris/screens/items/item_detail.dart';
import 'package:lris/screens/items/add_found_item.dart';

class FoundItemsScreen extends StatefulWidget {
  const FoundItemsScreen({super.key});

  @override
  State<FoundItemsScreen> createState() => _FoundItemsScreenState();
}

class _FoundItemsScreenState extends State<FoundItemsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showMyItemsOnly = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    await itemProvider.fetchAllFoundItems();
  }

  Future<void> _refreshData() async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    await itemProvider.fetchAllFoundItems();
  }

  List<FoundItem> _getFilteredItems(ItemProvider provider) {
    List<FoundItem> items = _showMyItemsOnly ? provider.myFoundItems : provider.allFoundItems;

    if (_searchQuery.isEmpty) return items;

    return items.where((item) {
      return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.locationName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final filteredItems = _getFilteredItems(itemProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Found Items'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search found items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showMyItemsOnly = !_showMyItemsOnly;
                        });
                      },
                      icon: Icon(
                        _showMyItemsOnly ? Icons.person : Icons.people,
                      ),
                      label: Text(
                        _showMyItemsOnly ? 'My Items' : 'All Items',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: itemProvider.isLoading && itemProvider.allFoundItems.isEmpty
            ? ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) =>  LoadingShimmer.itemCard(),
        )
            : filteredItems.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.find_in_page,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                _showMyItemsOnly
                    ? 'You haven\'t reported any found items yet'
                    : 'No found items',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              if (!_showMyItemsOnly)
                Text(
                  'Help others by reporting items you find',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              const SizedBox(height: 20),
              if (!_showMyItemsOnly)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddFoundItemScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Report Found Item'),
                ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final FoundItem item = filteredItems[index];

            // FIXED: Access user ID through the user map
            final int? currentUserId = authProvider.user?.id;
            final int? itemUserId = item.user?['id'];
            final bool isMyItem = currentUserId != null &&
                itemUserId != null &&
                currentUserId == itemUserId;

            return ItemCard.found(
              foundItem: item,
              isMyItem: isMyItem,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailScreen.found(
                      foundItem: item,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFoundItemScreen(),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}