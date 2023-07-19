import 'dart:typed_data';

// import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'dart:io';
import 'package:altmop/models/fluid_prop.dart';
import 'package:flutter/services.dart' show rootBundle;

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

TableRow rowItem(String label, String unit, double value) {
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

Future<Uint8List> makePdf(FluidProp propData) async {
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
              "Fluid Properties",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "Calculation Report",
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
    h2Row(
      "Calculation of Density, Specific Gravity & API",
    ),
    cardItem(
      [
        h3Row('Input Data'),
        rowItem("Picno Mass (Empty)", 'gr', propData.massaPicnoKosong),
        rowItem("Picno Mass (Oil Filled)", 'gr', propData.massaPicnoIsiOil),
        rowItem("Water Density", 'gr/ml', propData.massaJenisWater),
        rowItem("Picno Volume", 'ml', propData.volumePicno),
        h3Row('Output Data'),
        rowItem("Density", 'gr/ml', propData.density),
        rowItem("Specific Gravity", '', propData.specificGravity),
        rowItem("°API", '°API', propData.api),
      ],
    ),

    SizedBox(height: 20),

    // card 2
    h2Row(
      "Calculation of Pseudocritical Temperature & Pressure",
    ),
    cardItem(
      [
        h3Row('Input Data'),
        rowItem("API", '°API', propData.api),
        h3Row('Output Data'),
        rowItem("Gravity Oil", '', propData.gravityOil),
        rowItem("Tpc", '°R', propData.tpc),
        rowItem("Ppc", 'psia', propData.ppc),
      ],
    ),

    SizedBox(height: 20),

    // card 3
    h2Row(
      "Calculation of Solution GOR (Rs)",
    ),
    cardItem(
      [
        h3Row('Input Data'),
        rowItem("Reservoir Pressure", 'psi', propData.tekananReservoir),
        rowItem("Gravity Gas", 'psi', propData.gravityGas),
        rowItem("API", '°API', propData.api),
        rowItem("Reservoir Temperature", '°F', propData.temperatureReservoir),
        h3Row('Output Data'),
        rowItem("Solution GOR", 'scf/STB', propData.solutionGOR),
      ],
    ),

    SizedBox(height: 20),

    // card 4
    h2Row(
      "Calculation of Bubble Point Pressure",
    ),
    cardItem(
      [
        h3Row('Input Data'),
        rowItem("GOR", 'scf/STB', propData.gor),
        rowItem("Specific Gravity Gas", '', propData.specificGravityGas),
        rowItem("Specific Gravity Oil", '°API', propData.specificGravityMinyak),
        rowItem("Temperature Reservoir", '°F', propData.temperatureReservoir),
        h3Row('Output Data'),
        rowItem("Bubble Point Pressure", 'psi', propData.bubblePointPressure),
      ],
    ),

    SizedBox(height: 20),

    // card 5
    h2Row(
      "Calculation of Oil Compressibility",
    ),
    cardItem(
      [
        h3Row('Input Data'),
        rowItem("Reservoir Pressure", 'psi', propData.tekananReservoir),
        rowItem("Water Density", 'lbm/ft³', propData.densitasWater),
        rowItem("Bubble Point Pressure", 'psi', propData.bubblePointPressure),
        rowItem("Specific Gravity Oil", '', propData.specificGravityOil),
        rowItem("Oil Density", 'lbm/ft³', propData.densitasOil),
        h3Row('Output Data'),
        rowItem("Oil Compressibility", '1/psi', propData.compresibilitasOil),
      ],
    ),

    SizedBox(height: 20),

    // card 6
    h2Row(
      "Calculation of Formation Volume Factor",
    ),
    cardItem(
      [
        h3Row('Input Data'),
        rowItem("GOR", 'scf/STB', propData.gor),
        rowItem("Gravity Gas", '', propData.gravityGas),
        rowItem("Gravity Oil", '', propData.gravityOil),
        rowItem("Reservoir Temperature", '°F', propData.temperatureReservoir),
        rowItem("Oil Compresibility", '1/psi', propData.compresibilitasOil),
        rowItem("Reservoir Pressure", 'psi', propData.tekananReservoir),
        rowItem("Bubble Point Pressure", 'psi', propData.bubblePointPressure),
        h3Row('Output at or below bubble point pressure :'),
        rowItem("F", '', propData.F),
        rowItem("Formation Volume Factor", 'bbl/STB',
            propData.formationVolumeFactor),
        h3Row('Output above bubble point pressure :'),
        rowItem("Formation volume factor at Bubble Point", 'bbl/STB',
            propData.formationVolumeFactorAtBubblePoint),
        rowItem("Formation Volume Factor above Bubble Point", 'bbl/STB',
            propData.formationVolumeFactorAboveBubblePoint),
      ],
    ),

    SizedBox(height: 20),

    // card 7
    h2Row(
      "Calculation of Formation Viscocity",
    ),
    cardItem(
      [
        h3Row('Input Data'),
        rowItem("API", '°API', propData.api),
        rowItem("Reservoir Temperature", '°F', propData.temperatureReservoir),
        rowItem("GOR Solution", 'scf/STB', propData.solutionGOR),
        rowItem("Reservoir Pressure", 'psi', propData.tekananReservoir),
        rowItem("Bubble Point Pressure", 'psi', propData.tekananBubblePoint),
        h3Row('Output Data'),
        rowItem("A", '', propData.A),
        rowItem("µod", 'cp', propData.uod),
        rowItem("a", '', propData.a),
        rowItem("b", '', propData.b),
        rowItem("c", '', propData.c),
        rowItem("d", '', propData.d),
        rowItem("e", '', propData.e),
        rowItem("µob", 'cp', propData.uob),
        rowItem("µob", 'cp', propData.uo),
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
