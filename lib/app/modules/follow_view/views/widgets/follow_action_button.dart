import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/controllers/follow_controller.dart';
import '../../../../data/models/user_model.dart';

class FollowActionButton extends StatelessWidget {
  final UserModel user;

  const FollowActionButton({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final followController = Get.find<FollowController>();

    followController.initUser(user);

    return Obx(() {
      final state = followController.stateOf(user.uid);
      final loading = followController.isLoading(user.uid);

      debugPrint("user state: $state");
      debugPrint("user uid: ${user.uid}");

      return SizedBox(
        height: 32,
        child: ElevatedButton(
          onPressed: loading
              ? null
              : () => followController.onFollowTap(user),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: _btnColor(state),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            _btnText(state),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: state == FollowState.following
                  ? Colors.black
                  : Colors.white,
            ),
          ),
        ),
      );
    });
  }

  String _btnText(FollowState state) {
    switch (state) {
      case FollowState.following:
        return "Following";
      case FollowState.requested:
        return "Requested";
      case FollowState.followBack:
        return "Follow Back";
      default:
        return "Follow";
    }
  }

  Color _btnColor(FollowState state) {
    switch (state) {
      case FollowState.following:
        return Colors.grey.shade300;
      case FollowState.followBack:
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }
}
