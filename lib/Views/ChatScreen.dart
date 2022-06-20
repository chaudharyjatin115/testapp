// import 'dart:convert';
// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:emoji_picker_flutter/category_icons.dart';
// // import 'package:emoji_picker_flutter/config.dart';
// // import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:bubble/bubble.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
// import 'package:myknott/Config/CustomColors.dart';
// import 'package:myknott/Services/Services.dart';

// class ChatScreen extends StatefulWidget {
//   final String notaryId;
//   final String chatRoom;
//   const ChatScreen({Key key, this.notaryId, @required this.chatRoom})
//       : super(key: key);
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen>
//     with AutomaticKeepAliveClientMixin {
//   final NotaryServices notaryServices = NotaryServices();
//   final Color blueColor = CustomColor().blueColor;
//   TextEditingController messageController = TextEditingController();
//   List messageList = [];
//   bool isloading = true;
//   bool openEmoji = false;
//   // int i = 0;
//   bool hasData = false;
//   String firstName = "";
//   String lastName = "";
//   String modal = "";
//   int pageNumber = 0;
//   getMessages(String chatroom) async {
//     var messages = await notaryServices.getAllMessages(
//         widget.notaryId, pageNumber, chatroom);
//     for (var i in messages['chatMessages']) {
//       if (i['sentBy']['_id'] == widget.notaryId) {
//         setState(() {
//           firstName = i['sentBy']['firstName'];
//           lastName = i['sentBy']['lastName'];
//           modal = i['sentByModel'];
//         });
//         break;
//       }
//     }
//     if (messages['chatMessageCount'] == messageList.length) {
//       setState(() {
//         hasData = true;
//       });
//     }
//     for (var message in messages['chatMessages']) {
//       messageList.add(message);
//     }
//     messageList.sort(
//       (a, b) => DateTime.parse(b['sentAt']).compareTo(
//         DateTime.parse(
//           a['sentAt'],
//         ),
//       ),
//     );
//     pageNumber = pageNumber + 1;
//     setState(() {
//       isloading = false;
//     });
//   }

//   loadmoreMessage() async {
//     var messages = await notaryServices.getAllMessages(
//         widget.notaryId, pageNumber, widget.chatRoom);
//     if (messages['chatMessageCount'] == messageList.length) {
//       setState(() {
//         hasData = true;
//       });
//     }
//     for (var message in messages['chatMessages']) {
//       messageList.add(message);
//     }
//     messageList.sort(
//       (a, b) => DateTime.parse(b['sentAt']).compareTo(
//         DateTime.parse(
//           a['sentAt'],
//         ),
//       ),
//     );
//     setState(() {
//       pageNumber = pageNumber + 1;
//     });
//   }

//   setNewMessageToList(message) {
//     var newData = json.decode(message['sentBy']);
//     messageList.insert(0, {
//       "sentAt": message['sentAt'],
//       "_id": message['_id'],
//       "message": message['message'],
//       "sentBy": {
//         "_id": newData['_id'] ?? "",
//         "firstName": newData['firstName'] ?? "",
//         "lastName": newData['lastName'] ?? "",
//         "phoneNumber": newData['phoneNumber'] ?? "",
//         "phoneCountryCode": "+1",
//         "email": newData['email'] ?? "",
//         "userImageURL": newData['userImageURL'] ?? ""
//       },
//       "sentByModel": message['sentByModel'],
//       "chatroom": newData['chatroom'],
//       "__v": 0
//     });
//     setState(() {});
//   }

//   saveMessageToMessageList(message) {
//     messageList.insert(0, {
//       "sentAt": DateTime.now().toIso8601String(),
//       "seenByNotary": false,
//       "seenByCustomer": false,
//       "_id": "605b4ec86f1bf80015330011",
//       "message": message,
//       "sentBy": {
//         "_id": widget.notaryId,
//         "firstName": firstName,
//         "lastName": lastName,
//         "phoneNumber": "6350312240",
//         "phoneCountryCode": "+1",
//         "email": "newuser@gmail.com",
//         "userImageURL":
//             "https://mynotarybucket1.s3.us-east-2.amazonaws.com/31.jpeg"
//       },
//       "sentByModel": modal,
//       "chatroom": widget.chatRoom,
//       "__v": 0
//     });
//     setState(() {});
//   }

//   handleNotificationClick(RemoteMessage message) async {
//     if (message.data['type'] == "3" || message.data['type'] == "0") {
//       if (message.data['chatroom'] == widget.chatRoom) {
//         setNewMessageToList(message.data);
//       }
//     }
//   }

//   @override
//   void initState() {
//     NotaryServices().getToken();
//     FirebaseMessaging.onMessage.any((element) {
//       handleNotificationClick(element);
//       return false;
//     });
//     getMessages(widget.chatRoom);
//     super.initState();
//   }

//   @override
//   // ignore: must_call_super
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () {
//         if (openEmoji) {
//           openEmoji = false;
//           setState(() {});
//           return Future<bool>.value(false);
//         }
//         return Future<bool>.value(true);
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         bottomNavigationBar: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               // height: 50,
//               color: Color(0xFFF2F2F2),
//               width: MediaQuery.of(context).size.width,
//               child: Row(
//                 children: [
//                   SizedBox(
//                     width: 8,
//                   ),
//                   GestureDetector(
//                     onTap: () => setState(() {
//                       FocusScope.of(context).requestFocus(FocusNode());
//                       openEmoji = !openEmoji;
//                     }),
//                     child: CircleAvatar(
//                       radius: 20,
//                       backgroundColor: Colors.red.shade700,
//                       child: Icon(
//                         Icons.emoji_emotions,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   Flexible(
//                     child: Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Container(
//                         child: TextField(
//                           controller: messageController,
//                           onTap: () {
//                             setState(() {
//                               openEmoji = false;
//                             });
//                           },
//                           maxLines: 1,
//                           cursorColor: Colors.black,
//                           style: TextStyle(
//                               fontSize: 17, fontWeight: FontWeight.bold),
//                           decoration: InputDecoration(
//                               border: InputBorder.none,
//                               hintText: "Type a message..."),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: GestureDetector(
//                       onTap: () async {
//                         if (messageController.text.isNotEmpty) {
//                           final String message = messageController.text;
//                           saveMessageToMessageList(message);
//                           messageController.clear();
//                           await NotaryServices().sendMessage(
//                             message: message,
//                             notaryId: widget.notaryId,
//                             chatRoom: widget.chatRoom,
//                           );
//                           setState(() {});
//                           // await getMessages();
//                         }
//                       },
//                       child: CircleAvatar(
//                         radius: 23,
//                         backgroundColor: blueColor,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 4,
//                             ),
//                             Center(
//                               child: Icon(
//                                 Icons.send_rounded,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             openEmoji
//                 ? SizedBox(
//                     height: 300,
//                     child: EmojiPicker(
//                       config: Config(
//                           initCategory: Category.RECENT,
//                           bgColor: Color(0xFFF2F2F2),
//                           // bgColor: Colors.white,
//                           indicatorColor: blueColor,
//                           iconColor: Colors.grey,
//                           iconColorSelected: blueColor,
//                           progressIndicatorColor: Colors.transparent,
//                           showRecentsTab: true,
//                           recentsLimit: 28,
//                           emojiSizeMax: 28,
//                           categoryIcons: CategoryIcons(
//                               foodIcon: FontAwesomeIcons.appleAlt,
//                               travelIcon: Icons.location_pin),
//                           horizontalSpacing: 0,
//                           verticalSpacing: 0,
//                           // noRecentsText: "No Recents",
//                           // noRecentsStyle: const TextStyle(
//                           //     fontSize: 20, color: Colors.black26),
//                           buttonMode: ButtonMode.CUPERTINO),
//                       onEmojiSelected: (emoji, category) {
//                         messageController.text += category.emoji;
//                       },
//                     ),
//                   )
//                 : Container(),
//           ],
//         ),
//         body: !isloading
//             ? LazyLoadScrollView(
//                 isLoading: hasData,
//                 onEndOfPage: loadmoreMessage,
//                 child: ListView.builder(
//                   reverse: true,
//                   itemCount: messageList.length,
//                   physics: BouncingScrollPhysics(),
//                   itemBuilder: (context, index) {
//                     return messageList[index]['sentBy']['_id'] ==
//                             widget.notaryId
//                         ? Container(
//                             child: rightChild(messageList, index),
//                           )
//                         : Container(
//                             child: leftChild(messageList, index),
//                           );
//                   },
//                 ),
//               )
//             : Center(
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       height: 17,
//                       width: 17,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           Colors.black,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     Text(
//                       "Please Wait ...",
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }

// Widget leftChild(messageList, index) {
//   return Padding(
//     padding: const EdgeInsets.only(left: 2.0, top: 6.0, bottom: 2.0, right: 40),
//     child: Column(
//       children: [
//         Container(
//           child: Row(
//             children: [
//               SizedBox(
//                 width: 10,
//               ),
//               CircleAvatar(
//                 backgroundColor: Colors.transparent,
//                 radius: 25,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(25),
//                   child: messageList[index]['sentBy']['userImageURL'] != null
//                       ? CachedNetworkImage(
//                           imageUrl: messageList[index]['sentBy']
//                               ['userImageURL'],
//                           height: 25,
//                           width: 25,
//                         )
//                       : Container(),
//                 ),
//               ),
//               SizedBox(
//                 width: 3,
//               ),
//               Flexible(
//                 child: Bubble(
//                   elevation: 0.2,
//                   color: Colors.grey.shade50,
//                   nip: BubbleNip.leftTop,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 2.0, vertical: 3),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               messageList[index]['sentBy']['firstName'] ??
//                                   "" +
//                                       " " +
//                                       messageList[index]['sentBy']
//                                           ['lastName'] ??
//                                   "",
//                               textAlign: TextAlign.start,
//                               style: TextStyle(
//                                 fontSize: 15.5,
//                               ),
//                             ),
//                             SizedBox(width: 5),
//                             Text(
//                               DateFormat('hh:mm a').format(
//                                   DateTime.parse(messageList[index]['sentAt'])
//                                       .toLocal()),
//                               textAlign: TextAlign.start,
//                               style: TextStyle(fontSize: 14),
//                             ),
//                           ],
//                         ),
//                         Text(
//                           messageList[index]['sentByModel'] ?? "",
//                           textAlign: TextAlign.start,
//                           style: TextStyle(
//                             fontSize: 15,
//                             color: Colors.black.withOpacity(0.7),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 5,
//                         ),
//                         Text(
//                           messageList[index]['message'] ?? "",
//                           style: TextStyle(
//                             fontSize: 15.5,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                         SizedBox(
//                           height: 5,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(height: 5),
//       ],
//     ),
//   );
// }

// Widget rightChild(messageList, index) {
//   return Padding(
//     padding: const EdgeInsets.only(right: 5.0, top: 6.0, bottom: 8),
//     child: Column(
//       // mainAxisSize: MainAxisSize.max,
//       // crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Container(
//           child: Row(
//             children: [
//               SizedBox(
//                 width: 40,
//               ),
//               Flexible(
//                 child: Bubble(
//                   alignment: Alignment.centerRight,
//                   nip: BubbleNip.rightTop,
//                   color: CustomColor().chatColor,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             messageList[index]['sentBy']['firstName'] +
//                                     " " +
//                                     messageList[index]['sentBy']['lastName'] ??
//                                 "",
//                             textAlign: TextAlign.end,
//                             style: TextStyle(
//                               fontSize: 15.5,
//                               color: Colors.white,
//                             ),
//                           ),
//                           SizedBox(width: 5),
//                           Text(
//                             DateFormat('hh:mm a').format(
//                                 DateTime.parse(messageList[index]['sentAt'])
//                                     .toLocal()),
//                             textAlign: TextAlign.start,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         messageList[index]['sentByModel'],
//                         textAlign: TextAlign.start,
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: Colors.white.withOpacity(0.8),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 5,
//                       ),
//                       Text(
//                         messageList[index]['message'],
//                         style: TextStyle(
//                           fontSize: 15.5,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                       SizedBox(
//                         height: 5,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(height: 5),
//       ],
//     ),
//   );
// }
