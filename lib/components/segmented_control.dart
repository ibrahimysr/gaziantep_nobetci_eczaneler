import 'package:flutter/material.dart';

class SegmentedControl extends StatelessWidget {
  final bool showListView;
  final VoidCallback onListViewTap;
  final VoidCallback onMapViewTap;

  const SegmentedControl({
    super.key,
    required this.showListView,
    required this.onListViewTap,
    required this.onMapViewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onListViewTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: showListView ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list, color: showListView ? Colors.white : Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Liste',
                      style: TextStyle(
                        color: showListView ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onMapViewTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: !showListView ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, color: !showListView ? Colors.white : Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Harita',
                      style: TextStyle(
                        color: !showListView ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}