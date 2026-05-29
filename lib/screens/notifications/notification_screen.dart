import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lris/providers/notification_provider.dart';
import 'package:lris/widgets/loading_shimmer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    await notificationProvider.fetchNotifications();
  }

  Future<void> _refreshNotifications() async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    await notificationProvider.fetchNotifications();
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'match':
        return Colors.green;
      case 'claim':
        return Colors.orange;
      case 'claim_accepted':
        return Colors.green;
      case 'claim_rejected':
        return Colors.red;
      case 'claim_withdrawn':
        return Colors.grey;
      case 'found_report':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'match':
        return Icons.emoji_events;
      case 'claim':
        return Icons.handshake;
      case 'claim_accepted':
        return Icons.check_circle;
      case 'claim_rejected':
        return Icons.cancel;
      case 'claim_withdrawn':
        return Icons.remove_circle;
      case 'found_report':
        return Icons.favorite;
      default:
        return Icons.notifications;
    }
  }

  Future<void> _handleNotificationTap(dynamic notification) async {
    // Mark as read if not already
    if (!notification.isRead) {
      await Provider.of<NotificationProvider>(context, listen: false)
          .markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.notificationType) {
      case 'claim':
      case 'claim_accepted':
      case 'claim_rejected':
      case 'claim_withdrawn':
        if (notification.claimId != null) {
          // Navigate to claim details
          // You'll need to fetch the claim details first
          _showComingSoon('Claim Details');
        }
        break;

      case 'match':
      case 'found_report':
        if (notification.lostItemId != null) {
          // Navigate to lost item
          _showComingSoon('Lost Item Details');
        } else if (notification.foundItemId != null) {
          // Navigate to found item
          _showComingSoon('Found Item Details');
        } else if (notification.relatedId != null) {
          // Navigate using related ID
          _showComingSoon('Item Details');
        }
        break;

      default:
      // Default action
        _showComingSoon('Details');
        break;
    }
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title screen coming soon!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notificationProvider.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () async {
                await notificationProvider.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications marked as read'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: notificationProvider.isLoading &&
            notificationProvider.notifications.isEmpty
            ? ListView.builder(
          itemCount: 8,
          itemBuilder: (context, index) => LoadingShimmer.listTile(),
        )
            : notificationProvider.notifications.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'No notifications yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'When someone reports an item that matches yours,\nyou\'ll see it here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: notificationProvider.notifications.length,
          itemBuilder: (context, index) {
            final notification = notificationProvider.notifications[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 8,
              ),
              color: notification.isRead
                  ? Colors.white
                  : Colors.blue[50],
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getNotificationColor(
                    notification.notificationType,
                  ).withOpacity(0.1),
                  child: Icon(
                    _getNotificationIcon(notification.notificationType),
                    color: _getNotificationColor(
                      notification.notificationType,
                    ),
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.message),
                    const SizedBox(height: 4),
                    Text(
                      notification.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                trailing: notification.isRead
                    ? null
                    : Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () => _handleNotificationTap(notification),
              ),
            );
          },
        ),
      ),
    );
  }
}