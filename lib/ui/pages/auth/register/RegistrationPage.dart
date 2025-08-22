import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logosmart/ui/pages/auth/register/ChildRegisterPage.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();

  List regions = [];
  List districts = [];
  List quarters = [];

  List filteredDistricts = [];
  List filteredQuarters = [];

  int? agem;

  int? selectedRegionId;
  int? selectedDistrictId;
  int? selectedQuarterId;

  Future<void> loadLocationData() async {
    final String jsonStr = await rootBundle.loadString(
      'assets/jsons/regions.json',
    );
    final data = json.decode(jsonStr);
    setState(() {
      regions = data['regions'];
      districts = data['districts'];
      quarters = data['quarters'];
    });
  }

  @override
  void initState() {
    super.initState();
    loadLocationData();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15, right: 15, left: 15),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Image.asset(
                      "assets/images/arow_back.png",
                      width: 24,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Siz bilan yaqindan tanishamiz!",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 20),
                  ),

                  SizedBox(height: 25),

                  Text(
                    "Ismingiz",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 13),
                  ),
                  SizedBox(height: 6),
                  _buildTextField(_firstName, "Ismingiz"),

                  SizedBox(height: 20),

                  Text(
                    "Viloyatingiz",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 13),
                  ),
                  SizedBox(height: 5),

                  _buildDropdown<int>(

                    hind: "Viloyatingiz",
                    value: selectedRegionId,
                    items: List<Map<String, dynamic>>.from(regions),
                    onChanged: (val) {
                      setState(() {
                        selectedRegionId = val;
                        selectedDistrictId = null;
                        selectedQuarterId = null;
                        filteredDistricts = districts
                            .where((d) => d['region_id'] == val)
                            .toList();
                        filteredQuarters = [];
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  Text(
                    "Tumaningiz",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 13),
                  ),
                  SizedBox(height: 5),

                  _buildDropdown<int>(

                    hind: "Tumaningiz",
                    value: selectedDistrictId,
                    items: List<Map<String, dynamic>>.from(filteredDistricts),
                    onChanged: (val) {
                      setState(() {
                        selectedDistrictId = val;
                        selectedQuarterId = null;
                        filteredQuarters = quarters
                            .where((q) => q['district_id'] == val)
                            .toList();
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  Text(
                    "Mahallangiz",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 13),
                  ),
                  SizedBox(height: 5),

                  _buildDropdown<int>(
                    hind: "Mahallangiz",
                    value: selectedQuarterId,
                    items: List<Map<String, dynamic>>.from(filteredQuarters),
                    onChanged: (val) {
                      setState(() {
                        selectedQuarterId = val;
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  Text(
                    "Yoshingiz",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 13),
                  ),
                  SizedBox(height: 5),
                  _ageDropdown(hind: "Yoshingiz", value: agem, items:[],  onChanged: (val){setState(() {val=agem;

                  });}),


                  SizedBox(height: size.height * 0.142),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>ChildRegisterPage()));
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xff20B9E8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Keyingi",
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
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    hint, {
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
      cursorColor: Colors.grey.shade700,
      cursorHeight: 16,
      cursorWidth: 1.5,
      cursorRadius: Radius.zero,
      controller: controller,
      obscureText: obscureText,

      validator: (val) {
        if (val == null || val.isEmpty) {
          return "$hint to'ldirilishi shart!";
        }
        return null;
      },

      decoration: InputDecoration(
        isDense: true,

        contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 12),

        suffixIcon: suffixIcon,
        suffixIconColor: Colors.grey.shade600,
        filled: true,
        fillColor: Colors.white,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue.shade200, width: 1.8),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.8),
        ),
        errorStyle: TextStyle(
          fontSize: 11,
          height: 0.8,
          color: Colors.red.shade400,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({

    required hind,
    required T? value,
    required List<Map<String, dynamic>> items,
    required void Function(T?) onChanged,
  }) {
    var size = MediaQuery.of(context).size;
    return DropdownButtonFormField2<T>(

      style: TextStyle(fontSize: 14, color: Colors.grey.shade800),

      value: value,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item["id"] as T,
              child: Text(item["name"]),



            ),
          )
          .toList(),
      onChanged: onChanged,

      decoration: InputDecoration(

        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),

        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 12),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue.shade200, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.8),
        ),
        errorStyle: TextStyle(
          fontSize: 11,
          height: 0.8,
          color: Colors.red.shade400,
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 8),


      ),
      dropdownStyleData: DropdownStyleData(


        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2), // soyani rangi
              blurRadius: 20,
            ),

          ]
        ),
        maxHeight: 250,
        width: size.width*0.8,


        elevation: 4,
        offset: Offset(size.width*0.1,0)


      ),

      validator: (val) => val == null ? "$hind tanlanishi shart" : null,

    );
  }

  Widget _ageDropdown<T>({

    required hind,
    required T? value,
    required List<Map<String, dynamic>> items,
    required void Function(T?) onChanged,
  }) {
    var size = MediaQuery.of(context).size;


    return DropdownButtonFormField2<T>(


      style: TextStyle(fontSize: 14, color: Colors.grey.shade800),

      value: value,
      items: [

    for (int i = 1; i <= 200; i++)
      DropdownMenuItem(value: i as T, child: Text("$i")),
    ],
      onChanged: onChanged,

      decoration: InputDecoration(

        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),

        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 12),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue.shade200, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.8),
        ),
        errorStyle: TextStyle(
          fontSize: 11,
          height: 0.8,
          color: Colors.red.shade400,
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 8),


      ),
      dropdownStyleData: DropdownStyleData(


          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2), // soyani rangi
                  blurRadius: 20,
                ),

              ]
          ),
          maxHeight: 250,
          width: size.width*0.8,


          elevation: 4,
          offset: Offset(size.width*0.1,0)


      ),

      validator: (val) => val == null ? "$hind tanlanishi shart" : null,

    );
  }

}
