class KycStatusModel {
  final String status; // not_started | submitted | approved | rejected
  final String? applicantId;

  const KycStatusModel({required this.status, this.applicantId});

  factory KycStatusModel.fromJson(Map<String, dynamic> json) => KycStatusModel(
        status: json['status'] as String? ?? 'not_started',
        applicantId: json['applicantId'] as String?,
      );

  bool get isApproved => status == 'approved';
  bool get isSubmitted => status == 'submitted';
  bool get isRejected => status == 'rejected';
  bool get isNotStarted => status == 'not_started';
}
