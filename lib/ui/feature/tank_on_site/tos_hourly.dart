import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:altmop/models/well_selected.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:change_notifier_builder/change_notifier_builder.dart';
import 'package:altmop/helpers/sizes_helper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:altmop/ui/pdf_report/pdf_page.dart';
import 'package:altmop/ui/pdf_report/tank_on_site/pdf_tos_hourly.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class ChartData {
  ChartData(
    this.hourData,
    this.levelData,
    this.volumeData,
  );
  final String hourData;
  final double levelData;
  final double volumeData;
}

class TOSHourly extends StatefulWidget {
  final WellSelected wellsel;
  const TOSHourly({super.key, required this.wellsel});

  @override
  State<TOSHourly> createState() => _TOSHourlyState();
}

class _TOSHourlyState extends State<TOSHourly> {
  var truckCont = TextEditingController();
  bool isServerOk = true;
  bool isEdit = false;
  WidgetsToImageController chartToImgCont = WidgetsToImageController();

  double cmbblConst = 0.000006289814;
  String tempDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    tempDate = DateFormat('yyyy-MM-dd').format(args.value);

    SchedulerBinding.instance.addPostFrameCallback((duration) {
      setState(() {});
    });
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
        // widget.wellsel.setTrucking =
        //     jsonData['Trucking Transportation'].toString();
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
              'action=tostrucking'
              '&wellname=${widget.wellsel.getWellName}'
              '&showdate=${widget.wellsel.getH2ShowDate}'
              '&truck=${truckCont.text}'))
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

  Future<void> datePick() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Select date to show',
            style: TextStyle(color: Colors.blueGrey),
          ),
          content: Container(
            height: 300,
            width: 300,
            child: Column(
              children: <Widget>[
                SfDateRangePicker(
                  initialSelectedDate:
                      DateTime.parse(widget.wellsel.getH2ShowDate),
                  view: DateRangePickerView.month,
                  selectionMode: DateRangePickerSelectionMode.single,
                  onSelectionChanged: selectionChanged,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Ok',
                style: TextStyle(color: Colors.blueGrey),
              ),
              onPressed: () {
                widget.wellsel.setH2ShowDate = tempDate;
                widget.wellsel
                    .loadH2Data(widget.wellsel.getH2ShowDate)
                    .then((res) {
                  truckCont.text = widget.wellsel.getTrucking;
                  !res ? connErrorSnackBar() : null;
                  setState(() {});
                });
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blueGrey),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    truckCont.text = widget.wellsel.getTrucking;
    print(truckCont.text);
    print(widget.wellsel.getTrucking);
    print('update trucking');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  double calcVolByLevel(level) {
    double vol = 0;
    try {
      vol = double.parse(
          (level * double.parse(widget.wellsel.getCm1)).toStringAsFixed(3));
    } catch (e) {
      vol = double.parse((level).toStringAsFixed(3));
    }
    return vol;
  }

  String get totalVolume {
    String totalVol = '';
    for (var data in widget.wellsel.getDTosData) {
      if (data[0] == widget.wellsel.getH2ShowDate) {
        totalVol = data[1];
      }
    }
    return totalVol;
  }

  String get finalStockValue {
    double finalStock = 0;
    try {
      finalStock =
          double.parse(totalVolume) - double.parse(widget.wellsel.getTrucking);
    } catch (e) {
      finalStock = 0;
    }
    return finalStock.toStringAsFixed(3);
  }

  Widget dataTable() {
    Widget colName(String text) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: 12.sp,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    Widget rowContent(String text) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: 8.sp,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(5, 5),
          ),
        ],
      ),
      child: Table(
        columnWidths: {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(3),
        },
        border: TableBorder(
          horizontalInside: BorderSide(
            width: 1,
            color: Colors.blueGrey.shade100,
          ),
        ),
        children: [
          TableRow(
            children: [
              colName('Time\n(Hour)'),
              colName('Level\n(cm)'),
              colName('Volume\n(bbl)'),
            ],
          ),
          for (var data in widget.wellsel.getH2Data)
            TableRow(
              children: [
                rowContent('${data[1].substring(0, 2)}'),
                rowContent('${data[3]}'),
                rowContent('${calcVolByLevel(data[3])}'),
              ],
            ),
        ],
      ),
    );
  }

  late List<ChartData> _chartData;

  List<ChartData> getChartData() {
    List<ChartData> chartData = [];
    for (var data in widget.wellsel.getH2Data) {
      chartData.add(
        ChartData(
          '${data[1].substring(0, 2)}',
          data[3] * 1.0,
          calcVolByLevel(data[3]) * 1.0,
        ),
      );
    }
    return chartData;
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
        _chartData = getChartData();
        return Stack(
          children: [
            Container(
              color: Colors.blueGrey[50],
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Hourly Production",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${widget.wellsel.getWellName}",
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Date : '),
                        MaterialButton(
                          onPressed: datePick,
                          child: Container(
                            child: widget.wellsel.getH2ShowDate == ''
                                ? Text('Select a date')
                                : Text(widget.wellsel.getH2ShowDate),
                          ),
                        ),
                      ],
                    ),
                    widget.wellsel.getH2Data.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/no-data.png',
                                    scale: 2.5,
                                  ),
                                  SizedBox(height: 30),
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'There are no data to show in ',
                                        ),
                                        TextSpan(
                                          text: widget.wellsel.getH2ShowDate,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text('Please select another date to show.'),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              // Trucking Transport
                              formattedCard(
                                Image.asset(
                                  width: 35,
                                  'assets/images/vol-icon.png',
                                  color: Colors.blueGrey,
                                ),
                                TextFormField(
                                  enabled: false,
                                  controller:
                                      TextEditingController(text: totalVolume),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    labelStyle:
                                        TextStyle(color: Colors.black87),
                                    labelText: 'Total Volume',
                                    suffixText: 'BBL',
                                  ),
                                ),
                              ),
                              formattedCard(
                                Image.asset(
                                  width: 35,
                                  'assets/images/truck-icon.png',
                                  color: Colors.blueGrey,
                                ),
                                TextFormField(
                                  enabled: isEdit,
                                  controller: truckCont,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    labelStyle:
                                        TextStyle(color: Colors.black87),
                                    labelText: 'Trucking Transportation',
                                    suffixText: 'BBL',
                                    suffixIcon:
                                        isEdit ? Icon(Icons.edit) : null,
                                  ),
                                ),
                              ),
                              formattedCard(
                                Image.asset(
                                  width: 35,
                                  'assets/images/stock-icon.png',
                                  color: Colors.blueGrey,
                                ),
                                TextFormField(
                                  enabled: false,
                                  controller: TextEditingController(
                                      text: finalStockValue),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    labelStyle:
                                        TextStyle(color: Colors.black87),
                                    suffixText: 'BBL',
                                    labelText: 'Final Stock',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              Center(
                                child: Container(
                                  height: 400,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        10), // radius of 10
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        offset: Offset(5, 5),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: WidgetsToImage(
                                      controller: chartToImgCont,
                                      child: SfCartesianChart(
                                        legend: Legend(
                                          isVisible: true,
                                          position: LegendPosition.bottom,
                                          overflowMode:
                                              LegendItemOverflowMode.wrap,
                                        ),
                                        primaryXAxis: CategoryAxis(
                                            majorGridLines:
                                                MajorGridLines(width: 1),
                                            minorGridLines:
                                                MinorGridLines(width: 1),
                                            title:
                                                AxisTitle(text: 'Time, Hour')),
                                        primaryYAxis: NumericAxis(
                                            majorGridLines:
                                                MajorGridLines(width: 1),
                                            minorGridLines:
                                                MinorGridLines(width: 1),
                                            title:
                                                AxisTitle(text: 'Volume, BBL')),
                                        axes: <ChartAxis>[
                                          // CategoryAxis(
                                          //     name: 'xAxis',
                                          //     title: AxisTitle(
                                          //         text: 'Secondary X Axis'),
                                          //     opposedPosition: true),
                                          NumericAxis(
                                              majorGridLines:
                                                  MajorGridLines(width: 0),
                                              minorGridLines:
                                                  MinorGridLines(width: 0),
                                              name: 'yAxis',
                                              title:
                                                  AxisTitle(text: 'Level (cm)'),
                                              opposedPosition: true,
                                              interval: 5)
                                        ],
                                        series: <CartesianSeries>[
                                          ColumnSeries<ChartData, String>(
                                              name: 'Volume (BBL)',
                                              dataSource: _chartData,
                                              xValueMapper:
                                                  (ChartData data, _) =>
                                                      data.hourData,
                                              yValueMapper:
                                                  (ChartData data, _) =>
                                                      data.volumeData,
                                              xAxisName: 'xAxis',
                                              yAxisName: 'yAxis'),
                                          SplineSeries<ChartData, String>(
                                              name: 'Level (cm)',
                                              dataSource: _chartData,
                                              xValueMapper:
                                                  (ChartData data, _) =>
                                                      data.hourData,
                                              yValueMapper:
                                                  (ChartData data, _) =>
                                                      data.levelData),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              dataTable(),
                            ],
                          ),
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
                          final chartBytes = await chartToImgCont.capture();
                          final pdfBytes = await makePdf(widget.wellsel,
                              chartBytes!, totalVolume, finalStockValue);
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfPreviewPage(
                                pdfBytes: pdfBytes,
                                reportTitle: 'TOS Hourly',
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
                      width: 175,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!isEdit) {
                            isEdit = true;
                          } else {
                            isEdit = false;
                            // save hasil edit kirim ke api
                            sendEditedInfo(context);
                            widget.wellsel
                                .loadH2Data(widget.wellsel.getH2ShowDate)
                                .then((res) {
                              truckCont.text = widget.wellsel.getTrucking;
                              !res ? connErrorSnackBar() : null;
                              setState(() {});
                            });
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
                                    'Edit Trucking\nTransportation',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              )
                            : Row(
                                children: const [
                                  Icon(Icons.save),
                                  SizedBox(width: 10),
                                  Text(
                                    'Save Trucking\nTransportation',
                                    style: TextStyle(fontSize: 14),
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
