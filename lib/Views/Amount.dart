import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:myknott/Config/CustomColors.dart';
import 'package:myknott/Services/Services.dart';
import 'package:myknott/Views/OrderScreen.dart';

class AmountScreen extends StatefulWidget {
  final String notaryId;

  const AmountScreen({Key key, this.notaryId}) : super(key: key);
  @override
  _AmountScreenState createState() => _AmountScreenState();
}

class _AmountScreenState extends State<AmountScreen>
    with AutomaticKeepAliveClientMixin<AmountScreen> {
  final Color blueColor = CustomColor().blueColor;
  Map map = {};
  int i = 0;
  int totalpage = 0;
  bool hasMore = false;
  bool isloading = true;
  @override
  void initState() {
    NotaryServices().getToken();
    getData();
    super.initState();
  }

  getData() async {
    map.clear();
    setState(() {
      i = 0;
      isloading = true;
      hasMore = false;
    });
    map = await NotaryServices().getEarnings(widget.notaryId, i);
    if (i == map['pageNumber']) {
      hasMore = true;
    }
    i += 1;

    setState(() {
      totalpage = map['pageNumber'];
      isloading = false;
    });
  }

  getmoreData() async {
    var response = await NotaryServices().getEarnings(widget.notaryId, i);
    // print("Inside getMore Data");
    // List payouts = map['payouts'];
    // print(payouts);
    if (map['payouts'] != null && map['customers'] != null) {
      map['payouts'].addAll(response['payouts']);
      map['customers'].addAll(response['customers']);
    }
    if (response['pageCount'] == response['pageNumber']) {
      hasMore = true;
    } else {
      i = i + 1;
    }
    setState(() {});
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Notary Pay",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
      ),
      body: !isloading
          ? LazyLoadScrollView(
              onEndOfPage: getmoreData,
              isLoading: hasMore,
              child: RefreshIndicator(
                color: Colors.black,
                onRefresh: () => getData(),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: SafeArea(
                    child: map['payouts'].isNotEmpty
                        ? ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Card(
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          'assets/wallet.png',
                                          width: 90,
                                          height: 90,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Total Earnings ",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                  width: 42,
                                                ),
                                                Text(
                                                  ":  \$ ${map['totalAmount']}",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Pending Earnings ",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Text(
                                                  ":  \$ ${map['dueAmount']}",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: map['payouts'].length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 2),
                                    child: InkWell(
                                      hoverColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () => Navigator.of(context).push(
                                        PageRouteBuilder(
                                          transitionDuration:
                                              Duration(seconds: 0),
                                          pageBuilder: (_, __, ___) =>
                                              OrderScreen(
                                            isPending: false,
                                            notaryId: widget.notaryId,
                                            orderId: map['payouts'][index]
                                                ['order']['_id'],
                                          ),
                                        ),
                                      ),
                                      child: Card(
                                        elevation: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0,
                                            vertical: 2,
                                          ),
                                          child: ListTile(
                                            leading: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: map['customers'][index]
                                                          ['userImageURL'] !=
                                                      null
                                                  ? CachedNetworkImage(
                                                      imageUrl:
                                                          "${map['customers'][index]['userImageURL']}",
                                                      height: 45,
                                                      width: 45,
                                                    )
                                                  : Container(
                                                      height: 0,
                                                      width: 0,
                                                    ),
                                            ),
                                            isThreeLine: true,
                                            title: Text(
                                              map['payouts'][index]['order']
                                                          ['orderClosingType']
                                                      .toString()[0]
                                                      .toUpperCase() +
                                                  map['payouts'][index]['order']
                                                          ['orderClosingType']
                                                      .toString()
                                                      .substring(1) +
                                                  " Closing",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            contentPadding: EdgeInsets.only(
                                                left: 0.0, right: 0.0),
                                            trailing: map['payouts'][index]
                                                    ['paid']
                                                ? MaterialButton(
                                                    elevation: 0,
                                                    hoverElevation: 0,
                                                    highlightElevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    color: blueColor,
                                                    onPressed: () {},
                                                    child: Container(
                                                      child: Text(
                                                        "Paid",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16.5,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      ),
                                                    ),
                                                  )
                                                : MaterialButton(
                                                    minWidth: 0,
                                                    elevation: 0,
                                                    hoverElevation: 0,
                                                    highlightElevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    color: Color(0xffFde50E),
                                                    onPressed: () {},
                                                    child: Container(
                                                      child: Text(
                                                        "Pending",
                                                        style: TextStyle(
                                                            color: Colors.black
                                                                .withOpacity(
                                                              1,
                                                            ),
                                                            fontSize: 16.5,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      ),
                                                    ),
                                                  ),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "#${map['payouts'][index]['appointment']['escrowNumber']}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    "Property Address",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    map['payouts'][index]
                                                            ['appointment']
                                                        ['propertyAddress'],
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  FittedBox(
                                                    child: Text(
                                                      "Appointment Completed",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    DateFormat("MM/dd/yyyy")
                                                        .format(
                                                      DateTime.parse(
                                                        map['payouts'][index]
                                                            ['updatedAt'],
                                                      ).toLocal(),
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            ],
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height -
                                AppBar().preferredSize.height -
                                56,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/salary.svg",
                                  height: 100,
                                  width: 100,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30.0),
                                  child: Text(
                                    "You don't have any payment history",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.black.withOpacity(0.8),
                                        fontWeight: FontWeight.w700),
                                  ),
                                )
                              ],
                            ),
                          ),
                  ),
                ),
              ))
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}