import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:lris/models/lost_item.dart';
import 'package:lris/models/found_item.dart';
import 'package:lris/utils/helpers.dart';
import 'package:lris/widgets/custom_button.dart';
import 'package:lris/providers/auth_provider.dart';
import 'package:lris/providers/claim_provider.dart';
import 'package:lris/screens/claims/claims_on_my_items_screen.dart';
import 'add_found_item.dart';
import 'add_lost_item.dart';

class ItemDetailScreen extends StatelessWidget {
  final dynamic item;
  final bool isLost;

  const ItemDetailScreen.lost({super.key, required LostItem lostItem})
      : item = lostItem,
        isLost = true;

  const ItemDetailScreen.found({super.key, required FoundItem foundItem})
      : item = foundItem,
        isLost = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'found':
      case 'returned':
        return Colors.green;
      case 'closed':
      case 'donated':
        return Colors.blue;
      case 'disposed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _claimItem(BuildContext context, dynamic foundItem) async {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController additionalController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Claim This Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please describe why this item belongs to you:'),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., It has a unique scratch on the back...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: additionalController,
                decoration: const InputDecoration(
                  labelText: 'Additional Information (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Any proof or identifying details...',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (descriptionController.text.isNotEmpty) {
                Navigator.pop(context);

                final claimProvider = Provider.of<ClaimProvider>(
                    context,
                    listen: false
                );

                final success = await claimProvider.createClaim(
                  itemId: foundItem.id,
                  description: descriptionController.text,
                  additionalInfo: additionalController.text.isNotEmpty
                      ? additionalController.text
                      : null,
                );

                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Claim submitted successfully! The finder will review your claim.'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(claimProvider.error ?? 'Failed to submit claim'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Submit Claim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.id;
    final isOwner = item.user?['id'] == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(isLost ? 'Lost Item Details' : 'Found Item Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: _buildImage(),
            ),

            const SizedBox(height: 20),

            // Title and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // User info
            if (item.user != null) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    item.user!['full_name'][0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  item.user!['full_name'] ?? 'User',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Posted ${isLost
                      ? Helpers.timeAgo(item.lostDate)
                      : Helpers.timeAgo(item.foundDate)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 20),

            // Details Card
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.location_on,
                      title: isLost ? 'Lost Location' : 'Found Location',
                      value: item.locationName,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      title: isLost ? 'Lost Date' : 'Found Date',
                      value: Helpers.formatDate(
                        isLost ? item.lostDate : item.foundDate,
                      ),
                    ),
                    if (isLost &&
                        item.brand != null &&
                        item.brand!.isNotEmpty) ...[
                      const Divider(),
                      _buildDetailRow(
                        icon: Icons.branding_watermark,
                        title: 'Brand',
                        value: item.brand!,
                      ),
                    ],
                    if (item.color != null && item.color!.isNotEmpty) ...[
                      const Divider(),
                      _buildDetailRow(
                        icon: Icons.color_lens,
                        title: 'Color',
                        value: item.color!,
                      ),
                    ],
                    if (!isLost) ...[
                      const Divider(),
                      _buildDetailRow(
                        icon: Icons.home,
                        title: 'Current Location',
                        value: item.currentLocation,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Contact Info
            if (!isLost) ...[
              const Text(
                'Contact Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text('Phone'),
                        subtitle: Text(
                          item.user?['phone_number'] ?? 'Not provided',
                        ),
                      ),
                      if (item.user?['email'] != null) ...[
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email'),
                          subtitle: Text(item.user!['email']),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Action Buttons
            if (!isLost && !isOwner)
              CustomButton(
                text: 'Claim This Item',
                onPressed: () => _claimItem(context, item),
                backgroundColor: Colors.green,
                fullWidth: true,
              ),

            const SizedBox(height: 10),

            CustomButton(
              text: 'Report Similar',
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    isLost ? const AddLostItemScreen() : const AddFoundItemScreen(),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (item.image != null && item.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: item.image!,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => Center(
            child: Icon(
              isLost ? Icons.inventory : Icons.find_in_page,
              size: 80,
              color: Colors.grey,
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: Icon(
          isLost ? Icons.inventory : Icons.find_in_page,
          size: 80,
          color: Colors.grey,
        ),
      );
    }
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}