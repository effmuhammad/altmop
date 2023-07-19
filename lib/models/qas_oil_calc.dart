import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class QasOilCalc extends ChangeNotifier {
  bool _isLoadingData = false;
  bool _isServerOk = true;
  double suhuCal = 0;
  double waktuPengukuran = 0;
  double tinggiCairan = 0;
  double volumeCairan = 0;
  double tinggiAirBebas = 0;
  double volumeAirBebas = 0;
  double suhuLab = 0;
  double suhuTank = 0;
  double densitasPengukuran = 0;
  double densitasSTD15oC = 0;
  double bsw = 0;
  double saltCont = 0;
  String api = '';
  double grossObs = 0;
  double faktorKoreksiVolume = 0;
  double volumeKoreksi = 0;
  double netStdM3 = 0;
  double netStdBbl = 0;
  double totalStdProduksiGross = 0;
  double totalStdProduksiNett = 0;
  double totalStdTrfKePPGross = 0;
  double totalStdTrfKePPNett = 0;

  Map<String, double> calcRes = {};

  Future<bool> calculate() async {
    print('calculate qas oil data');
    setLoadingData = true;
    try {
      print('&saltCont=$saltCont');
      final response = await http
          .get(Uri.parse(
              'https://script.google.com/macros/s/AKfycbzvByrGdXYp7C1enGKzmoQIPz6BVAwRgrJQ28z2GbWo1JcjSKzGLb2nKODuFrV58CTHSw/exec?'
              'action=read'
              '&user_req=qas_oil_calc'
              '&suhuCal=$suhuCal'
              '&waktuPengukuran=$waktuPengukuran'
              '&tinggiCairan=$tinggiCairan'
              '&tinggiAirBebas=$tinggiAirBebas'
              '&suhuLab=$suhuLab'
              '&densitasPengukuran=$densitasPengukuran'
              '&bsw=$bsw'
              '&saltCont=$saltCont'
              '&totalStdProduksiGross=$totalStdProduksiGross'
              '&totalStdProduksiNett=$totalStdProduksiNett'
              '&totalStdTrfKePPGross=$totalStdTrfKePPGross'
              '&totalStdTrfKePPNett=$totalStdTrfKePPNett'))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print(jsonData);

        volumeCairan = jsonData['volumeCairan'] * 1.0;
        volumeAirBebas = jsonData['volumeAirBebas'] * 1.0;
        suhuTank = jsonData['suhuTank'] * 1.0;
        densitasSTD15oC = jsonData['densitasSTD15oC'] * 1.0;
        api = jsonData['api'];
        grossObs = jsonData['grossObs'] * 1.0;
        faktorKoreksiVolume = jsonData['faktorKoreksiVolume'] * 1.0;
        volumeKoreksi = jsonData['volumeKoreksi'] * 1.0;
        netStdM3 = jsonData['netStdM3'] * 1.0;
        netStdBbl = jsonData['netStdBbl'] * 1.0;
      } else {
        setServerOk = false;
        setLoadingData = false;
        return false;
        // throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
      setServerOk = false;
      setLoadingData = false;
      return false;
    }
    setLoadingData = false;
    return true;
  }

  void inputChange(int id, String value) {
    switch (id) {
      case 1:
        suhuCal = double.parse(value);
        break;
      case 2:
        waktuPengukuran = double.parse(value);
        break;
      case 3:
        tinggiCairan = double.parse(value);
        break;
      case 4:
        volumeCairan = double.parse(value);
        break;
      case 5:
        tinggiAirBebas = double.parse(value);
        break;
      case 6:
        volumeAirBebas = double.parse(value);
        break;
      case 7:
        suhuLab = double.parse(value);
        break;
      case 8:
        suhuTank = double.parse(value);
        break;
      case 9:
        densitasPengukuran = double.parse(value);
        break;
      case 10:
        densitasSTD15oC = double.parse(value);
        break;
      case 11:
        bsw = double.parse(value);
        break;
      case 12:
        saltCont = double.parse(value);
        break;
      case 13:
        api = value;
        break;
      case 14:
        grossObs = double.parse(value);
        break;
      case 15:
        faktorKoreksiVolume = double.parse(value);
        break;
      case 16:
        volumeKoreksi = double.parse(value);
        break;
      case 17:
        netStdM3 = double.parse(value);
        break;
      case 18:
        netStdBbl = double.parse(value);
        break;
      case 19:
        totalStdProduksiGross = double.parse(value);
        break;
      case 20:
        totalStdProduksiNett = double.parse(value);
        break;
      case 21:
        totalStdTrfKePPGross = double.parse(value);
        break;
      case 22:
        totalStdTrfKePPNett = double.parse(value);
        break;
      default:
        // Handle invalid id
        break;
    }
    notifyListeners();
  }

  set setLoadingData(bool value) {
    _isLoadingData = value;
    notifyListeners();
  }

  set setServerOk(bool value) {
    _isServerOk = value;
    notifyListeners();
  }

  bool get isLoadingData => _isLoadingData;
  bool get isServerOk => _isServerOk;
}
