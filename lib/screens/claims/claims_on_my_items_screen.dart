import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lris/providers/claim_provider.dart';
import 'package:lris/providers/auth_provider.dart';
import 'package:lris/widgets/loading_shimmer.dart';
import 'package:lris/models/claim.dart';
import 'package:lris/models/found_item.dart';
import 'package:lris/screens/items/item_detail.dart';

class ClaimsOnMyItemsScreen extends StatefulWidget {
  const ClaimsOnMyItemsScreen({super.key});

  @override
  State<ClaimsOnMyItemsScreen> createState() => _ClaimsOnMyItemsScreenState();
}

class _ClaimsOnMyItemsScreenState extends State<ClaimsOnMyItemsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final claimProvider = Provider.of<ClaimProvider>(context, listen: false);
    await claimProvider.fetchClaimsOnMyItems();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending review':
        return Colors.orange;
      case 'accepted':
      case 'claim accepted':
        return Colors.green;
      case 'rejected':
      case 'claim rejected':
        return Colors.red;
      case 'withdrawn':
      case 'claim withdrawn':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Future<void> _acceptClaim(BuildContext context, Claim claim) async {
    final claimProvider = Provider.of<ClaimProvider>(context, listen: false);
    bool success = await claimProvider.acceptClaim(claim.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Claim accepted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(claimProvider.error ?? 'Failed to accept claim'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRejectDialog(BuildContext context, Claim claim) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Claim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to reject this claim?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text;
              Navigator.pop(context);

              final claimProvider = Provider.of<ClaimProvider>(
                context,
                listen: false,
              );

              bool success = await claimProvider.rejectClaim(
                claim.id,
                reason: reason,
              );

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      reason.isEmpty
                          ? 'Claim rejected'
                          : 'Claim rejected: $reason',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                await _loadData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Claims on My Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              authProvider.user?.fullName?.split(' ')[0] ?? 'User',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: Consumer<ClaimProvider>(
                builder: (context, claimProvider, child) {
                  if (claimProvider.isLoading && claimProvider.claimsOnMyItems.isEmpty) {
                    return ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) => LoadingShimmer.listTile(),
                    );
                  }

                  if (claimProvider.claimsOnMyItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 100,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No claims yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'When someone claims an item you found,\nit will appear here',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: claimProvider.claimsOnMyItems.length,
                    itemBuilder: (context, index) {
                      final claim = claimProvider.claimsOnMyItems[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(claim.status)
                                    .withOpacity(0.1),
                                child: Icon(
                                  claim.isPending
                                      ? Icons.pending
                                      : claim.isAccepted
                                      ? Icons.check_circle
                                      : claim.isRejected
                                      ? Icons.cancel
                                      : Icons.remove_circle,
                                  color: _getStatusColor(claim.status),
                                ),
                              ),
                              title: Text(
                                claim.itemDetails['title'] ?? 'Unknown Item',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Claimant: ${claim.claimantDetails['full_name'] ?? 'Unknown'}',
                                  ),
                                  Text(
                                    'Claimed: ${claim.timeAgo}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(
                                  claim.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: _getStatusColor(claim.status),
                              ),
                              onTap: () {
                                try {
                                  // Create a FoundItem from the claim's itemDetails
                                  final foundItem = FoundItem.fromJson(claim.itemDetails);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDetailScreen.found(
                                        foundItem: foundItem,
                                      ),
                                    ),
                                  ).then((_) => _loadData());
                                } catch (e) {
                                  print('Error navigating to item detail: $e');
                                  _loadData();
                                }
                              },
                            ),
                            if (claim.isPending)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        _showRejectDialog(context, claim);
                                      },
                                      icon: const Icon(Icons.close),
                                      label: const Text('Reject'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _acceptClaim(context, claim);
                                      },
                                      icon: const Icon(Icons.check),
                                      label: const Text('Accept'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}