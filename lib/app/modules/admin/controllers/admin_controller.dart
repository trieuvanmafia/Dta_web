import 'dart:html';
import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminController extends GetxController {
  //TODO: Implement AdminController
  RxBool isLoading = false.obs;
  RxBool isLogin = false.obs;
  late TextEditingController nameController;
  late TextEditingController passController;

  @override
  void onInit() {
    super.onInit();
    nameController = new TextEditingController();
    passController = new TextEditingController();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  void login(){

    if(nameController.text == passController.text && nameController.text.isNotEmpty){
      nameController.text = '';
      passController.text = '';
      isLogin.value = true;
    }
  }

  void onUploadExel() async {
    isLoading.value = true;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      var excel = Excel.decodeBytes(file.bytes);

      List dataJson = [];
      for (var table in excel.tables.keys) {
        print(table); //sheet Name
        print(excel.tables[table]?.maxCols);
        print(excel.tables[table]?.maxRows);
        if (excel.tables[table]?.maxCols != 12) {
          // lỗi format file
          return;
        }
        excel.tables[table]!.rows.asMap().entries.forEach((element) {
          int index = element.key;
          var row = element.value;
          var json = '';

          if (index != 0) {
            json = "{"
                '"id":${row[0] is String ? '"${row[0]}"' : row[0]},'
                '"ma_nganh":${row[1] is String ? '"${row[1]}"' : row[1]},'
                '"ma_chuyen_nganh":${row[2] is String ? '"${row[2]}"' : row[2]},'
                '"ten_nganh":${row[3] is String ? '"${row[3]}"' : row[3]},'
                '"truong_va_dao_tao":${row[4] is String ? '"${row[4]}"' : row[4]},'
                '"to_hop_xet_tuyen_THPT":${row[5] is String ? '"${row[5]}"' : row[5]},'
                '"diem_thi_thpt":${row[6] is String ? '"${row[6]}"' : row[6]},'
                '"to_hop_xet_tuyen_hoc_ba":${row[7] is String ? '"${row[7]}"' : row[7]},'
                '"diem_hoc_ba":${row[8] is String ? '"${row[8]}"' : row[8]},'
                '"hoc_phi":${row[9] is String ? '"${row[9]}"' : row[9]},'
                '"link":${row[10] is String ? '"${row[10]}"' : row[10]},'
                '"ghi_chu":${row[11] is String ? '"${row[11]}"' : row[11]}'
                "}";
            dataJson.add(json);
          }
        });
      }

      print(dataJson);

      FirebaseFirestore.instance
          .collection('Data')
          .doc('dataJson')
          .update({'dataJson': dataJson.toString()});

      //uploadfile
      FirebaseFirestore.instance
          .collection('Data')
          .doc('dataExel')
          .update({'lastUpdate': DateTime.now()});
      final storageRef = FirebaseStorage.instance.ref('data/data.xlsx');
      await storageRef.putData(file.bytes!);
    }
    isLoading.value = false;
  }

  void launchDownload(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }
}
