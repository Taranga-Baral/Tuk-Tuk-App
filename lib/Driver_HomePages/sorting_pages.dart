// lib/driver_home_page/sorting_page.dart
import 'package:flutter/material.dart';

class SortingPage extends StatelessWidget {
  final String selectedSortOption;
  
  const SortingPage({Key? key, required this.selectedSortOption}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      'Timestamp Newest First',
      'Price Expensive First',
      'Price Cheap First',
      'Distance Largest First',
      'Distance Smallest First',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sort Options'),
      ),
      body: ListView.builder(
        itemCount: sortOptions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(sortOptions[index]),
            trailing: selectedSortOption == sortOptions[index]
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              Navigator.pop(context, sortOptions[index]);
            },
          );
        },
      ),
    );
  }
}
