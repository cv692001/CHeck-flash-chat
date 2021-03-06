import 'dart:convert';

import 'dart:io';
import 'package:flash_chat/services/encoding_decoding_services.dart';

//import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:flutter_emoji_keyboard/flutter_emoji_keyboard.dart';
import 'package:flash_chat/pages/RegisterPage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash_chat/widgets/ChatAppBar.dart';
import 'package:flash_chat/config/style.dart';
import 'package:intl/intl.dart';
import 'package:flash_chat/config/color_palette.dart';
import 'package:share/share.dart';
import 'fullImageWidget.dart';
import 'package:flash_chat/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class chat extends StatefulWidget {
  final String recieverAbout;
  final String recieverId;
  final String recieverAvatar;
  final String recieverName;
  final String recieverAge;
  final bool isLiked;

  chat({
    Key key,
    this.recieverAbout,
    @required this.recieverAvatar,
    @required this.recieverId,
    @required this.recieverName,
    @required this.recieverAge,
    @required this.isLiked,
  });

  @override
  _chatState createState() => _chatState(recieverAge: recieverAge,recieverAvatar: recieverAvatar,
      recieverId: recieverId,recieverName: recieverName,recieverAbout: recieverAbout);
}

class _chatState extends State<chat> {
  final String recieverAbout;
  final String recieverId;
  final String recieverAvatar;
  final String recieverName;
  final String recieverAge;
  final bool isLiked;

  _chatState({
    Key key,
    this.recieverAbout,
    @required this.recieverAvatar,
    @required this.recieverId,
    @required this.recieverName,
    @required this.recieverAge,
    @required this.isLiked,
  });


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readLocal();
  }

  SharedPreferences preferences;
  String id;

  readLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id") ?? "";



    Firestore.instance
        .collection("users")
        .document(id)
        .updateData({'chattingWith': recieverId});


    Firestore.instance.collection("users").document(id).get().then((value){
      List a = value.data["blockedto"];

      if(a.contains(recieverId)){
        setState(() {
          block = true;
        });
      }else{
        setState(() {
          block = false;
        });
      }
    });

    setState(() {});
  }

  bool block = false;

  @override
  Widget build(BuildContext context) {
    blockFunction(){
      Firestore.instance.collection("users").document(id).get().then((value) {
        List a = value.data["blockedto"];
        List b = value.data["blockedby"];
        print(a);

        if(a.contains(recieverId)){
          Firestore.instance.collection("users").document(id).updateData({

            "blockedto": FieldValue.arrayRemove([recieverId]),

          });

          Firestore.instance.collection("users").document(recieverId).updateData({

            "blockedby": FieldValue.arrayRemove([id]),

          });




          Firestore.instance.collection("users").document(id).updateData({



          }).then((value) {

            setState(() {
              block = !block;
            });
          });


          print("TRUE");
          print(a.length);
          print(isLiked);
          print(a.length);
        }
        else{

          Firestore.instance.collection("users").document(recieverId).updateData({

            "blockedby": FieldValue.arrayUnion([id]),
          });

          Firestore.instance.collection("users").document(id).updateData({

            "blockedto": FieldValue.arrayUnion([recieverId]),
          }).then((value) {
            setState(() {
              block = !block;

            });
          });



          print("true");
          print(a.length);
          print(isLiked);
          print(a.length);
        }





      });

    }

    showAlertDialog(BuildContext context) {

      // set up the button
      Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () {

          //onDeleteMsg(document);

          blockFunction();
          Navigator.pop(context);
        },
      );

      Widget cancelButton = FlatButton(
        child: Text("NO"),
        onPressed: () {
          Navigator.pop(context);
        },
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
        title: block ?  Text("Unblock User"):Text("Block User") ,
        content: block ? Text("Are you sure to Unblock $recieverName !!"):Text("Are you sure to Block $recieverName !!"),
        actions: [
          okButton,
          cancelButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    void handleClick(String value) {
      switch (value) {
        case 'Block':
          showAlertDialog(context) ;

          break;
        case 'Profile':
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (value) => UserProfileScreen(
                    recieverAbout: recieverAbout,
                    recieverAvatar: recieverAvatar,
                    recieverId: recieverId,
                    recieverName: recieverName,
                    recieverAge: recieverAge,
                  )));
          break;
      }
    }
    void handleClick2(String value) {
      switch (value) {
        case 'Unblock':
          showAlertDialog(context) ;

          break;
        case 'Profile':
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (value) => UserProfileScreen(
                    recieverAbout: recieverAbout,
                    recieverAvatar: recieverAvatar,
                    recieverId: recieverId,
                    recieverName: recieverName,
                    recieverAge: recieverAge,
                  )));
          break;
      }
    }
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(90),
          child: Material(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (value) => UserProfileScreen(
                              recieverAbout: recieverAbout,
                              recieverAvatar: recieverAvatar,
                              recieverId: recieverId,
                              recieverName: recieverName,
                              recieverAge: recieverAge,
                            )));
                  },
                  child: Container(
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],

                    ),
                    //color: Palette.primaryBackgroundColor,
                    child: Row(

                      children: <Widget>[




                        Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).padding.top+3,
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        Expanded(
                          flex: 7,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 6,
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  child: Container(
                                    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                                    child: Column(

                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(

                                          (recieverName[0].toUpperCase() +
                                              recieverName.substring(1)).length <= 15 ?  (recieverName[0].toUpperCase() +
                                              recieverName.substring(1)) :
                                          (recieverName[0].toUpperCase() +
                                              recieverName.substring(1)).replaceRange(15,  (recieverName[0].toUpperCase() +
                                              recieverName.substring(1)).length, '...'),
                                          textAlign: TextAlign.start,
                                          style:  GoogleFonts.quicksand(
                                              textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:22

                                              )
                                          ),
                                        ),
                                        Text(



                                            (recieverAbout[0].toUpperCase() +
                                                recieverAbout.substring(1)).length <= 25 ?  (recieverAbout[0].toUpperCase() +
                                                recieverAbout.substring(1)) :
                                            (recieverAbout[0].toUpperCase() +
                                                recieverAbout.substring(1)).replaceRange(25,  (recieverAbout[0].toUpperCase() +
                                                recieverAbout.substring(1)).length, '...'),
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            style:  GoogleFonts.quicksand(
                                                textStyle: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize:15
                                                )
                                            )
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(flex: 2, child: Container(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top,
                                  left: 10
                              ),
                              child: CircleAvatar(
                                radius: 33,
                                backgroundImage:
                                CachedNetworkImageProvider(recieverAvatar),
                              ),
                            ),
                          ),
                        ),),
                        Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).padding.top+3,
                            ),
                            PopupMenuButton<String>(
                              onSelected: block ? handleClick2 : handleClick,
                              itemBuilder: (BuildContext context) {
                                return block ? {'Unblock', 'Profile'}.map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                  );
                                }).toList()
                                    : {'Block', 'Profile'}.map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                  );
                                }).toList();
                              },
                            ),
                            // IconButton(
                            //   icon: Icon(Icons.,
                            //
                            //       size: 30,
                            //       color: Colors.redAccent),
                            //   onPressed: () => Navigator.of(context).pop(),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock,size: 10,),
                      Text("  End to End Encrypted Chats",
                        style: TextStyle(
                            fontSize: 10
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body:
        ChatScreen(recieverAvatar: recieverAvatar, recieverId: recieverId));
  }
}



class ChatScreen extends StatefulWidget {
  final String recieverAvatar;
  final String recieverId;
  final bool isLiked;

  ChatScreen({
    Key key,
    @required this.recieverAvatar,
    @required this.recieverId,
    @required this.isLiked,
  }) : super(key: key);
  @override
  _ChatScreenState createState() =>
      _ChatScreenState(recieverAvatar: recieverAvatar, recieverId: recieverId);
}

class _ChatScreenState extends State<ChatScreen> {
  final String recieverAvatar;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final String recieverId;
  final bool isLiked;

  _ChatScreenState({
    Key key,
    @required this.recieverAvatar,
    @required this.recieverId,
    @required this.isLiked,
  });





  readLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id") ?? "";

    if (id.hashCode <= recieverId.hashCode) {
      chatId = '$id-$recieverId';
    } else {
      chatId = '$recieverId-$id';
    }

    Firestore.instance
        .collection("users")
        .document(id)
        .updateData({'chattingWith': recieverId});

    setState(() {});
  }

  TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool isDisplayStickers;
  bool isLoading;
  ScrollController listScrollController = ScrollController();

  File imageFile;
  File imageFile1;
  String imageUrl;

  String chatId;
  SharedPreferences preferences;
  String id;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    focusNode.addListener(onFocusChange);

    isDisplayStickers = false;
    isLoading = false;
    chatId = null;

    readLocal();
  }

  onFocusChange() {
    //hide stickers whenever keypad appears
    if (focusNode.hasFocus) {
      setState(() {
        isDisplayStickers = false;
      });
    }
  }

  String encryptedS,decryptedS = "Text";
  var password = "null";
  PlatformStringCryptor cryptor;


  var key = "1";

  void onSendMessage(String contentMsg, int type) async {
    //type 0 message
    //type 2 gif
    //type 1 images

    cryptor = PlatformStringCryptor();
    final salt = await cryptor.generateSalt();
    password = contentMsg;
    key = await cryptor.generateKeyFromPassword(password, salt);
    // here pass the password entered by user and the key
    encryptedS = EncodingDecodingService.encodeAndEncrypt(
      contentMsg,
      chatId, // using doc id as IV
      "1",
    );





    if (contentMsg != "") {
      textEditingController.clear();


      Firestore.instance.collection("users").document(id).updateData({

        "activeChat": FieldValue.arrayUnion([

          recieverId

        ]),
      });
      Firestore.instance.collection("users").document(recieverId).updateData({

        "activeChat": FieldValue.arrayUnion([
          id
        ]),
      });

      String time = DateTime.now().millisecondsSinceEpoch.toString();

      var docRef = Firestore.instance
          .collection("messages")
          .document(chatId)
          .collection(chatId)
          .document(time);

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          docRef,
          {
            //sender of the message
            "idFrom": id,
            //reciever of the message
            "idTo": recieverId,
            "timestamp": time,
            "content": encryptedS,
            "type": type,
          },
        );
      });

      listScrollController.animateTo(0.0,
          duration: Duration(microseconds: 100), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: "Empty message Can't be send");
    }
  }

  Widget buildSticker() {



    void onEmojiSelected(Emoji emoji) {
      textEditingController.text += emoji.text;
    }

    return EmojiKeyboard(
      onEmojiSelected: onEmojiSelected,
    );


  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      createListMessagaes(),

                      createInput(),
                      (isDisplayStickers ? buildSticker() : Container()),
                    ],
                  ),
                ),
              ],
            ),
            createLoading(),
          ],
        ),
        onWillPop: onBackPress);
  }

  createLoading() {
    return Positioned(child: isLoading ? circularProgress() : Container());
  }

  Future<bool> onBackPress() {
    if (isDisplayStickers) {
      setState(() {
        isDisplayStickers = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  createStickers() {
    print("yes");
    return Container(
      child: Column(
        children: <Widget>[
          //first Row
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/BMPSCLh0SQxvGQ81uP/giphy.gif",
                    2),
                child: Image.network(
                  'https://media.giphy.com/media/BMPSCLh0SQxvGQ81uP/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/RfXmmUJf9G26Za3dLB/giphy.gif",
                    2),
                child: Image.network(
                  'https://media.giphy.com/media/RfXmmUJf9G26Za3dLB/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/5adFM0HmVdP8s/giphy.gif", 2),
                child: Image.network(
                  'https://media.giphy.com/media/5adFM0HmVdP8s/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/pVVKJJuEQre3219fLh/giphy.gif",
                    2),
                child: Image.network(
                  'https://media.giphy.com/media/pVVKJJuEQre3219fLh/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/X7sdcJ1kA5u41SWEqa/giphy.gif",
                    2),
                child: Image.network(
                  'https://media.giphy.com/media/X7sdcJ1kA5u41SWEqa/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/3FjuotitkhOffmPamc/giphy.gif",
                    2),
                child: Image.network(
                  'https://media.giphy.com/media/3FjuotitkhOffmPamc/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/z1RIYMGmxZjwc/giphy.gif", 2),
                child: Image.network(
                  'https://media.giphy.com/media/z1RIYMGmxZjwc/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/LThD8JVDd19hm/giphy.gif", 2),
                child: Image.network(
                  'https://media.giphy.com/media/LThD8JVDd19hm/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/xUOxf9qA9iupNWfT3y/giphy.gif",
                    2),
                child: Image.network(
                  'https://media.giphy.com/media/xUOxf9qA9iupNWfT3y/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  void getSticker() {
    focusNode.unfocus();

    setState(() {
      isDisplayStickers = !isDisplayStickers;
    });
  }

  var listMessage;
  var s;

  createListMessagaes() {
    return Flexible(
        child: chatId == null
            ? Center(
          child: CircularProgressIndicator(
            valueColor:
            AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
          ),
        )
            : StreamBuilder(
            stream: Firestore.instance
                .collection('messages')
                .document(chatId)
                .collection(chatId)
                .orderBy("timestamp", descending: true)
                .limit(20)
                .snapshots(),
            builder: (context, snapshots) {
              if (!snapshots.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.lightBlueAccent),
                  ),
                );
              } else {
                listMessage = snapshots.data.documents;

                return  ListView.builder(

                  padding: EdgeInsets.all(10.0),
                  itemCount: snapshots.data.documents.length,

                  itemBuilder: (context, index) {
                    // print(index);
                    // print("sss");
                    return  createItem(index , listMessage[index] , s);
                  },
                  reverse: true,
                  controller: listScrollController,
                );
              }
            }));
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
        listMessage != null &&
        listMessage[index - 1]["idFrom"] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
        listMessage != null &&
        listMessage[index - 1]["idFrom"] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  onDeleteMsg(DocumentSnapshot document) {

    var docRef = Firestore.instance
        .collection("messages")
        .document(chatId)
        .collection(chatId)
        .document(document['timestamp']);

    encryptedS = EncodingDecodingService.encodeAndEncrypt(
      "???? This Msg was deleted",
      chatId, // using doc id as IV
      "1",
    );

    docRef.updateData({
      "content": encryptedS,
      "type": 0,
    });

  }


  showAlertDialog(BuildContext context, DocumentSnapshot document) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {

        onDeleteMsg(document);
        Navigator.pop(context);
      },
    );

    Widget cancelButton = FlatButton(
      child: Text("NO"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30)),
      title: Text("Delete Message"),
      content: Text("Are you sure to delete message !!"),
      actions: [
        okButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  createItem(int index, DocumentSnapshot document , String s) {

    decryptedS = EncodingDecodingService.decryptAndDecode(
      document['content'],
      chatId,
      "1",
    );

    if (document["idFrom"] == id) {
      return GestureDetector(
        onLongPress: (){
          showAlertDialog(context, document);
        },

        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            document['type'] == 0
                ? Padding(
              padding: const EdgeInsets.only(
                  top: 10,bottom: 10,right: 17
              ),
              child: Material(

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
                elevation: 3,
                shadowColor: Colors.grey.shade400,
                color: Palette.selfMessageBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    direction: Axis.horizontal,
                    children: [
                      Container(

                        constraints: BoxConstraints(maxWidth: 235),

                        child: Text(
                            decryptedS == null ? "yoyo":decryptedS,
                            style: GoogleFonts.quicksand(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize:15
                                )
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                : document['type'] == 1
                ? Container(
              child: FlatButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FullPhoto(
                            url: decryptedS,
                          )));
                },
                child: Material(
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                            Colors.lightBlueAccent),
                      ),
                      width: 200,
                      height: 200,
                      padding: EdgeInsets.all(70.0),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Material(
                      child: Image.asset(
                        "images/img_not_available.jpeg",
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                    ),
                    imageUrl: decryptedS,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              margin: EdgeInsets.only(
                  bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                  right: 0.0),
            )
                : Container(
              child: Image.network(
                decryptedS,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : CircularProgressIndicator();
                },
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              margin: EdgeInsets.only(
                  bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                  right: 17.0),
            )
          ],
        ),
      );
    } else {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                            Colors.lightBlueAccent),
                      ),
                      width: 35,
                      height: 35,
                      padding: EdgeInsets.all(10.0),
                    ),
                    imageUrl: recieverAvatar,
                    width: 35,
                    height: 35,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(18.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                )
                    : Container(
                  width: 35.0,
                ),
                document['type'] == 0
                    ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Material(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        elevation: 3,
                        shadowColor: Colors.grey.shade400,
                        color: Palette.otherMessageBackgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 235),
                            child: Text(
                                decryptedS==null ? "yoyo ": decryptedS,
                                style: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize:15
                                    )
                                )
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    : document['type'] == 1
                    ? Container(
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullPhoto(
                                url: decryptedS,
                              )));
                    },
                    child: Material(
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                                Colors.lightBlueAccent),
                          ),
                          width: 200,
                          height: 200,
                          padding: EdgeInsets.all(70.0),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            Material(
                              child: Image.asset(
                                "images/img_not_available.jpeg",
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                        imageUrl: decryptedS,
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
                    : Container(
                  child: Image.network(
                    decryptedS,
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : CircularProgressIndicator();
                    },
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
              ],
            ),
            isLastMessageLeft(index)
                ? Container(
              child: Text(
                  "Seen :" +
                      DateFormat("dd MM yyyy - hh:mm:aa").format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp']))),
                  style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize:12
                      )
                  )
              ),
              margin: EdgeInsets.only(bottom: 5.0, left: 50.0, top: 0.0),
            )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  createInput() {
    return Container(
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: IconButton(
                  icon: Icon(
                    Icons.image,
                    color: Colors.lightBlueAccent,
                  ),
                  onPressed: () {
                    getImage();
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                  icon: Icon(
                    Icons.insert_emoticon,
                    color: Colors.lightBlueAccent,
                  ),
                  onPressed: () {
                    print("yes1");
                    getSticker();
                  }),
            ),

            Flexible(
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    print('Dragged Down');
                    if (details.primaryVelocity < 50) {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    child: TextField(
                        cursorColor: Colors.blue,


                        focusNode: focusNode,

                        textAlign: TextAlign.left,
                        controller: textEditingController,
                        decoration: InputDecoration(

                          fillColor: Colors.white,
                            filled: true,

                            border: InputBorder.none,
                            hintText: "Write here...",
                            alignLabelWithHint: true,
                            hintStyle: GoogleFonts.quicksand(
                                textStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize:16
                                )
                            )

                        ),
                        style: GoogleFonts.quicksand(
                            textStyle: TextStyle(
                                color: Colors.black54,
                                fontSize:17
                            )
                        )
                    ),
                  ),
                )),
            Material(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.lightBlueAccent,
                  ),
                  onPressed: () {
                    onSendMessage(textEditingController.text, 0);
                  },
                ),
              ),
            ),
          ],
        ),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
              bottom:  BorderSide(
                color: Colors.grey,
                width: 0.5,
              )
          ),
          color: Colors.white,
        ));
  }

  Future getImage() async {
    imageFile1 = await ImagePicker.pickImage(source: ImageSource.gallery,
      imageQuality: 30,
    );


    final filePath = imageFile1.absolute.path;

    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    File compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 40);




    if (compressedImage != null) {
      setState(() {
        this.imageFile = compressedImage;
        isLoading = true;
      });
    }



    if (imageFile != null) {
      isLoading = true;
      uploadImageFile();
    }
  }

  Future uploadImageFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference =
    FirebaseStorage.instance.ref().child("Chat Images").child(fileName);

    StorageUploadTask storageUploadTask = storageReference.putFile(imageFile);

    StorageTaskSnapshot storageTaskSnapshot =
    await storageUploadTask.onComplete;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;

      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Error : " + error);
    });
  }
}

class UserProfileScreen extends StatefulWidget {
  final String recieverAbout;
  final String recieverId;
  final String recieverAvatar;
  final String recieverName;
  final String recieverAge;
  final bool isLiked;

  UserProfileScreen({
    Key key,
    this.recieverAbout,
    this.recieverAvatar,
    this.recieverId,
    this.recieverName,
    this.recieverAge,
    this.isLiked,
  }) : super(key: key);
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState(
    recieverAbout,
    recieverId,
    recieverAvatar,
    recieverName,
    recieverAge,
    isLiked,
  );
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final String recieverAbout;
  final String recieverId;
  final String recieverAvatar;
  final String recieverName;
  final String recieverAge;
  bool isLiked;

  _UserProfileScreenState(
      this.recieverAbout,
      this.recieverId,
      this.recieverAvatar,
      this.recieverName,
      this.recieverAge,
      this.isLiked,
      );

  int likes =0;

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    //likes = eachUser.likes;
    readDataFromLocal();

  }

  List a;

  SharedPreferences preferences;

  String id = "";
  String applink = " Flash Chat !!";

  void readDataFromLocal() async {

    preferences = await SharedPreferences.getInstance();

    id = preferences.getString("id");


    Firestore.instance.collection("users").document(recieverId).get().then((value){
      List a = value.data["likedby"];
      setState(() {
        likes = a.length;
        for(int i =0; i< a.length; i++){
          print(a[i]);
          print("Id $id");
          if(a[i] == id){
            print("I AM IN");
            isLiked = true;
            break;
          }else{
            isLiked = false;
          }
        }

      });
    });


    Firestore.instance.collection("applink").document("applink").get().then((value){
      print(value.data["link"]);

      applink = value.data["link"];
      setState(() {

        applink = applink;

      });
    });



  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(

              children: <Widget>[
                SizedBox(
                  height: 78,
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    left: 3,
                    right: 3,

                  ),
                  child: Stack(
                    children: [
                      Container(
                        height: 460,

                        child: Material(

                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FullPhoto(
                                        url: recieverAvatar,
                                      )));
                            },
                            child: Stack(
                              children: <Widget>[


                                Container(
                                  // display the old image
                                  child: Center(

                                    child: ClipRRect(

                                      child: CachedNetworkImage(
                                        placeholder: (context, url) => Container(
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.lightBlueAccent),
                                              strokeWidth: 1.0,

                                            ),
                                          ),


                                        ),
                                        imageUrl: recieverAvatar,
                                        height: 460,
                                        width: MediaQuery.of(context).size.width,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),


                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(0)),
                                  ),




                                  clipBehavior: Clip.hardEdge,
                                )


                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 396,
                        ),
                        child: Container(




                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),

                            ),
                          ),
                          child: Column(
                            children: [
                              Row(

                                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                children: [
                                  Column(

                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left:20, top: 20),
                                        child: Row(

                                          children: [

                                            Text(


                                                (recieverName[0].toUpperCase() + recieverName.substring(1)).length <= 15 ?  (recieverName[0].toUpperCase() + recieverName.substring(1)  + ", ") :
                                                (recieverName[0].toUpperCase() + recieverName.substring(1)  + ", ").replaceRange(15,  (recieverName[0].toUpperCase() + recieverName.substring(1)  + ", ").length, '...') ,

                                                textAlign: TextAlign.start,

                                                style: GoogleFonts.quicksand(
                                                  textStyle: TextStyle(
                                                    fontSize: 22,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w400,

                                                  ),
                                                )
                                            ),





                                            Text(
                                              recieverAge,

                                              style: GoogleFonts.quicksand(
                                                textStyle: TextStyle(
                                                    fontSize: 22,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w400,
                                                    letterSpacing: 1
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),


                                      ),

                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 30,
                                      top: 10,
                                    ),
                                    child: Column(
                                      children: [
                                        isLiked == true ? Icon(
                                          Icons.favorite,
                                          size: 35,
                                          color: Colors.red.shade700,
                                        ):Icon(
                                          Icons.favorite,
                                          size: 35,
                                          color: Colors.grey,
                                        ),
                                        Text("Likes: $likes",
                                          style: GoogleFonts.quicksand(
                                            textStyle: TextStyle(
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                          textAlign: TextAlign.right,
                                        ),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.black54,
                                thickness: 0.2,

                              ),

                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    top: 20,
                                    bottom: 80
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  //crossAxisAlignment: CrossAxisAlignment.end,
                                  //mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      constraints: new BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width - 84),
                                      child:
                                      Text(


                                        recieverAbout[0].toUpperCase() +
                                            recieverAbout.substring(1),

                                        textAlign: TextAlign.start,

                                        style:GoogleFonts.quicksand(
                                          textStyle:  TextStyle(

                                            fontSize: 17,
                                            color: Colors.black,


                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),


                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),



              ],
            ),
          ),

          Container(
            decoration: new BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],

            ),
            child: ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.flash_on_rounded,
                          color: Colors.yellow.shade900,
                          size: 30,
                        ),
                        Text('Flash Chat',
                          style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                fontSize: 22,
                                letterSpacing: 3,
                                color: Colors.black,

                              )
                          ),

                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            top: MediaQuery.of(context).padding.top+3,
            child: IconButton(icon: Icon(Icons.share,

              color: Colors.blue.shade700,
            ), onPressed:(){

              Share.share(applink, subject: 'Look what I made!');

            },

            ),
          )
        ],
      ),
    );
  }
}
