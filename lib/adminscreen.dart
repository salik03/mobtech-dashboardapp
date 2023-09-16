import 'package:dashboardapp/ui_sizes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class admindashboard extends StatefulWidget {
  const admindashboard({super.key});

  @override
  State<admindashboard> createState() => _admindashboardState();
}

class _admindashboardState extends State<admindashboard> {
  final TextEditingController addTag = TextEditingController();
  final TextEditingController postName = TextEditingController();
  final TextEditingController postDescription = TextEditingController();
  final MultiSelectController _controller = MultiSelectController();
  late List<ValueItem> selectedTags;
  var db = FirebaseFirestore.instance;
  bool initializing = true;
  late List tags = [];
  late List<Map<String, dynamic>> posts = [];
  Map<String, dynamic> postData = {};
  OutlineInputBorder enabledTextFieldBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.purple),
      borderRadius: BorderRadius.circular(15));

  Future<void> postUpdate() async {
    Navigator.pop(context);
    tags.clear();
    for (int i = 0; i < selectedTags.length; i++) {
      tags.add(selectedTags[i].label);
    }

    postData = {
      "tags": tags,
      "name": postName.text,
      "description": postDescription.text,
      "createdAt": FieldValue.serverTimestamp()
    };

    await db.collection("posts").add(postData);
    posts.insert(0, postData);
    await sendNotification();
    setState(() {});
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
      "title": tags[0].toString(),
      "body": postName.text
    };
    var request = http.Request(
        'POST', Uri.parse('http://10.12.52.227:3000/sendPushNotifications'));
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
          'Mobilon',
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
                          height: UiSizes.height_160,
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color.fromARGB(137, 179, 176, 176),
                                Color.fromARGB(60, 166, 156, 156)
                              ]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Column(children: [
                            SizedBox(
                              height: UiSizes.height_25,
                              child: ListView.builder(
                                  itemCount: posts[i]['tags'].length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: ((context, index) => Row(
                                        children: [
                                          Container(
                                            width: UiSizes.width_105,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                gradient: const LinearGradient(
                                                    colors: [
                                                      Color.fromARGB(
                                                          255, 62, 160, 240),
                                                      Color.fromARGB(
                                                          255, 22, 122, 204)
                                                    ])),
                                            child: Center(
                                              child: Text(
                                                posts[i]['tags'][index],
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: UiSizes.width_5,
                                          )
                                        ],
                                      ))),
                            ),
                            SizedBox(
                              height: UiSizes.height_10,
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
                              height: UiSizes.height_10,
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
                        height: UiSizes.height_20,
                      )
                    ],
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAdaptiveDialog(
              context: context,
              builder: (builder) {
                return AlertDialog(
                  title: const Text("Create an Update"),
                  content: Column(
                    children: [
                      SizedBox(
                        width: UiSizes.width_400,
                        child: MultiSelectDropDown(
                          hint: 'Select a Tag',
                          onOptionSelected: (List<ValueItem> selectedOptions) {
                            print(selectedOptions);
                            selectedTags = selectedOptions;
                          },
                          options: const <ValueItem>[
                            ValueItem(label: 'Chairperson'),
                            ValueItem(label: 'Vice Chairperson'),
                            ValueItem(label: 'Content Team'),
                            ValueItem(label: 'Marketing Team'),
                            ValueItem(label: 'Design Team'),
                            ValueItem(
                              label: 'Tech Team',
                            ),
                            ValueItem(label: 'Project Team'),
                          ],
                          selectionType: SelectionType.multi,
                          chipConfig:
                              const ChipConfig(wrapType: WrapType.scroll),
                          dropdownHeight: UiSizes.height_300,
                          optionTextStyle: const TextStyle(fontSize: 16),
                          selectedOptionIcon: const Icon(Icons.check_circle),
                        ),
                      ),
                      SizedBox(
                        height: UiSizes.height_20,
                      ),
                      TextField(
                        controller: postName,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 72, 68, 68),
                            fontSize: 18),
                        cursorRadius: const Radius.circular(20),
                        cursorColor: const Color.fromARGB(95, 88, 87, 87),
                        decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(135, 50, 49, 49))),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(72, 72, 65, 65))),
                            hintText: 'Post Title',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(135, 118, 116, 116),
                                fontSize: 18)),
                      ),
                      SizedBox(
                        height: UiSizes.height_10,
                      ),
                      TextField(
                        maxLines: 4,
                        controller: postDescription,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 72, 68, 68),
                            fontSize: 14),
                        cursorRadius: const Radius.circular(20),
                        cursorColor: const Color.fromARGB(95, 88, 87, 87),
                        decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(135, 50, 49, 49))),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(72, 72, 65, 65))),
                            hintText: 'Description',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(135, 118, 116, 116),
                                fontSize: 14)),
                      ),
                      SizedBox(
                        height: UiSizes.height_20,
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
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
