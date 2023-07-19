import 'package:change_notifier_builder/change_notifier_builder.dart';
import 'package:flutter/material.dart';
import 'package:altmop/models/well_selected.dart';
import 'package:altmop/helpers/sizes_helper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:altmop/ui/pdf_report/pdf_page.dart';
import 'package:altmop/ui/pdf_report/tank_on_site/pdf_tos_information.dart';

class TOSInfo extends StatefulWidget {
  final WellSelected wellsel;
  const TOSInfo({super.key, required this.wellsel});

  @override
  State<TOSInfo> createState() => _TOSInfoState();
}

class _TOSInfoState extends State<TOSInfo> {
  bool isServerOk = true;
  bool isEdit = false;
  var capCont = TextEditingController();
  var tempCont = TextEditingController();
  var denCont = TextEditingController();
  var cm1Cont = TextEditingController();

  @override
  void initState() {
    super.initState();
    setFormController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setFormController() {
    capCont.text =
        widget.wellsel.getCapacity != '' ? widget.wellsel.getCapacity : '-';
    tempCont.text = widget.wellsel.getTemperature != ''
        ? widget.wellsel.getTemperature
        : '-';
    denCont.text =
        widget.wellsel.getDensity != '' ? widget.wellsel.getDensity : '-';
    cm1Cont.text = widget.wellsel.getCm1 != '' ? widget.wellsel.getCm1 : '-';
  }

  void connErrorSnackBar() {
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.error(
        maxLines: 4,
        message:
            'Something went wrong :( . Check your internet connection or call your technical support.',
      ),
    );
  }

  void updateTosProperties() async {
    try {
      final response = await http
          .get(Uri.parse(
              'https://script.google.com/macros/s/AKfycbxTAp84bJrtCd65U2tt7M5IuYm9zGLwkbkRsY1_2J_6DQLmfOWhFbujLoNAzMixGXrb/exec?'
              'action=read'
              '&user_req=properties'
              '&wellname=${widget.wellsel.getWellName}'))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        widget.wellsel.setServerOk = true;
        print(jsonData);
        widget.wellsel.setCapacity = jsonData['Capacity'].toString();
        widget.wellsel.setTrucking =
            jsonData['Trucking Transportation'].toString();
        widget.wellsel.setTemperature = jsonData['Temperature'].toString();
        widget.wellsel.setDensity = jsonData['Density'].toString();
        widget.wellsel.setCM1 = jsonData['1 CM'].toString();
      } else {
        widget.wellsel.setServerOk = false;
        connErrorSnackBar();
        throw Exception('Failed to load data');
      }
    } catch (e) {
      widget.wellsel.setServerOk = false;
      connErrorSnackBar();
    }
    widget.wellsel.setLoadingData = false;
  }

  void sendEditedInfo(context) async {
    try {
      widget.wellsel.setLoadingData = true;
      final response = await http
          .get(Uri.parse(
              'https://script.google.com/macros/s/AKfycbxTAp84bJrtCd65U2tt7M5IuYm9zGLwkbkRsY1_2J_6DQLmfOWhFbujLoNAzMixGXrb/exec?'
              'action=tospropset'
              '&wellname=${widget.wellsel.getWellName}'
              '&capacity=${capCont.text}'
              '&temperature=${tempCont.text}'
              '&density=${denCont.text}'
              '&cm1=${cm1Cont.text}'))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        widget.wellsel.setServerOk = true;
        updateTosProperties();
      } else {
        widget.wellsel.setServerOk = false;
        widget.wellsel.setLoadingData = false;
        connErrorSnackBar();
        throw Exception('Failed to load data');
      }
    } catch (e) {
      widget.wellsel.setServerOk = false;
      widget.wellsel.setLoadingData = false;
      connErrorSnackBar();
    }
  }

  Widget formattedCard(Widget icon, Widget title, {bool loading = false}) {
    return Container(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 3,
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade100,
                Colors.blueGrey.shade100,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: ListTile(
              horizontalTitleGap: 18.0,
              leading: icon,
              trailing: loading
                  ? SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(),
                    )
                  : null,
              title: title,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierBuilder(
      notifier: widget.wellsel,
      builder: (BuildContext context, WellSelected? __, _) {
        // tank level max 180 min 0
        double illustrationTankLevel = 0;
        double tankLevel = 0;
        print(widget.wellsel.getTankLevel);
        print(widget.wellsel.getHeight);
        try {
          tankLevel = double.parse(widget.wellsel.getTankLevel);
          illustrationTankLevel =
              tankLevel * 180 / double.parse(widget.wellsel.getHeight);
        } catch (e) {
          illustrationTankLevel = 0;
          tankLevel = 0;
        }

        setFormController();
        return Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Stack(
                          children: [
                            Container(
                              height: 250,
                              width: 300,
                              // color: Colors.red,
                              child: Image.asset(
                                'assets/images/cube-tank-edited.png',
                              ),
                            ),
                            Positioned(
                              bottom: 33,
                              right: 140,
                              child: Container(
                                height: 180,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(10), // radius of 10
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 33,
                              right: 140,
                              child: Container(
                                height: illustrationTankLevel,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(10), // radius of 10
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20 + illustrationTankLevel,
                              right: 60,
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(math.pi),
                                      child: Image.asset(
                                        'assets/images/arrow.png',
                                        color: Colors.blueGrey.shade900,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 25,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          8), // radius of 10
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    child: Center(
                                        child: Text(
                                      '$tankLevel cm',
                                      style: TextStyle(color: Colors.black),
                                    )),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    formattedCard(
                      Image.asset(
                        width: 35,
                        'assets/images/cube-tank.png',
                        color: Colors.blueGrey,
                      ),
                      TextFormField(
                        enabled: false,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: Colors.black87),
                          labelText: 'Tank Name',
                        ),
                        initialValue: widget.wellsel.getWellName == 'None'
                            ? 'None'
                            : 'TOS ${widget.wellsel.getWellName}',
                      ),
                    ),
                    formattedCard(
                      const Icon(
                        Icons.date_range_rounded,
                        color: Colors.blueGrey,
                        size: 35,
                      ),
                      TextFormField(
                        enabled: false,
                        controller: TextEditingController(
                            text: widget.wellsel.getInstDate),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: Colors.black87),
                          labelText: 'Instalation Date',
                        ),
                      ),
                    ),
                    // formattedCard(
                    //   Image.asset(
                    //     width: 35,
                    //     'assets/images/vol-icon.png',
                    //     color: Colors.blueGrey,
                    //   ),
                    //   TextFormField(
                    //     enabled: false,
                    //     controller: TextEditingController(text: ),
                    //     decoration: const InputDecoration(
                    //       border: InputBorder.none,
                    //       labelStyle: TextStyle(color: Colors.black87),
                    //       labelText: 'Total Volume',
                    //       suffixText: 'BBL',
                    //     ),
                    //   ),
                    // ),
                    formattedCard(
                      Image.asset(
                        width: 35,
                        'assets/images/cap-icon.png',
                        color: Colors.blueGrey,
                      ),
                      TextFormField(
                        enabled: isEdit,
                        controller: capCont,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: Colors.black87),
                          labelText: 'Capacity',
                          suffixText: 'BBL',
                          suffixIcon: isEdit ? Icon(Icons.edit) : null,
                        ),
                      ),
                    ),
                    // formattedCard(
                    //   Image.asset(
                    //     width: 35,
                    //     'assets/images/truck-icon.png',
                    //     color: Colors.blueGrey,
                    //   ),
                    //   TextFormField(
                    //     enabled: isEdit,
                    //     controller: truckCont,
                    //     decoration: InputDecoration(
                    //       border: InputBorder.none,
                    //       labelStyle: TextStyle(color: Colors.black87),
                    //       labelText: 'Trucking Transportation',
                    //       suffixText: 'BBL',
                    //       suffixIcon: isEdit ? Icon(Icons.edit) : null,
                    //     ),
                    //   ),
                    // ),
                    // formattedCard(
                    //   Image.asset(
                    //     width: 35,
                    //     'assets/images/stock-icon.png',
                    //     color: Colors.blueGrey,
                    //   ),
                    //   TextFormField(
                    //     enabled: false,
                    //     // controller: capCont,
                    //     decoration: const InputDecoration(
                    //       border: InputBorder.none,
                    //       labelStyle: TextStyle(color: Colors.black87),
                    //       suffixText: 'BBL',
                    //       labelText: 'Final Stock',
                    //     ),
                    //   ),
                    // ),
                    formattedCard(
                      Image.asset(
                        width: 35,
                        'assets/images/temp-icon.png',
                        color: Colors.blueGrey,
                      ),
                      TextFormField(
                        enabled: isEdit,
                        controller: tempCont,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: Colors.black87),
                          labelText: 'Temperature',
                          suffixText: '°C',
                          suffixIcon: isEdit ? Icon(Icons.edit) : null,
                        ),
                      ),
                    ),
                    formattedCard(
                      Image.asset(
                        width: 35,
                        'assets/images/den-icon.png',
                        color: Colors.blueGrey,
                      ),
                      TextFormField(
                        enabled: isEdit,
                        controller: denCont,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: Colors.black87),
                          labelText: 'Density',
                          suffixIcon: isEdit ? Icon(Icons.edit) : null,
                        ),
                      ),
                    ),
                    formattedCard(
                      const Icon(
                        Icons.offline_pin_outlined,
                        color: Colors.blueGrey,
                        size: 35,
                      ),
                      TextFormField(
                        enabled: false,
                        controller: TextEditingController(text: 'Active'),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: Colors.black87),
                          labelText: 'Status',
                        ),
                      ),
                    ),
                    formattedCard(
                      Image.asset(
                        width: 35,
                        'assets/images/rul-icon.png',
                        color: Colors.blueGrey,
                      ),
                      TextFormField(
                        enabled: isEdit,
                        controller: cm1Cont,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: Colors.black87),
                          labelText: '1 CM',
                          suffixText: 'BBL',
                          suffixIcon: isEdit ? Icon(Icons.edit) : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          final pdfBytes = await makePdf(widget.wellsel);
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfPreviewPage(
                                pdfBytes: pdfBytes,
                                reportTitle: 'TOS Information',
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: Colors.blueGrey,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: 155,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!isEdit) {
                            isEdit = true;
                          } else {
                            isEdit = false;
                            // save hasil edit kirim ke api
                            sendEditedInfo(context);
                          }
                          setState(() {});
                        },
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        child: !isEdit
                            ? Row(
                                children: const [
                                  Icon(Icons.edit),
                                  SizedBox(width: 10),
                                  Text(
                                    'Edit Data',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              )
                            : Row(
                                children: const [
                                  Icon(Icons.save),
                                  SizedBox(width: 10),
                                  Text(
                                    'Save Data',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: widget.wellsel.isLoadingData,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingAnimationWidget.discreteCircle(
                        color: Theme.of(context).primaryColor,
                        size: displayWidth(context) / 4,
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Synchronizing data with server,\nplease wait ...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
