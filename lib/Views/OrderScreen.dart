import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:future_button/future_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myknott/Config/CustomColors.dart';
import 'package:myknott/Views/ChatScreen.dart';
import 'package:myknott/Views/DocumentScreen.dart';
import 'package:myknott/Views/MapScreen.dart';
import 'package:myknott/Services/Services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timelines/timelines.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderScreen extends StatefulWidget {
  final String orderId;
  final String notaryId;
  final bool isPending;
  final bool messageTrigger;
  const OrderScreen(
      {Key key,
      this.orderId,
      this.notaryId,
      this.isPending,
      this.messageTrigger = false})
      : super(key: key);
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with TickerProviderStateMixin {
  final Color blueColor = CustomColor().blueColor;
  Dio dio = Dio();
  bool isloading = false;
  bool isuploading = false;
  bool arrivedtoAppointment = false;
  bool sigingComplete = false;
  bool isPending;
  bool documentDelivered = false;
  bool documentsDownloaded = false;
  bool signerContacted = false;
  bool istrigger = false;
  final Map orders = Map();
  final List<Map> docsByNotary = [];
  final storage = FlutterSecureStorage();
  TabController tabController;
  List list = [];
  final NotaryServices notaryServices = NotaryServices();

  @override
  void initState() {
    NotaryServices().getToken();
    tabController = TabController(
        length: 4, vsync: this, initialIndex: widget.messageTrigger ? 1 : 0);
    getData();
    super.initState();
  }

  getData() async {
    try {
      setState(() {});
      String jwt = await storage.read(key: 'jwt');
      dio.options.headers['Authorization'] = jwt;
      var body = {"notaryId": widget.notaryId, "orderId": widget.orderId};
      var response = await dio
          .post(notaryServices.baseUrl + "notary/getOrderDetails/", data: body);
      orders.clear();
      docsByNotary.clear();
      orders.addAll(response.data);

      response.data.forEach((key, value) {
        print("key : $key , value : $value");
      });
      for (var i in orders['order']['uploadedDocuments']) {
        if (i['uploadedBy'] == widget.notaryId) {
          docsByNotary.add(i);
        }
      }
      setState(() {});
    } catch (e) {
      print("Error 87 orderscreen ");
      print(e);
      print("----------");
      if (this.mounted) {
        Fluttertoast.showToast(
            msg: "Something 87 went wrong..",
            backgroundColor: blueColor,
            fontSize: 16,
            textColor: Colors.white,
            gravity: ToastGravity.SNACKBAR);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool ispending = isPending ?? widget.isPending;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(isPending);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Order Details",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700, fontSize: 19),
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop(isPending);
              }),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData().copyWith(color: Colors.black),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: TabBar(
              physics: BouncingScrollPhysics(),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black.withOpacity(0.7),
              controller: tabController,
              isScrollable: true,
              indicatorColor: blueColor,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  child: Text(
                    "Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                Tab(
                  child: Text(
                    "Chat",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                Tab(
                  child: Text(
                    "Documents",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                Tab(
                  child: Text(
                    "Signing Location",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            (orders.isEmpty)
                ? Center(
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
                  )
                : SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            ispending
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      //     FutureFlatButton(
                                      //       disabledColor: Colors.yellow,
                                      //       progressIndicatorBuilder: (context) =>
                                      //           SizedBox(
                                      //         height: 17,
                                      //         width: 17,
                                      //         child: Center(
                                      //           child: CircularProgressIndicator(
                                      //             valueColor:
                                      //                 AlwaysStoppedAnimation<Color>(
                                      //               Colors.black.withOpacity(0.5),
                                      //             ),
                                      //             strokeWidth: 2,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       onPressed: () async {
                                      //         await NotaryServices().declineNotary(
                                      //             widget.notaryId, widget.orderId);
                                      //         Navigator.of(context).pop(false);
                                      //       },
                                      //       shape: RoundedRectangleBorder(
                                      //         borderRadius:
                                      //             BorderRadius.circular(5),
                                      //       ),
                                      //       color: Colors.yellow,
                                      //       child: Text(
                                      //         "Reject",
                                      //         style: TextStyle(
                                      //             color:
                                      //                 Colors.black.withOpacity(1),
                                      //             fontSize: 15.5,
                                      //             fontWeight: FontWeight.bold),
                                      //       ),
                                      //     ),
                                      //     FutureFlatButton(
                                      //       disabledColor: blueColor,
                                      //       progressIndicatorBuilder: (context) =>
                                      //           SizedBox(
                                      //         height: 17,
                                      //         width: 17,
                                      //         child: Center(
                                      //           child: CircularProgressIndicator(
                                      //             valueColor:
                                      //                 AlwaysStoppedAnimation<Color>(
                                      //               Colors.white,
                                      //             ),
                                      //             strokeWidth: 2,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       onPressed: () async {
                                      //         bool success = await NotaryServices()
                                      //             .acceptNotary(widget.notaryId,
                                      //                 widget.orderId);
                                      //         Fluttertoast.showToast(
                                      //             msg: success
                                      //                 ? "Order accepted."
                                      //                 : "Can't accept order now.",
                                      //             backgroundColor: blueColor,
                                      //             fontSize: 16,
                                      //             textColor: Colors.white,
                                      //             gravity: ToastGravity.SNACKBAR);
                                      //         if (success) {
                                      //           setState(() {
                                      //             isPending = false;
                                      //           });
                                      //         }
                                      //       },
                                      //       shape: RoundedRectangleBorder(
                                      //         borderRadius:
                                      //             BorderRadius.circular(5),
                                      //       ),
                                      //       color: blueColor,
                                      //       child: Text(
                                      //         "Accept",
                                      //         style: TextStyle(
                                      //             color: Colors.white,
                                      //             fontSize: 15.5,
                                      //             fontWeight: FontWeight.bold),
                                      //       ),
                                      //     )
                                    ],
                                  )
                                : Container(),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Order Status",
                                  style: TextStyle(
                                    color: blueColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                changeStatus(context, ispending),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              height: orders['order']['confirmedAt'] != null
                                  ? 120
                                  : 80,
                              child: Center(
                                child: ListView(
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width +
                                          160,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width +
                                                150,
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 30,
                                                ),
                                                orders['order']
                                                            ['confirmedAt'] !=
                                                        null
                                                    ? DotIndicator(
                                                        color: blueColor,
                                                      )
                                                    : OutlinedDotIndicator(
                                                        color: blueColor,
                                                      ),

                                                Container(
                                                  color: blueColor,
                                                  height: 3.0,
                                                  width: 100.0,
                                                ),

                                                orders['order'][
                                                            'docsDownloadedAt'] !=
                                                        null
                                                    ? DotIndicator(
                                                        color: blueColor,
                                                      )
                                                    : OutlinedDotIndicator(
                                                        color: blueColor,
                                                      ),

                                                //
                                                Container(
                                                  color: blueColor,
                                                  height: 3.0,
                                                  width: 100.0,
                                                ),

                                                orders['order'][
                                                            'notaryArrivedAt'] ==
                                                        null
                                                    ? OutlinedDotIndicator(
                                                        color: blueColor,
                                                      )
                                                    : DotIndicator(
                                                        color: blueColor,
                                                      ),

                                                //
                                                Container(
                                                  color: blueColor,
                                                  height: 3.0,
                                                  width: 100.0,
                                                ),

                                                orders['order'][
                                                            'signingCompletedAt'] ==
                                                        null
                                                    ? OutlinedDotIndicator(
                                                        color: blueColor,
                                                      )
                                                    : DotIndicator(
                                                        color: blueColor,
                                                      ),
                                                Container(
                                                  color: blueColor,
                                                  height: 3.0,
                                                  width: 100.0,
                                                ),

                                                //
                                                orders['order']
                                                            ['deliveredAt'] ==
                                                        null
                                                    ? OutlinedDotIndicator(
                                                        color: blueColor,
                                                      )
                                                    : DotIndicator(
                                                        color: blueColor,
                                                      ),
                                              ],
                                              // shrinkWrap: true,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    width: 90,
                                                    child: Text(
                                                      "Signer Contacted",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 14.5),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  orders['order']
                                                              ['confirmedAt'] !=
                                                          null
                                                      ? Container(
                                                          width: 90,
                                                          child: Text(
                                                            DateFormat(
                                                              "MM/dd/yyyy hh:mm a",
                                                            ).format(
                                                              DateTime.parse(
                                                                orders['order'][
                                                                    'confirmedAt'],
                                                              ).toLocal(),
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 14.5),
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                              //
                                              Column(
                                                children: [
                                                  Container(
                                                    width: 120,
                                                    child: Text(
                                                      "Documents Downloaded",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 14.5),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  orders['order'][
                                                              'docsDownloadedAt'] !=
                                                          null
                                                      ? Container(
                                                          width: 90,
                                                          child: Text(
                                                            DateFormat(
                                                              "MM/dd/yyyy hh:mm a",
                                                            ).format(
                                                              DateTime.parse(
                                                                orders['order'][
                                                                    'docsDownloadedAt'],
                                                              ).toLocal(),
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 14.5),
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                              //
                                              Column(
                                                children: [
                                                  Container(
                                                    width: 120,
                                                    child: Text(
                                                      "Arrived to Appointment",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 14.5),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  orders['order'][
                                                              'notaryArrivedAt'] !=
                                                          null
                                                      ? Container(
                                                          width: 90,
                                                          child: Text(
                                                            DateFormat(
                                                              "MM/dd/yyyy hh:mm a",
                                                            ).format(
                                                              DateTime.parse(
                                                                orders['order'][
                                                                    'notaryArrivedAt'],
                                                              ).toLocal(),
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 14.5),
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                    width: 100,
                                                    child: Text(
                                                      "Signing Completed",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 14.5),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  orders['order'][
                                                              'signingCompletedAt'] !=
                                                          null
                                                      ? Container(
                                                          width: 90,
                                                          child: Text(
                                                            DateFormat(
                                                              "MM/dd/yyyy hh:mm a",
                                                            ).format(
                                                              DateTime.parse(
                                                                orders['order'][
                                                                    'signingCompletedAt'],
                                                              ).toLocal(),
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 14.5),
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                    width: 120,
                                                    child: Text(
                                                      "Documents Delivered",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 14.5),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  orders['order']
                                                              ['deliveredAt'] !=
                                                          null
                                                      ? Container(
                                                          width: 90,
                                                          child: Text(
                                                            DateFormat(
                                                              "MM/dd/yyyy hh:mm a",
                                                            ).format(
                                                              DateTime.parse(
                                                                orders['order'][
                                                                    'deliveredAt'],
                                                              ).toLocal(),
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 14.5),
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            sigingLocation(context),
                            SizedBox(height: 10),
                            sigerDetails(context),
                            SizedBox(height: 10),
                            uploadedByNotary(context),
                            SizedBox(height: 10),
                            uploadDocs(context, ispending),
                            SizedBox(height: 10),
                            orderInfo(context),
                            SizedBox(height: 10),
                            companyDetails(context),
                          ],
                        ),
                      ),
                    ),
                  ),
            orders.isNotEmpty
                ?

                //ChatScreen(
                //     notaryId: widget.notaryId,
                //     chatRoom: orders['order']['chatroom'],
                //   )
                Container()
                : Container(),
            orders.isNotEmpty
                ? DocumentScreen(
                    documents: orders['order']['uploadedDocuments'] ?? [],
                    notaryId: widget.notaryId,
                  )
                : Container(),
            MapScreen(
              orderInfo: orders,
            ),
          ],
        ),
      ),
    );
  }

  Widget companyDetails(cobtext) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    "assets/location_company.png",
                    height: 40,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Title Company & Agent Information",
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  "Company Name",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.8), fontSize: 17),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  ": ${orders['order']['customer']['companyName']}",
                  style: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w400,
                    fontSize: 17.5,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  "First Name",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.8), fontSize: 17),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  ": ${orders['order']['customer']['firstName']}",
                  style: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w400,
                    fontSize: 17.5,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  "Last Name",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.8), fontSize: 17),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  ": ${orders['order']['customer']['lastName']}",
                  style: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w400,
                    fontSize: 17.5,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  "Phone Number",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.8), fontSize: 17),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  ": ${orders['order']['customer']['phoneNumber']}",
                  style: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w400,
                    fontSize: 17.5,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  "Email",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.8), fontSize: 17),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  ": ${orders['order']['customer']['email'] ?? "none"}",
                  style: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w400,
                    fontSize: 17.5,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 17,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Address",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.8), fontSize: 17),
                ),
                SizedBox(
                  width: 15,
                ),
                Flexible(
                  child: Text(
                    ": ${orders['order']['customer']['companyAddress']}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      // fontWeight: FontWeight.w400,
                      fontSize: 17.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget uploadDocs(BuildContext context, bool isPending) {
    return MaterialButton(
      elevation: 0,
      color: blueColor,
      child: Center(
        child: Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (isuploading)
                  ? SizedBox(
                      height: 15,
                      width: 15,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Container(),
              (isuploading) ? SizedBox(width: 10) : Container(),
              !isuploading
                  ? Text(
                      "Upload Documents",
                      style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )
                  : Text(
                      "Uploading... ",
                      style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
            ],
          ),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      onPressed: () {
        if (!isPending) {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            builder: (context) => ClipRRect(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text(
                          "Upload Documents",
                          style: TextStyle(
                              fontSize: 16.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.camera_alt,
                          size: 26,
                        ),
                        title: Text(
                          "Camera",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onTap: () async {
                          PermissionStatus permissionStatus =
                              await Permission.camera.request();
                          if (permissionStatus.isGranted) {
                            final picker = ImagePicker();
                            File _image;
                            final pickedFile = await picker.getImage(
                                source: ImageSource.camera);
                            Navigator.of(context).pop();

                            setState(() {
                              isuploading = true;
                              if (pickedFile != null) {
                                _image = File(pickedFile.path);
                              } else {}
                            });
                            try {
                              await NotaryServices().uploadImageToAPINew(
                                  _image, widget.notaryId, widget.orderId);
                              await getData();
                              Fluttertoast.showToast(
                                  msg: "Documents uploaded Successfully.",
                                  backgroundColor: blueColor,
                                  fontSize: 16,
                                  textColor: Colors.white,
                                  gravity: ToastGravity.SNACKBAR);
                            } catch (e) {}
                            setState(() {
                              isuploading = false;
                            });
                          } else if (permissionStatus.isPermanentlyDenied) {
                            openAppSettings();
                          } else {
                            await Permission.camera.request();
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.file_upload, size: 26),
                        onTap: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: [
                              'jpg',
                              'pdf',
                              'doc',
                              'txt',
                              'png'
                            ],
                          );
                          File _image;
                          if (result != null) {
                            PlatformFile file = result.files.first;
                            setState(() {
                              isuploading = true;

                              _image = File(file.path);
                            });
                          } else {}
                          Navigator.of(context).pop();
                          try {
                            await NotaryServices().uploadImageToAPINew(
                                _image, widget.notaryId, widget.orderId);
                            await getData();
                            Fluttertoast.showToast(
                                msg: "Documents uploaded Successfully.",
                                backgroundColor: blueColor,
                                fontSize: 16,
                                textColor: Colors.white,
                                gravity: ToastGravity.SNACKBAR);
                          } catch (e) {}
                          setState(() {
                            isuploading = false;
                          });
                        },
                        title: Text(
                          "Documents",
                          style: TextStyle(
                              fontSize: 16.5, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          Fluttertoast.showToast(
              msg: "Accept order to upload documents.",
              backgroundColor: blueColor,
              fontSize: 16,
              textColor: Colors.white,
              gravity: ToastGravity.BOTTOM);
        }
      },
    );
  }

  Widget orderInfo(context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/info.png",
                  height: 45,
                ),
                SizedBox(
                  width: 7,
                ),
                Text(
                  "Order Information",
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  "Closing Type",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.8), fontSize: 17),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  ": ${orders['order']['orderClosingType'].toString().replaceRange(0, 1, orders['order']['orderClosingType'][0].toString().toUpperCase())}",
                  style: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w400,
                    fontSize: 17.5,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  "Escrow #",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.8), fontSize: 17),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  ": ${orders['order']['appointment']['escrowNumber']}",
                  style: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w400,
                    fontSize: 17.5,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  "Order Type",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.8), fontSize: 17),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  ": ${orders['order']['orderInvoiceType'].toString().replaceRange(0, 1, orders['order']['orderInvoiceType'][0].toString().toUpperCase())}" ==
                          ": Inhouse"
                      ? ": In-office"
                      : ": ${orders['order']['orderInvoiceType'].toString().replaceRange(0, 1, orders['order']['orderInvoiceType'][0].toString().toUpperCase())}",
                  style: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w400,
                    fontSize: 17.5,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            orders['order']['appointment']['closingInstructions'] != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Closing Instructions : ",
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.8), fontSize: 17),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Flexible(
                        child: Text(
                          "${orders['order']['appointment']['closingInstructions'].toString().replaceRange(0, 1, orders['order']['appointment']['closingInstructions'][0].toString().toUpperCase())}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                            // fontWeight: FontWeight.w400,
                            fontSize: 17.5,
                          ),
                        ),
                      )
                    ],
                  )
                : Container(),
            orders['order']['appointment']['closingInstructions'] != null
                ? SizedBox(
                    height: 20,
                  )
                : Container(),
            orders['order']['appointment']['instructFlag'] != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Closing Alert(s) : ",
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.8), fontSize: 17),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text(
                          "${orders['order']['appointment']['instructFlag'].toString().replaceRange(0, 1, orders['order']['appointment']['instructFlag'][0].toString().toUpperCase())}",
                          style: TextStyle(
                            color: Colors.black,
                            // fontWeight: FontWeight.w400,
                            fontSize: 17.5,
                          ),
                        ),
                      )
                    ],
                  )
                : Container(),
            orders['order']['appointment']['instructFlag'] != null
                ? SizedBox(
                    height: 20,
                  )
                : Container(),
            Row(
              children: [
                Text(
                  "Earning Amount",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.8), fontSize: 17),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  "\$ ${orders['order']['payAmnt']}",
                  style: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w400,
                    fontSize: 17.5,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Property Address : ",
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.8),
                    fontSize: 17,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: Text(
                    orders['order']['appointment']['propertyAddress'],
                    // textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget sigerDetails(context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/avatar.png",
                  height: 40,
                ),
                SizedBox(
                  width: 7,
                ),
                Text(
                  "Signer Details",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  "Signer Name",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.8), fontSize: 17),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  ": ${orders['order']['appointment']['signerFullName']}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.5,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Signer Phone Number :",
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.8), fontSize: 17),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Row(children: [
                      Text(
                        "${orders['order']['appointment']['signerPhoneNumber']}",
                        style: TextStyle(
                          color: Colors.black,
                          // fontWeight: FontWeight.w400,
                          fontSize: 17.5,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await launch(
                              "tel:${orders['order']['appointment']['signerPhoneNumber']}");
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                            radius: 17,
                            backgroundColor: blueColor,
                            child: Icon(
                              Icons.phone,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await launch(
                              "tel:${orders['order']['appointment']['signerPhoneNumber']}");
                        },
                        child: Image.asset(
                          "assets/chat.png",
                          height: 36,
                        ),
                      )
                    ]),
                  ],
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Row(
              children: [],
            ),
            SizedBox(
              height: 10,
            ),
            orders['order']['appointment']['signerAddress'] != null
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Address",
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.8), fontSize: 17),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Flexible(
                        child: Text(
                          "${orders['order']['appointment']['signerAddress']}",
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontSize: 17),
                        ),
                      ),
                    ],
                  )
                : Container(),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget sigingLocation(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: () async {
          try {
            var latitude = orders['order']['appointment']['latitude'];
            var longitude = orders['order']['appointment']['longitude'];
            String googleUrl =
                'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
            if (await canLaunch(googleUrl)) {
              await launch(googleUrl);
            } else {
              Fluttertoast.showToast(
                  msg: "Can't open Maps.",
                  backgroundColor: blueColor,
                  fontSize: 16,
                  textColor: Colors.white,
                  gravity: ToastGravity.SNACKBAR);
            }
          } catch (e) {
            print("Error on 1436 OrderS : $e");
            Fluttertoast.showToast(
                msg: "Something 1436 went wrong.",
                backgroundColor: blueColor,
                fontSize: 16,
                textColor: Colors.white,
                gravity: ToastGravity.SNACKBAR);
          }
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  child: Container(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Image.asset(
                            "assets/location.png",
                            height: 50,
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            "Signing Location",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Address",
                          style: TextStyle(
                              fontSize: 17, color: Colors.grey.shade700),
                        ),
                        SizedBox(
                          child: Text(
                            orders['order']['appointment']['place'] ??
                                "" + "    ",
                            textAlign: TextAlign.start,
                            // maxLines: ,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade700),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Date: " +
                              DateFormat("MM/dd/yyyy").format(
                                DateTime.parse(
                                  orders["order"]["appointment"]["time"],
                                ).toLocal(),
                              ),
                          style: TextStyle(
                            fontSize: 16,
                            // color: Colors.grey.shade700),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Time: " +
                              DateFormat("h:mm a").format(
                                DateTime.parse(
                                  orders["order"]["appointment"]["time"],
                                ).toLocal(),
                              ),
                          style: TextStyle(
                            fontSize: 16,
                            // color: Colors.grey.shade700),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget uploadedByNotary(context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Documents Uploaded By Notary",
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: docsByNotary.length == 0 ? 1 : docsByNotary.length,
              itemBuilder: (context, index) {
                if (docsByNotary.length == 0) {
                  return ListTile(
                    title: Text(
                      "No Documents Uploaded...",
                      style: TextStyle(
                        fontSize: 16.5,
                      ),
                    ),
                  );
                } else
                  return ListTile(
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "${index + 1}.",
                          style: TextStyle(
                            fontSize: 16.5,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Text(
                            docsByNotary[index]['documentName'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: InkWell(
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        await launch(docsByNotary[index]['documentURL']);
                      },
                      child: Text(
                        "View",
                        style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff051c91)),
                      ),
                    ),
                  );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget changeStatus(context, bool isPending) {
    return MaterialButton(
      elevation: 0,
      color: blueColor,
      height: 40,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      onPressed: () {
        if (!isPending) {
          return showModalBottomSheet(
              backgroundColor: Colors.white,
              isScrollControlled: true,
              useRootNavigator: true,
              enableDrag: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              builder: (BuildContext context) {
                return StatefulBuilder(builder: (BuildContext context,
                    void Function(void Function()) setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Change Status",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Card(
                              elevation: 0,
                              child: ListTile(
                                onTap: () {
                                  signerContacted = signerContacted
                                      ? (signerContacted)
                                      : !signerContacted;
                                  sigingComplete = false;
                                  documentDelivered = false;
                                  documentsDownloaded = false;
                                  arrivedtoAppointment = false;
                                  setState(() {});
                                },
                                enabled: orders['order']['confirmedAt'] == null
                                    ? true
                                    : false,
                                title: Text(
                                  "Signer Contacted",
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight:
                                        orders['order']['confirmedAt'] == null
                                            ? FontWeight.w700
                                            : FontWeight.normal,
                                  ),
                                ),
                                trailing: Container(
                                  width: 27,
                                  height: 27,
                                  child: signerContacted
                                      ? Icon(
                                          Icons.check,
                                          size: 22,
                                          color: Colors.white,
                                        )
                                      : Container(),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: !signerContacted
                                          ? Colors.grey
                                          : blueColor,
                                    ),
                                    shape: BoxShape.circle,
                                    color: signerContacted
                                        ? blueColor
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Card(
                              elevation: 0,
                              child: ListTile(
                                onTap: () {
                                  documentsDownloaded = documentsDownloaded
                                      ? (documentsDownloaded)
                                      : !documentsDownloaded;
                                  sigingComplete = false;
                                  documentDelivered = false;
                                  arrivedtoAppointment = false;
                                  signerContacted = false;
                                  setState(() {});
                                },
                                enabled:
                                    orders['order']['docsDownloadedAt'] == null
                                        ? true
                                        : false,
                                title: Text(
                                  "Documents Downloaded",
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: orders['order']
                                                ['docsDownloadedAt'] ==
                                            null
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                  ),
                                ),
                                trailing: Container(
                                  width: 27,
                                  height: 27,
                                  child: documentsDownloaded
                                      ? Icon(
                                          Icons.check,
                                          size: 22,
                                          color: Colors.white,
                                        )
                                      : Container(),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: !documentsDownloaded
                                          ? Colors.grey
                                          : blueColor,
                                    ),
                                    shape: BoxShape.circle,
                                    color: documentsDownloaded
                                        ? blueColor
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Card(
                              elevation: 0,
                              child: ListTile(
                                onTap: () {
                                  arrivedtoAppointment = arrivedtoAppointment
                                      ? (arrivedtoAppointment)
                                      : !arrivedtoAppointment;
                                  sigingComplete = false;
                                  documentDelivered = false;
                                  signerContacted = false;

                                  documentsDownloaded = false;
                                  setState(() {});
                                },
                                enabled:
                                    orders['order']['notaryArrivedAt'] == null
                                        ? true
                                        : false,
                                title: Text(
                                  "Arrived to Appointment",
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: orders['order']
                                                ['notaryArrivedAt'] ==
                                            null
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                  ),
                                ),
                                trailing: Container(
                                  width: 27,
                                  height: 27,
                                  child: arrivedtoAppointment
                                      ? Icon(
                                          Icons.check,
                                          size: 22,
                                          color: Colors.white,
                                        )
                                      : Container(),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: !arrivedtoAppointment
                                              ? Colors.grey
                                              : blueColor),
                                      shape: BoxShape.circle,
                                      color: arrivedtoAppointment
                                          ? blueColor
                                          : Colors.transparent),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Card(
                              elevation: 0,
                              child: ListTile(
                                onTap: () {
                                  sigingComplete = sigingComplete
                                      ? (sigingComplete)
                                      : !sigingComplete;
                                  arrivedtoAppointment = false;
                                  documentsDownloaded = false;
                                  documentDelivered = false;
                                  signerContacted = false;
                                  setState(() {});
                                },
                                trailing: Container(
                                  width: 27,
                                  height: 27,
                                  child: sigingComplete
                                      ? Icon(
                                          Icons.check,
                                          size: 22,
                                          color: Colors.white,
                                        )
                                      : Container(),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: !sigingComplete
                                              ? Colors.grey
                                              : blueColor),
                                      shape: BoxShape.circle,
                                      color: sigingComplete
                                          ? blueColor
                                          : Colors.transparent),
                                ),
                                enabled: orders['order']
                                            ['signingCompletedAt'] ==
                                        null
                                    ? true
                                    : false,
                                title: Text(
                                  "Signing Complete",
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: orders['order']
                                                ['signingCompletedAt'] ==
                                            null
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Card(
                              elevation: 0,
                              child: ListTile(
                                onTap: () {
                                  setState(() {
                                    arrivedtoAppointment = false;
                                    sigingComplete = false;
                                    documentsDownloaded = false;
                                    signerContacted = false;
                                    documentDelivered = documentDelivered
                                        ? (documentDelivered)
                                        : !documentDelivered;
                                  });
                                },
                                trailing: Container(
                                  width: 27,
                                  height: 27,
                                  child: documentDelivered
                                      ? Icon(
                                          Icons.check,
                                          size: 22,
                                          color: Colors.white,
                                        )
                                      : Container(),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: !documentDelivered
                                              ? Colors.grey
                                              : blueColor),
                                      shape: BoxShape.circle,
                                      color: documentDelivered
                                          ? blueColor
                                          : Colors.transparent),
                                ),
                                enabled: orders['order']['deliveredAt'] == null
                                    ? true
                                    : false,
                                title: Text(
                                  "Document Delivered",
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight:
                                        orders['order']['deliveredAt'] == null
                                            ? FontWeight.w700
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MaterialButton(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      signerContacted = false;
                                      arrivedtoAppointment = false;
                                      sigingComplete = false;
                                      documentDelivered = false;
                                      documentsDownloaded = false;
                                    });
                                  },
                                  color: Colors.white,
                                  child: Container(
                                    child: Center(
                                      child: Text(
                                        "Back",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
                                      ),
                                    ),
                                    width: 80,
                                    height: 40,
                                  ),
                                ),
                                MaterialButton(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      isloading = true;
                                    });
                                    try {
                                      if (documentsDownloaded) {
                                        await notaryServices
                                            .markDocumentsDownloaded(
                                                widget.notaryId,
                                                widget.orderId);
                                        documentsDownloaded = false;
                                      } else if (arrivedtoAppointment) {
                                        await notaryServices
                                            .markOrderInProgress(
                                                widget.notaryId,
                                                widget.orderId);
                                        arrivedtoAppointment = false;
                                      } else if (sigingComplete) {
                                        await notaryServices
                                            .markSigningCompleted(
                                                widget.notaryId,
                                                widget.orderId);

                                        sigingComplete = false;
                                      } else if (documentDelivered) {
                                        await notaryServices
                                            .markOrderAsDelivered(
                                                widget.notaryId,
                                                widget.orderId);
                                        documentDelivered = false;
                                      } else if (signerContacted) {
                                        await notaryServices
                                            .markOrderAsConfirmed(
                                                widget.notaryId,
                                                widget.orderId);
                                      }
                                      signerContacted = false;
                                    } catch (e) {}
                                    await getData();
                                    setState(() {
                                      isloading = false;
                                    });
                                    Fluttertoast.showToast(
                                        msg:
                                            "Order Status changed successfully.",
                                        backgroundColor: blueColor,
                                        fontSize: 16,
                                        textColor: Colors.white,
                                        gravity: ToastGravity.SNACKBAR);
                                    Navigator.of(context).pop();
                                  },
                                  color: blueColor,
                                  child: Container(
                                    child: Center(
                                      child: isloading
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              ),
                                            )
                                          : Text(
                                              "Update",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                    ),
                                    width: 80,
                                    height: 40,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                });
              },
              context: context);
        } else {
          Fluttertoast.showToast(
              msg: "Accept order to update status.",
              backgroundColor: blueColor,
              fontSize: 16,
              textColor: Colors.white,
              gravity: ToastGravity.BOTTOM);
        }
      },
      child: Text(
        "Change Status",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
