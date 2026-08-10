class KycStatusModel {
  /// not_started | submitted | retry | approved | rejected
  final String status;
  final String? applicantId;

  /// Sumsub `reviewRejectType` — RETRY or FINAL. Empty unless rejected.
  /// Kept for diagnostics; the UI branches on [status], which the backend has
  /// already derived from it.
  final String rejectType;

  /// Sumsub `rejectLabels` — machine-readable reasons. These are NEVER shown
  /// raw: `KycRejectLabels` maps them to translated copy.
  final List<String> rejectLabels;

  const KycStatusModel({
    required this.status,
    this.applicantId,
    this.rejectType = '',
    this.rejectLabels = const [],
  });

  factory KycStatusModel.fromJson(Map<String, dynamic> json) => KycStatusModel(
        status: json['status'] as String? ?? 'not_started',
        applicantId: json['applicantId'] as String?,
        rejectType: json['rejectType'] as String? ?? '',
        rejectLabels:
            (json['rejectLabels'] as List<dynamic>?)?.cast<String>() ??
                const [],
      );

  bool get isApproved => status == 'approved';
  bool get isSubmitted => status == 'submitted';

  /// A rejection the user can recover from by submitting again (B77).
  bool get isRetry => status == 'retry';

  /// A final rejection. There is no retry path from here.
  bool get isRejected => status == 'rejected';

  bool get isNotStarted => status == 'not_started';

  /// Whether the app should keep asking the backend for a newer value.
  /// Approved and rejected are the only states nothing can move out of, so
  /// everything else is worth refreshing (B80).
  bool get isPendingDecision => !isApproved && !isRejected;
}
