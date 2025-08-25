import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Color(0xffd5eef7),
      appBar: AppBar(
        toolbarHeight: 75,
        backgroundColor: Color(0xffd5eef7),
        title: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Assalomu alaykum",style: TextStyle(fontSize: 16,color: Colors.blueGrey.shade700),),
                  Text("Lobarxon!",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.blueGrey.shade800),)
                ],
              ),
              ImageIcon(AssetImage("assets/icons/notification.png"),size: 20,color: Colors.blueGrey.shade800,)
            ],
          ),
        ),

      ),
      body: SingleChildScrollView(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
          ],
        ),
      )),
    );
  }
}
