import 'package:flutter/material.dart';
import 'package:flutter_application_1/color/colors.dart';

class TaskAssignApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TaskAssignScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TaskAssignScreen extends StatelessWidget {
  final List<Map<String, String>> tasks = [
    {
      "title": "Prathamesh",
      "date": "20 Apr 2025",
      "time": "15:21",
      "name": "diksha algat",
      "description": "hii"
    },
    {
      "title": "nilesh",
      "date": "20 Apr 2025",
      "time": "15:22",
      "name": "diksha algat",
      "description": "hello"
    },
    {
      "title": "pritesh",
      "date": "21 Apr 2025",
      "time": "15:22",
      "name": "diksha algat",
      "description": "test"
    },
    {
      "title": "sumit",
      "date": "15 Apr 2025",
      "time": "13:49",
      "name": "diksha algat",
      "description": "yy"
    },
    {
      "title": "kundan",
      "date": "16 Apr 2025",
      "time": "10:15",
      "name": "diksha algat",
      "description": ""
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kwhite,
      appBar: AppBar(
        backgroundColor: kOrange,
        title: Text('Task Assign To Me', style: TextStyle(color: kwhite)),
        centerTitle: true,
        leading: Icon(Icons.menu, color: kwhite),
        actions: [
          Icon(Icons.notifications, color: kwhite),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: kwhite,
            child: Row(
              children: [
                tabButton("PENDING", true),
                tabButton("CHECKED IN", false),
                tabButton("COMPLETED", false),
              ],
            ),
          ),
          SizedBox(height: 20),
          //SizedBox(height: 20,),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextField(
          //     decoration: InputDecoration(
          //       hintText: "Search by Task name",
          //       hintStyle: TextStyle(color: kgreyText),
          //       prefixIcon: Icon(Icons.search, color: kgreyText),
          //       filled: true,
          //       fillColor: kwhite,
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(10),
          //         borderSide: BorderSide.none,
          //       ),
          //     ),
          //   ),
          // ),

          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  color: kwhite,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        color: kgreyText,
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(task["date"]!.split(" ")[0],
                                style: TextStyle(color: kwhite)),
                            Text(
                              task["date"]!.split(" ")[1] +
                                  " " +
                                  task["date"]!.split(" ")[2],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kwhite,
                              ),
                            ),
                            Text(task["time"]!, style: TextStyle(color: kwhite)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task["title"]!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: kBlack)),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.person, size: 14, color: kgreyText),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      task["name"]!,
                                      style: TextStyle(color: kgreyText),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 14, color: kgreyText),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      "${task["date"]} ${task["time"]} - To - ${task["date"]} ${task["time"]}",
                                      style: TextStyle(color: kgreyText),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.notes, size: 14, color: kgreyText),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      task["description"]!.isEmpty
                                          ? "-"
                                          : task["description"]!,
                                      style: TextStyle(color: kgreyText),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Icon(Icons.location_pin, color: kOrange),
                          Icon(Icons.group, color: kOrange),
                        ],
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget tabButton(String text, bool isActive) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? kOrange : kgreyText,
          borderRadius: BorderRadius.circular(isActive ? 30 : 0),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? kwhite : kBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
