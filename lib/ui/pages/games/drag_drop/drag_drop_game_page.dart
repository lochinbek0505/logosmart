import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logosmart/ui/theme/app_colors.dart'; // Proyektingizdagi ranglar

import '../../../../models/target_node_model.dart'; // Kerakli model yo'llari
import '../../main/widgets/custom_text_widget.dart';
import 'models/vegetable_item.dart';

class DragDropGamePage extends StatefulWidget {
  const DragDropGamePage({Key? key}) : super(key: key);

  @override
  State<DragDropGamePage> createState() => _DragDropGamePageState();
}

class _DragDropGamePageState extends State<DragDropGamePage> {
  late List<VegetableItem> items;
  late List<VegetableItem> shadowItems;

  final Map<String, bool> matchedResults = {};
  int score = 20;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    items = [
      VegetableItem(id: 'pepper', imagePath: 'assets/game/yellow_pepper.png', name: 'Pepper'),
      VegetableItem(id: 'tomato', imagePath: 'assets/game/tomato.png', name: 'Tomato'),
      VegetableItem(id: 'eggplant', imagePath: 'assets/game/eggplant.png', name: 'Eggplant'),
      VegetableItem(id: 'cucumber', imagePath: 'assets/game/cucumber.png', name: 'Cucumber'),
    ];

    shadowItems = List.from(items);
    // shadowItems.shuffle(); // Agarda soyalar almashib turishini xohlasangiz
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // ArrowGame dagi bir xil fon rangi
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.h),

            // --- TEPADAGI HEADER (ArrowGame kodidan olindi) ---
            _buildHeader(),

            SizedBox(height: 30.h),

            // --- ASOSIY O'YIN MAYDONI (Drag va Drop) ---
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chap ustun: Rangli elementlar (Draggable)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: items.map((item) {
                        if (matchedResults[item.id] == true) {
                          return SizedBox(height: 100.h, width: 90.w);
                        }

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          child: Draggable<VegetableItem>(
                            data: item,
                            feedback: Image.asset(item.imagePath, width: 85.w, height: 85.h),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: Image.asset(item.imagePath, width: 85.w, height: 85.h),
                            ),
                            child: Image.asset(item.imagePath, width: 85.w, height: 85.h),
                          ),
                        );
                      }).toList(),
                    ),

                    // O'ng ustun: Soyalar (DragTarget)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: shadowItems.map((shadowItem) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          child: DragTarget<VegetableItem>(
                            onAcceptWithDetails: (details) {
                              if (details.data.id == shadowItem.id) {
                                setState(() {
                                  matchedResults[shadowItem.id] = true;
                                  score += 10;
                                });
                                _showSnackbar("To'g'ri topdingiz!", Colors.green);
                              } else {
                                _showSnackbar("Xato, qayta urinib ko'ring!", Colors.red);
                              }
                            },
                            builder: (context, candidateData, rejectedData) {
                              if (matchedResults[shadowItem.id] == true) {
                                return Image.asset(shadowItem.imagePath, width: 85.w, height: 85.h);
                              }

                              return ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF555555),
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(shadowItem.imagePath, width: 85.w, height: 85.h),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // --- PAZUA TUGMASI (ArrowGame stiliga moslashtirilgan o'lchamda) ---
            Center(
              child: Container(
                width: 72.w,
                height: 72.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00B0FF),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.25),
                      spreadRadius: 2.w,
                      blurRadius: 6.r,
                      offset: Offset(0, 3.h),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.pause_rounded, color: Colors.white, size: 36.w),
                  onPressed: () {
                    // Pauza bosilgandagi mantiq shakllantiriladi
                  },
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // Header metodi to'liq ArrowGame'dan ko'chirildi va moslashtirildi
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                size: 40.w,
                color: const Color(0xffFFC754),
              ),
              SizedBox(width: 8.w),
              CustomTextWidget(text: "$score", sizeText: 32.sp),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 8.5,
              bottom: 11.5,
            ),
            width: 80.w,
            height: 80.h,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/icons/circle.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage("assets/icons/circle_bad.png"),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}