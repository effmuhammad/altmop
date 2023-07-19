import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:altmop/ui/pdf_report/pdf_qas_oil.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

// import 'package:pdf/pdf.dart';

class PdfPreviewPage extends StatefulWidget {
  const PdfPreviewPage(
      {super.key, required this.pdfBytes, required this.reportTitle});
  final Uint8List pdfBytes;
  final String reportTitle;
  @override
  State<PdfPreviewPage> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<PdfPreviewPage> {
  @override
  void dispose() {
    super.dispose();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  Future<void> saveFile(
    String fileName,
    Uint8List pdfFile,
  ) async {
    var file = File('');

    // Platform.isIOS comes from dart:io
    if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      file = File('${dir.path}/$fileName');
    }

    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        status = await Permission.storage.request();
      }
      if (status.isGranted) {
        const downloadsFolderPath = '/storage/emulated/0/Download/';
        Directory dir = Directory(downloadsFolderPath);
        file = File('${dir.path}/$fileName');
      }
    }

    try {
      await file.writeAsBytes(pdfFile.buffer
          .asUint8List(pdfFile.offsetInBytes, pdfFile.lengthInBytes));
      var saveSuccess = SnackBar(
        showCloseIcon: true,
        content: Text.rich(
          TextSpan(
            text: 'File tersimpan di folder: ',
            children: <InlineSpan>[
              TextSpan(
                text: 'Download/$fileName ',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(saveSuccess);
    } on FileSystemException catch (err) {
      // handle error
      debugPrint("save file error");
      print(err);
      var saveSuccess = SnackBar(
        content: Text("Gagal menyimpan file"),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(saveSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    var pdfFile = widget.pdfBytes;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reportTitle),
      ),
      floatingActionButton: Wrap(
        direction: Axis.vertical, //use vertical to show  on vertical axis
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            child: FloatingActionButton(
              heroTag: "btn1",
              onPressed: () async {
                // action code print
                await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdfFile);
              },
              child: Icon(Icons.print),
            ),
          ), //button first

          Container(
            margin: EdgeInsets.all(10),
            child: FloatingActionButton(
              heroTag: "btn2",
              onPressed: () async {
                await Printing.sharePdf(
                  bytes: await pdfFile,
                  filename: 'generated.pdf'.replaceAll(':', '.'),
                );
              },
              // backgroundColor: Colors.blue,
              child: Icon(Icons.share),
            ),
          ), // button second

          Container(
            margin: EdgeInsets.all(10),
            child: FloatingActionButton(
              heroTag: "btn3",
              onPressed: () async {
                //action code for button 3
                await saveFile(
                    'generated.pdf'.replaceAll(':', '.'), await pdfFile);
              },
              // backgroundColor: Colors.blue,
              child: Icon(Icons.download),
            ),
          ), // button third

          // Add more buttons here
        ],
      ),
      body: PdfPreview(
        useActions: false,
        build: (context) => pdfFile,
      ),
    );
  }
}
