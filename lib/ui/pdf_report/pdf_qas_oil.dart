import 'dart:typed_data';

// import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'dart:io';
import 'package:altmop/models/qas_oil_calc.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> makePdf(QasOilCalc qasOilCalc) async {
  final pdf = Document();
  final logo = MemoryImage(
      (await rootBundle.load('assets/images/logo5_26_1061-removebg.png'))
          .buffer
          .asUint8List());
  final inputData = [
    {
      'id': 1,
      'enabled': true,
      'label': 'Tank Temperature Calibration',
      'unit': '°C',
      'value': qasOilCalc.suhuCal,
    },
    {
      'id': 2,
      'enabled': true,
      'label': 'Measuring Time',
      'unit': 'WIB',
      'value': qasOilCalc.waktuPengukuran,
    },
    {
      'id': 3,
      'enabled': true,
      'label': 'Liquid Height + Measuring Table',
      'unit': 'mm',
      'value': qasOilCalc.tinggiCairan,
    },
    {
      'id': 4,
      'enabled': false,
      'label': 'Liquid Volume',
      'unit': 'm3',
      'value': qasOilCalc.volumeCairan,
    },
    {
      'id': 5,
      'enabled': true,
      'label': 'Water Free Height + Measuring Table',
      'unit': 'mm',
      'value': qasOilCalc.tinggiAirBebas,
    },
    {
      'id': 6,
      'enabled': false,
      'label': 'Water Free Volume',
      'unit': 'm3',
      'value': qasOilCalc.volumeAirBebas,
    },
    {
      'id': 7,
      'enabled': true,
      'label': 'Temperature (Lab)',
      'unit': '°C',
      'value': qasOilCalc.suhuLab,
    },
    {
      'id': 8,
      'enabled': false,
      'label': 'Temperature (Tank)',
      'unit': '°C',
      'value': qasOilCalc.suhuTank,
    },
    {
      'id': 9,
      'enabled': true,
      'label': 'Density (Measurement)',
      'unit': '',
      'value': qasOilCalc.densitasPengukuran,
    },
    {
      'id': 10,
      'enabled': false,
      'label': 'Density (STD 15°C)',
      'unit': '',
      'value': qasOilCalc.densitasSTD15oC,
    },
    {
      'id': 11,
      'enabled': true,
      'label': 'BSW',
      'unit': '%',
      'value': qasOilCalc.bsw,
    },
    {
      'id': 12,
      'enabled': true,
      'label': 'Salt Cont',
      'unit': 'PTB',
      'value': qasOilCalc.saltCont,
    },
    {
      'id': 13,
      'enabled': false,
      'label': '°API',
      'unit': '',
      'value': qasOilCalc.api,
    },
    {
      'id': 14,
      'enabled': false,
      'label': 'Gross OBS',
      'unit': 'm3',
      'value': qasOilCalc.grossObs,
    },
    {
      'id': 15,
      'enabled': false,
      'label': 'Correction Volume Factor',
      'unit': '',
      'value': qasOilCalc.faktorKoreksiVolume,
    },
    {
      'id': 16,
      'enabled': false,
      'label': 'Correction Volume',
      'unit': 'm3',
      'value': qasOilCalc.volumeKoreksi,
    },
    {
      'id': 17,
      'enabled': false,
      'label': 'Net STD M3',
      'unit': 'm3',
      'value': qasOilCalc.netStdM3,
    },
    {
      'id': 18,
      'enabled': false,
      'label': 'Net STD BBL',
      'unit': 'bbl',
      'value': qasOilCalc.netStdBbl,
    },
    {
      'id': 19,
      'enabled': true,
      'label': 'Total STD Production Gross',
      'unit': 'm3',
      'value': qasOilCalc.totalStdProduksiGross,
    },
    {
      'id': 20,
      'enabled': true,
      'label': 'Total STD Production Nett',
      'unit': 'm3',
      'value': qasOilCalc.totalStdProduksiNett,
    },
    {
      'id': 21,
      'enabled': true,
      'label': 'Total STD Trf ke PPP Gross',
      'unit': 'm3',
      'value': qasOilCalc.totalStdTrfKePPGross,
    },
    {
      'id': 22,
      'enabled': true,
      'label': 'Total STD TRF to PPP Nett',
      'unit': 'm3',
      'value': qasOilCalc.totalStdTrfKePPNett,
    },
  ];
  pdf.addPage(
    Page(
      build: (context) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      "QAS Oil Calculation Report",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Image(logo),
                )
              ],
            ),
            SizedBox(height: 30),
            Table(
              columnWidths: {
                0: FlexColumnWidth(11),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(8),
              },
              border: TableBorder.all(
                width: 0,
                color: PdfColor.fromInt(0xffffffff),
                // color: PdfColor.fromInt(0x000000),
              ), // Set the border to be transparent

              children: [
                for (Map data in inputData)
                  TableRow(
                    children: [
                      Text(data['label']),
                      Text(':'),
                      data['value'].toString() != ''
                          ? Text('${data['value'].toString()} ${data['unit']}')
                          : Text('0.0 ${data['unit']}'),
                      SizedBox(height: 25),
                    ],
                  ),
              ],
            ),
          ],
        );
      },
    ),
  );
  return pdf.save();
}

Widget paddedText(
  final String text, {
  final TextAlign align = TextAlign.left,
}) =>
    Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: align,
      ),
    );

Widget ketText(
  final int nilai, {
  final TextAlign align = TextAlign.left,
}) =>
    Container(
      color: nilai < 70 ? PdfColors.red : PdfColors.green,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          nilai < 70 ? 'Not Passed' : 'Passed',
          textAlign: align,
          style: const TextStyle(
            color: PdfColors.white,
          ),
        ),
      ),
    );
