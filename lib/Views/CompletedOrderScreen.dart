// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:myknott/Services/Services.dart';
import 'package:myknott/Views/InProgressOrderScreen.dart';
import 'package:myknott/Views/OrderScreen.dart';

class CompletedOrderScreen extends StatefulWidget {
  final String notaryId;
  final Function updateCompleted;

  const CompletedOrderScreen({Key key, this.notaryId, this.updateCompleted})
      : super(key: key);
  @override
  _CompletedOrderScreenState createState() => _CompletedOrderScreenState();
}

class _CompletedOrderScreenState extends State<CompletedOrderScreen>
    with AutomaticKeepAliveClientMixin<CompletedOrderScreen> {
  Map orders = {};
  int pageNumber = 0;
  bool hasData = false;
  String notaryId;
  bool isloading = false;

  getCompletedOrders() async {
    setState(() {
      pageNumber = 0;
      isloading = true;
      hasData = false;
    });
    try {
      orders.clear();
      var response = await NotaryServices()
          .getCompletedOrders(widget.notaryId, pageNumber);
      orders.addAll(response);
      print(" 37 resp cos $response");
      widget.updateCompleted(response['appointments'].length);
      if (response['pageNumber'] == response['pageCount']) {
        hasData = true;
      } else {
        pageNumber += 1;
      }
    } catch (e) {}
    setState(() {
      isloading = false;
    });
  }

  getMoreData() async {
    try {
      var response = await NotaryServices()
          .getCompletedOrders(widget.notaryId, pageNumber);
      print(" getMoreData Response of CompletedOrderScreen.dart --------\n ");
      response.forEach((key, value) {
        print("key : $key , value : $value ");
      });
      orders['orders'].addAll(response['orders']);
      if (response['pageNumber'] == response['pageCount']) {
        hasData = true;
      } else {
        pageNumber += 1;
      }
    } catch (e) {
      print("Error on 61 CompleteOS.dart \n $e \n");
    }
    setState(() {});
  }

  List data = [];
  @override
  void initState() {
    NotaryServices().getToken();
    getCompletedOrders();
    super.initState();
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    print("---------order cos 79");
    print(orders['appointments']);
    return !isloading
        ? LazyLoadScrollView(
            isLoading: hasData,
            onEndOfPage: getMoreData,
            child: RefreshIndicator(
              color: Colors.black,
              onRefresh: () async {
                await getCompletedOrders();
              },
              child: ListView.builder(
                itemCount: orders['appointments'].length != 0
                    ? orders['appointments'].length
                    : 1,

                // physics: BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  // orders['appointments'][index]
                  // print(
                  //     " 99 cos : ${orders['appointments'][index]["signingInfo"]['signerInfo']}");
                  return orders['appointments'].isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 2,
                                  ),
                                  ListTile(
                                    tileColor: Colors.white,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          transitionDuration:
                                              Duration(seconds: 0),
                                          pageBuilder: (_, __, ___) =>
                                              OrderScreen(
                                            isPending: false,
                                            notaryId: widget.notaryId,
                                            orderId: orders['appointments']
                                                [index]['_id'],
                                          ),
                                        ),
                                      );
                                    },
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "#" +
                                              orders['appointments'][index]
                                                          ['signingInfo']
                                                      ['escrowNumber']
                                                  .toString(),
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              orders['appointments'][index]
                                                              ["signingInfo"]
                                                          ['signerInfo']
                                                      ['fisrtName'] +
                                                  " " +
                                                  orders['appointments'][index]
                                                              ["signingInfo"]
                                                          ['signerInfo']
                                                      ['lastName'],
                                              style: TextStyle(
                                                  fontSize: 16.5,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.call,
                                                  size: 25,
                                                  color: Colors.blueAccent,
                                                ))
                                          ],
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Property Address",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          orders['appointments'][index]
                                                  ['signingInfo']
                                              ['propertyAddress'],
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        ListTile(
                                          horizontalTitleGap: 10,
                                          leading: Image.asset(
                                            "assets/location.png",
                                            height: 40,
                                          ),
                                          contentPadding: EdgeInsets.all(0),
                                          title: Text(
                                            orders['appointments'][index]
                                                    ['appointmentInfo']['place']
                                                ['completeAddress'],

                                            // widget.place,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                "Appointment Date & Time : " +
                                                    DateFormat("MM/dd/yyyy ")
                                                        .format(
                                                      DateTime.parse(
                                                        orders['appointments']
                                                                    [index][
                                                                'appointmentInfo']
                                                            ['date'],
                                                      ).toLocal(),
                                                    ) +
                                                    getTime(orders['appointments']
                                                                [index]
                                                            ['appointmentInfo']
                                                        ['time']),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height -
                              AppBar().preferredSize.height -
                              200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/appointment1.png",
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
                                  "You don't have any Completed appointments",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black.withOpacity(0.8),
                                      fontWeight: FontWeight.w700),
                                ),
                              )
                            ],
                          ),
                        );
                },
              ),
            ),
          )
        : Container(
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
          );
  }

  @override
  bool get wantKeepAlive => true;
}
