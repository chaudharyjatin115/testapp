import 'dart:io';
import 'package:amazon_s3_cognito/amazon_s3_cognito.dart';
import 'package:amazon_s3_cognito/aws_region.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotaryServices {
  final Dio dio = Dio();
  final storage = FlutterSecureStorage();

  acceptNotary(String notaryId, String orderId) async {
    try {
      String jwt = await storage.read(key: 'jwt');
      Map body = {"orderId": orderId, "notaryId": notaryId};
      dio.options.headers['Authorization'] = jwt;
      var response = await dio.post(
          "https://my-notary-app.herokuapp.com/notary/acceptOrder",
          data: body);
      print(response.data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  declineNotary(String notaryId, String orderId) async {
    // print
    try {
      String jwt = await storage.read(key: 'jwt');
      Map body = {"orderIdToDecline": orderId, "notaryId": notaryId};
      dio.options.headers['Authorization'] = jwt;
      var response = await dio.post(
          "https://my-notary-app.herokuapp.com/notary/declineOrder",
          data: body);
      print(response.data);
      return true;
    } catch (e) {
      return false;
    }
  }

  markDocumentsDownloaded(String notaryId, String orderId) async {
    try {
      String jwt = await storage.read(key: 'jwt');
      Map body = {"orderId": orderId, "notaryId": notaryId};
      dio.options.headers['Authorization'] = jwt;
      var response = await dio.post(
          "https://my-notary-app.herokuapp.com/notary/markDocumentsDownloaded",
          data: body);
      print(response.data);
    } catch (e) {
      print(e);
    }
  }

  markOrderInProgress(String notaryId, String orderId) async {
    try {
      String jwt = await storage.read(key: 'jwt');
      Map body = {"orderId": orderId, "notaryId": notaryId};
      dio.options.headers['Authorization'] = jwt;
      var response = await dio.post(
          "https://my-notary-app.herokuapp.com/notary/markOrderInProgress",
          data: body);
      print(response.data);
    } catch (e) {
      print(e);
    }
  }

  markSigningCompleted(String notaryId, String orderId) async {
    try {
      String jwt = await storage.read(key: 'jwt');
      Map body = {"orderId": orderId, "notaryId": notaryId};
      dio.options.headers['Authorization'] = jwt;
      var response = await dio.post(
          "https://my-notary-app.herokuapp.com/notary/markSigningCompleted",
          data: body);
      print(response.data);
    } catch (e) {
      print(e);
    }
  }

  markOrderAsConfirmed(String notaryId, String orderId) async {
    try {
      String jwt = await storage.read(key: 'jwt');
      Map body = {"orderId": orderId, "notaryId": notaryId};
      dio.options.headers['Authorization'] = jwt;
      var response = await dio.post(
          "https://my-notary-app.herokuapp.com/notary/markOrderAsConfirmed",
          data: body);
      print(response.data);
    } catch (e) {
      print(e);
    }
  }

  markOrderAsDelivered(String notaryId, String orderId) async {
    try {
      String jwt = await storage.read(key: 'jwt');
      Map body = {"orderId": orderId, "notaryId": notaryId};
      dio.options.headers['Authorization'] = jwt;
      var response = await dio.post(
          "https://my-notary-app.herokuapp.com/notary/markOrderAsDelivered",
          data: body);
      print(response.data);
    } catch (e) {
      print(e);
    }
  }

  getInProgressOrders(String notaryId, int pageNumber) async {
    try {
      print(pageNumber);
      String jwt = await storage.read(key: 'jwt');
      dio.options.headers['Authorization'] = jwt;
      var response = await dio.post(
          "https://my-notary-app.herokuapp.com/notary/getInProgressOrders",
          data: {"notaryId": notaryId, "pageNumber": pageNumber});
      return response.data;
    } catch (e) {
      print(e);
      return {};
    }
  }

  getCompletedOrders(String notaryId, int pageNumber) async {
    try {
      print(pageNumber);
      String jwt = await storage.read(key: 'jwt');
      dio.options.headers['Authorization'] = jwt;
      var response = await dio.post(
          "https://my-notary-app.herokuapp.com/notary/getCompletedOrders",
          data: {"notaryId": notaryId, "pageNumber": pageNumber});
      return response.data;
    } catch (e) {
      print(e);
      return {};
    }
  }

  getAppointments(DateTime dateTime, String notaryId) async {
    try {
      String jwt = await storage.read(key: 'jwt');
      dio.options.headers['Authorization'] = jwt;
      var response = await dio.post(
          "https://my-notary-app.herokuapp.com/notary/getDashboard",
          data: {
            "notaryId": notaryId,
            "today12am": dateTime.year.toString() +
                "-" +
                dateTime.month.toString() +
                "-" +
                dateTime.day.toString() +
                " 00:00:00 GMT+0530"
          });
      return response.data;
    } catch (e) {
      print(e);
      return {};
    }
  }

  getUserProfileInfo(String notaryId) async {
    try {
      String jwt = await storage.read(key: 'jwt');
      dio.options.headers['Authorization'] = jwt;
      var response = await dio.post(
        "https://my-notary-app.herokuapp.com/notary/getProfile",
        data: {"notaryId": notaryId, "PageNumber": "0"},
      );
      return response.data;
    } catch (e) {
      print(e);
      return {};
    }
  }

  getEarnings(String notaryId, int pageNumber) async {
    print("current page Number $pageNumber");
    String jwt = await storage.read(key: 'jwt');
    dio.options.headers['Authorization'] = jwt;
    var response = await dio.post(
      "https://my-notary-app.herokuapp.com/notary/getEarnings",
      data: {"notaryId": notaryId, "pageNumber": pageNumber},
    );
    print("pageNumber ${response.data['pageNumber']}");
    return response.data;
  }

  getAllMessages(String notaryId, int pageNumber, String chatRoom) async {
    try {
      String jwt = await storage.read(key: 'jwt');
      dio.options.headers['Authorization'] = jwt;
      var response = await dio.post(
        "https://my-notary-app.herokuapp.com/notary/listMessages",
        data: {
          "notaryId": notaryId,
          "chatroomId": chatRoom,
          "pageNumber": pageNumber,
        },
      );
      return response.data;
    } catch (e) {
      print(e);
      return {};
    }
  }

  sendMessage({String message, String notaryId, String chatRoom}) async {
    try {
      String jwt = await storage.read(key: 'jwt');
      dio.options.headers['Authorization'] = jwt;
      await dio.post(
        "https://my-notary-app.herokuapp.com/notary/sendMessage/",
        data: {
          "notaryId": notaryId,
          "chatroomId": chatRoom,
          "chatMessage": "$message"
        },
      );
    } catch (e) {}
  }

  getToken() async {
    final storage = new FlutterSecureStorage();
    String token = await FirebaseAuth.instance.currentUser.getIdToken();
    storage.write(key: "jwt", value: "Bearer " + token);
    print(token);
  }

  uploadImageToAPI(File _image, String notaryId, String orderId) async {
    print("notaryId $notaryId");
    print("orderId $orderId");
    String fileName = _image.path.split('/').last;
    String name = "n/$notaryId/o/$orderId/$fileName";
    print(name);
    String uploadedImageUrl = await AmazonS3Cognito.upload(
        _image.path,
        "mynotarybucket1",
        "us-east-2:98ee1e86-593d-4880-99af-0cd58dbfac15",
        name,
        AwsRegion.US_EAST_2,
        AwsRegion.US_EAST_2);
    print(uploadedImageUrl);
    Map body = {
      "documentArray": [
        {
          "documentName": fileName,
          "documentURL": uploadedImageUrl,
        }
      ],
      "orderId": orderId,
      "notaryId": notaryId
    };
    String jwt = await storage.read(key: 'jwt');
    dio.options.headers['Authorization'] = jwt;
    var response = await dio.post(
        "https://my-notary-app.herokuapp.com/notary/uploadMultipleDocumentsForOrder",
        data: body);
    print("=====================");
    print(response.data);
  }
}
