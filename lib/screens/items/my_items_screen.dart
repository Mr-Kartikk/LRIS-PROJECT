import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lris/providers/item_provider.dart';
import 'package:lris/widgets/item_card.dart';
import 'package:lris/widgets/loading_shimmer.dart';
import 'item_detail.dart';

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  _MyItemsScreenState createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen> {
  final int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    await itemProvider.fetchMyItems();
  }

  Future<void> _refreshData() async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    await itemProvider.fetchMyItems();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Items'),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.inventory),
                text: 'Lost (${itemProvider.myLostItems.length})',
              ),
              Tab(
                icon: Icon(Icons.find_in_page),
                text: 'Found (${itemProvider.myFoundItems.length})',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Lost Items Tab
            RefreshIndicator(
              onRefresh: _refreshData,
              child: itemProvider.isLoading && itemProvider.myLostItems.isEmpty
                  ? ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) =>
                          LoadingShimmer.itemCard(),
                    )
                  : itemProvider.myLostItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory, size: 100, color: Colors.grey),
                          SizedBox(height: 20),
                          Text(
                            'No lost items reported',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Report lost items to track them here',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: itemProvider.myLostItems.length,
                      itemBuilder: (context, index) {
                        final item = itemProvider.myLostItems[index];
                        return ItemCard.lost(
                          lostItem: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ItemDetailScreen.lost(lostItem: item),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),

            // Found Items Tab
            RefreshIndicator(
              onRefresh: _refreshData,
              child: itemProvider.isLoading && itemProvider.myFoundItems.isEmpty
                  ? ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) =>
                          LoadingShimmer.itemCard(),
                    )
                  : itemProvider.myFoundItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.find_in_page,
                            size: 100,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'No found items reported',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Report found items to track them here',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: itemProvider.myFoundItems.length,
                      itemBuilder: (context, index) {
                        final item = itemProvider.myFoundItems[index];
                        return ItemCard.found(
                          foundItem: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ItemDetailScreen.found(foundItem: item),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
