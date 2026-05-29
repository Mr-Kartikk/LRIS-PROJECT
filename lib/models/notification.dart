class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String notificationType;
  final bool isRead;
  final bool isSeen;
  final DateTime createdAt;
  final String timeAgo;
  final int? claimId;
  final Map<String, dynamic>? claimDetails;
  final int? relatedId;

  // ADD THESE FIELDS
  final int? lostItemId;
  final int? foundItemId;
  final String? lostItemTitle;
  final String? foundItemTitle;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.isRead,
    required this.isSeen,
    required this.createdAt,
    required this.timeAgo,
    this.claimId,
    this.claimDetails,
    this.relatedId,
    // ADD THESE
    this.lostItemId,
    this.foundItemId,
    this.lostItemTitle,
    this.foundItemTitle,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      notificationType: json['notification_type'],
      isRead: json['is_read'] ?? false,
      isSeen: json['is_seen'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      timeAgo: json['time_ago'] ?? '',
      claimId: json['claim'],
      claimDetails: json['claim_details'],
      relatedId: json['related_id'],
      // ADD THESE - check if they exist in your API response
      lostItemId: json['lost_item'],
      foundItemId: json['found_item'],
      lostItemTitle: json['lost_item_title'],
      foundItemTitle: json['found_item_title'],
    );
  }
}