import 'dart:typed_data';

// import 'package:flutter/material.dart';
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

Future<Uint8List> makePdf(WellSelected wellsel, Uint8List chartBytes) async {
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
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(4),
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
            colName('Date'),
            colName('Total Production (BBL)'),
          ],
        ),
        for (var data in wellsel.getDTosData)
          TableRow(
            children: [
              rowContent('${data[0]}'),
              rowContent('${data[1]}'),
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
              "Daily Data",
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
