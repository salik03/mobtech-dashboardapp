import 'package:dashboardapp/globals.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class updatesScreen extends StatefulWidget {
  final bool? admin;
  const updatesScreen({Key? key, this.admin}) : super(key: key);

  @override
  State<updatesScreen> createState() => _updatesScreenState();
}

class _updatesScreenState extends State<updatesScreen> {
  final TextEditingController addTag = TextEditingController();
  final TextEditingController postName = TextEditingController();
  final TextEditingController postDescription = TextEditingController();
  late String tag;
  var db = FirebaseFirestore.instance;
  bool initializing = true;
  late List<Map<String, dynamic>> posts = [];
  Map<String, dynamic> postData = {};
  OutlineInputBorder enabledTextFieldBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.purple),
      borderRadius: BorderRadius.circular(15));

  Future<void> postUpdate() async {
    Navigator.pop(context);

    if (GlobalVars.globalPassword!.contains("chair")) {
      tag = "Chairperson";
    } else if (GlobalVars.globalPassword!.contains("vicechair")) {
      tag = "Vice Chairperson";
    } else if (GlobalVars.globalPassword!.contains("technical")) {
      tag = "Technical Team";
    } else if (GlobalVars.globalPassword!.contains("project")) {
      tag = "Project Team";
    } else if (GlobalVars.globalPassword!.contains("content")) {
      tag = "Content Team";
    } else if (GlobalVars.globalPassword!.contains("marketing")) {
      tag = "Marketing Team";
    } else if (GlobalVars.globalPassword!.contains("design")) {
      tag = "Design Team";
    } else {
      tag = "Core Team";
    }

    postData = {
      "tag": tag,
      "name": postName.text,
      "description": postDescription.text,
      "createdAt": FieldValue.serverTimestamp()
    };

    await db.collection("posts").add(postData);
    posts.insert(0, postData);
    await sendNotification();
    setState(() {
      postName.clear();
      postDescription.clear();
    });
  }

  @override
  void initState() {
    fetchPosts();
    super.initState();
  }

  Future<void> fetchPosts() async {
    await db.collection("posts").orderBy("createdAt").get().then((event) {
      for (var doc in event.docs) {
        posts.add(doc.data());
      }
      posts = posts.reversed.toList();
      setState(() {
        initializing = false;
      });
    });
  }

  Future<void> sendNotification() async {
    var headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> notificationData = {
      "title": tag.toString(),
      "body": postName.text
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://mobilon-backend.onrender.com/sendPushNotifications'));
    request.body = jsonEncode(notificationData);
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Latest Updates',
            style: TextStyle(fontFamily: 'Raleway'),
          ),
        ),
        body: initializing
            ? Center(
                child: LoadingAnimationWidget.inkDrop(
                  color: const Color.fromARGB(255, 199, 110, 215),
                  size: 80,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Column(
                      children: [
                        Material(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          elevation: 20,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            height: GlobalVars.height_160,
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Color.fromARGB(137, 179, 176, 176),
                                  Color.fromARGB(60, 166, 156, 156)
                                ]),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Column(children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  height: GlobalVars.height_25,
                                  child: Container(
                                    width: GlobalVars.width_105,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: const LinearGradient(colors: [
                                          Color.fromARGB(255, 62, 160, 240),
                                          Color.fromARGB(255, 22, 122, 204)
                                        ])),
                                    child: Center(
                                      child: Text(
                                        posts[i]['tag'],
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: GlobalVars.height_10,
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text(
                                    posts[i]['name'],
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: GlobalVars.height_10,
                              ),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                      padding: const EdgeInsets.only(left: 7),
                                      child: Text(posts[i]['description'])))
                            ]),
                          ),
                        ),
                        SizedBox(
                          height: GlobalVars.height_20,
                        )
                      ],
                    );
                  },
                ),
              ),
        floatingActionButton: widget.admin ?? false
            ? FloatingActionButton(
                onPressed: () {
                  showAdaptiveDialog(
                      context: context,
                      builder: (builder) {
                        return AlertDialog(
                          title: const Text("Create an Update"),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: GlobalVars.height_20,
                                ),
                                TextField(
                                  controller: postName,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 72, 68, 68),
                                      fontSize: 18),
                                  cursorRadius: const Radius.circular(20),
                                  cursorColor:
                                      const Color.fromARGB(95, 88, 87, 87),
                                  decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color.fromARGB(
                                                  135, 50, 49, 49))),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color.fromARGB(
                                                  72, 72, 65, 65))),
                                      hintText: 'Post Title',
                                      hintStyle: TextStyle(
                                          color: Color.fromARGB(
                                              135, 118, 116, 116),
                                          fontSize: 18)),
                                ),
                                SizedBox(
                                  height: GlobalVars.height_10,
                                ),
                                TextField(
                                  maxLines: 4,
                                  controller: postDescription,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 72, 68, 68),
                                      fontSize: 14),
                                  cursorRadius: const Radius.circular(20),
                                  cursorColor:
                                      const Color.fromARGB(95, 88, 87, 87),
                                  decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color.fromARGB(
                                                  135, 50, 49, 49))),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color.fromARGB(
                                                  72, 72, 65, 65))),
                                      hintText: 'Description',
                                      hintStyle: TextStyle(
                                          color: Color.fromARGB(
                                              135, 118, 116, 116),
                                          fontSize: 14)),
                                ),
                                SizedBox(
                                  height: GlobalVars.height_20,
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      await postUpdate();
                                      print("About to send Notifications");
                                      await sendNotification();
                                    },
                                    child: const Text("Post"))
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: const Icon(Icons.add),
              )
            : null);
  }
}
