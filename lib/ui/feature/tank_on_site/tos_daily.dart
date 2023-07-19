import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:altmop/models/well_selected.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:change_notifier_builder/change_notifier_builder.dart';
import 'package:altmop/helpers/sizes_helper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:altmop/ui/pdf_report/pdf_page.dart';
import 'package:altmop/ui/pdf_report/tank_on_site/pdf_tos_daily.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class ChartData {
  ChartData(this.dateData, this.totalProdData);
  final String dateData;
  final double totalProdData;
}

class TOSDaily extends StatefulWidget {
  final WellSelected wellsel;
  const TOSDaily({super.key, required this.wellsel});

  @override
  State<TOSDaily> createState() => _TOSDailyState();
}

class _TOSDailyState extends State<TOSDaily> {
  WidgetsToImageController chartToImgCont = WidgetsToImageController();

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

  @override
  void initState() {
    super.initState();
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
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(4),
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
              colName('Date'),
              colName('Total Production (BBL)'),
            ],
          ),
          for (var data in widget.wellsel.getDTosData)
            TableRow(
              children: [
                rowContent('${data[0]}'),
                rowContent('${data[1]}'),
              ],
            ),
        ],
      ),
    );
  }

  late List<ChartData> _chartData;

  List<ChartData> getChartData() {
    print(widget.wellsel.getDTosData);
    List<ChartData> chartData = [];
    for (var data in widget.wellsel.getDTosData) {
      chartData.add(
        ChartData(
          '${data[0]}',
          double.parse(data[1]),
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
                          "Daily Production",
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
                    const SizedBox(height: 30),
                    widget.wellsel.getDTosData.isEmpty
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
                                          text: 'There are no data to show.',
                                        ),
                                      ],
                                    ),
                                  ),
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
                                            title: AxisTitle(text: 'Date')),
                                        primaryYAxis: NumericAxis(
                                            majorGridLines:
                                                MajorGridLines(width: 1),
                                            minorGridLines:
                                                MinorGridLines(width: 1),
                                            title: AxisTitle(
                                                text: 'Total Production, BBL')),
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
                                              name: 'Total Production',
                                              dataSource: _chartData,
                                              xValueMapper:
                                                  (ChartData data, _) =>
                                                      data.dateData,
                                              yValueMapper:
                                                  (ChartData data, _) =>
                                                      data.totalProdData),
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
                                reportTitle: 'TOS Daily',
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
