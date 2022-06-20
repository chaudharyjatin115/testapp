// import 'package:flutter/cupertino.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:myknott/Services/Services.dart';
import 'package:myknott/Views/InProgressOrderScreen.dart';
import 'package:myknott/Views/OrderScreen.dart';
import 'package:myknott/Views/Widgets/confirmCard.dart';
import 'package:myknott/Views/homePage.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class NewAppointmentScreen extends StatefulWidget {
  var notaryId;
  // Function updateTotalNewApp;
  var myUserInfo;
  NewAppointmentScreen(this.notaryId, this.myUserInfo);

  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  List myPendingList = [];
  bool isloading = false;
  var pageNumber = 0;
  bool hasData = false;
  Dio dio = Dio();
  final storage = FlutterSecureStorage();

  getPending() async {
    setState(() {
      hasData = false;
    });
    try {
      print(" getpending notaryId : $notaryId");
      String jwt = await storage.read(key: 'jwt');
      dio.options.headers['Authorization'] = jwt;
      myPendingList.clear();
      Map data = {
        "notaryId": notaryId,
        "pageNumber": 1
      }; // replace id with userInfo[_id]
      var response = await dio.post(
          NotaryServices().baseUrl + "appointment/getPendingAppointments",
          data: data);

      //print response
      // response.data.forEach(
      //     (key, v) => print("Response from 49 NApp: key : $key ,value : $v"));

      if (response.data['pageNumber'] == response.data['pageCount']) {
        hasData = true;
      } else
        pageNumber += 1;
      for (var item in response.data["appointments"]) {
        print("56 item getpending: ");
        // item.forEach((k, v) => print(" k : $k , v : $v"));
        myPendingList.add(
          {
            "id": item["_id"],
            "companyName": item['endCustomerInfo']['company']['name'],
            // "payAmnt": item["payAmnt"],
            "name": item["signingInfo"]["signerInfo"]['fisrtName'] +
                " " +
                item["signingInfo"]["signerInfo"]['lastName'],
            "propertyAddress": item["signingInfo"]["propertyAddress"],
            "date": item['appointmentInfo']['date'],
            "appointmentPlace": item["appointmentInfo"]["place"]
                ['completeAddress'],
            "time": item["appointmentInfo"]['time'],
            // "logo": item["customer"]["userImageURL"],
            "closingType": item['leadId']['type'],
          },
        );
        print("mypending list updated");
        // updatePending(response.data['leadId']);
      }
    } catch (e) {
      print("error on 81 NApp : $e");
      Fluttertoast.showToast(
          msg: "Something 81 went wrong..",
          backgroundColor: Colors.blue,
          fontSize: 16,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);
    }
    setState(() {
      isloading = true;
    });
  }

  @override
  void initState() {
    getPending();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(
        "-----------------pendingList---------------------------\n $myPendingList \n ----------");
    // widget.updateTotalNewApp(myPendingList.length);
    return isloading
        ? Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: RefreshIndicator(
                color: Colors.black,
                backgroundColor: Colors.purple,
                onRefresh: () async {
                  await getPending();
                  // initState();
                },
                child: myPendingList != null || myPendingList.length != 0
                    ? ListView.builder(
                        itemCount: myPendingList.length,
                        itemBuilder: ((context, index) {
                          return GestureDetector(
                            onTap: () async {
                              bool isDone = await Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: Duration(seconds: 0),
                                  pageBuilder: (_, __, ___) => OrderScreen(
                                    notaryId: widget.notaryId,
                                    // orderId: item["id"],
                                    isPending: true,
                                  ),
                                ),
                              );
                              // try {
                              //   if (!isDone) {
                              //     myPendingList.remove(item);
                              //     // updatePending(                          //Check this once
                              //     //     pendingList
                              //     //         .length);
                              //     setState(() {});
                              //   }
                              // } catch (e) {}
                            },
                            child: ConfirmCards(
                              // imageUrl:
                              //     "assets/userr.png", // Change to url
                              name: myPendingList[index]['name'],
                              address: myPendingList[index]['propertyAddress'],
                              orderId: myPendingList[index]['id'],
                              notaryId: notaryId,
                              refresh: getPending,
                              date: myPendingList[index]['date'],
                              place: myPendingList[index]['appointmentPlace'],
                              time: myPendingList[index]['time'].toString(),
                              closeType: myPendingList[index]['closingType'],
                            ),
                          );
                        }))
                    : Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Image.asset(
                              "assets/pendingorder.png",
                              height: 100,
                              width: 100,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                "You don't have any pending requests",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black.withOpacity(0.8),
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40.0),
                              child: Text(
                                "Tip: Accept Appointments as soon you receive message",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      )

                // ListView.builder(
                //     padding: EdgeInsets.all(15),
                //     physics: BouncingScrollPhysics(),
                //     // shrinkWrap: true,
                //     itemCount: myPendingList.length,
                //     itemBuilder: (context, index) {
                //       print(" 64 newApp ${myPendingList[index]['name']} ");
                //       return Card(
                //         elevation: 2.5,
                //         //   child:
                //         //   Padding(
                //         // padding: EdgeInsets.only(bottom: 15),
                //         child: Container(
                //           // color: Colors.amberAccent,
                //           color: Colors.white,
                //           // padding: EdgeInsets.only(bottom: 50),
                //           height: 130,
                //           // width: 16,
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.start,
                //             children: [
                //               SizedBox(
                //                 width: 15,
                //               ),
                //               Image.asset(
                //                 "assets/user.png",
                //                 width: 45,
                //                 height: 40,
                //               ),
                //               SizedBox(
                //                 width: 15,
                //               ),
                //               Column(
                //                 mainAxisAlignment:
                //                     MainAxisAlignment.start,
                //                 crossAxisAlignment:
                //                     CrossAxisAlignment.start,
                //                 children: [
                //                   SizedBox(
                //                     height: 1,
                //                   ),
                //                   Text(
                //                     myPendingList[index]['name'],
                //                     style: TextStyle(
                //                         fontWeight: FontWeight.bold,
                //                         fontSize: 20),
                //                   ),
                //                   SizedBox(
                //                     height: 2,
                //                   ),
                //                   Text(
                //                     myPendingList[index]['companyName'],
                //                     style: TextStyle(
                //                         fontSize: 18,
                //                         fontStyle: FontStyle.italic),
                //                   ),
                //                   SizedBox(
                //                     height: 3,
                //                   ),
                //                   Text("Appointment "),
                //                   Text(
                //                     "Date & Time :   " +
                //                         DateFormat("MM/dd/yyyy ").format(
                //                           DateTime.parse(
                //                                   myPendingList[index]
                //                                           ['date']
                //                                       .toString())
                //                               .toLocal(),
                //                         ) +
                //                         getTime(
                //                             myPendingList[index]['time']),
                //                     style: TextStyle(
                //                         fontWeight: FontWeight.w700),
                //                   ),
                //                   // .toString()),
                //                 ],
                //               ),
                //             ],
                //           ),
                //           // ),
                //         ),
                //       );
                //     })
                // : Center(
                //     child: Text(
                //     "List is empty",
                //     style: TextStyle(fontSize: 56),
                //   )),
                ),
          )
        : Center(
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                ),
                CircularProgressIndicator(color: Colors.black),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Please Wait",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
          );
  }
}
