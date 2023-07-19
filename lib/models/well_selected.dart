import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WellSelected extends ChangeNotifier {
  List<String> _allWell = ['None'];
  bool _isLoadingAllWell = false;
  bool _isLoadingData = false;
  bool _isServerOk = true;
  String _wellName = 'None';
  String _length = '';
  String _width = '';
  String _height = '';
  String _instDate = '';
  String _location = '';
  String _village = '';
  String _status = '';
  String _gsName = '';
  String _liftingMethod = '';
  String _waterCut = '';
  String _BSnW = '';
  String _capacity = '';
  String _trucking = '';
  String _temperature = '';
  String _density = '';
  String _cm1 = '';
  List<dynamic> _h2Data = [];
  List<dynamic> _dData = [];
  List<dynamic> _dTosData = [];
  String _h2ShowDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _tankLevel = '0';

  Future<bool> loadTankLevel() async {
    print('load tank level data');
    setLoadingData = true;
    try {
      final response = await http
          .get(Uri.parse(
              'https://script.google.com/macros/s/AKfycbxTAp84bJrtCd65U2tt7M5IuYm9zGLwkbkRsY1_2J_6DQLmfOWhFbujLoNAzMixGXrb/exec?'
              'action=read'
              '&user_req=tank_level'
              '&wellname=$_wellName'))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        try {
          setTankLevel = jsonData[3].toStringAsFixed(1);
        } catch (e) {
          setTankLevel = '0';
        }
        print(_tankLevel);
      } else {
        setServerOk = false;
        setLoadingData = false;
        return false;
        // throw Exception('Failed to load data');
      }
    } catch (e) {
      print('load tank level error');
      print(e);

      setServerOk = false;
      setLoadingData = false;
      return false;
    }
    setLoadingData = false;
    return true;
  }

  Future<bool> loadDTosData() async {
    print('load daily tos data');
    setLoadingData = true;
    try {
      final response = await http
          .get(Uri.parse(
              'https://script.google.com/macros/s/AKfycbxTAp84bJrtCd65U2tt7M5IuYm9zGLwkbkRsY1_2J_6DQLmfOWhFbujLoNAzMixGXrb/exec?'
              'action=read'
              '&user_req=d_tos_data'
              '&wellname=$_wellName'))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setServerOk = true;
        setDTosData = jsonData;
        print(_dTosData);
      } else {
        setServerOk = false;
        setLoadingData = false;
        return false;
        // throw Exception('Failed to load data');
      }
    } catch (e) {
      print('load d tos data error');
      print(e);
      setServerOk = false;
      setLoadingData = false;
      return false;
    }
    setLoadingData = false;
    return true;
  }

  Future<bool> loadDData() async {
    print('load daily data');
    setLoadingData = true;
    try {
      final response = await http
          .get(Uri.parse(
              'https://script.google.com/macros/s/AKfycbxTAp84bJrtCd65U2tt7M5IuYm9zGLwkbkRsY1_2J_6DQLmfOWhFbujLoNAzMixGXrb/exec?'
              'action=read'
              '&user_req=d_data'
              '&wellname=$_wellName'))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setServerOk = true;
        setDData = jsonData;
        print(_dData);
      } else {
        setServerOk = false;
        setLoadingData = false;
        return false;
        // throw Exception('Failed to load data');
      }
    } catch (e) {
      print('load d data error');
      print(e);
      setServerOk = false;
      setLoadingData = false;
      return false;
    }
    setLoadingData = false;
    return true;
  }

  Future<bool> loadH2Data(String date) async {
    print('load h2 data');
    setLoadingData = true;
    try {
      final response = await http
          .get(Uri.parse(
              'https://script.google.com/macros/s/AKfycbxTAp84bJrtCd65U2tt7M5IuYm9zGLwkbkRsY1_2J_6DQLmfOWhFbujLoNAzMixGXrb/exec?'
              'action=read'
              '&user_req=h2_data'
              '&wellname=$_wellName'
              '&date=$date'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setServerOk = true;
        setH2Data = jsonData[0];
        try {
          setTrucking = jsonData[1].toStringAsFixed(3);
        } catch (e) {
          setTrucking = '0.000';
        }
        print(_h2Data);
      } else {
        setServerOk = false;
        setLoadingData = false;
        return false;
        // throw Exception('Failed to load data');
      }
    } catch (e) {
      print('load h2 data error');
      print(e);
      setServerOk = false;
      setLoadingData = false;
      return false;
    }
    setLoadingData = false;
    return true;
  }

  List<String> get getAllWell => _allWell;
  bool get isServerOk => _isServerOk;
  bool get isLoadingAllWell => _isLoadingAllWell;
  bool get isLoadingData => _isLoadingData;
  String get getWellName => _wellName;
  String get getLength => _length;
  String get getWidth => _width;
  String get getHeight => _height;
  String get getInstDate => _instDate;
  String get getLocation => _location;
  String get getVillage => _village;
  String get getStatus => _status;
  String get getGSName => _gsName;
  String get getLiftingMethod => _liftingMethod;
  String get getWaterCut => _waterCut;
  String get getBSnW => _BSnW;

  String get getCapacity => _capacity;
  String get getTrucking => _trucking;
  String get getTemperature => _temperature;
  String get getDensity => _density;
  String get getCm1 => _cm1;

  List<dynamic> get getH2Data => _h2Data;
  List<dynamic> get getDData => _dData;
  List<dynamic> get getDTosData => _dTosData;

  String get getH2ShowDate => _h2ShowDate;

  String get getTankLevel => _tankLevel;

  set setAllWell(var val) {
    _allWell = [];
    for (var i in val['allwell']) {
      _allWell.add(i);
    }
    if (_wellName == 'None') {
      _wellName = _allWell[0];
    }
    notifyListeners();
  }

  set setServerOk(bool val) {
    _isServerOk = val;
    notifyListeners();
  }

  set setLoadingAllWell(bool val) {
    _isLoadingAllWell = val;
    notifyListeners();
  }

  set setLoadingData(bool val) {
    _isLoadingData = val;
    notifyListeners();
  }

  set setWellName(String val) {
    _wellName = val;
    notifyListeners();
  }

  set setLength(String val) {
    _length = val;
    notifyListeners();
  }

  set setWidth(String val) {
    _width = val;
    notifyListeners();
  }

  set setHeight(String val) {
    _height = val;
    notifyListeners();
  }

  set setInstDate(String val) {
    _instDate = val;
    notifyListeners();
  }

  set setLocation(String val) {
    _location = val;
    notifyListeners();
  }

  set setVillage(String val) {
    _village = val;
    notifyListeners();
  }

  set setStatus(String val) {
    _status = val;
    notifyListeners();
  }

  set setGSName(String val) {
    _gsName = val;
    notifyListeners();
  }

  set setLiftingMethod(String val) {
    _liftingMethod = val;
    notifyListeners();
  }

  set setWaterCut(String val) {
    _waterCut = val;
    notifyListeners();
  }

  set setBSnW(String val) {
    _BSnW = val;
    notifyListeners();
  }

  set setCapacity(String val) {
    _capacity = val;
    notifyListeners();
  }

  set setTrucking(String val) {
    _trucking = val;
    notifyListeners();
  }

  set setTemperature(String val) {
    _temperature = val;
    notifyListeners();
  }

  set setDensity(String val) {
    _density = val;
    notifyListeners();
  }

  set setCM1(String val) {
    _cm1 = val;
    notifyListeners();
  }

  set setH2Data(var val) {
    _h2Data = val;
    notifyListeners();
  }

  set setDData(var val) {
    _dData = val;

    notifyListeners();
  }

  set setDTosData(var val) {
    _dTosData = val;
    notifyListeners();
  }

  set setH2ShowDate(String val) {
    _h2ShowDate = val;
    notifyListeners();
  }

  set setTankLevel(String val) {
    _tankLevel = val;
    notifyListeners();
  }
}
