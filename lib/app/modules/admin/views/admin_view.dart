import 'package:captone2_dta_bot/app/common/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_chart/d_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/types/gf_button_type.dart';

import '../controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if(controller.isLogin.value){
        return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo-dtu.png',
                    fit: BoxFit.fitWidth,
                  ),
                  const Text(
                    'Admin Page',
                    style: TextStyle(fontSize: 40),
                  ),
                  Container(
                    color: Colors.black12,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        const Text(
                          ' Quản lý file data về các ngành học của chatbot',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('Data')
                              .doc('dataExel')
                              .get(),
                          builder:
                              (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(snapshot.hasError.toString()),
                              );
                            }
                            if (!snapshot.hasData) {
                              return const SizedBox(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return Row(
                              children: [
                                Text(
                                  " File data về ngành học của DTAbot[nếu muốn update bạn nên tải file này về và chỉnh sửa]: ",
                                  style: TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${snapshot.data?['name']}  ",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                ),
                                GFButton(
                                  onPressed: () {
                                    controller.launchDownload(snapshot.data?['url']);
                                  },
                                  text: "Tải Xuống",
                                  icon: Icon(
                                    Icons.download,
                                    color: Colors.lightGreen,
                                  ),
                                  color: Colors.lightGreen,
                                  type: GFButtonType.outline,
                                ),
                              ],
                            );
                          },
                        ),
                        Row(
                          children: [
                            const Text(
                              "Tải file lên và tự động update :",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            !controller.isLoading.value
                                ? GFButton(
                              onPressed: () {
                                controller.onUploadExel();
                              },
                              text: "Tải file lên",
                              icon: Icon(
                                Icons.upload_outlined,
                                color: Colors.redAccent,
                              ),
                              color: Colors.redAccent,
                              type: GFButtonType.outline,
                            )
                                : SizedBox(),
                            SizedBox(
                              width: 10,
                            ),
                            controller.isLoading.value
                                ? Row(
                              children: const [
                                SizedBox(
                                  child: CircularProgressIndicator(
                                    color: Colors.redAccent,
                                  ),
                                  width: 25,
                                  height: 25,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Đang xử lý và upload file')
                              ],
                            )
                                : SizedBox(),
                          ],
                        )
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('ReportData')
                        .snapshots(),
                    builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                      var items = snapshot.data?.docs ?? [];
                      Set checkData = {};
                      Map saveData = {};

                      items.forEach((element) {
                        String majorID =
                            '${element['ma_nganh']}${element['ma_chuyen_nganh']}';
                        if (checkData.add(majorID)) {
                          saveData[majorID] = {
                            'majorName': element['ten_nganh'],
                            'count': 1
                          };
                        } else {
                          saveData[majorID]['count'] = saveData[majorID]['count'] + 1;
                        }
                      });
                      List<Map<String,dynamic>> listChart = [];
                      checkData.forEach((element) {
                        listChart.add(
                            {'domain': '${saveData[element]['majorName']}', 'measure': (saveData[element]['count']/items.length) * 100 }
                        );
                      });

                      if (!snapshot.hasData) {
                        return const SizedBox(
                          height: 400,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          Text(
                            'Biểu đồ phân tích phần trăm ngành học quan tâm dựa trên data lấy từ chatbot (Hiện Tại Đang Có : ${items.length} Câu Trả Lời)',
                            style:
                            TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 80),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: DChartBar(
                                data: [
                                  {
                                    'id': 'Bar 1',
                                    'data': listChart,
                                  },
                                ],
                                yAxisTitle: 'ngành học',
                                xAxisTitle:
                                'phần trăm dựa trên tổng số lượt trả lời trên chatbot',
                                measureMin: 0,
                                measureMax: 100,
                                minimumPaddingBetweenLabel: 1,
                                domainLabelPaddingToAxisLine: 16,
                                axisLineTick: 2,
                                axisLinePointTick: 2,
                                axisLinePointWidth: 10,
                                axisLineColor: Colors.green,
                                measureLabelPaddingToAxisLine: 16,
                                barColor: (barData, index, id) => id == 'Bar 1'
                                    ? Colors.green.shade300
                                    : Colors.green.shade900,
                                barValue: (barData, index) =>
                                '${barData['measure']}%',
                                showBarValue: true,
                                barValuePosition: BarValuePosition.outside,
                                verticalDirection: false,
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ],
              ),
            ));
      }
      return Scaffold(
        body: Center(
          child: Container(
            height: 300,
            width: 300,
            padding: EdgeInsets.all(30),
            color: textSelectColor.withOpacity(0.2),
            child: Column(
              children: [
                SizedBox(height: 10,),

                Image.asset(
                  'assets/images/logo-dtu.png',
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(height: 10,),
                TextField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                      hintText: 'Tên Đăng Nhập của Admin',
                      labelText: 'Tên Đăng Nhập của Admin',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(width: 3, color: Colors.blue),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(width: 3, color: Colors.red),
                        borderRadius: BorderRadius.circular(15),
                      )),
                ),
                SizedBox(height: 10,),
                TextField(
                  obscureText: true,
                  controller: controller.passController,
                  decoration: InputDecoration(
                      hintText: 'Mật Khẩu',
                      labelText: 'Mật Khẩu',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(width: 3, color: Colors.blue),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(width: 3, color: Colors.red),
                        borderRadius: BorderRadius.circular(15),
                      )),
                ),
                GFButton(
                    onPressed: controller.login,
                    text:"Đăng Nhập"
                ),
              ],
            ),
          ),
        ),
      );

    });
  }
}
