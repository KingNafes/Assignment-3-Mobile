class OrderPlan {
  final int id;
  final String date;
  final double targetCost;
  final List<int> selectedItemIds;

  OrderPlan({
    required this.id,
    required this.date,
    required this.targetCost,
    required this.selectedItemIds,
  });

  // Convert an OrderPlan object into a map for storing in the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'targetCost': targetCost,
      'selectedItems': selectedItemIds.join(','), // store as a comma-separated string
    };
  }

  // Convert a map from the database into an OrderPlan object
  factory OrderPlan.fromMap(Map<String, dynamic> map) {
    return OrderPlan(
      id: map['id'],
      date: map['date'],
      targetCost: map['targetCost'],
      selectedItemIds: map['selectedItems'].split(',').map((e) => int.parse(e)).toList(),
    );
  }
}