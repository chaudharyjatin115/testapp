// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:myknott/Config/CustomColors.dart';
import 'package:myknott/Services/Services.dart';
import 'package:myknott/Views/InProgressOrderScreen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'OrderScreen.dart';

var _selectedDay = DateTime.now();
var _focusedDay = DateTime.now();

class CalenderScreen extends StatefulWidget {
  final String notaryId;
  const CalenderScreen({Key key, this.notaryId}) : super(key: key);
  @override
  _CalenderScreenState createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen>
    with AutomaticKeepAliveClientMixin {
  Map data = {};
  final Color blueColor = CustomColor().blueColor;
  bool isloading = false;
  DateTime dateTime;
  // final CalendarController calendarController = CalendarController();
  final NotaryServices services = NotaryServices();

  @override
  initState() {
    NotaryServices().getToken();
    getAppointment(DateTime.now());
    super.initState();
  }

  getAppointment(DateTime date) async {
    setState(() {
      isloading = true;
      dateTime = date;
    });
    data.clear();
    data = await services.getAppointments(date, widget.notaryId);
    print("40 ClandrSn");
    data.forEach((key, value) {
      print("key : $key , value : $value ");
    });
    print("all appointments");
    data['appointmentCount'] != 0
        ? data['appointments'][0]
            .forEach((key, value) => print("key : $key, value :$value"))
        : print("appointment are empty");
    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "All Appointments",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              child: TableCalendar(
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle),
                  isTodayHighlighted: true,
                ),
                headerStyle: HeaderStyle(
                    titleTextStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5),
                    titleCentered: true,
                    formatButtonVisible: false),
                // calendarController: calendarController,
                selectedDayPredicate: (day) {
                  // print(" day : $day , selectday : $_selectedDay");
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (day, focusDay) {
                  print(" dayy : $day , ff : $focusDay");
                  getAppointment(day);
                  if (!isSameDay(_selectedDay, day)) {
                    print(" selectedDay $day , events $focusDay");

                    setState(() {
                      _selectedDay = day;
                      _focusedDay = focusDay;
                    });
                  }
                },
                firstDay: DateTime(1991),
                focusedDay: _focusedDay,
                lastDay: DateTime(2055),

                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),
            Expanded(
              child: !isloading
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: data['appointments'].isNotEmpty
                          ? data['appointments'].length
                          : 1,
                      itemBuilder: (BuildContext context, int index) {
                        // print(
                        // " 120 ${data['appointments'][index]['signingInfo']['signerInfo']['firstName']} ,${data['appointments'][index]['signingInfo']['signerInfo']['lastName']} ");
                        return data['appointments'].isNotEmpty
                            ? InkWell(
                                hoverColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      transitionDuration: Duration(seconds: 0),
                                      pageBuilder: (_, __, ___) => OrderScreen(
                                        notaryId: widget.notaryId,
                                        isPending: false,
                                        orderId:
                                            data['appointments'][index] != null
                                                ? data['appointments'][index]
                                                : 0,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    elevation: 0.2,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        ListTile(
                                          leading: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child:
                                                // data['notary']
                                                //             ['userImageURL'] !=
                                                //         null
                                                //     ? CachedNetworkImage(
                                                //         imageUrl: data['notary']
                                                //             ['userImageURL'],
                                                //         height: 40,
                                                //         width: 40,
                                                //       )
                                                Container(
                                              color: Colors
                                                  .amberAccent, // remove if needed
                                              height: 40,
                                              width: 40,
                                            ),
                                          ),
                                          title: Text(
                                            "Refinance of  " +
                                                data['appointments'][index]
                                                            ['signingInfo']
                                                        ['signerInfo']
                                                    ['fisrtName'] +
                                                " " +
                                                data['appointments'][index]
                                                        ['signingInfo']
                                                    ['signerInfo']['lastName'],
                                            style: TextStyle(
                                                fontSize: 16.5,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          isThreeLine: true,
                                          subtitle: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['appointments'][index]
                                                        ['signingInfo']
                                                    ['propertyAddress'],
                                                style: TextStyle(
                                                  fontSize: 16.5,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                DateFormat('MM/dd/yyyy ')
                                                        .format(DateTime.parse(
                                                                data['appointments']
                                                                            [
                                                                            index]
                                                                        [
                                                                        'appointmentInfo']
                                                                    ['date'])
                                                            .toLocal()) +
                                                    getTime(data['appointments']
                                                                [index]
                                                            ['appointmentInfo']
                                                        ['time']),
                                                //,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 15.0),
                                              child: Text(
                                                "Update Status",
                                                style: TextStyle(
                                                    color: blueColor,
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 50,
                                    ),
                                    Image.asset(
                                      "assets/appointment1.png",
                                      height: 100,
                                      width: 100,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Text(
                                        "You don't have any appointments for ${DateFormat('MM-dd-y').format(dateTime)}.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            fontWeight: FontWeight.w700),
                                      ),
                                    )
                                  ],
                                ),
                              );
                      },
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
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
