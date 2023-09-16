import 'package:dashboardapp/roadmap.dart';
import 'package:dashboardapp/ui_sizes.dart';
import 'package:flutter/material.dart';

class roadMapsPage extends StatefulWidget {
  const roadMapsPage({super.key});

  @override
  State<roadMapsPage> createState() => _roadMapsPageState();
}

class _roadMapsPageState extends State<roadMapsPage> {
  @override
  Widget build(BuildContext context) {
    var roadmaps = {
      'Android Developer': 'https://roadmap.sh/android',
      'Flutter Developer': 'https://roadmap.sh/flutter',
      'React Native Developer': 'https://roadmap.sh/react-native',
      'UX Design': 'https://roadmap.sh/ux-design',
      'Java': 'https://roadmap.sh/java',
      'Mongo DB': 'https://roadmap.sh/mongodb',
    };
    List keys = roadmaps.keys.toList();
    return Padding(
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
                        roadmaplink: roadmaps[keys[i]],
                      ),
                    ),
                  );
                },
                child: Material(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  elevation: 20,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    height: UiSizes.height_100,
                    width: UiSizes.fullwidth,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Color.fromARGB(137, 179, 176, 176),
                          Color.fromARGB(60, 166, 156, 156)
                        ]),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Center(
                      child: Text(
                        keys[i],
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
                height: UiSizes.height_20,
              ),
            ],
          );
        },
      ),
    );
  }
}
