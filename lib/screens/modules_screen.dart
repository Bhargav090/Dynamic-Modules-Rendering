import 'dart:convert';
import 'package:dynamicrendering/screens/cake_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  List<dynamic> modules = [];
  @override
  void initState() {
    super.initState();
    loadData();
  }

  // for fetching the modules from the json file-----------------
  Future<void> loadData() async {
    final String jsonString =
        await rootBundle.loadString('lib/backend/api.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    setState(() {
      modules = data['modules'];
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding:EdgeInsets.only(left:height*0.02),
          child: Text('Welcome', style: TextStyle(fontSize: height*0.026, fontWeight: FontWeight.w600),),
        ),
      ),
      body: modules.isEmpty
      // Like if there were not modules then it will this display this part-----
          ? Center(
              child: Text(
                "Sorry There is No Modules for Now😔",
                style: TextStyle(
                    fontSize: height * 0.04, fontWeight: FontWeight.w700),
              ),
            )
            // if modules are there then it will show this part------------
          : ListView.builder(
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index] as Map<String, dynamic>;
                final courseImage = module['image']!;
                final courseName = module['name']!;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CakeScreen(module: module),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(height * 0.02),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical:height*0.01),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(height*0.02),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                courseImage,
                                width: height*0.7,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: height * 0.02),
                          Padding(
                              padding: EdgeInsets.all(height * 0.02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    courseName,
                                    style: TextStyle(
                                      fontSize: height * 0.03,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: height * 0.01),
                                  Text(
                                    "Tap to explore more!",
                                    style: TextStyle(
                                      fontSize: height * 0.02,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
