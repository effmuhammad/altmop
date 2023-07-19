import 'package:altmop/ui/get_data_page.dart';
import 'package:altmop/ui/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:altmop/ui/feature/well_monitoring/well_monitoring.dart';
import 'dart:async';
import 'package:change_notifier_builder/change_notifier_builder.dart';
import 'package:altmop/ui/home/feature_card.dart';
import 'package:altmop/ui/feature/tank_on_site/tank_on_site_monitoring.dart';
import 'package:altmop/ui/feature/qas_oil.dart';
import 'package:altmop/ui/feature/fluid_properties.dart';
import 'package:altmop/models/well_selected.dart';
import 'package:device_preview/device_preview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:altmop/models/fluid_prop.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altmop/models/qas_oil_calc.dart';

class User {
  final String name;

  User({required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class MySharedPreferences {
  static const String _userKey = 'user';

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = json.encode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  static Future<User> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) {
      return User(name: 'Altmop User');
    }
    final userMap = json.decode(userJson);
    return User.fromJson(userMap);
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MaterialApp(
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          title: 'ALTMOP',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            primaryColor: Colors
                .blueGrey.shade100, //const Color.fromRGBO(241, 149, 8, 1),
            scaffoldBackgroundColor:
                Colors.white, //const Color.fromRGBO(246, 231, 216, 1),
            cardColor: Colors.white,
          ),
          home: const MainScreen(title: 'ALTMOP 4.0'),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.title});

  final String title;

  @override
  State<MainScreen> createState() => _MainState();
}

class _MainState extends State<MainScreen> {
  var wellSel = WellSelected();
  FluidProp propData = FluidProp();
  QasOilCalc qasOilCalc = QasOilCalc();
  TextEditingController userName = TextEditingController(text: '');

  void connErrorSnackBar() {
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.error(
        textAlign: TextAlign.start,
        maxLines: 4,
        message:
            'Something went wrong :( . Check your internet connection or call your technical support.',
      ),
    );
  }

  void updateAllWell() async {
    wellSel.setLoadingAllWell = true;
    try {
      final response = await http
          .get(Uri.parse(
              'https://script.google.com/macros/s/AKfycbxTAp84bJrtCd65U2tt7M5IuYm9zGLwkbkRsY1_2J_6DQLmfOWhFbujLoNAzMixGXrb/exec?'
              'action=read'
              '&user_req=allwell'))
          .timeout(Duration(seconds: 20));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        wellSel.setServerOk = true;
        print(jsonData['allwell']);
        wellSel.setAllWell = jsonData;
      } else {
        wellSel.setServerOk = false;
        connErrorSnackBar();
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
      wellSel.setServerOk = false;
      connErrorSnackBar();
    }
    wellSel.setLoadingAllWell = false;
    updateWellProperties();
    wellSel.loadDData().then((res) => !res ? connErrorSnackBar() : null);
    wellSel.loadDTosData().then((res) => !res ? connErrorSnackBar() : null);
    wellSel.loadTankLevel().then((res) => !res ? connErrorSnackBar() : null);
    wellSel
        .loadH2Data(wellSel.getH2ShowDate)
        .then((res) => !res ? connErrorSnackBar() : null);
  }

  void updateWellProperties() async {
    wellSel.setLoadingData = true;
    try {
      final response = await http
          .get(Uri.parse(
              'https://script.google.com/macros/s/AKfycbxTAp84bJrtCd65U2tt7M5IuYm9zGLwkbkRsY1_2J_6DQLmfOWhFbujLoNAzMixGXrb/exec?'
              'action=read'
              '&user_req=properties'
              '&wellname=${wellSel.getWellName}'))
          .timeout(Duration(seconds: 20));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        wellSel.setServerOk = true;
        print(jsonData);
        wellSel.setLength = jsonData['Length'].toString();
        wellSel.setWidth = jsonData['Width'].toString();
        wellSel.setHeight = jsonData['Height'].toString();
        wellSel.setInstDate = jsonData['Instalation Date'].toString();
        wellSel.setLocation = jsonData['Location'].toString();
        wellSel.setVillage = jsonData['Village'].toString();
        wellSel.setStatus = jsonData['Status'].toString();
        wellSel.setGSName = jsonData['GS Name'].toString();
        wellSel.setLiftingMethod = jsonData['Lifting Method'].toString();
        wellSel.setWaterCut = jsonData['Water Cut'].toString();
        wellSel.setBSnW = jsonData['BS&W'].toString();

        wellSel.setCapacity = jsonData['Capacity'].toString();
        wellSel.setTrucking = jsonData['Trucking Transportation'].toString();
        wellSel.setTemperature = jsonData['Temperature'].toString();
        wellSel.setDensity = jsonData['Density'].toString();
        wellSel.setCM1 = jsonData['1 CM'].toString();
      } else {
        wellSel.setServerOk = false;
        connErrorSnackBar();
        throw Exception('Failed to load data');
      }
    } catch (e) {
      wellSel.setServerOk = false;
      print('aaaa');
      connErrorSnackBar();
    }
    wellSel.setLoadingData = false;
  }

  Future<void> requestPermission() async {
    /// status can either be: granted, denied, restricted or permanentlyDenied
    var status = await Permission.location.status;
    var status1 = await Permission.bluetooth.status;
    var status2 = await Permission.bluetoothConnect.status;
    var status3 = await Permission.bluetoothScan.status;
    var status4 = await Permission.bluetoothAdvertise.status;
    if (status.isGranted &&
        status1.isGranted &&
        status2.isGranted &&
        status3.isGranted &&
        status4.isGranted) {
      debugPrint("Permission is granted");
    } else {
      if (await Permission.location.request().isGranted) {
        debugPrint("Location permission was granted");
      }
      if (await Permission.bluetooth.request().isGranted) {
        debugPrint("Permission1 was granted");
      }
      if (await Permission.bluetoothConnect.request().isGranted) {
        debugPrint("Permission2 was granted");
      }
      if (await Permission.bluetoothScan.request().isGranted) {
        debugPrint("Permission3 was granted");
      }
      if (await Permission.bluetoothAdvertise.request().isGranted) {
        debugPrint("Permission4 was granted");
      }
    }
    enableBluetooth();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    BluetoothEnable.enableBluetooth.then((result) {
      if (result == "true") {
        // Bluetooth has been enabled
      } else if (result == "false") {
        // Bluetooth has not been enabled
      }
    });
  }

  void loadSP() async {
    userName.text =
        await MySharedPreferences.loadUser().then((value) => value.name);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    updateAllWell();
    requestPermission();
    loadSP();
    print("Home paling depan");
  }

  void _showChangeNameDialog() {
    String newName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Change Name',
            style: TextStyle(color: Colors.blueGrey),
          ),
          content: TextFormField(
            controller: userName,
            decoration: InputDecoration(
              hintText: 'Enter your new name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                print(userName.text);
                MySharedPreferences.saveUser(User(name: userName.text));
                userName.text = await MySharedPreferences.loadUser()
                    .then((value) => value.name);
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var dateTimeUpdate = DateTimeUpdate();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 50.r,
        title: Text(widget.title, style: TextStyle(fontSize: 18.sp)),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.sp),
            child: GestureDetector(
              onTap: () {
                enableBluetooth();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
              },
              child: Icon(
                Icons.settings_rounded,
                size: 26.0.sp,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => _showChangeNameDialog(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome,',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          SizedBox(
                            width: 240.sp,
                            child: Text(
                              userName.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 70.r,
                  width: 70.r,
                  child:
                      Image.asset('assets/images/logo5_26_1061-removebg.png'),
                )
              ],
            ),
            SizedBox(height: 20.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.all(
                  Radius.circular(10.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor,
                    blurRadius: 5.0,
                    spreadRadius: 0.5,
                    offset: Offset(3.0, 5.0),
                  )
                ],
              ),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                // height: 110.0.r,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.r),
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.r, vertical: 10.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ChangeNotifierBuilder(
                        notifier: dateTimeUpdate,
                        builder: (BuildContext context,
                            DateTimeUpdate? dateTimeUpdate, _) {
                          return Text(
                            dateTimeUpdate!.time,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20.sp,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 5.h),
                      ChangeNotifierBuilder(
                        notifier: dateTimeUpdate,
                        builder: (BuildContext context,
                            DateTimeUpdate? dateTimeUpdate, _) {
                          return Text(
                            "${dateTimeUpdate!.dayToday}, ${dateTimeUpdate.dateToday}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 2.h),
                      ChangeNotifierBuilder(
                        notifier: wellSel,
                        builder:
                            (BuildContext context, WellSelected? wellSel, _) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Select Well",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              DropdownButton<String>(
                                value: wellSel!.getWellName,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 15.sp,
                                elevation: 16,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                ),
                                underline: Container(
                                  height: 2,
                                  color: Colors.blueGrey,
                                ),
                                onChanged: (String? newValue) {
                                  wellSel.setWellName = newValue!;
                                  updateWellProperties();
                                  wellSel.loadDData().then((res) =>
                                      !res ? connErrorSnackBar() : null);
                                  wellSel
                                      .loadH2Data(wellSel.getH2ShowDate)
                                      .then((res) =>
                                          !res ? connErrorSnackBar() : null);
                                  wellSel.loadDTosData().then((res) =>
                                      !res ? connErrorSnackBar() : null);
                                  wellSel.loadTankLevel().then((res) =>
                                      !res ? connErrorSnackBar() : null);
                                },
                                items: wellSel.getAllWell
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                              SizedBox(width: 20.w),
                              GestureDetector(
                                onTap: updateAllWell,
                                child: wellSel.isLoadingAllWell
                                    ? SizedBox(
                                        height: 20.h,
                                        width: 20.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.r,
                                        ))
                                    : Icon(
                                        Icons.refresh,
                                        size: 25.sp,
                                      ),
                              )
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Expanded(flex: 1, child: SizedBox()),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(flex: 1, child: SizedBox()),
                FeatureCard(
                  title: 'Well Monitoring',
                  iconPath: 'assets/images/sec1.png',
                  onPressed: () {
                    print('Well Monitoring Pressed');
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WellMonitoring(
                          wellsel: wellSel,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 20.w),
                FeatureCard(
                  title: 'Tank On Site Monitoring',
                  iconPath: 'assets/images/sec3.png',
                  onPressed: () {
                    print('Tank On Site Monitoring Pressed');
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TankOnSiteMonitoring(
                          wellsel: wellSel,
                        ),
                      ),
                    );
                  },
                ),
                const Expanded(flex: 1, child: SizedBox()),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(flex: 3, child: SizedBox()),
                FeatureCard(
                  title: 'QAS Oil',
                  iconPath: 'assets/images/sec2.png',
                  onPressed: () {
                    print('QAS Oil Pressed');
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => QasOil(
                          qasOilCalc: qasOilCalc,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 20.w),
                FeatureCard(
                  title: 'Fluid Properties',
                  iconPath: 'assets/images/sec4.png',
                  onPressed: () {
                    print('Fluid Properties Pressed');
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FluidProperties(
                          propData: propData,
                        ),
                      ),
                    );
                  },
                ),
                const Expanded(flex: 3, child: SizedBox()),
              ],
            ),
            const Expanded(flex: 1, child: SizedBox()),
            Padding(
              padding: EdgeInsets.all(8.0.r),
              child: Text(
                "Artificial Lift Technology Monitoring Production",
                style: TextStyle(color: Colors.blueGrey, fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DateTimeUpdate extends ChangeNotifier {
  String _dayToday = '';
  String _dateToday = '';
  String _time = '';

  DateTimeUpdate() {
    updateTime();
    Timer.periodic(Duration(milliseconds: 500), (t) {
      updateTime();
    });
  }
  void updateTime() {
    DateTime now = DateTime.now();
    _dayToday = DateFormat('EEEE').format(now);
    _dateToday = DateFormat('d MMMM yyyy').format(now);
    _time = DateFormat("HH:mm:ss").format(now);
    notifyListeners();
  }

  String get dayToday => _dayToday;
  String get dateToday => _dateToday;
  String get time => _time;
}
