import 'package:dashboardapp/roadmap.dart';
import 'package:dashboardapp/globals.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class roadMapsPage extends StatefulWidget {
  final bool? adminbool;
  const roadMapsPage({Key? key, this.adminbool}) : super(key: key);

  @override
  State<roadMapsPage> createState() => _roadMapsPageState();
}

class _roadMapsPageState extends State<roadMapsPage> {
  final TextEditingController roadmapName = TextEditingController();
  final TextEditingController roadmapLink = TextEditingController();
  Map<String, dynamic> postData = {};
  var db = FirebaseFirestore.instance;
  late List<Map<String, dynamic>> roadmaps = [];
  bool initializing = true;

  Future<void> addResource() async {
    Navigator.pop(context);

    postData = {
      "name": roadmapName.text,
      "link": roadmapLink.text,
    };

    await db.collection("resources").add(postData);
    roadmaps.insert(0, postData);
    setState(() {
      roadmapName.clear();
      roadmapLink.clear();
    });
  }

  Future<void> fetchMaps() async {
    await db.collection("resources").orderBy("name").get().then((event) {
      for (var doc in event.docs) {
        roadmaps.add(doc.data());
      }
      roadmaps = roadmaps.reversed.toList();
      setState(() {
        initializing = false;
      });
    });
  }

  @override
  void initState() {
    fetchMaps();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Roadmaps'),
        ),
        body: initializing
            ? Center(
                child: LoadingAnimationWidget.inkDrop(
                  color: const Color.fromARGB(255, 199, 110, 215),
                  size: 80,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView.builder(
                  itemCount: roadmaps.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewApp(
                                  roadmaplink: roadmaps[i]["link"],
                                ),
                              ),
                            );
                          },
                          child: Material(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            elevation: 20,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              height: GlobalVars.height_100,
                              width: GlobalVars.fullwidth,
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Color.fromARGB(137, 179, 176, 176),
                                    Color.fromARGB(60, 166, 156, 156)
                                  ]),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Center(
                                child: Text(
                                  roadmaps[i]['name'],
                                  style: const TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: GlobalVars.height_20,
                        ),
                      ],
                    );
                  },
                ),
              ),
        floatingActionButton: widget.adminbool ?? false
            ? FloatingActionButton(
                onPressed: () {
                  showAdaptiveDialog(
                      context: context,
                      builder: (builder) {
                        return AlertDialog(
                          title: const Text("Add a resource"),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: roadmapName,
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
                                      hintText: 'Resource Name',
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
                                  controller: roadmapLink,
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
                                      hintText: 'Roadmap Link',
                                      hintStyle: TextStyle(
                                          color: Color.fromARGB(
                                              135, 118, 116, 116),
                                          fontSize: 14)),
                                ),
                                SizedBox(
                                  height: GlobalVars.height_20,
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      addResource();
                                    },
                                    child: const Text("Add"))
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
