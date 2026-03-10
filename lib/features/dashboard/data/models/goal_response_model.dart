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

  /// Amount saved so far in integer cents. Derived server-side from contributions.
  final int currentAmountCents;

  /// ISO 8601 date string: "2025-12-31".
  final String deadline;

  final String category;

  const GoalResponseModel({
    required this.id,
    required this.name,
    required this.targetAmountCents,
    required this.currentAmountCents,
    required this.deadline,
    required this.category,
  });

  factory GoalResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GoalResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GoalResponseModelToJson(this);

  /// Cents → dollars for display. $30,000.00 = targetAmountCents 3_000_000.
  double get targetAmount => targetAmountCents / 100.0;

  /// Cents → dollars for display.
  double get currentAmount => currentAmountCents / 100.0;

  /// Progress ratio in [0.0, 1.0]. Safe against zero target.
  double get progress => targetAmountCents > 0
      ? (currentAmountCents / targetAmountCents).clamp(0.0, 1.0)
      : 0.0;

  /// Parses the ISO 8601 deadline string into a [DateTime].
  DateTime get deadlineDate => DateTime.parse(deadline);
}
