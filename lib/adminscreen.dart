import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  late List tags = [];
  late List posts = [];
  Map<String, dynamic> postData = {};
  OutlineInputBorder enabledTextFieldBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.purple),
      borderRadius: BorderRadius.circular(15));

  @override
  void initState() {
    fetchPosts();
    super.initState();
  }

  void fetchPosts() async {
    await db.collection("posts").get().then((event) {
      for (var doc in event.docs) {
        posts.add(doc.data());
      }
      print(posts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mobile Tech'),
      ),
      body: Padding(padding: EdgeInsets.all(20)),
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
                          onPressed: () {
                            Navigator.pop(context);
                            for (int i = 0; i < selectedTags.length; i++) {
                              tags.add(selectedTags[i].label);
                            }
                            print(tags);
                            postData['tags'] = tags;
                            postData['name'] = postName.text;
                            postData['description'] = postDescription.text;
                            db.collection("posts").add(postData);
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
