import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensesPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const ExpensesPieChart({
    super.key,
    required this.transactions,
  });

  final List<Color> colors = const [
    Color(0xff0293ee),
    Color(0xfff8b250),
    Color(0xff845bef),
    Color(0xff13d38e),
  ];

  @override
  Widget build(BuildContext context) {
    // If transactions are still loading or empty, show a progress indicator
    if (transactions.isEmpty) {
      return Center(
        child: CircularProgressIndicator(), // Show loading indicator
      );
    }

    final expenseCategories = _calculateExpenseCategories();

    // If no categories are calculated, show the "No transactions available" message
    if (expenseCategories.isEmpty) {
      return Center(child: Text("No transactions available"));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final containerHeight = screenWidth * 0.9;

    return Container(
      height: containerHeight,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.only(top: 20, bottom: 20)),
          // Pie Chart
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 10,
                centerSpaceRadius: 60,
                sections: expenseCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: data['percentage'],
                    title: '${data['percentage'].toStringAsFixed(1)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(
              height: 56), // Add spacing between the chart and the legend
          // Legend
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: expenseCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildLegendItem(
                  data['category'],
                  colors[index % colors.length],
                  data['percentage'],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Assuming the following logic for _calculateExpenseCategories method
  List<Map<String, dynamic>> _calculateExpenseCategories() {
    List<Map<String, dynamic>> categories = [];

    // Example logic to categorize transactions
    if (transactions.isNotEmpty) {
      double totalAmount = transactions.fold(0.0, (sum, transaction) {
        return sum + transaction['value']; // Sum all the transaction values
      });

      // Assuming we want to group transactions by their type or category
      var groupedByType = {};

      for (var transaction in transactions) {
        String category = transaction['trans_type'] ?? 'Unknown';
        double value = transaction['value'] ?? 0.0;

        // Adding the value to the category group
        if (groupedByType.containsKey(category)) {
          groupedByType[category] += value;
        } else {
          groupedByType[category] = value;
        }
      }

      // Create a list of expense categories with percentages
      groupedByType.forEach((category, totalValue) {
        double percentage = (totalValue / totalAmount) * 100;
        categories.add({
          'category': category,
          'percentage': percentage,
        });
      });
    }

    return categories;
  }

  Widget _buildLegendItem(String category, Color color, double percentage) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text('$category: ${percentage.toStringAsFixed(1)}%'),
        )
      ],
    );
  }
}
