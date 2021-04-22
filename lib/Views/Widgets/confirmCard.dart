import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_button/future_button.dart';
import 'package:myknott/Config.dart/CustomColors.dart';
import 'package:myknott/Services/Services.dart';

class ConfirmCards extends StatefulWidget {
  final Function refresh;
  final String notaryId;
  final String orderId;
  final String name;
  final String price;
  final String address;
  final String imageUrl;
  const ConfirmCards(
      {Key key,
      this.name,
      this.price,
      this.address,
      this.notaryId,
      this.orderId,
      this.refresh,
      @required this.imageUrl})
      : super(key: key);

  @override
  _ConfirmCardsState createState() => _ConfirmCardsState();
}

class _ConfirmCardsState extends State<ConfirmCards> {
  final Color blueColor = CustomColor().blueColor;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: ListTile(
              leading: widget.imageUrl != null
                  ? CircleAvatar(
                      backgroundColor: Colors.transparent,
                      maxRadius: 20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          height: 40,
                          width: 40,
                          imageUrl: widget.imageUrl,
                        ),
                      ),
                    )
                  : Container(
                      height: 40,
                      width: 40,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: blueColor,
                        child: Text(
                          widget.name[0],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16.5),
                        ),
                      ),
                    ),
              title: Text(
                widget.name,
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
              ),
              // dense: true,
              trailing: Text(
                "\$ ${widget.price}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // visualDensity: VisualDensity.compact,
              // minVerticalPadding: 10,
              subtitle: Text(
                widget.address,
                style: TextStyle(fontSize: 15.5),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FutureFlatButton(
                disabledColor: Colors.yellow,
                progressIndicatorBuilder: (context) => SizedBox(
                  height: 17,
                  width: 17,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.black.withOpacity(0.5),
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                onPressed: () async {
                  await NotaryServices()
                      .declineNotary(widget.notaryId, widget.orderId);
                  await widget.refresh();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                color: Colors.yellow,
                child: Text(
                  "Decline",
                  style: TextStyle(
                      color: Colors.black.withOpacity(1),
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold),
                ),
              ),
              FutureFlatButton(
                disabledColor: blueColor,
                progressIndicatorBuilder: (context) => SizedBox(
                  height: 17,
                  width: 17,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                onPressed: () async {
                  bool success = await NotaryServices()
                      .acceptNotary(widget.notaryId, widget.orderId);
                  await widget.refresh();
                  Fluttertoast.showToast(
                      msg: success
                          ? "Order accepted."
                          : "Can't accept order now.",
                      backgroundColor: blueColor,
                      fontSize: 16,
                      textColor: Colors.white,
                      gravity: ToastGravity.SNACKBAR);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                color: blueColor,
                child: Text(
                  "Accept",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
