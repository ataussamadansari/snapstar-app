import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/controllers/subscriber_controller.dart';
import '../core/utils/subscribe_state.dart';

class SubscriberButton extends StatefulWidget {
  final String userId;

  const SubscriberButton({super.key, required this.userId});

  @override
  State<SubscriberButton> createState() => _SubscriberButtonState();
}

class _SubscriberButtonState extends State<SubscriberButton> {
  final controller = Get.find<SubscriberController>();

  @override
  void initState() {
    super.initState();
    controller.loadStatus(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.getState(widget.userId);

      String text;
      Color bgColor;
      Color textColor;

      switch (state) {
        case SubscribeState.mutual:
          text = "Subscribed";
          bgColor = Colors.grey.shade300;
          textColor = Colors.black;
          break;

        case SubscribeState.subscribed:
          text = "Subscribed";
          bgColor = Colors.grey.shade300;
          textColor = Colors.black;
          break;

        case SubscribeState.subscribeBack:
          text = "Subscribe Back";
          bgColor = Colors.blue;
          textColor = Colors.white;
          break;

        case SubscribeState.none:
        default:
          text = "Subscribe";
          bgColor = Colors.blue;
          textColor = Colors.white;
      }

      return InkWell(
        onTap: () => controller.toggle(widget.userId),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.0)
          ),
          child: Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
      );

      /*return ElevatedButton(
        onPressed: () => controller.toggle(widget.userId),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
      );*/
    });
  }
}


/*class SubscriberButton extends StatelessWidget {
  final String userId;

  const SubscriberButton({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriberController>();

    controller.checkStatus(userId);

    return Obx(() {
      final isSubscribed = controller.isSubscribed(userId);

      return ElevatedButton(
        onPressed: () => controller.toggle(userId),
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isSubscribed ? Colors.grey[300] : Colors.blue,
        ),
        child: Text(
          isSubscribed ? "Subscribed" : "Subscribe",
          style: TextStyle(
            color: isSubscribed ? Colors.black : Colors.white,
          ),
        ),
      );
    });
  }
}*/
