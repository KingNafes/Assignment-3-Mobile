class FoodItem {
  final int id;
  final String name;
  final double cost;

  FoodItem({
    required this.id,
    required this.name,
    required this.cost,
  });

  // Convert a FoodItem object into a map for storing in the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
    };
  }

  // Convert a map from the database into a FoodItem object
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      cost: map['cost'],
    );
  }
}
