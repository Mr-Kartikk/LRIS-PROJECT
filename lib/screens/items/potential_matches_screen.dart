import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lris/providers/item_provider.dart';
import 'package:lris/screens/items/item_detail.dart';

class PotentialMatchesScreen extends StatefulWidget {
  const PotentialMatchesScreen({super.key});

  @override
  State<PotentialMatchesScreen> createState() => _PotentialMatchesScreenState();
}

class _PotentialMatchesScreenState extends State<PotentialMatchesScreen> {
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
    final matches = itemProvider.potentialMatches; // This must exist in ItemProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Potential Matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: matches.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'No matches found yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'When someone reports an item that matches yours, it will appear here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            final isLostToFound = match['type'] == 'lost_to_found';
            final myItem = match['myItem'];
            final matchedItem = match['matchedItem'];
            final score = (match['score'] * 100).toInt();

            return Card(
              margin: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.green.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: () {
                  // Navigate to matched item detail
                  if (isLostToFound) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailScreen.found(
                          foundItem: matchedItem,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailScreen.lost(
                          lostItem: matchedItem,
                        ),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '$score% Match',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            isLostToFound
                                ? Icons.arrow_forward
                                : Icons.arrow_back,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        match['message'] ?? 'Potential match found!',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLostToFound ? 'Your Lost Item' : 'Your Found Item',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  myItem?.title ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              isLostToFound
                                  ? Icons.arrow_forward
                                  : Icons.arrow_back,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  isLostToFound ? 'Found Item' : 'Lost Item',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  matchedItem?.title ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // Navigate to my item
                                if (isLostToFound) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDetailScreen.lost(
                                        lostItem: myItem,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDetailScreen.found(
                                        foundItem: myItem,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text('View My Item'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to matched item
                                if (isLostToFound) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDetailScreen.found(
                                        foundItem: matchedItem,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDetailScreen.lost(
                                        lostItem: matchedItem,
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text('View Match'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}