import 'package:flutter/material.dart';
import 'database_helper.dart';

class FoodOrderingScreen extends StatefulWidget {
  @override
  _FoodOrderingScreenState createState() => _FoodOrderingScreenState();
}

class _FoodOrderingScreenState extends State<FoodOrderingScreen> {
  final TextEditingController _targetCostController = TextEditingController();
  DateTime? _selectedDate;
  double _targetCost = 0.0;
  List<Map<String, dynamic>> _foodItems = [];
  List<Map<String, dynamic>> _selectedItems = [];
  String? _queryResult;

  @override
  void initState() {
    super.initState();
    DatabaseHelper().initDatabase();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    List<Map<String, dynamic>> items = await DatabaseHelper().getFoodItems();
    setState(() {
      _foodItems = items;
    });
  }

  Future<void> _onSaveOrder() async {
    if (_selectedDate == null || _selectedItems.isEmpty || _targetCost <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all fields.")));
      return;
    }

    List<int> selectedFoodIds =
    _selectedItems.map((item) => item['id'] as int).toList();

    await DatabaseHelper().saveOrder(
      _selectedDate!.toString(),
      _targetCost,
      selectedFoodIds,
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Order saved successfully!")));
  }

  Future<void> _queryOrders(String date) async {
    List<Map<String, dynamic>> orders = await DatabaseHelper().getOrderPlans(date);
    setState(() {
      _queryResult = orders.isNotEmpty
          ? "Order(s) found: ${orders.length}"
          : "No orders found for the selected date.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Ordering App'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageFoodScreen(),
                ),
              ).then((_) => _loadFoodItems());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _targetCostController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Target Cost per Day'),
              onChanged: (value) {
                setState(() {
                  _targetCost = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                _selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2025),
                );
                setState(() {});
              },
              child: Text(_selectedDate == null
                  ? 'Select Date'
                  : 'Date: ${_selectedDate!.toLocal()}'),
            ),
            SizedBox(height: 10),
            Text('Select Food Items ${_foodItems.length}:'),
            Expanded(
              child: ListView.builder(
                itemCount: _foodItems.length,
                itemBuilder: (context, index) {
                  var foodItem = _foodItems[index];
                  return CheckboxListTile(
                    title: Text('${foodItem['name']} (\$${foodItem['cost']})'),
                    value: _selectedItems.contains(foodItem),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected!) {
                          _selectedItems.add(foodItem);
                        } else {
                          _selectedItems.remove(foodItem);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _onSaveOrder,
              child: Text('Save Order'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedDate != null) {
                  _queryOrders(_selectedDate!.toString());
                }
              },
              child: Text('Query Orders'),
            ),
            if (_queryResult != null) Text(_queryResult!),
          ],
        ),
      ),
    );
  }
}

class ManageFoodScreen extends StatefulWidget {
  @override
  _ManageFoodScreenState createState() => _ManageFoodScreenState();
}

class _ManageFoodScreenState extends State<ManageFoodScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  Future<void> _addFoodItem() async {
    if (_nameController.text.isEmpty || _costController.text.isEmpty) return;

    await DatabaseHelper().insertFoodItem(
      _nameController.text,
      double.tryParse(_costController.text) ?? 0.0,
    );

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Food item added successfully!")));
    _nameController.clear();
    _costController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Food Items')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Food Name'),
            ),
            TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cost'),
            ),
            ElevatedButton(
              onPressed: _addFoodItem,
              child: Text('Add Food Item'),
            ),
          ],
        ),
      ),
    );
  }
}
