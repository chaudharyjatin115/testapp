import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:myknott/Config/CustomColors.dart';
import 'package:myknott/Services/Services.dart';
import 'package:myknott/Services/auth.dart';
import 'package:myknott/Views/CalenderScreen.dart';
import 'package:myknott/Views/ProgessScreen.dart';
import 'package:myknott/Views/UserProfile.dart';
import 'package:myknott/Views/Widgets/card.dart';
import 'package:myknott/Views/Widgets/confirmCard.dart';
import 'package:myknott/Views/OrderScreen.dart';
import 'package:myknott/Views/newAppointment.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myknott/Views/Amount.dart';
import 'AuthScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

var notaryId = "";
var notaryUserObj;
var loginUserInfo;

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  Dio dio = Dio();
  final Color blueColor = CustomColor().blueColor;
  final storage = FlutterSecureStorage();
  TabController tabController;
  int currentIndex = 0;
  int pageNumber = 0;
  bool hasData = false;
  List appointmentList = [];
  List pendingList = [];
  Map userInfo = {};
  bool isloading = false;
  String totalAppointment = "";
  String totalpending = "";

  updateAppointment(int order) {
    if (order == 0) {
      totalAppointment = "";
    } else
      totalAppointment = "($order)";
  }

  updatePending(int order) {
    if (order == 0) {
      totalpending = "";
    } else
      totalpending = "($order)";
  }

  handleForegroundNotification(RemoteMessage message) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    print("meseg 68:${message.data['type']}");
    try {
      if (message.data['type'] == 2 || message.data['type'] == "2") {
        pendingList.clear();
        String jwt = await storage.read(key: 'jwt');
        dio.options.headers['Authorization'] = jwt;
        Map data = {"notaryId": userInfo['_id'], "pageNumber": "0"};
        var response = await dio.post(
            NotaryServices().baseUrl + "appointment/getPendingAppointments",
            data: data);
        print("Response from 76\n");
        response.data.forEach((key, v) => print("key : $key , value : $v"));
        for (var item in response.data["orders"]) {
          pendingList.add(
            {
              "id": item["_id"],
              "payAmnt": item["payAmnt"],
              "name": item["appointment"]["signerFullName"],
              "address": item["appointment"]["propertyAddress"],
              "appointmentPlace": item["appointment"]["place"],
              "time": item["appointment"]['time'],
              "logo": item["customer"]["userImageURL"],
              "closingType": item['orderClosingType'],
            },
          );
        }
        updatePending(pendingList.length);
        setState(() {});
      } else if (message.data['type'] == 1 || message.data['type'] == "1") {
        if (message.data['action'] == 'revoked') {
          await preferences.clear();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => AuthScreen(),
            ),
          );
        }
      }
    } catch (e) {
      print("Error on 105 homepage : $e");
    }
  }

  handleNotificationClick(RemoteMessage message) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (message.data['type'] == 2 || message.data['type'] == "2") {
      String orderId = message.data['orderId'];
      String notaryId = message.data['notaryId'];
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OrderScreen(
            isPending: true,
            notaryId: notaryId,
            orderId: orderId,
          ),
        ),
      );
    } else if (message.data['type'] == 0 || message.data['type'] == "0") {
      String orderId = message.data['orderId'];
      String notaryId = message.data['notaryId'];

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OrderScreen(
            isPending: false,
            notaryId: notaryId,
            orderId: orderId,
            messageTrigger: true,
          ),
        ),
      );
    } else if (message.data['type'] == 1 || message.data['type'] == "1") {
      if (message.data['action'] == 'revoked') {
        await preferences.clear();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AuthScreen(),
          ),
        );
      }
    } else if (message.data['type'] == 4 || message.data['type'] == "4") {
      String orderId = message.data['orderId'];
      String notaryId = message.data['notaryId'];
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OrderScreen(
            isPending: false,
            notaryId: notaryId,
            orderId: orderId,
          ),
        ),
      );
    }
  }

  @override
  initState() {
    FirebaseMessaging.onMessageOpenedApp.any((element) {
      handleNotificationClick(element);
      return false;
    });
    FirebaseMessaging.onMessage.any((element) {
      handleForegroundNotification(element);
      return false;
    });
    tabController = TabController(length: 4, vsync: this);
    getUserInfo();
    getAppointment();
    getPending();
    super.initState();
  }

  @override
  dispose() {
    tabController.dispose();
    super.dispose();
  }

  getUserInfo() async {
    FirebaseMessaging.instance.onTokenRefresh
        .any((element) => AuthService().updateToken(element));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedUserinfo = prefs.getString("userInfo");
    userInfo = await json.decode(encodedUserinfo);
    setState(() {
      notaryId = userInfo['_id'];
      loginUserInfo = userInfo;
      // notaryUserObj =;
    });
  }

  getAppointment() async {
    try {
      appointmentList.clear();
      String jwt = await storage.read(key: 'jwt');
      dio.options.headers['Authorization'] = jwt;
      print(" user ID 205 : ${userInfo['_id']}");
      var body = {
        "notaryId": userInfo['_id'],
        // "today12am": DateTime.now().year.toString() +
        //     "-" +
        //     DateTime.now().month.toString() +
        //     "-" +
        //     DateTime.now().day.toString() +
        //     " 00:00:00 GMT${NotaryServices.getTimezoneOffsetString(DateTime.now())}"
      };
      var response = await dio.post(
          NotaryServices().baseUrl + "dashboard/getDashboard",
          data: body);

      print("response from 219 :\n");
      response.data
          .forEach((key, value) => print("key : $key , value : $value"));
      for (var i in response.data['pendingAppointments']) {
        i.forEach((k, v) => print(" 223 : k : $k , v : $v"));
        appointmentList.add({
          "id": i['_id'],
          "date": i['appointmentInfo']['date'],
          "address": i['signingInfo']["propertyAddress"],
          "name": i['signingInfo']["signerInfo"]['fisrtName'],
          "phone": i['signingInfo']["signerInfo"]['phoneNumber'],
          "orderId": i["_id"],
          // "logo": i['customer']['userImageURL'],
          "place": i['appointmentInfo']['place']['completeAddress']
        });
        updateAppointment(appointmentList.length);
        setState(() {});
      }
    } catch (e) {
      print("Error on 237 : $e\n");
      Fluttertoast.showToast(
          msg: "Something 237 went wrong..",
          backgroundColor: blueColor,
          fontSize: 16,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);
    }
  }

  getPending() async {
    setState(() {
      pageNumber = 0;
      hasData = false;
    });
    try {
      String jwt = await storage.read(key: 'jwt');
      dio.options.headers['Authorization'] = jwt;
      pendingList.clear();
      Map data = {
        "notaryId": userInfo['_id'],
        "pageNumber": pageNumber
      }; // replace id with userInfo[_id]
      var response = await dio.post(
          NotaryServices().baseUrl + "appointment/getPendingAppointments",
          data: data);

      //print response
      // response.data.forEach(
      // (key, v) => print("Response from 257 : key : $key ,value : $v"));

      // if (response.data['pageNumber'] == response.data['pageCount']) {
      //   hasData = true;
      // } else
      // pageNumber += 1;
      for (var item in response.data["appointments"]) {
        // print("268 item getpending: ");
        // item.forEach((k, v) => print(" k : $k , v : $v"));
        pendingList.add(
          {
            "id": item["_id"],
            "companyName": item['endCustomerInfo']['company']['name'],
            // "payAmnt": item["payAmnt"],
            "name": item["signingInfo"]["signerInfo"]['fisrtName'] +
                " " +
                item["signingInfo"]["signerInfo"]['lastName'],
            "address": item["signingInfo"]["propertyAddress"],
            "date": item['appointmentInfo']['date'],
            "appointmentPlace": item["appointmentInfo"]["place"]
                ['completeAddress'],
            "time": item["appointmentInfo"]['time'],
            // "logo": item["customer"]["userImageURL"],
            "closingType": item['leadId']['type'],
          },
        );
        // updatePending(response.data['leadId']);
      }
    } catch (e) {
      print("error on 282 : $e");
      Fluttertoast.showToast(
          msg: "Something 282 went wrong..",
          backgroundColor: blueColor,
          fontSize: 16,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);
    }
    setState(() {
      isloading = true;
    });
  }

  fetchMoreData() async {
    try {
      String jwt = await storage.read(key: 'jwt');
      dio.options.headers['Authorization'] = jwt;
      Map data = {"notaryId": userInfo['_id'], "pageNumber": pageNumber};
      var response = await dio
          .post(NotaryServices().baseUrl + "notary/getInvites/", data: data);
      if (response.data['pageNumber'] == response.data['pageCount']) {
        hasData = true;
      } else
        pageNumber += 1;
      for (var item in response.data["orders"]) {
        pendingList.add(
          {
            "id": item["_id"],
            "payAmnt": item["payAmnt"],
            "name": item["appointment"]["signerFullName"],
            "address": item["appointment"]["propertyAddress"],
            "appointmentPlace": item["appointment"]["place"],
            "time": item["appointment"]['time'],
            "logo": item["customer"]["userImageURL"],
            "closingType": item['orderClosingType'],
          },
        );
      }
    } catch (e) {}
    setState(() {
      isloading = true;
    });
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    String greeting() {
      var hour = DateTime.now().hour;
      if (hour < 12) {
        return 'Morning';
      }
      if (hour < 17) {
        return 'Afternoon';
      }
      return 'Evening';
    }

    String notaryFirstName = userInfo["firstName"] == null
        ? "firstName"
        : userInfo["firstName"] + " ";
    String notaryLastName =
        userInfo["lastName"] == null ? "" : userInfo["lastName"];
    String fullName = notaryFirstName + notaryLastName;

    // print("photo url from 323 homepage : ");
    // print(userInfo['photoURL']);

    return Scaffold(
      // backgroundColor: Colors.white,
      backgroundColor: Colors.grey.shade50,

      bottomNavigationBar: Material(
        color: Colors.white,
        elevation: 10,
        child: SalomonBottomBar(
          currentIndex: currentIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: (i) {
            tabController.animateTo(i);
            setState(() {
              currentIndex = i;
            });
          },
          items: [
            SalomonBottomBarItem(
              icon: Icon(
                Icons.home_filled,
                size: 26,
              ),
              title: Text(
                "Home",
                style: TextStyle(fontSize: 14.5),
              ),
            ),
            SalomonBottomBarItem(
              icon: Icon(
                Icons.bookmark_sharp,
                size: 26,
              ),
              title: Text(
                "Appointments",
                style: TextStyle(fontSize: 14.5),
              ),
            ),
            SalomonBottomBarItem(
              icon: Icon(
                Icons.contact_phone_rounded,
                size: 26,
              ),
              title: Text(
                "Leads",
                style: TextStyle(fontSize: 14.5),
              ),
            ),
            SalomonBottomBarItem(
              icon: Icon(
                Icons.person,
                size: 26,
              ),
              title: Text(
                "Profile",
                style: TextStyle(fontSize: 14.5),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          LazyLoadScrollView(
            isLoading: hasData,
            onEndOfPage: () => fetchMoreData(),
            child: RefreshIndicator(
              color: Colors.black,
              onRefresh: () async {
                await getAppointment();
                await getPending();
              },
              child: SafeArea(
                child: (isloading)
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: CircleAvatar(
                                            radius: 45,
                                            backgroundColor: Colors.redAccent,
                                            child: CircleAvatar(
                                              radius: 40,
                                              backgroundColor: Colors.white,
                                              child: Icon(Icons.person,
                                                  size: 50,
                                                  color: Colors.black),
                                            ),
                                          )),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),
                                        Text(
                                          "Good " + greeting() + " , ",
                                          style: TextStyle(fontSize: 17),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          fullName,
                                          style: TextStyle(
                                              fontSize: 16.5,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                pendingList.isEmpty
                                    ? Container(
                                        height: 15,
                                        color: Colors.amberAccent,
                                        child: Text(" No Pending appointment"),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                              "Pending Requests",
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                "Accept the Appointment as soon it comes. Appointment are assigned on first accepted basis.",
                                                style: TextStyle(
                                                    fontSize: 15.5,
                                                    color: Colors.black
                                                        .withOpacity(0.7)),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            pendingList.isNotEmpty
                                                ? CarouselSlider(
                                                    options: CarouselOptions(
                                                      autoPlayAnimationDuration:
                                                          Duration(seconds: 1),
                                                      autoPlay: true,
                                                      enableInfiniteScroll:
                                                          false,
                                                      height: 220,
                                                    ),
                                                    items: pendingList
                                                        .map(
                                                          (item) =>
                                                              GestureDetector(
                                                            onTap: () async {
                                                              bool isDone =
                                                                  await Navigator.of(
                                                                          context)
                                                                      .push(
                                                                PageRouteBuilder(
                                                                  transitionDuration:
                                                                      Duration(
                                                                          seconds:
                                                                              0),
                                                                  pageBuilder: (_,
                                                                          __,
                                                                          ___) =>
                                                                      OrderScreen(
                                                                    notaryId:
                                                                        userInfo[
                                                                            '_id'],
                                                                    orderId: item[
                                                                        "id"],
                                                                    isPending:
                                                                        true,
                                                                  ),
                                                                ),
                                                              );
                                                              try {
                                                                if (!isDone) {
                                                                  pendingList
                                                                      .remove(
                                                                          item);
                                                                  updatePending(
                                                                      pendingList
                                                                          .length);
                                                                  setState(
                                                                      () {});
                                                                }
                                                              } catch (e) {}
                                                            },
                                                            child: ConfirmCards(
                                                              // imageUrl:
                                                              //     "assets/userr.png", // Change to url
                                                              address: item[
                                                                  "address"],
                                                              name:
                                                                  item["name"],

                                                              notaryId:
                                                                  userInfo[
                                                                      '_id'],
                                                              orderId:
                                                                  item["id"],
                                                              refresh:
                                                                  getPending,
                                                              place: item[
                                                                  "address"],
                                                              time: item['time']
                                                                  .toString(),
                                                              date:
                                                                  item['date'],
                                                              closeType: item[
                                                                  'closingType'],
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                  )
                                                : Container(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
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
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      20.0),
                                                          child: Text(
                                                            "You don't have any pending requests",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.8),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      40.0),
                                                          child: Text(
                                                            "Tip: Accept Appointments as soon you receive message",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 15.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ]),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Today's Appointment $totalAppointment",
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          PageRouteBuilder(
                                            transitionDuration:
                                                Duration(seconds: 0),
                                            pageBuilder: (context, animation1,
                                                    animation2) =>
                                                CalenderScreen(
                                                    notaryId: userInfo['_id']),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "View All",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  child: (appointmentList.isNotEmpty)
                                      ? ListView.builder(
                                          itemBuilder: (context, index) {
                                            print(DateTime.parse(
                                                    appointmentList[index]
                                                        ['date'])
                                                .toLocal());
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Cards(
                                                notaryName: fullName,
                                                notaryId: userInfo['_id'],
                                                orderId: appointmentList[index]
                                                    ['orderId'],
                                                name: appointmentList[index]
                                                    ['name'],
                                                place: appointmentList[index]
                                                    ['place'],
                                                time: formatDate(
                                                    DateTime.parse(
                                                      appointmentList[index]
                                                          ['date'],
                                                    ).toLocal(),
                                                    [
                                                      'mm',
                                                      '/',
                                                      'dd',
                                                      '/',
                                                      'yyyy',
                                                      ' ',
                                                      '@',
                                                      ' ',
                                                      'hh',
                                                      ':',
                                                      'nn',
                                                      ' ',
                                                      'am'
                                                    ]),
                                                phone: appointmentList[index]
                                                    ['phone'].toString(),
                                                // imageUrl: appointmentList[index]
                                                //     ["logo"],
                                              ),
                                            );
                                          },
                                          shrinkWrap: true,
                                          physics: BouncingScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          itemCount: appointmentList.length,
                                        )
                                      : Container(
                                          child: Container(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 30,
                                                ),
                                                Image.asset(
                                                  "assets/appointment.png",
                                                  height: 100,
                                                  width: 100,
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 30.0),
                                                  child: Text(
                                                    "You don't have any appointments for today.",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black
                                                            .withOpacity(0.8),
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 17,
                              width: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Please Wait ...",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          ProgressScreen(
            penList: pendingList,
            userI: userInfo,
            notaryId: userInfo.isNotEmpty ? userInfo['_id'] : "",
          ),
          AmountScreen(
            notaryId: userInfo.isNotEmpty ? userInfo['_id'] : "",
          ),
          UserProfile(
            notaryId: userInfo.isNotEmpty ? userInfo['_id'] : "",
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// appointmentList.isNotEmpty
//                                     ? Container(
//                                         height:
//                                             appointmentList.isEmpty ? 0 : 150,
//                                         child: (appointmentList.isEmpty)
//                                             ? Container()
//                                             : ListView.builder(
//                                                 itemBuilder: (context, index) {
//                                                   return Cards(
//                                                     notaryId: userInfo['notary']
//                                                         ['_id'],
//                                                     orderId:
//                                                         appointmentList[index]
//                                                             ['orderId'],
//                                                     name: appointmentList[index]
//                                                         ['name'],
//                                                     place:
//                                                         appointmentList[index]
//                                                             ['place'],
//                                                     time: DateFormat("h:mm a")
//                                                         .format(
//                                                       DateTime.parse(
//                                                         appointmentList[index]
//                                                             ['date'],
//                                                       ).toLocal(),
//                                                     ),
//                                                     phone:
//                                                         appointmentList[index]
//                                                             ['phone'],
//                                                     imageUrl:
//                                                         appointmentList[index]
//                                                             ["logo"],
//                                                   );
//                                                 },
//                                                 shrinkWrap: true,
//                                                 physics:
//                                                     BouncingScrollPhysics(),
//                                                 scrollDirection: Axis.vertical,
//                                                 itemCount:
//                                                     appointmentList.length,
//                                               ),
//                                       )
//                                     : Container(
//                                         child: Column(
//                                           mainAxisSize: MainAxisSize.max,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.center,
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             SizedBox(
//                                               height: 30,
//                                             ),
//                                             Image.asset(
//                                               "assets/appointment.png",
//                                               height: 100,
//                                               width: 100,
//                                             ),
//                                             SizedBox(
//                                               height: 20,
//                                             ),
//                                             Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 30.0),
//                                               child: Text(
//                                                 "You don't have any appointments for today.",
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                     fontSize: 16,
//                                                     color: Colors.black
//                                                         .withOpacity(0.8),
//                                                     fontWeight:
//                                                         FontWeight.w700),
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               height: 20,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
