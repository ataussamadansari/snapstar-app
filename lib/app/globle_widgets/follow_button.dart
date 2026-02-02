import 'package:flutter/material.dart';

import '../data/controllers/follow_controller.dart';

class FollowButton extends StatelessWidget {
  final FollowState state;
  final bool isLoading;
  final VoidCallback onTap;

  const FollowButton({
    super.key,
    required this.state,
    required this.isLoading,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 32,
        width: 32,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _btnColor(state),
          foregroundColor: state == FollowState.following ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(
          _btnText(state),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _btnText(FollowState state) {
    switch (state) {
      case FollowState.following: return "Following";
      case FollowState.requested: return "Cancel Request";
      case FollowState.followBack: return "Follow Back";
      case FollowState.requestedMe: return "Accept"; // Action oriented
      default: return "Follow";
    }
  }

  Color _btnColor(FollowState state) {
    switch (state) {
      case FollowState.following: return Colors.grey.shade300;
      case FollowState.requested: return Colors.grey.shade400;
      case FollowState.followBack: return Colors.blueAccent;
      case FollowState.requestedMe: return Colors.green; // Highlight accept action
      default: return Colors.blue;
    }
  }
}