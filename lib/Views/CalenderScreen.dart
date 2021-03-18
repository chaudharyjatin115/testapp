import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Services/Services.dart';
import 'secondScreen.dart';

class CalenderScreen extends StatefulWidget {
  final String notaryId;
  const CalenderScreen({Key key, this.notaryId}) : super(key: key);
  @override
  _CalenderScreenState createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen>
    with AutomaticKeepAliveClientMixin {
  Map data = {};
  bool isloading = false;
  final CalendarController calendarController = CalendarController();
  final NotaryServices services = NotaryServices();

  @override
  // ignore: must_call_super
  initState() {
    getAppointment(DateTime.now());
    super.initState();
  }

  getAppointment(DateTime date) async {
    setState(() {
      isloading = true;
    });
    data.clear();
    data = await services.getAppointments(date, widget.notaryId);
    setState(() {
      isloading = false;
    });
    print(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Container(
                // height: MediaQuery.of(context).size.height / 3,
                child: TableCalendar(
                  calendarStyle: CalendarStyle(
                    // markersColor: Colors.blue.shade800,
                    selectedColor: Colors.blue.shade800,
                    highlightToday: false,
                  ),
                  headerStyle: HeaderStyle(
                      titleTextStyle: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.5),
                      centerHeaderTitle: true,
                      formatButtonVisible: false),
                  calendarController: calendarController,
                  onDaySelected: (day, events, holidays) {
                    print(day);
                    getAppointment(day);
                  },
                  // endDay: DateTime.now(),
                ),
              ),
              Expanded(
                child: !isloading
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            data.isNotEmpty ? data['appointments'].length : 0,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            hoverColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SecondScreen(
                                    notaryId: widget.notaryId,
                                    isPending: false,
                                    orderId: data['appointments'][index]
                                        ['orderId'],
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CachedNetworkImage(
                                        imageUrl: data['notary']
                                            ['userImageURL'],
                                        height: 40,
                                        width: 40,
                                      ),
                                    ),
                                    title: Text(
                                      "Refinance of " +
                                          data['appointments'][index]
                                              ['appointment']['signerFullName'],
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
                                                  ['appointment']
                                              ['propertyAddress'],
                                          style: TextStyle(
                                            fontSize: 16.5,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          DateFormat('MMM-d-yyyy hh:mm a')
                                              .format(DateTime.parse(
                                                  data['appointments'][index]
                                                      ['appointment']['time'])),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15.0),
                                        child: Text(
                                          "Change Status",
                                          style: TextStyle(
                                              color: Colors.blue.shade900,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
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
                          );
                        },
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade800),
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
