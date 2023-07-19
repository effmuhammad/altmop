import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:altmop/models/well_selected.dart';
import 'dart:convert';
import 'dart:async';
import 'package:change_notifier_builder/change_notifier_builder.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:altmop/helpers/sizes_helper.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:altmop/ui/pdf_report/pdf_page.dart';
import 'package:altmop/ui/pdf_report/well_monitoring/pdf_wellmo_information.dart';

class WellInfo extends StatefulWidget {
  final WellSelected wellsel;
  const WellInfo({super.key, required this.wellsel});

  @override
  State<WellInfo> createState() => _WellInfoState();
}

class _WellInfoState extends State<WellInfo> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isServerOk = true;
  bool isEdit = false;
  var locCont = TextEditingController();
  var vilCont = TextEditingController();
  var staCont = TextEditingController();
  var gsnCont = TextEditingController();
  var lifMetCont = TextEditingController();
  var watCutCont = TextEditingController();
  var bsnwCont = TextEditingController();

  void setFormController() {
    locCont.text =
        widget.wellsel.getLocation != '' ? widget.wellsel.getLocation : '-';
    vilCont.text =
        widget.wellsel.getVillage != '' ? widget.wellsel.getVillage : '-';
    staCont.text =
        widget.wellsel.getStatus != '' ? widget.wellsel.getStatus : '-';
    gsnCont.text =
        widget.wellsel.getGSName != '' ? widget.wellsel.getGSName : '-';
    lifMetCont.text = widget.wellsel.getLiftingMethod != ''
        ? widget.wellsel.getLiftingMethod
        : '-';
    watCutCont.text =
        widget.wellsel.getWaterCut != '' ? widget.wellsel.getWaterCut : '-';
    bsnwCont.text = widget.wellsel.getBSnW != '' ? widget.wellsel.getBSnW : '-';
  }

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

  void updateWellProperties() async {
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
        // Length: 600, Width: 240, Height: 240, Instalation Date: 2023-06-19, Location: , Village: , Status: , GS Name: , Lifting Method: , Water Cut: }
        widget.wellsel.setLength = jsonData['Length'].toString();
        widget.wellsel.setWidth = jsonData['Width'].toString();
        widget.wellsel.setHeight = jsonData['Height'].toString();
        widget.wellsel.setInstDate = jsonData['Instalation Date'].toString();
        widget.wellsel.setLocation = jsonData['Location'].toString();
        widget.wellsel.setVillage = jsonData['Village'].toString();
        widget.wellsel.setStatus = jsonData['Status'].toString();
        widget.wellsel.setGSName = jsonData['GS Name'].toString();
        widget.wellsel.setLiftingMethod = jsonData['Lifting Method'].toString();
        widget.wellsel.setWaterCut = jsonData['Water Cut'].toString();
        widget.wellsel.setBSnW = jsonData['BS&W'].toString();
      } else {
        widget.wellsel.setServerOk = false;
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
              'action=wellpropset'
              '&wellname=${widget.wellsel.getWellName}'
              '&location=${locCont.text}'
              '&village=${vilCont.text}'
              '&status=${staCont.text}'
              '&gsname=${gsnCont.text}'
              '&lifmet=${lifMetCont.text}'
              '&watercut=${watCutCont.text}'
              '&bsnw=${bsnwCont.text}'))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        widget.wellsel.setServerOk = true;
        updateWellProperties();
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

  @override
  void initState() {
    super.initState();
    setFormController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget formattedCard(Widget icon, Widget title, {bool loading = false}) {
    return Container(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        // color: Colors.blueGrey.shade100,
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
    return Stack(
      children: [
        ChangeNotifierBuilder(
          notifier: widget.wellsel,
          builder: (BuildContext context, WellSelected? __, _) {
            setFormController();
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  formattedCard(
                    Image.asset(
                      width: 35,
                      'assets/images/sec1.png',
                      color: Colors.blueGrey,
                    ),
                    TextFormField(
                      enabled: false,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black87),
                        labelText: 'Well Name',
                      ),
                      initialValue: widget.wellsel.getWellName,
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
                  formattedCard(
                    const Icon(
                      Icons.location_searching_sharp,
                      color: Colors.blueGrey,
                      size: 35,
                    ),
                    TextFormField(
                      enabled: isEdit,
                      controller: locCont,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black87),
                        labelText: 'Location',
                        suffixIcon: isEdit ? Icon(Icons.edit) : null,
                      ),
                    ),
                  ),
                  formattedCard(
                    const Icon(
                      Icons.pin_drop_outlined,
                      color: Colors.blueGrey,
                      size: 35,
                    ),
                    TextFormField(
                      enabled: isEdit,
                      controller: vilCont,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black87),
                        labelText: 'Village',
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
                      enabled: isEdit,
                      controller: staCont,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black87),
                        labelText: 'Status',
                        suffixIcon: isEdit ? Icon(Icons.edit) : null,
                      ),
                    ),
                  ),
                  formattedCard(
                    const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.blueGrey,
                      size: 35,
                    ),
                    TextFormField(
                      enabled: isEdit,
                      controller: gsnCont,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black87),
                        labelText: 'GS Name',
                        suffixIcon: isEdit ? Icon(Icons.edit) : null,
                      ),
                    ),
                  ),
                  formattedCard(
                    const Icon(
                      Icons.upload_outlined,
                      color: Colors.blueGrey,
                      size: 35,
                    ),
                    TextFormField(
                      enabled: isEdit,
                      controller: lifMetCont,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black87),
                        labelText: 'Lifting Method',
                        suffixIcon: isEdit ? Icon(Icons.edit) : null,
                      ),
                    ),
                  ),
                  formattedCard(
                    const Icon(
                      Icons.water_drop_outlined,
                      color: Colors.blueGrey,
                      size: 35,
                    ),
                    TextFormField(
                      enabled: isEdit,
                      controller: watCutCont,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black87),
                        labelText: 'Water Cut',
                        suffixIcon: isEdit ? Icon(Icons.edit) : null,
                      ),
                    ),
                  ),
                  formattedCard(
                    const Icon(
                      Icons.water_outlined,
                      color: Colors.blueGrey,
                      size: 35,
                    ),
                    TextFormField(
                      enabled: isEdit,
                      controller: bsnwCont,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black87),
                        labelText: 'BS&W',
                        suffixIcon: isEdit ? Icon(Icons.edit) : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
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
                            reportTitle: 'Well Monitoring Information',
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
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
        ChangeNotifierBuilder(
          notifier: widget.wellsel,
          builder: (BuildContext context, WellSelected? __, _) {
            return Visibility(
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
            );
          },
        ),
      ],
    );
  }
}
