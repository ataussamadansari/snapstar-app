import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/controllers/follow_controller.dart';
import '../data/models/user_model.dart';
class SuggestionCard extends StatelessWidget {
  final UserModel user;
  const SuggestionCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final followController = Get.find<FollowController>();
    followController.initUser(user);

    return Container(
      width: 120, // Slightly increased for better spacing
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(user.photoUrl),
          ),
          const SizedBox(height: 8),
          Text(
            user.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final state = followController.stateOf(user.uid);
            final loading = followController.isLoading(user.uid);

            if (state == FollowState.requestedMe) {
              return Row(
                children: [
                  Expanded(
                    child: _actionBtn("Accept", Colors.blue, () => followController.acceptRequest(user)),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _actionBtn("Delete", Colors.grey.shade300, () => followController.rejectRequest(user.uid), textColor: Colors.black),
                  ),
                ],
              );
            }

            return SizedBox(
              height: 32,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : () => followController.onFollowTap(user),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _getBtnColor(state),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: loading
                    ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                  _getBtnText(state),
                  style: TextStyle(
                    fontSize: 11,
                    color: state == FollowState.following || state == FollowState.requested ? Colors.black87 : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Helper Methods ---

  Widget _actionBtn(String label, Color bg, VoidCallback onTap, {Color textColor = Colors.white}) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          padding: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Color _getBtnColor(FollowState state) {
    switch (state) {
      case FollowState.following: return Colors.grey.shade300;
      case FollowState.requested: return Colors.grey.shade400;
      case FollowState.followBack: return Colors.blueAccent;
      case FollowState.requestedMe: return Colors.green; // Highlight accept action
      default: return Colors.blue;
    }
  }

  String _getBtnText(FollowState state) {
    switch (state) {
      case FollowState.following: return "Following";
      case FollowState.requested: return "Cancel Request";
      case FollowState.followBack: return "Follow Back";
      case FollowState.requestedMe: return "Accept"; // Action oriented
      default: return "Follow";
    }
  }
}


/*class SuggestionCard extends StatelessWidget {
  final UserModel user;
  const SuggestionCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final followController = Get.find<FollowController>();

    followController.initUser(user);

    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(user.photoUrl),
          ),
          const SizedBox(height: 6),

          Text(
            user.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 6),

          Obx(() {
            final state = followController.stateOf(user.uid);
            final loading = followController.isLoading(user.uid);

            if (state == FollowState.requestedMe) {
              return Row(
                children: [
                  // Accept Button
                  Expanded(
                    child: _actionBtn("Accept", Colors.blue, () async {
                      followController.acceptRequest(user);
                    }),
                  ),
                  const SizedBox(width: 4),
                  // Reject Button
                  Expanded(
                    child: _actionBtn("Delete", Colors.grey.shade300, () {
                      followController.rejectRequest(user.uid);
                    }, textColor: Colors.black),
                  ),
                ],
              );
            }

            return SizedBox(
              height: 32, // Thoda height badhayi hai better look ke liye
              width: double.infinity, // Card ki poori width lega
              child: ElevatedButton(
                onPressed: loading ? null : () => followController.onFollowTap(user),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 4), // Padding kam ki
                  backgroundColor: state == FollowState.following
                      ? Colors.grey.shade200
                      : state == FollowState.followBack
                      ? Colors.indigo
                      : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: FittedBox( // 🔥 Ye text ko overlap hone se bachayega
                  fit: BoxFit.scaleDown,
                  child: Text(
                    state == FollowState.following ? "Following"
                        : state == FollowState.requested ? "Requested"
                        : state == FollowState.followBack ? "Follow Back"
                        : "Follow",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: state == FollowState.following
                          ? Colors.black87
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Helper Widget for small buttons
  Widget _actionBtn(String label, Color bg, VoidCallback onTap, {Color textColor = Colors.white}) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: bg, padding: EdgeInsets.zero, elevation: 0),
        onPressed: onTap,
        child: Text(label, style: TextStyle(color: textColor, fontSize: 11)),
      ),
    );
  }

  // Helper methods for clean code
  Color _getBtnColor(FollowState state) {
    switch (state) {
      case FollowState.following: return Colors.grey.shade200;
      case FollowState.requested: return Colors.grey.shade300; // Visual cue for cancel
      case FollowState.followBack: return Colors.indigo;
      default: return Colors.blue;
    }
  }

  String _getBtnText(FollowState state) {
    switch (state) {
      case FollowState.following: return "Following";
      case FollowState.requested: return "Requested"; // Tap to Cancel
      case FollowState.followBack: return "Follow Back";
      default: return "Follow";
    }
  }
}*/
