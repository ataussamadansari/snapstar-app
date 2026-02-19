import 'package:get/get.dart';
import 'package:snapstar_app/app/data/controllers/comment_controller.dart';
import 'package:snapstar_app/app/data/controllers/subscriber_controller.dart';
import 'package:snapstar_app/app/data/providers/comment_provider.dart';
import 'package:snapstar_app/app/data/providers/like_provider.dart';
import 'package:snapstar_app/app/data/providers/post_provider.dart';
import 'package:snapstar_app/app/data/providers/subscriber_provider.dart';
import 'package:snapstar_app/app/data/providers/user_provider.dart';
import 'package:snapstar_app/app/data/repositories/comment_repository.dart';
import 'package:snapstar_app/app/data/repositories/like_repository.dart';
import 'package:snapstar_app/app/data/repositories/subscriber_repository.dart';
import 'package:snapstar_app/app/data/repositories/user_repository.dart';

import '../../data/controllers/like_controller.dart';
import '../../data/repositories/post_repository.dart';
import '../../modules/splash_view/controllers/splash_controller.dart';


class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<UserProvider>(UserProvider(), permanent: true);
    Get.put<SubscriberProvider>(SubscriberProvider(), permanent: true);
    Get.put<PostProvider>(PostProvider(), permanent: true);
    Get.put<LikeProvider>(LikeProvider(), permanent: true);
    Get.put<CommentProvider>(CommentProvider(), permanent: true);

    Get.put<SubscriberRepository>(SubscriberRepository(Get.find<SubscriberProvider>()), permanent: true,);
    Get.put<UserRepository>(UserRepository(Get.find<UserProvider>()), permanent: true,);
    Get.put<PostRepository>(PostRepository(Get.find<PostProvider>()), permanent: true,);
    Get.put<LikeRepository>(LikeRepository(Get.find<LikeProvider>()), permanent: true,);
    Get.put<CommentRepository>(CommentRepository(Get.find<CommentProvider>()), permanent: true,);


    Get.put(SplashController(), permanent: true);
    Get.put(LikeController(), permanent: true);
    Get.put(SubscriberController(), permanent: true);
    Get.put(CommentController(), permanent: true);
  }
}