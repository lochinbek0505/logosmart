import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late List<bool> chekeSelected;



  List<Map<String, dynamic>> settings=[
    {
      "text":"Bildirishnoma ovozi",
    },
    {
      "text":"O'yinlar ovozi",

    },
    {
      "text":"Vibratsiya",

    }
  ];


  @override
  void initState() {
    super.initState();
    chekeSelected = List.filled(settings.length, false);

  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [

          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    "assets/images/arow_back.png",
                    width: 22,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  "Sozlamalar",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: settings.length,

                itemBuilder: (context, index) {

                  return Padding(
                    padding: const EdgeInsets.only(left: 6,right: 6,bottom: 10),
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade200,
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: Offset(0, 2)
                            )
                          ],
                        border: Border.all(color: Colors.grey.shade200,)

                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(settings[index]["text"],style: TextStyle(
                              color: Colors.blueGrey.shade800,
                              fontWeight: FontWeight.w400,
                              fontSize: 17
                            ),),

                        GestureDetector(
                          onTap: () {
                            setState(() {
                              chekeSelected[index]=!chekeSelected[index];
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            width: 42,
                            height: 26,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: chekeSelected[index] ? Color(0xff20B9E8) : Colors.grey.shade400,
                            ),
                            child: Stack(
                              children: [
                                AnimatedAlign(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  alignment:
                                  chekeSelected[index] ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 400),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: chekeSelected[index] ? Colors.white : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),




                      ],
                        ),
                      ),
                    ),
                  );
                }
              ),
            )
          ]
        ),
      )),
    );
  }
}
