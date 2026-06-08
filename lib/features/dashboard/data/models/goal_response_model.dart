import 'package:json_annotation/json_annotation.dart';

part 'goal_response_model.g.dart';

/// REST DTO for GET /api/v1/users/{userId}/goals.
/// All monetary values are integer cents: $1.00 = 100. Never a double.
@JsonSerializable()
class GoalResponseModel {
  final String id;
  final String name;

  /// Target savings amount in integer cents. $1.00 = 100.
  final int targetAmountCents;

  /// Combined progress in integer cents (cash + invested). Derived server-side.
  final int currentAmountCents;

  /// Net cash assigned to this goal (deposits − withdrawals), integer cents. Derived.
  final int cashContributedCents;

  /// Current market value of BUY transactions assigned to this goal, integer cents. Derived.
  final int investedValueCents;

  /// ISO 8601 date string: "2025-12-31".
  final String deadline;

  final String category;

  /// RFC 3339 timestamp of goal creation. Used for the linear projection.
  final String createdAt;

  const GoalResponseModel({
    required this.id,
    required this.name,
    required this.targetAmountCents,
    required this.currentAmountCents,
    required this.cashContributedCents,
    required this.investedValueCents,
    required this.deadline,
    required this.category,
    required this.createdAt,
  });

  factory GoalResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GoalResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GoalResponseModelToJson(this);

  /// Cents → dollars for display. $30,000.00 = targetAmountCents 3_000_000.
  double get targetAmount => targetAmountCents / 100.0;

  /// Cents → dollars for display.
  double get currentAmount => currentAmountCents / 100.0;

  /// Cents → dollars for display.
  double get cashContributed => cashContributedCents / 100.0;

  /// Cents → dollars for display.
  double get investedValue => investedValueCents / 100.0;

  /// Whether any holdings have been assigned to this goal.
  bool get hasInvestments => investedValueCents > 0;

  /// Progress ratio in [0.0, 1.0]. Safe against zero target.
  double get progress => targetAmountCents > 0
      ? (currentAmountCents / targetAmountCents).clamp(0.0, 1.0)
      : 0.0;

  /// Parses the ISO 8601 deadline string into a [DateTime].
  DateTime get deadlineDate => DateTime.parse(deadline);

  /// Parses the RFC 3339 creation timestamp into a local [DateTime].
  DateTime get createdAtDate => DateTime.parse(createdAt).toLocal();

  /// Linear completion estimate: at the current saving rate (since creation),
  /// the date the target would be reached. Null when there is no progress yet
  /// or the goal was created moments ago (rate not yet meaningful).
  DateTime? get projectedCompletionDate {
    if (currentAmountCents <= 0 || currentAmountCents >= targetAmountCents) {
      return null;
    }
    final elapsedDays = DateTime.now().difference(createdAtDate).inDays;
    if (elapsedDays < 1) return null;
    final remainingCents = targetAmountCents - currentAmountCents;
    final centsPerDay = currentAmountCents / elapsedDays;
    if (centsPerDay <= 0) return null;
    final remainingDays = (remainingCents / centsPerDay).ceil();
    return DateTime.now().add(Duration(days: remainingDays));
  }
}
