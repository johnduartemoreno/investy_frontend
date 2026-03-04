import 'package:equatable/equatable.dart';

class Goal extends Equatable {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;

  const Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
  });

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [id, name, targetAmount, currentAmount, deadline];
}
