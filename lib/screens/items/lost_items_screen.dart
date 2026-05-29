import 'package:flutter/material.dart';
import 'package:lris/models/lost_item.dart';
import 'package:lris/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:lris/providers/item_provider.dart';
import 'package:lris/widgets/item_card.dart';
import 'package:lris/widgets/loading_shimmer.dart';
import 'item_detail.dart';
import 'add_lost_item.dart';

class LostItemsScreen extends StatefulWidget {
  const LostItemsScreen({super.key});

  @override
  State<LostItemsScreen> createState() => _LostItemsScreenState();
}

class _LostItemsScreenState extends State<LostItemsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showMyItemsOnly = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    await itemProvider.fetchAllLostItems();
  }

  Future<void> _refreshData() async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    await itemProvider.fetchAllLostItems();
  }

  List<LostItem> _getFilteredItems(ItemProvider provider) {
    List<LostItem> items = _showMyItemsOnly ? provider.myLostItems : provider.allLostItems;

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
    final filteredItems = _getFilteredItems(itemProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost Items'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search lost items...',
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
                        _showMyItemsOnly
                            ? Icons.person
                            : Icons.people,
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
        child: itemProvider.isLoading && itemProvider.allLostItems.isEmpty
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
                Icons.inventory,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                _showMyItemsOnly
                    ? 'You haven\'t reported any lost items yet'
                    : 'No lost items found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              if (!_showMyItemsOnly)
                Text(
                  'Be the first to report a lost item',
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
                        builder: (context) => const AddLostItemScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Report Lost Item'),
                ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final LostItem item = filteredItems[index];

            final int? currentUserId =
                Provider.of<AuthProvider>(context, listen: false).user?.id;

            final int? itemUserId = item.user?['id'];

            final bool isMyItem =
                currentUserId != null &&
                    itemUserId != null &&
                    currentUserId == itemUserId;

            return ItemCard.lost(
              lostItem: item,
              isMyItem: isMyItem,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailScreen.lost(
                      lostItem: item,
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
              builder: (context) => const AddLostItemScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}