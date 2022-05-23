import 'package:get/get.dart';

class HomeController extends GetxController {
  final List<String> menuBarTitle = [
    'TRANG CHỦ',
    'THÔNG BÁO',
    'TIN TỨC TUYỂN SINH',
    'LIÊN HỆ'
  ];

  final index = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  void onChangeMenu(int index) {
    this.index.value = index;
  }

  @override
  void onClose() {}
}
