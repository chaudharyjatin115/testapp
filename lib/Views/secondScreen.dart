import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:future_button/future_button.dart';
import 'package:intl/intl.dart';
import 'package:myknott/Views/ChatScreen.dart';
import 'package:myknott/Views/DocumentScreen.dart';
import 'package:myknott/Views/MapScreen.dart';
import 'package:myknott/Services/Services.dart';
import 'package:timelines/timelines.dart';

class SecondScreen extends StatefulWidget {
  final String orderId;
  final String notaryId;
  final bool isPending;
  final bool messageTrigger;
  const SecondScreen(
      {Key key,
      this.orderId,
      this.notaryId,
      this.isPending,
      this.messageTrigger = false})
      : super(key: key);
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen>
    with TickerProviderStateMixin {
  Dio dio = Dio();
  bool isloading = false;
  bool arrivedtoAppointment = false;
  bool sigingComplete = false;
  bool isPending;
  bool documentDelivered = false;
  bool documentsDownloaded = false;
  bool signerContacted = false;
  bool istrigger = false;
  final Map orders = Map();
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
    print("notary Id ${widget.notaryId}");
    print("order Id ${widget.orderId}");
    super.initState();
  }

  getData() async {
    try {
      setState(() {});
      String jwt = await storage.read(key: 'jwt');
      dio.options.headers['Authorization'] = jwt;
      var body = {"notaryId": widget.notaryId, "orderId": widget.orderId};
      var response = await dio.post(
          "https://my-notary-app.herokuapp.com/notary/getOrderDetails/",
          data: body);
      orders.clear();
      orders.addAll(response.data);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          content: Text(
            "Something went wrong...",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool ispending = isPending ?? widget.isPending;
    print(widget.orderId);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Order Details",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 19),
        ),
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
            indicatorColor: Colors.blue.shade700,
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
                                    FutureFlatButton(
                                      disabledColor: Colors.yellow,
                                      // disabledTextColor: ,
                                      progressIndicatorBuilder: (context) =>
                                          SizedBox(
                                        height: 17,
                                        width: 17,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.black.withOpacity(0.5),
                                            ),
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await NotaryServices().declineNotary(
                                            widget.notaryId, widget.orderId);
                                        Navigator.of(context).pop();
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      color: Colors.yellow,
                                      child: Text(
                                        "Decline",
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    FutureFlatButton(
                                      disabledColor: Colors.blue.shade700,
                                      progressIndicatorBuilder: (context) =>
                                          SizedBox(
                                        height: 17,
                                        width: 17,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await NotaryServices().acceptNotary(
                                            widget.notaryId, widget.orderId);
                                        setState(() {
                                          isPending = false;
                                        });
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      color: Colors.blue.shade700,
                                      child: Text(
                                        "Accept",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
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
                                  color: Colors.blue.shade900,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              MaterialButton(
                                elevation: 0,
                                color: Colors.blue.shade700,
                                height: 40,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                onPressed: () {
                                  if (!ispending) {
                                    return showModalBottomSheet(
                                        backgroundColor: Colors.white,
                                        isScrollControlled: true,
                                        useRootNavigator: true,
                                        enableDrag: true,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(builder:
                                              (BuildContext context,
                                                  void Function(void Function())
                                                      setState) {
                                            return Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  100,
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: ListView(
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Image.asset(
                                                                "assets/progress.jpg"),
                                                            Text(
                                                              "Change Status",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
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
                                                              signerContacted =
                                                                  signerContacted
                                                                      ? (signerContacted)
                                                                      : !signerContacted;
                                                              sigingComplete =
                                                                  false;

                                                              documentDelivered =
                                                                  false;
                                                              documentsDownloaded =
                                                                  false;
                                                              arrivedtoAppointment =
                                                                  false;
                                                              setState(() {});
                                                            },
                                                            enabled: orders['order']
                                                                        [
                                                                        'confirmedAt'] ==
                                                                    null
                                                                ? true
                                                                : false,
                                                            title: Text(
                                                              "Signer Contacted",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            trailing: Container(
                                                              width: 30,
                                                              height: 30,
                                                              child: signerContacted
                                                                  ? Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: Colors
                                                                          .white,
                                                                    )
                                                                  : Container(),
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: !signerContacted
                                                                          ? Colors
                                                                              .grey
                                                                          : Colors
                                                                              .blue
                                                                              .shade700),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: signerContacted
                                                                      ? Colors
                                                                          .blue
                                                                          .shade800
                                                                      : Colors
                                                                          .transparent),
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
                                                              documentsDownloaded =
                                                                  documentsDownloaded
                                                                      ? (documentsDownloaded)
                                                                      : !documentsDownloaded;
                                                              sigingComplete =
                                                                  false;
                                                              documentDelivered =
                                                                  false;
                                                              arrivedtoAppointment =
                                                                  false;
                                                              signerContacted =
                                                                  false;
                                                              setState(() {});
                                                            },
                                                            enabled: orders['order']
                                                                        [
                                                                        'docsDownloadedAt'] ==
                                                                    null
                                                                ? true
                                                                : false,
                                                            title: Text(
                                                              "Documents Downloaded",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            trailing: Container(
                                                              width: 30,
                                                              height: 30,
                                                              child: documentsDownloaded
                                                                  ? Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: Colors
                                                                          .white,
                                                                    )
                                                                  : Container(),
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: !documentsDownloaded
                                                                          ? Colors
                                                                              .grey
                                                                          : Colors
                                                                              .blue
                                                                              .shade700),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: documentsDownloaded
                                                                      ? Colors
                                                                          .blue
                                                                          .shade800
                                                                      : Colors
                                                                          .transparent),
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
                                                              arrivedtoAppointment =
                                                                  arrivedtoAppointment
                                                                      ? (arrivedtoAppointment)
                                                                      : !arrivedtoAppointment;
                                                              sigingComplete =
                                                                  false;
                                                              documentDelivered =
                                                                  false;
                                                              signerContacted =
                                                                  false;

                                                              documentsDownloaded =
                                                                  false;
                                                              setState(() {});
                                                            },
                                                            enabled: orders['order']
                                                                        [
                                                                        'notaryArrivedAt'] ==
                                                                    null
                                                                ? true
                                                                : false,
                                                            title: Text(
                                                              "Arrived to appointment",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            trailing: Container(
                                                              width: 30,
                                                              height: 30,
                                                              child: arrivedtoAppointment
                                                                  ? Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: Colors
                                                                          .white,
                                                                    )
                                                                  : Container(),
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: !arrivedtoAppointment
                                                                          ? Colors
                                                                              .grey
                                                                          : Colors
                                                                              .blue
                                                                              .shade700),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: arrivedtoAppointment
                                                                      ? Colors
                                                                          .blue
                                                                          .shade800
                                                                      : Colors
                                                                          .transparent),
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
                                                              sigingComplete =
                                                                  sigingComplete
                                                                      ? (sigingComplete)
                                                                      : !sigingComplete;

                                                              arrivedtoAppointment =
                                                                  false;
                                                              documentsDownloaded =
                                                                  false;
                                                              documentDelivered =
                                                                  false;
                                                              signerContacted =
                                                                  false;

                                                              setState(() {});
                                                            },
                                                            trailing: Container(
                                                              width: 30,
                                                              height: 30,
                                                              child: sigingComplete
                                                                  ? Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: Colors
                                                                          .white,
                                                                    )
                                                                  : Container(),
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: !sigingComplete
                                                                          ? Colors
                                                                              .grey
                                                                          : Colors
                                                                              .blue
                                                                              .shade700),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: sigingComplete
                                                                      ? Colors
                                                                          .blue
                                                                          .shade800
                                                                      : Colors
                                                                          .transparent),
                                                            ),
                                                            enabled: orders['order']
                                                                        [
                                                                        'signingCompletedAt'] ==
                                                                    null
                                                                ? true
                                                                : false,
                                                            title: Text(
                                                              "Signing Complete",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
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
                                                                arrivedtoAppointment =
                                                                    false;
                                                                sigingComplete =
                                                                    false;
                                                                documentsDownloaded =
                                                                    false;
                                                                signerContacted =
                                                                    false;

                                                                documentDelivered =
                                                                    documentDelivered
                                                                        ? (documentDelivered)
                                                                        : !documentDelivered;
                                                              });
                                                            },
                                                            trailing: Container(
                                                              width: 30,
                                                              height: 30,
                                                              child: documentDelivered
                                                                  ? Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: Colors
                                                                          .white,
                                                                    )
                                                                  : Container(),
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: !documentDelivered
                                                                          ? Colors
                                                                              .grey
                                                                          : Colors
                                                                              .blue
                                                                              .shade700),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: documentDelivered
                                                                      ? Colors
                                                                          .blue
                                                                          .shade800
                                                                      : Colors
                                                                          .transparent),
                                                            ),
                                                            enabled: orders['order']
                                                                        [
                                                                        'deliveredAt'] ==
                                                                    null
                                                                ? true
                                                                : false,
                                                            title: Text(
                                                              "Document Delivered",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            MaterialButton(
                                                              elevation: 0,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5)),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                setState(() {
                                                                  signerContacted =
                                                                      false;

                                                                  arrivedtoAppointment =
                                                                      false;
                                                                  sigingComplete =
                                                                      false;
                                                                  documentDelivered =
                                                                      false;
                                                                  documentsDownloaded =
                                                                      false;
                                                                });
                                                              },
                                                              color:
                                                                  Colors.white,
                                                              child: Container(
                                                                child: Center(
                                                                  child: Text(
                                                                    "No",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            17),
                                                                  ),
                                                                ),
                                                                width: 80,
                                                                height: 40,
                                                              ),
                                                            ),
                                                            MaterialButton(
                                                              elevation: 0,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                setState(() {
                                                                  isloading =
                                                                      true;
                                                                });
                                                                try {
                                                                  if (documentsDownloaded) {
                                                                    await notaryServices.markDocumentsDownloaded(
                                                                        widget
                                                                            .notaryId,
                                                                        widget
                                                                            .orderId);
                                                                    documentsDownloaded =
                                                                        false;
                                                                  } else if (arrivedtoAppointment) {
                                                                    await notaryServices.markOrderInProgress(
                                                                        widget
                                                                            .notaryId,
                                                                        widget
                                                                            .orderId);
                                                                    arrivedtoAppointment =
                                                                        false;
                                                                  } else if (sigingComplete) {
                                                                    await notaryServices.markSigningCompleted(
                                                                        widget
                                                                            .notaryId,
                                                                        widget
                                                                            .orderId);

                                                                    sigingComplete =
                                                                        false;
                                                                  } else if (documentDelivered) {
                                                                    await notaryServices.markOrderAsDelivered(
                                                                        widget
                                                                            .notaryId,
                                                                        widget
                                                                            .orderId);
                                                                    documentDelivered =
                                                                        false;
                                                                  } else if (signerContacted) {
                                                                    await notaryServices.markOrderAsConfirmed(
                                                                        widget
                                                                            .notaryId,
                                                                        widget
                                                                            .orderId);
                                                                  }
                                                                  signerContacted =
                                                                      false;
                                                                } catch (e) {
                                                                  print(e);
                                                                }
                                                                await getData();
                                                                setState(() {
                                                                  isloading =
                                                                      false;
                                                                });
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              color: Colors.blue
                                                                  .shade800,
                                                              child: Container(
                                                                child: Center(
                                                                  child: isloading
                                                                      ? SizedBox(
                                                                          height:
                                                                              20,
                                                                          width:
                                                                              20,
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              strokeWidth: 2,
                                                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Text(
                                                                          "Yes Please",
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
                                              ),
                                            );
                                          });
                                        },
                                        context: context);
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
                              )
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            // color: Colors.black,
                            height: 120,
                            child: Center(
                              child: ListView(
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width + 160,
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
                                              orders['order']['confirmedAt'] !=
                                                      null
                                                  ? DotIndicator(
                                                      color:
                                                          Colors.blue.shade900,
                                                    )
                                                  : OutlinedDotIndicator(
                                                      color:
                                                          Colors.blue.shade900,
                                                    ),

                                              Container(
                                                color: Colors.blue.shade700,
                                                height: 3.0,
                                                width: 100.0,
                                              ),

                                              orders['order'][
                                                          'docsDownloadedAt'] !=
                                                      null
                                                  ? DotIndicator(
                                                      color:
                                                          Colors.blue.shade900,
                                                    )
                                                  : OutlinedDotIndicator(
                                                      color:
                                                          Colors.blue.shade900,
                                                    ),

                                              //
                                              Container(
                                                color: Colors.blue.shade700,
                                                height: 3.0,
                                                width: 100.0,
                                              ),

                                              orders['order']
                                                          ['notaryArrivedAt'] ==
                                                      null
                                                  ? OutlinedDotIndicator(
                                                      color:
                                                          Colors.blue.shade900,
                                                    )
                                                  : DotIndicator(
                                                      color:
                                                          Colors.blue.shade900,
                                                    ),

                                              //
                                              Container(
                                                color: Colors.blue.shade700,
                                                height: 3.0,
                                                width: 100.0,
                                              ),

                                              orders['order'][
                                                          'signingCompletedAt'] ==
                                                      null
                                                  ? OutlinedDotIndicator(
                                                      color:
                                                          Colors.blue.shade900,
                                                    )
                                                  : DotIndicator(
                                                      color:
                                                          Colors.blue.shade900,
                                                    ),
                                              Container(
                                                color: Colors.blue.shade700,
                                                height: 3.0,
                                                width: 100.0,
                                              ),

                                              //
                                              orders['order']['deliveredAt'] ==
                                                      null
                                                  ? OutlinedDotIndicator(
                                                      color:
                                                          Colors.blue.shade900,
                                                    )
                                                  : DotIndicator(
                                                      color:
                                                          Colors.blue.shade900,
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
                                                    textAlign: TextAlign.center,
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
                                                          textAlign:
                                                              TextAlign.center,
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
                                                    textAlign: TextAlign.center,
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
                                                          textAlign:
                                                              TextAlign.center,
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
                                                    textAlign: TextAlign.center,
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
                                                          textAlign:
                                                              TextAlign.center,
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
                                                    textAlign: TextAlign.center,
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
                                                          textAlign:
                                                              TextAlign.center,
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
                                                    textAlign: TextAlign.center,
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
                                                          textAlign:
                                                              TextAlign.center,
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
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Escrow Number :",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      "#" +
                                          orders["order"]["appointment"]
                                                  ["escrowNumber"]
                                              .toString(),
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Amount",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      "\$ ${orders["order"]["amount"]}",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      child: Container(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_pin,
                                              color: Colors.red.shade700,
                                              size: 50,
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: Text(
                                                "Signing Location",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              "Address",
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.grey.shade700),
                                            ),
                                            SizedBox(
                                              child: Text(
                                                orders['order']['appointment']
                                                        ['place'] ??
                                                    "" + "    ",
                                                textAlign: TextAlign.start,
                                                // maxLines: ,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color:
                                                        Colors.grey.shade700),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "Date: " +
                                                  DateFormat("MM/dd/yyyy")
                                                      .format(
                                                    DateTime.parse(
                                                      orders["order"]
                                                              ["appointment"]
                                                          ["time"],
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
                                                      orders["order"]
                                                              ["appointment"]
                                                          ["time"],
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
                          SizedBox(
                            height: 10,
                          ),
                          Card(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/file.jpg",
                                        height: 50,
                                      ),
                                      SizedBox(
                                        width: 5,
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
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            fontSize: 17),
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
                                        "Escrow for this file",
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            fontSize: 17),
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
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            fontSize: 17),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        ": ${orders['order']['orderInvoiceType'].toString().replaceRange(0, 1, orders['order']['orderInvoiceType'][0].toString().toUpperCase())}",
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
                                        "Earning Amount",
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            fontSize: 17),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        "\$ ${orders['order']['amount']}",
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
                                        "Closing Type",
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            fontSize: 17),
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
                                  orders['order']['appointment']
                                              ['closingInstructions'] !=
                                          null
                                      ? SizedBox(
                                          height: 20,
                                        )
                                      : Container(),
                                  orders['order']['appointment']
                                              ['closingInstructions'] !=
                                          null
                                      ? Row(
                                          children: [
                                            Text(
                                              "Closing Instruction",
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.8),
                                                  fontSize: 17),
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Text(
                                              ": ${orders['order']['appointment']['closingInstructions']}",
                                              style: TextStyle(
                                                color: Colors.black,
                                                // fontWeight: FontWeight.w400,
                                                fontSize: 17.5,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          orders['order']['appointment']
                                              ['propertyAddress'],
                                          // textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.8),
                                              fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Card(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/avatar.jpg",
                                        height: 50,
                                      ),
                                      SizedBox(
                                        width: 5,
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
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            fontSize: 17),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        ": ${orders['order']['appointment']['signerFullName']}",
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
                                        "Signer Phone Number",
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            fontSize: 17),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        ": ${orders['order']['appointment']['signerPhoneNumber']}",
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
                                        "Signer Email",
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            fontSize: 17),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        ": ${orders['order']['appointment']['signerEmail'] ?? "none"}",
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
                                  orders['order']['appointment']
                                              ['signerAddress'] !=
                                          null
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Address",
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.8),
                                                  fontSize: 17),
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Flexible(
                                              child: Text(
                                                "${orders['order']['appointment']['signerAddress']}",
                                                style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.8),
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
                          ),
                          Card(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/company.jpg",
                                        height: 50,
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
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            fontSize: 17),
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
                                        "CA First Name",
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            fontSize: 17),
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
                                        "CA Last Name",
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            fontSize: 17),
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
                                        "CA Phone Number",
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            fontSize: 17),
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
                                        "CA Email",
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            fontSize: 17),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Address",
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            fontSize: 17),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          orders.isNotEmpty
              ? ChatScreen(
                  notaryId: widget.notaryId,
                  chatRoom: orders['order']['chatroom'],
                )
              : Container(),
          orders.isNotEmpty
              ? DocumentScreen(
                  documents: orders['order']['uploadedDocuments'] ?? [])
              : Container(),
          MapScreen(
            orderInfo: orders,
          ),
        ],
      ),
    );
  }
}
