import 'package:flutter/material.dart';

class NearbySegmentedControl extends StatelessWidget {
  final bool showListView;
  final VoidCallback onListViewTap;
  final VoidCallback onMapViewTap;

  const NearbySegmentedControl({
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
            color: Colors.grey.withValues(alpha:0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentTab(context, Icons.list, 'Liste', true),
          ),
          Expanded(
            child: _buildSegmentTab(context, Icons.map, 'Harita', false),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(
      BuildContext context, IconData icon, String text, bool isListTab) {
    bool isActive = (isListTab && showListView) || (!isListTab && !showListView);
    Color activeColor = Colors.red;
    Color inactiveColor = Colors.grey;
    Color activeTextIconColor = Colors.white;

    return GestureDetector(
      onTap: isActive ? null : (isListTab ? onListViewTap : onMapViewTap),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? activeTextIconColor : inactiveColor),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isActive ? activeTextIconColor : inactiveColor,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}