import 'dart:typed_data';

// import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'dart:io';
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

Future<Uint8List> makePdf(WellSelected wellsel, Uint8List chartBytes,
    String totalVolume, String finalStock) async {
  final logo = MemoryImage(
      (await rootBundle.load('assets/images/logo5_26_1061-removebg.png'))
          .buffer
          .asUint8List());
  final chart = MemoryImage(chartBytes);

  double calcVolByLevel(level) {
    double vol = 0;
    try {
      vol = double.parse(
          (level * double.parse(wellsel.getCm1)).toStringAsFixed(3));
    } catch (e) {
      vol = double.parse((level).toStringAsFixed(3));
    }
    return vol;
  }

  Widget dataTable() {
    Widget colName(String text) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: 12,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    Widget rowContent(String text) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      );
    }

    return Table(
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(3),
      },
      border: TableBorder(
        horizontalInside: BorderSide(
          width: 1,
          color: PdfColor.fromInt(0xFFCFD8DC),
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
        for (var data in wellsel.getH2Data)
          TableRow(
            children: [
              rowContent('${data[1].substring(0, 2)}'),
              rowContent('${data[3]}'),
              rowContent('${calcVolByLevel(data[3])}'),
            ],
          ),
      ],
    );
  }

  List<Widget> pdfContents = [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text(
              "TOS ${wellsel.getWellName} Tank on Site Report",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "Hourly Data Report on ${wellsel.getH2ShowDate}",
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
        rowItem('Total Volume', 'BBL', totalVolume),
        rowItem('Trucking Transportation', 'BBL', wellsel.getTrucking),
        rowItem('Final Stock', 'BBL', finalStock),
      ],
    ),
    SizedBox(height: 30),
    Center(
      child: SizedBox(
        height: 400,
        width: 400,
        child: Image(chart),
      ),
    ),
    dataTable(),
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
