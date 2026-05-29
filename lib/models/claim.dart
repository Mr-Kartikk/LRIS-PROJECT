class Claim {
  final int id;
  final int itemId;
  final Map<String, dynamic> itemDetails;
  final int claimantId;
  final Map<String, dynamic> claimantDetails;
  final String description;
  final String? additionalInfo;
  final String? proofImage;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String timeAgo;

  Claim({
    required this.id,
    required this.itemId,
    required this.itemDetails,
    required this.claimantId,
    required this.claimantDetails,
    required this.description,
    this.additionalInfo,
    this.proofImage,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.reviewedAt,
    required this.timeAgo,
  });

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'],
      itemId: json['item'],
      itemDetails: json['item_details'] ?? {},
      claimantId: json['claimant'],
      claimantDetails: json['claimant_details'] ?? {},
      description: json['description'] ?? '',
      additionalInfo: json['additional_info'],
      proofImage: json['proof_image'],
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      createdAt: DateTime.parse(json['created_at']),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'])
          : null,
      timeAgo: json['time_ago'] ?? '',
    );
  }

  bool get isPending => status == 'pending' || status == 'Pending Review';
  bool get isAccepted => status == 'accepted' || status == 'Claim Accepted';
  bool get isRejected => status == 'rejected' || status == 'Claim Rejected';
  bool get isWithdrawn => status == 'withdrawn' || status == 'Claim Withdrawn';
}