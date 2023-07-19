import 'package:altmop/ui/pdf_report/pdf_qas_oil.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:altmop/helpers/sizes_helper.dart';
import 'package:altmop/models/qas_oil_calc.dart';
import 'package:change_notifier_builder/change_notifier_builder.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:altmop/ui/pdf_report/pdf_page.dart';

class QasOil extends StatefulWidget {
  const QasOil({super.key, required this.qasOilCalc});
  final QasOilCalc qasOilCalc;

  @override
  State<QasOil> createState() => _QasOilState();
}

class _QasOilState extends State<QasOil> {
  List inputData = [];

  @override
  void initState() {
    super.initState();
    updateInputForm();
  }

  void updateInputForm() {
    inputData = [
      {
        'id': 1,
        'enabled': true,
        'label': 'Tank Temperature Calibration',
        'unit': '°C',
        'controller':
            TextEditingController(text: '${widget.qasOilCalc.suhuCal}'),
      },
      {
        'id': 2,
        'enabled': true,
        'label': 'Measuring Time',
        'unit': 'WIB',
        'controller':
            TextEditingController(text: '${widget.qasOilCalc.waktuPengukuran}'),
      },
      {
        'id': 3,
        'enabled': true,
        'label': 'Liquid Height + Measuring Table',
        'unit': 'mm',
        'controller':
            TextEditingController(text: '${widget.qasOilCalc.tinggiCairan}'),
      },
      {
        'id': 4,
        'enabled': false,
        'label': 'Liquid Volume',
        'unit': 'm3',
        'controller':
            TextEditingController(text: '${widget.qasOilCalc.volumeCairan}'),
      },
      {
        'id': 5,
        'enabled': true,
        'label': 'Water Free Height + Measuring Table',
        'unit': 'mm',
        'controller':
            TextEditingController(text: '${widget.qasOilCalc.tinggiAirBebas}'),
      },
      {
        'id': 6,
        'enabled': false,
        'label': 'Water Free Volume',
        'unit': 'm3',
        'controller':
            TextEditingController(text: '${widget.qasOilCalc.volumeAirBebas}'),
      },
      {
        'id': 7,
        'enabled': true,
        'label': 'Temperature (Lab)',
        'unit': '°C',
        'controller':
            TextEditingController(text: '${widget.qasOilCalc.suhuLab}'),
      },
      {
        'id': 8,
        'enabled': false,
        'label': 'Temperature (Tank)',
        'unit': '°C',
        'controller':
            TextEditingController(text: '${widget.qasOilCalc.suhuTank}'),
      },
      {
        'id': 9,
        'enabled': true,
        'label': 'Density (Measurement)',
        'unit': '',
        'controller': TextEditingController(
            text: '${widget.qasOilCalc.densitasPengukuran}'),
      },
      {
        'id': 10,
        'enabled': false,
        'label': 'Density (STD 15°C)',
        'unit': '',
        'controller':
            TextEditingController(text: '${widget.qasOilCalc.densitasSTD15oC}'),
      },
      {
        'id': 11,
        'enabled': true,
        'label': 'BSW',
        'unit': '%',
        'controller': TextEditingController(text: '${widget.qasOilCalc.bsw}'),
      },
      {
        'id': 12,
        'enabled': true,
        'label': 'Salt Cont',
        'unit': 'PTB',
        'controller':
            TextEditingController(text: '${widget.qasOilCalc.saltCont}'),
      },
      {
        'id': 13,
        'enabled': false,
        'label': '°API',
        'unit': '',
        'controller': TextEditingController(text: '${widget.qasOilCalc.api}'),
      },
      {
        'id': 14,
        'enabled': false,
        'label': 'Gross OBS',
        'unit': 'm3',
        'controller':
            TextEditingController(text: '${widget.qasOilCalc.grossObs}'),
      },
      {
        'id': 15,
        'enabled': false,
        'label': 'Correction Volume Factor',
        'unit': '',
        'controller': TextEditingController(
            text: '${widget.qasOilCalc.faktorKoreksiVolume}'),
      },
      {
        'id': 16,
        'enabled': false,
        'label': 'Correction Volume',
        'unit': 'm3',
        'controller':
            TextEditingController(text: '${widget.qasOilCalc.volumeKoreksi}'),
      },
      {
        'id': 17,
        'enabled': false,
        'label': 'Net STD M3',
        'unit': 'm3',
        'controller':
            TextEditingController(text: '${widget.qasOilCalc.netStdM3}'),
      },
      {
        'id': 18,
        'enabled': false,
        'label': 'Net STD BBL',
        'unit': 'bbl',
        'controller':
            TextEditingController(text: '${widget.qasOilCalc.netStdBbl}'),
      },
      {
        'id': 19,
        'enabled': true,
        'label': 'Total STD Production Gross',
        'unit': 'm3',
        'controller': TextEditingController(
            text: '${widget.qasOilCalc.totalStdProduksiGross}'),
      },
      {
        'id': 20,
        'enabled': true,
        'label': 'Total STD Production Nett',
        'unit': 'm3',
        'controller': TextEditingController(
            text: '${widget.qasOilCalc.totalStdProduksiNett}'),
      },
      {
        'id': 21,
        'enabled': true,
        'label': 'Total STD Trf ke PPP Gross',
        'unit': 'm3',
        'controller': TextEditingController(
            text: '${widget.qasOilCalc.totalStdTrfKePPGross}'),
      },
      {
        'id': 22,
        'enabled': true,
        'label': 'Total STD TRF to PPP Nett',
        'unit': 'm3',
        'controller': TextEditingController(
            text: '${widget.qasOilCalc.totalStdTrfKePPNett}'),
      },
    ];
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

  Widget calcCard(int card, Widget content) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(5, 5),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget h2Txt(int card, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget h3Txt(String text) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: Colors.blueGrey.shade700,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget tff(int id, bool act, String label, String suffix,
      TextEditingController input) {
    return TextFormField(
      enabled: act,
      keyboardType: TextInputType.number,
      controller: input,
      onChanged: (value) => widget.qasOilCalc.inputChange(id, value),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black87,
          fontSize: 14,
          // fontWeight: FontWeight.w500,
        ),
        suffixText: suffix,
        border: act ? UnderlineInputBorder() : InputBorder.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text("QAS Oil"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Wrap(
                    children: [
                      Text(
                          '*Use "." to separate decimal number. You can input data to calculate in the form with line.')
                    ],
                  ),
                  SizedBox(height: 20),
                  h2Txt(
                    1,
                    "QAS Oil Calculation",
                  ),
                  calcCard(
                    1,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (Map form in inputData)
                          tff(
                            form['id'],
                            form['enabled'],
                            form['label'],
                            form['unit'],
                            form['controller'],
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 70),
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final pdfBytes = await makePdf(widget.qasOilCalc);
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfPreviewPage(
                              pdfBytes: pdfBytes,
                              reportTitle: 'QAS Oil Calculation',
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
                  SizedBox(width: 5),
                  SizedBox(
                    height: 50,
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.qasOilCalc.calculate().then((res) {
                          !res ? connErrorSnackBar() : null;
                          updateInputForm();
                          setState(() {});
                        });
                      },
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(Size(120, 50)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(
                            Icons.calculate,
                            size: 22,
                          ),
                          Text(
                            'Calculate',
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
            notifier: widget.qasOilCalc,
            builder: (BuildContext context, QasOilCalc? __, _) {
              return Visibility(
                visible: widget.qasOilCalc.isLoadingData,
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
                          'Calculation on progress,\nplease wait ...',
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
      ),
    );
  }
}
