// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:future_button/future_button.dart';
import 'package:intl/intl.dart';
import 'package:myknott/Config/CustomColors.dart';
import 'package:myknott/Services/Services.dart';
import 'package:myknott/Views/InProgressOrderScreen.dart';

class ConfirmCards extends StatefulWidget {
  final Function refresh;
  final String notaryId;
  final String orderId;
  final String name;
  // final String price;
  final String address;
  final date;
  // final String imageUrl;
  final String place;
  final String time;
  final String closeType;
  const ConfirmCards({
    this.name,
    // this.price,
    this.address,
    this.notaryId,
    this.orderId,
    this.refresh,
    this.date,
    // @required this.imageUrl,
    @required this.place,
    this.time,
    @required this.closeType,
  });

  @override
  _ConfirmCardsState createState() => _ConfirmCardsState();
}

class _ConfirmCardsState extends State<ConfirmCards> {
  final Color blueColor = CustomColor().blueColor;

  TextEditingController textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.closeType + " Closing",
                      style: TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: 5),
                    ListTile(
                      horizontalTitleGap: 10,
                      leading: Image.asset(
                        "assets/location.png",
                        height: 40,
                        width: 60,
                      ),
                      contentPadding: EdgeInsets.all(0),
                      title: Text(
                        widget.place,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            widget.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Text(
                            "Appointment Date & Time : " +
                                DateFormat("MM/dd/yyyy ").format(
                                  DateTime.parse(widget.date).toLocal(),
                                ) +
                                getTime(int.parse(widget.time)),
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
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // FutureFlatButton(
                //       disabledColor: Colors.yellow,
                //       progressIndicatorBuilder: (context) => SizedBox(
                //         height: 15,
                //         width: 15,
                //         child: Center(
                //           child: CircularProgressIndicator(
                //             valueColor: AlwaysStoppedAnimation<Color>(
                //               Colors.black.withOpacity(0.5),
                //             ),
                //             strokeWidth: 2,
                //           ),
                //         ),
                //       ),
                //       onPressed: () async {
                //         textController.text = "";
                //         //TO DO : open a Container with textfield , User will enter the reason for Rejecting Appointment
                //         showModalBottomSheet(
                //             backgroundColor: Colors.transparent,
                //             context: context,
                //             builder: (context) {
                //               return Container(
                //                 padding: EdgeInsets.all(12),
                //                 decoration: BoxDecoration(
                //                   borderRadius: BorderRadius.only(
                //                       topLeft: Radius.circular(15),
                //                       topRight: Radius.circular(15)),
                //                   color: Colors.white,
                //                 ),
                //                 child: Column(
                //                   crossAxisAlignment: CrossAxisAlignment.start,
                //                   children: [
                //                     SizedBox(
                //                       height: 20,
                //                     ),
                //                     Text(
                //                       "Reason for Declining ",
                //                       style: TextStyle(
                //                           fontSize: 18,
                //                           fontWeight: FontWeight.bold,
                //                           color: Colors.blue),
                //                     ),
                //                     SizedBox(
                //                       height: 10,
                //                     ),
                //                     TextField(
                //                       controller: textController,
                //                       decoration: InputDecoration(
                //                           filled: true,
                //                           border: OutlineInputBorder(
                //                               borderSide: BorderSide())),
                //                     ),
                //                     SizedBox(
                //                       height: 50,
                //                     ),
                //                     Material(
                //                       color: Colors.transparent,
                //                       child: InkWell(
                //                         onTap: () async {
                //                           var declined = await NotaryServices()
                //                               .declineNotary(widget.orderId,
                //                                   textController.text);
                //                           await widget.refresh();

                //                           if (declined) {
                //                             Navigator.pop(context);
                //                             Fluttertoast.showToast(
                //                                 msg: "Appointment Rejected",
                //                                 backgroundColor: Colors.black54,
                //                                 fontSize: 16,
                //                                 textColor: Colors.white,
                //                                 gravity: ToastGravity.BOTTOM);
                //                           } else {
                //                             Navigator.pop(context);
                //                             Fluttertoast.showToast(
                //                                 msg: "Appointment not Rejected",
                //                                 backgroundColor: Colors.black54,
                //                                 fontSize: 16,
                //                                 textColor: Colors.white,
                //                                 gravity: ToastGravity.BOTTOM);
                //                           }
                //                         },
                //                         splashColor: Colors.deepOrange,
                //                         child: Center(
                //                           child: Container(
                //                             height: 40,
                //                             width: 150,
                //                             decoration: BoxDecoration(
                //                                 border: Border.all(),
                //                                 borderRadius: BorderRadius.all(
                //                                     Radius.circular(15)),
                //                                 color: Colors.lightBlueAccent),
                //                             child: Center(
                //                               child: Text(
                //                                 "Submit",
                //                                 style: TextStyle(
                //                                     fontWeight: FontWeight.w700,
                //                                     fontSize: 18),
                //                               ),
                //                             ),
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               );
                //             });
                //       },
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(100),
                //       ),
                //       color: Colors.yellow,
                //       child: Container(
                //         padding: EdgeInsets.symmetric(horizontal: 10),
                //         child: Center(
                //           child: Text(
                //             "Reject",
                //             style: TextStyle(
                //                 color: Colors.black.withOpacity(1),
                //                 fontSize: 16.5,
                //                 fontWeight: FontWeight.bold),
                //           ),
                //         ),
                //       ),
                //     ),
                //     FutureFlatButton(
                //       disabledColor: blueColor,
                //       progressIndicatorBuilder: (context) => SizedBox(
                //         height: 15,
                //         width: 15,
                //         child: Center(
                //           child: CircularProgressIndicator(
                //             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                //             strokeWidth: 2,
                //           ),
                //         ),
                //       ),
                //       onPressed: () async {
                //         bool success = await NotaryServices()
                //             .acceptNotary(widget.notaryId, widget.orderId);
                //         await widget.refresh();
                //         Fluttertoast.showToast(
                //             msg: success
                //                 ? "Order accepted."
                //                 : "Can't accept order now.",
                //             backgroundColor: blueColor,
                //             fontSize: 16,
                //             textColor: Colors.white,
                //             gravity: ToastGravity.SNACKBAR);
                //       },
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(100),
                //       ),
                //       color: blueColor,
                //       child: Container(
                //         padding: EdgeInsets.symmetric(horizontal: 10),
                //         child: Center(
                //           child: Text(
                //             "Accept",
                //             style: TextStyle(
                //                 color: Colors.white,
                //                 fontSize: 16.5,
                //                 fontWeight: FontWeight.bold),
                //           ),
                //         ),
                //       ),
                //     )
              ],
            ),
            SizedBox(
              height: 5,
            )
          ],
        ),
      ),
    );
  }
}
