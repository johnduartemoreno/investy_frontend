class BrokerAccountModel {
  final String broker;
  final String status; // pending | approved | rejected | suspended
  final String? brokerRefId;
  final String? createdAt;

  const BrokerAccountModel({
    required this.broker,
    required this.status,
    this.brokerRefId,
    this.createdAt,
  });

  factory BrokerAccountModel.fromJson(Map<String, dynamic> json) =>
      BrokerAccountModel(
        broker: json['broker'] as String? ?? 'alpaca',
        status: json['status'] as String? ?? 'pending',
        brokerRefId: json['brokerRefId'] as String?,
        createdAt: json['createdAt'] as String?,
      );

  bool get isActive => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
}
