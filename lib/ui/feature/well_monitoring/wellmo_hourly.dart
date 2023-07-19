import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:altmop/models/well_selected.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:change_notifier_builder/change_notifier_builder.dart';
import 'package:altmop/helpers/sizes_helper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:altmop/ui/pdf_report/pdf_page.dart';
import 'package:altmop/ui/pdf_report/well_monitoring/pdf_wellmo_hourly.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class ChartData {
  ChartData(this.hourData, this.grossProdData, this.pressureData,
      this.temperatureData);
  final String hourData;
  final double grossProdData;
  final double pressureData;
  final double temperatureData;
}

class HourlyProd extends StatefulWidget {
  final WellSelected wellsel;
  const HourlyProd({super.key, required this.wellsel});

  @override
  State<HourlyProd> createState() => _HourlyProdState();
}

class _HourlyProdState extends State<HourlyProd> {
  WidgetsToImageController chartToImgCont = WidgetsToImageController();

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
        textAlign: TextAlign.start,
        maxLines: 4,
        message:
            'Something went wrong :( . Check your internet connection or call your technical support.',
      ),
    );
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
    _chartData = getChartData();
  }

  @override
  void dispose() {
    super.dispose();
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
          3: FlexColumnWidth(3),
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
              colName('Gross Prod.\n(bbl/h)'),
              colName('Pressure\n(psi)'),
              colName('Temperature\n(°F)'),
            ],
          ),
          for (var data in widget.wellsel.getH2Data)
            TableRow(
              children: [
                rowContent('${data[1].substring(0, 2)}'),
                rowContent((data[2] / 24).toStringAsFixed(3)),
                rowContent('${data[5]}'),
                rowContent('${data[4]}'),
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
          (data[2] / 24) * 1.0,
          data[5] * 1.0,
          data[4] * 1.0,
        ),
      );
    }
    return chartData;
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
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Date : ', style: TextStyle(fontSize: 16)),
                        MaterialButton(
                          onPressed: datePick,
                          child: Container(
                            child: widget.wellsel.getH2ShowDate == ''
                                ? Text(
                                    'Select a date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    widget.wellsel.getH2ShowDate,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                                            title: AxisTitle(
                                                text:
                                                    'Gross Production, bbl/h')),
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
                                              title: AxisTitle(
                                                  text: 'Pressure, Ps ig'),
                                              opposedPosition: true,
                                              interval: 5)
                                        ],
                                        series: <CartesianSeries>[
                                          SplineSeries<ChartData, String>(
                                              name: 'Gross Production',
                                              dataSource: _chartData,
                                              xValueMapper:
                                                  (ChartData data, _) =>
                                                      data.hourData,
                                              yValueMapper:
                                                  (ChartData data, _) =>
                                                      data.grossProdData),
                                          SplineSeries<ChartData, String>(
                                              name: 'Pressure',
                                              dataSource: _chartData,
                                              xValueMapper:
                                                  (ChartData data, _) =>
                                                      data.hourData,
                                              yValueMapper:
                                                  (ChartData data, _) =>
                                                      data.pressureData,
                                              xAxisName: 'xAxis',
                                              yAxisName: 'yAxis'),
                                          SplineSeries<ChartData, String>(
                                              name: 'Temperature',
                                              dataSource: _chartData,
                                              xValueMapper:
                                                  (ChartData data, _) =>
                                                      data.hourData,
                                              yValueMapper:
                                                  (ChartData data, _) =>
                                                      data.temperatureData,
                                              xAxisName: 'xAxis',
                                              yAxisName: 'yAxis'),
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
                          final pdfBytes =
                              await makePdf(widget.wellsel, chartBytes!);
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfPreviewPage(
                                pdfBytes: pdfBytes,
                                reportTitle: 'Well Monitoring Hourly',
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
