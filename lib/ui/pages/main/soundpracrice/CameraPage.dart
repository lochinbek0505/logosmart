import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logosmart/ui/widgets/AICamera.dart';
import 'package:camera/camera.dart';

import '../../../../core/storage/level_state.dart';

class CameraPage extends StatefulWidget {
  LevelState data;
  CameraPage({super.key , required this.data});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  void initState() {
    super.initState();
    // Future.delayed(const Duration(seconds: 5), () {
    //   Navigator.of(context).push(MaterialPageRoute(builder: (_) =>  FinishButtonPage()),);
    // });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,

        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/backround_xira.png"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(
              width: size.width,
              height: size.height,
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Image.asset(
                                "assets/icons/arrow_right_button.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Image.asset(
                                "assets/icons/star.png",
                                width: 40,
                                height: 40,
                              ),
                              SizedBox(width: 12),
                              Image.asset(
                                "assets/icons/namber_o.png",
                                height: 35,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: size.width, height: 150),
                Container(
                  width: size.width * 0.6,
                  height: size.width * 0.6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Color(0xff20B9E8), width: 3
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(19),
                      color: Colors.white,
                      image: DecorationImage(
                        image: AssetImage("assets/images/yarimta_qizcha.png"),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 15),
                Container(
                  width: size.width * 0.6,
                  height: size.width * 0.6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: Color(0xff20B9E8), width: 3
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: AICamera(
                      modelPath: widget.data.exercise!.modelPath,
                      labelsPath: widget.data.exercise!.labelsPath,
                      useGpu: true,
                      numThreads: 2,
                      lensDirection: CameraLensDirection.front,
                      intervalMs: 450,
                      iouThreshold: 0.45,
                      confThreshold: 0.35,
                      classThreshold: 0.5,
                      // Natijalarni olish: UI’da chizmaymiz, faqat yuqoriga yuboramiz
                      onDetections: _onDetectionsLog,
                    ),
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );


  }


  static void _onDetectionsLog(List<Map<String, dynamic>> results, Size imgSize) {
    if (results.isEmpty) return;

    // Birinchi natijani toast qilib ko‘rsatamiz
    final first = results.first;
    final tag = first['tag'] ?? 'Unknown';
    final box = first['box'] as List?;
    final conf = box != null && box.length > 4
        ? ((box[4] as num).toDouble() * 100).toStringAsFixed(0)
        : '?';

    Fluttertoast.showToast(
      msg: "Aniqlandi: $tag ($conf%)",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

}
