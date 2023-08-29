import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
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
              padding: EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (BuildContext context, int i) {
                  return Column(
                    children: [
                      Material(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        elevation: 20,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          height: 160,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                const Color.fromARGB(137, 179, 176, 176),
                                const Color.fromARGB(60, 166, 156, 156)
                              ]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Column(children: [
                            SizedBox(
                              height: 25,
                              child: ListView.builder(
                                  itemCount: posts[i]['tags'].length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: ((context, index) => Row(
                                        children: [
                                          Container(
                                            width: 105,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                gradient: LinearGradient(
                                                    colors: [
                                                      Color.fromARGB(
                                                          255, 62, 160, 240),
                                                      const Color.fromARGB(
                                                          255, 22, 122, 204)
                                                    ])),
                                            child: Center(
                                              child: Text(
                                                posts[i]['tags'][index],
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          )
                                        ],
                                      ))),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: Text(
                                  posts[i]['name'],
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                    padding: EdgeInsets.only(left: 7),
                                    child: Text(posts[i]['description'])))
                          ]),
                        ),
                      ),
                      SizedBox(
                        height: 20,
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
                        width: 400,
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
                          dropdownHeight: 300,
                          optionTextStyle: const TextStyle(fontSize: 16),
                          selectedOptionIcon: const Icon(Icons.check_circle),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
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
                      const SizedBox(
                        height: 10,
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
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            await postUpdate();
                          },
                          child: const Text("Post"))
                    ],
                  ),
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
