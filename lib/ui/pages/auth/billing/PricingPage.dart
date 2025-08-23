import 'package:flutter/material.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPage();
}

class _PricingPage extends State<PricingPage> {
  int selectedIndex = 0;
  final List<Map<String, String>> prices = [
    {"current": "100 000", "old": "200 000"},
    {"current": "500 000", "old": "1 200 000"},
    {"current": "1 000 000", "old": "2 400 000"},
    {"current": "10 000 000", "old": "24 000 000"},
  ];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Image.asset(
                        "assets/images/arow_back.png",
                        width: 24,
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      "Qayta tiklash",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(4),

                    height: 54,
                    width: size.width,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.5,
                        color: selectedIndex == 0
                            ? Color(0xff20B9E8)
                            : Colors.grey.shade300,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: selectedIndex == 0
                              ? Color(0xff9ed6ff)
                              : Colors.grey.shade300,
                          blurRadius: 3,
                          spreadRadius: 1,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            selectedIndex == 0
                                ? Icon(
                              Icons.radio_button_checked,
                              size: 24,
                              color: Color(0xff20B9E8),
                            )
                                : Icon(
                              Icons.radio_button_off,
                              size: 24,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(width: 18),
                            Text(
                              "1 oylik",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(4),

                    height: 54,
                    width: size.width,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.5,
                        color: selectedIndex == 1
                            ? Color(0xff20B9E8)
                            : Colors.grey.shade300,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: selectedIndex == 1
                              ? Color(0xff9ed6ff)
                              : Colors.grey.shade300,
                          blurRadius: 3,
                          spreadRadius: 1,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            selectedIndex == 1
                                ? Icon(
                              Icons.radio_button_checked,
                              size: 24,
                              color: Color(0xff20B9E8),
                            )
                                : Icon(
                              Icons.radio_button_off,
                              size: 24,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(width: 18),
                            RichText(
                              text: TextSpan(
                                text: "5 oylik",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                                children: [
                                  TextSpan(
                                    text: " + 1oy",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Color(0xff93ed5f),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = 2;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(4),

                    height: 54,
                    width: size.width,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.5,
                        color: selectedIndex == 2
                            ? Color(0xff20B9E8)
                            : Colors.grey.shade300,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: selectedIndex == 2
                              ? Color(0xff9ed6ff)
                              : Colors.grey.shade300,
                          blurRadius: 3,
                          spreadRadius: 1,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            selectedIndex == 2
                                ? Icon(
                              Icons.radio_button_checked,
                              size: 24,
                              color: Color(0xff20B9E8),
                            )
                                : Icon(
                              Icons.radio_button_off,
                              size: 24,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(width: 18),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(text: " + 2oy",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Color(0xff93ed5f),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                ],
                                text: "10 oylik",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),

                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = 3;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(4),

                    height: 54,
                    width: size.width,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.5,
                        color: selectedIndex == 3
                            ? Color(0xff20B9E8)
                            : Colors.grey.shade300,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: selectedIndex == 3
                              ? Color(0xff9ed6ff)
                              : Colors.grey.shade300,
                          blurRadius: 3,
                          spreadRadius: 1,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            selectedIndex == 3
                                ? Icon(
                              Icons.radio_button_checked,
                              size: 24,
                              color: Color(0xff20B9E8),
                            )
                                : Icon(
                              Icons.radio_button_off,
                              size: 24,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(width: 18),
                            Text(
                              "Butun umrlik",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6),

                Container(
                  margin: EdgeInsets.all(4),
                  width: size.width,
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(width: 1.5, color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Siz uchun",
                            style: TextStyle(
                              color: Colors.grey.shade800,

                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),

                        Row(
                          children: [
                            Image.asset(
                              "assets/images/green.png",
                              width: 26,
                              height: 26,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "50 dan ortiq o'yinlar",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        Row(
                          children: [
                            Image.asset(
                              "assets/images/green.png",
                              width: 26,
                              height: 26,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "100 dan ortiq video darslar",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        Row(
                          children: [
                            Image.asset(
                              "assets/images/green.png",
                              width: 26,
                              height: 26,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "5 ta konsultatsiya",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        Row(
                          children: [
                            Image.asset(
                              "assets/images/green.png",
                              width: 26,
                              height: 26,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "10 dan ortiq marafonlar",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        Row(
                          children: [
                            Image.asset(
                              "assets/images/green.png",
                              width: 26,
                              height: 26,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Jamiyat",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        Row(
                          children: [
                            Image.asset(
                              "assets/images/blue.png",
                              width: 26,
                              height: 26,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Nutqni chiqarishga 100% kafolat",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14),

                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: selectedIndex == -1
                                ? "Narx tanlang"
                                : prices[selectedIndex]["current"],
                            style: TextStyle(
                              color: Colors.grey.shade900,
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                            children: selectedIndex == -1
                                ? []
                                : [
                              TextSpan(
                                text: " UZS",
                                style: TextStyle(
                                  color: Colors.grey.shade900,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (selectedIndex != -1)
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              prices[selectedIndex]["old"]! + " usz",
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.grey.shade600,
                                decorationThickness: 1.2,
                                color: Colors.grey.shade600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(0xff20B9E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Tasdiqlash",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
