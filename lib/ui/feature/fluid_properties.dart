import 'package:flutter/material.dart';
import 'package:altmop/models/fluid_prop.dart';
import 'package:change_notifier_builder/change_notifier_builder.dart';
import 'package:altmop/ui/pdf_report/pdf_page.dart';
import 'package:altmop/ui/pdf_report/pdf_fluid_properties.dart';

class FluidProperties extends StatefulWidget {
  const FluidProperties({super.key, required this.propData});
  final FluidProp propData;
  @override
  State<FluidProperties> createState() => _FluidPropertiesState();
}

// catatan: sementara controller di matikan dulu
class _FluidPropertiesState extends State<FluidProperties> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget calcCard(int card, Widget content) {
    return Visibility(
      visible: widget.propData.isHide(card) ? false : true,
      child: Container(
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
      ),
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
        IconButton(
          onPressed: () {
            widget.propData.hideCardHandler(card);
          },
          icon: Transform.rotate(
            angle: !widget.propData.isHide(card) ? 0 : 3.14,
            child: Icon(
              Icons.expand_circle_down_outlined,
              size: 30,
            ),
          ),
        )
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

  Widget tff(bool act, String label, String suffix, double data, int indVar) {
    return TextFormField(
      enabled: act,
      keyboardType: TextInputType.number,
      initialValue: act ? data.toString() : null,
      controller: !act ? TextEditingController(text: data.toString()) : null,
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
      onChanged: (value) {
        if (indVar == 1) widget.propData.massaPicnoKosong = double.parse(value);
        if (indVar == 2) widget.propData.massaPicnoIsiOil = double.parse(value);
        if (indVar == 3) widget.propData.massaJenisWater = double.parse(value);
        if (indVar == 4) widget.propData.volumePicno = double.parse(value);
        if (indVar == 5) widget.propData.tpc = double.parse(value);
        if (indVar == 6) widget.propData.ppc = double.parse(value);
        if (indVar == 7) widget.propData.tekananReservoir = double.parse(value);
        if (indVar == 8) widget.propData.gravityGas = double.parse(value);
        if (indVar == 9)
          widget.propData.temperatureReservoir = double.parse(value);
        if (indVar == 10) widget.propData.densitasWater = double.parse(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text("Fluid Properties"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ChangeNotifierBuilder<FluidProp>(
            notifier: widget.propData,
            builder: (BuildContext context, FluidProp? __, _) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Wrap(
                        children: [
                          Text(
                              '*Use "." to separate decimal number. You can input data to calculate in the form with line.')
                        ],
                      ),
                      SizedBox(height: 20), // card 1
                      h2Txt(
                        1,
                        "Calculation of Density, Specific Gravity & API",
                      ),
                      calcCard(
                        1,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            h3Txt('Input Data'),
                            tff(
                              true,
                              "Picno Mass (Empty)",
                              'gr',
                              widget.propData.massaPicnoKosong,
                              1,
                            ),
                            tff(
                              true,
                              "Picno Mass (Oil Filled)",
                              'gr',
                              widget.propData.massaPicnoIsiOil,
                              2,
                            ),
                            tff(
                              true,
                              "Water Density",
                              'gr/ml',
                              widget.propData.massaJenisWater,
                              3,
                            ),
                            tff(
                              true,
                              "Picno Volume",
                              'ml',
                              widget.propData.volumePicno,
                              4,
                            ),
                            SizedBox(height: 20),
                            h3Txt('Output Data'),
                            tff(
                              false,
                              "Density",
                              'gr/ml',
                              widget.propData.density,
                              0,
                            ),
                            tff(
                              false,
                              "Specific Gravity",
                              '',
                              widget.propData.specificGravity,
                              0,
                            ),
                            tff(
                              false,
                              "°API",
                              '°API',
                              widget.propData.api,
                              0,
                            ),
                          ],
                        ),
                      ),
                      // card 2
                      SizedBox(height: 40),
                      h2Txt(
                        2,
                        "Calculation of Pseudocritical Temperature & Pressure",
                      ),
                      calcCard(
                        2,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            h3Txt('Input Data'),
                            tff(
                              false,
                              "API",
                              '°API',
                              widget.propData.api,
                              0,
                            ),
                            SizedBox(height: 20),
                            h3Txt('Output Data'),
                            tff(
                              false,
                              "Gravity Oil",
                              '',
                              widget.propData.gravityOil,
                              0,
                            ),
                            tff(
                              true,
                              "Tpc",
                              '°R',
                              widget.propData.tpc,
                              5,
                            ),
                            tff(
                              true,
                              "Ppc",
                              'psia',
                              widget.propData.ppc,
                              6,
                            ),
                          ],
                        ),
                      ),
                      // card 3
                      SizedBox(height: 40),
                      h2Txt(
                        3,
                        "Calculation of Solution GOR (Rs)",
                      ),
                      calcCard(
                        3,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            h3Txt('Input Data'),
                            tff(
                              true,
                              "Reservoir Pressure",
                              'psi',
                              widget.propData.tekananReservoir,
                              7,
                            ),
                            tff(
                              true,
                              "Gravity Gas",
                              'psi',
                              widget.propData.gravityGas,
                              8,
                            ),
                            tff(
                              false,
                              "API",
                              '°API',
                              widget.propData.api,
                              0,
                            ),
                            tff(
                              true,
                              "Reservoir Temperature",
                              '°F',
                              widget.propData.temperatureReservoir,
                              9,
                            ),
                            SizedBox(height: 20),
                            h3Txt('Output Data'),
                            tff(
                              false,
                              "Solution GOR",
                              'scf/STB',
                              widget.propData.solutionGOR,
                              0,
                            ),
                          ],
                        ),
                      ),
                      // card 4
                      SizedBox(height: 40),
                      h2Txt(
                        4,
                        "Calculation of Bubble Point Pressure",
                      ),
                      calcCard(
                        4,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            h3Txt('Input Data'),
                            tff(
                              false,
                              "GOR",
                              'scf/STB',
                              widget.propData.gor,
                              0,
                            ),
                            tff(
                              false,
                              "Specific Gravity Gas",
                              '',
                              widget.propData.specificGravityGas,
                              0,
                            ),
                            tff(
                              false,
                              "Specific Gravity Oil",
                              '°API',
                              widget.propData.specificGravityMinyak,
                              0,
                            ),
                            tff(
                              false,
                              "Temperature Reservoir",
                              '°F',
                              widget.propData.temperatureReservoir,
                              0,
                            ),
                            SizedBox(height: 20),
                            h3Txt('Output Data'),
                            tff(
                              false,
                              "Bubble Point Pressure",
                              'psi',
                              widget.propData.bubblePointPressure,
                              0,
                            ),
                          ],
                        ),
                      ),
                      // card 5
                      SizedBox(height: 40),
                      h2Txt(
                        5,
                        "Calculation of Oil Compressibility",
                      ),
                      calcCard(
                        5,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            h3Txt('Input Data'),
                            tff(
                              false,
                              "Reservoir Pressure",
                              'psi',
                              widget.propData.tekananReservoir,
                              0,
                            ),
                            tff(
                              true,
                              "Water Density",
                              'lbm/ft³',
                              widget.propData.densitasWater,
                              10,
                            ),
                            tff(
                              false,
                              "Bubble Point Pressure",
                              'psi',
                              widget.propData.bubblePointPressure,
                              0,
                            ),
                            tff(
                              false,
                              "Specific Gravity Oil",
                              '',
                              widget.propData.specificGravityOil,
                              0,
                            ),
                            tff(
                              false,
                              "Oil Density",
                              'lbm/ft³',
                              widget.propData.densitasOil,
                              0,
                            ),
                            SizedBox(height: 20),
                            h3Txt('Output Data'),
                            tff(
                              false,
                              "Oil Compressibility",
                              '1/psi',
                              widget.propData.compresibilitasOil,
                              0,
                            ),
                          ],
                        ),
                      ),
                      // card 6
                      SizedBox(height: 40),
                      h2Txt(
                        6,
                        "Calculation of Formation Volume Factor",
                      ),
                      calcCard(
                        6,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            h3Txt('Input Data'),
                            tff(
                              false,
                              "GOR",
                              'scf/STB',
                              widget.propData.gor,
                              0,
                            ),
                            tff(
                              false,
                              "Gravity Gas",
                              '',
                              widget.propData.gravityGas,
                              0,
                            ),
                            tff(
                              false,
                              "Gravity Oil",
                              '',
                              widget.propData.gravityOil,
                              0,
                            ),
                            tff(
                              false,
                              "Reservoir Temperature",
                              '°F',
                              widget.propData.temperatureReservoir,
                              0,
                            ),
                            tff(
                              false,
                              "Oil Compresibility",
                              '1/psi',
                              widget.propData.compresibilitasOil,
                              0,
                            ),
                            tff(
                              false,
                              "Reservoir Pressure",
                              'psi',
                              widget.propData.tekananReservoir,
                              0,
                            ),
                            tff(
                              false,
                              "Bubble Point Pressure",
                              'psi',
                              widget.propData.bubblePointPressure,
                              0,
                            ),
                            SizedBox(height: 20),
                            h3Txt('Output at or below bubble point pressure :'),
                            tff(
                              false,
                              "F",
                              '',
                              widget.propData.F,
                              0,
                            ),
                            tff(
                              false,
                              "Formation Volume Factor",
                              'bbl/STB',
                              widget.propData.formationVolumeFactor,
                              0,
                            ),
                            SizedBox(height: 20),
                            h3Txt('Output above bubble point pressure :'),
                            tff(
                              false,
                              "Formation volume factor at Bubble Point",
                              'bbl/STB',
                              widget
                                  .propData.formationVolumeFactorAtBubblePoint,
                              0,
                            ),
                            tff(
                              false,
                              "Formation Volume Factor above Bubble Point",
                              'bbl/STB',
                              widget.propData
                                  .formationVolumeFactorAboveBubblePoint,
                              0,
                            ),
                          ],
                        ),
                      ),
                      // card 7
                      SizedBox(height: 40),
                      h2Txt(
                        7,
                        "Calculation of Formation Viscocity",
                      ),
                      calcCard(
                        7,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            h3Txt('Input Data'),
                            tff(
                              false,
                              "API",
                              '°API',
                              widget.propData.api,
                              0,
                            ),
                            tff(
                              false,
                              "Reservoir Temperature",
                              '°F',
                              widget.propData.temperatureReservoir,
                              0,
                            ),
                            tff(
                              false,
                              "GOR Solution",
                              'scf/STB',
                              widget.propData.solutionGOR,
                              0,
                            ),
                            tff(
                              false,
                              "Reservoir Pressure",
                              'psi',
                              widget.propData.tekananReservoir,
                              0,
                            ),
                            tff(
                              false,
                              "Bubble Point Pressure",
                              'psi',
                              widget.propData.tekananBubblePoint,
                              0,
                            ),
                            SizedBox(height: 20),
                            h3Txt('Output Data'),
                            tff(
                              false,
                              "A",
                              '',
                              widget.propData.A,
                              0,
                            ),
                            tff(
                              false,
                              "µod",
                              'cp',
                              widget.propData.uod,
                              0,
                            ),
                            tff(
                              false,
                              "a",
                              '',
                              widget.propData.a,
                              0,
                            ),
                            tff(
                              false,
                              "b",
                              '',
                              widget.propData.b,
                              0,
                            ),
                            tff(
                              false,
                              "c",
                              '',
                              widget.propData.c,
                              0,
                            ),
                            tff(
                              false,
                              "d",
                              '',
                              widget.propData.d,
                              0,
                            ),
                            tff(
                              false,
                              "e",
                              '',
                              widget.propData.e,
                              0,
                            ),
                            tff(
                              false,
                              "µob",
                              'cp',
                              widget.propData.uob,
                              0,
                            ),
                            tff(
                              false,
                              "µob",
                              'cp',
                              widget.propData.uo,
                              0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final pdfBytes = await makePdf(widget.propData);
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfPreviewPage(
                          pdfBytes: pdfBytes,
                          reportTitle: 'Fluid Properties Calculation',
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
            ),
          ),
        ],
      ),
    );
  }
}
