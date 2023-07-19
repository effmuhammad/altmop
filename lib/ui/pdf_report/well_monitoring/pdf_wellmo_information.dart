import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:altmop/models/well_selected.dart';

Widget h2Row(String text) {
  return Table(
    defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
    border: TableBorder.all(
      width: 0,
      color: PdfColor.fromInt(0xffffffff),
    ),
    children: [
      TableRow(
        children: [
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    ],
  );
}

Widget cardItem(List<TableRow> items) {
  return Table(
    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
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

    children: items,
  );
}

TableRow h3Row(String text) {
  return TableRow(
    children: [
      Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      SizedBox(height: 30),
    ],
  );
}

TableRow rowItem(String label, String unit, String value) {
  return TableRow(
    children: [
      Text(
        label,
      ),
      Text(':'),
      Text('$value $unit'),
      SizedBox(height: 20),
    ],
  );
}

Future<Uint8List> makePdf(WellSelected wellsel) async {
  final logo = MemoryImage(
      (await rootBundle.load('assets/images/logo5_26_1061-removebg.png'))
          .buffer
          .asUint8List());
  List<Widget> pdfContents = [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text(
              "${wellsel.getWellName} Well Monitoring Report",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "Well General Information",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
    // card 1
    cardItem(
      [
        rowItem('Well Name', '', wellsel.getWellName),
        rowItem('Instalation Date', '', wellsel.getInstDate),
        rowItem('Location', '', wellsel.getLocation),
        rowItem('Village', '', wellsel.getVillage),
        rowItem('Status', '', wellsel.getStatus),
        rowItem('GS Name', '', wellsel.getGSName),
        rowItem('Lifting Method', '', wellsel.getLiftingMethod),
        rowItem('Water Cut', '', wellsel.getWaterCut),
        rowItem('BS&W', '', wellsel.getBSnW),
      ],
    ),
  ];
  final pdf = Document();

  pdf.addPage(
    MultiPage(
      build: (context) {
        return pdfContents;
      },
    ),
  );
  return pdf.save();
}
