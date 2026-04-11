/// Outbound DTO for POST /api/v1/users/{userId}/goals.
/// targetAmountCents is integer cents: $1.00 = 100. Never a float.
class CreateGoalRequestModel {
  final String name;
  final int targetAmountCents;
  final String category;
  final String deadline; // "YYYY-MM-DD"

  const CreateGoalRequestModel({
    required this.name,
    required this.targetAmountCents,
    required this.category,
    required this.deadline,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'targetAmountCents': targetAmountCents,
        'category': category,
        'deadline': deadline,
      };
}
