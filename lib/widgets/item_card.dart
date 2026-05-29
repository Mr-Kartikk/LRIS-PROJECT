import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lris/models/lost_item.dart';
import 'package:lris/models/found_item.dart';
import 'package:lris/utils/helpers.dart';

class ItemCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback? onTap;
  final bool isLost;
  final bool isMyItem;

  const ItemCard.lost({
    super.key,
    required LostItem lostItem,
    this.onTap,
    this.isMyItem = false,
  })  : item = lostItem,
        isLost = true;

  const ItemCard.found({
    super.key,
    required FoundItem foundItem,
    this.onTap,
    this.isMyItem = false,
  })  : item = foundItem,
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isMyItem
            ? const BorderSide(color: Colors.blue, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: _getImageWidget(),
              ),

              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isMyItem)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'MY ITEM',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.status.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      item.description.length > 100
                          ? '${item.description.substring(0, 100)}...'
                          : item.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // User info
                    if (item.user != null)
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              item.user!['full_name'][0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.user!['full_name'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          isLost ? Icons.location_on : Icons.find_in_page,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isLost
                                ? 'Lost: ${item.locationName}'
                                : 'Found: ${item.locationName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isLost
                              ? 'Lost: ${Helpers.formatDate(item.lostDate)}'
                              : 'Found: ${Helpers.formatDate(item.foundDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          Helpers.timeAgo(item.datePosted),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getImageWidget() {
    if (item.image != null && item.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: item.image!,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(strokeWidth: 1),
          ),
          errorWidget: (context, url, error) => Center(
            child: Icon(
              isLost ? Icons.inventory : Icons.find_in_page,
              size: 30,
              color: Colors.grey,
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: Icon(
          isLost ? Icons.inventory : Icons.find_in_page,
          size: 30,
          color: Colors.grey,
        ),
      );
    }
  }
}