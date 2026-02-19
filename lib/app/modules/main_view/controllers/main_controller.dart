import 'package:get/get.dart';

class MainController extends GetxController {
  // Current active index
  var currentIndex = 0.obs;

  // Change index method
  void changeIndex(int index) {
    currentIndex.value = index;
  }
}