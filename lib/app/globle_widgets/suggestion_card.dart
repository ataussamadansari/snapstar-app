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
}
