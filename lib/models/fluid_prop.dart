import 'package:flutter/material.dart';
import 'dart:math';

class FluidProp extends ChangeNotifier {
  bool _hideCard1 = false;
  bool _hideCard2 = false;
  bool _hideCard3 = false;
  bool _hideCard4 = false;
  bool _hideCard5 = false;
  bool _hideCard6 = false;
  bool _hideCard7 = false;
  bool _hideCard8 = false;

  // editable variable
  double _massaPicnoKosong = 0.0; // 1
  double _massaPicnoIsiOil = 0.0; // 2
  double _massaJenisWater = 0.0; // 3
  double _volumePicno = 0.0; // 4
  double _tpc = 0.0; // 5
  double _ppc = 0.0; // 6
  double _tekananReservoir = 0.0; // 7
  double _gravityGas = 0.0; // 8
  double _temperatureReservoir = 0.0; // 9
  double _densitasWater = 0.0; // 10

  // calculated variable
  double density = 0.0;
  double specificGravity = 0.0;
  double api = 0.0;
  double gravityOil = 0.0;
  double solutionGOR = 0.0;
  double gor = 0.0;
  double specificGravityGas = 0.0;
  double specificGravityMinyak = 0.0;
  double bubblePointPressure = 0.0;
  double specificGravityOil = 0.0;
  double densitasOil = 0.0;
  double compresibilitasOil = 0.0;
  double F = 0.0;
  double formationVolumeFactor = 0.0;
  double formationVolumeFactorAtBubblePoint = 0.0;
  double formationVolumeFactorAboveBubblePoint = 0.0;
  double tekananBubblePoint = 0.0;
  double A = 0.0;
  double uod = 0.0;
  double a = 0.0;
  double b = 0.0;
  double c = 0.0;
  double d = 0.0;
  double e = 0.0;
  double uob = 0.0;
  double uo = 0.0;

  void hideCardHandler(int card) {
    switch (card) {
      case 1:
        hideCard1 = !hideCard1;
        break;
      case 2:
        hideCard2 = !hideCard2;
        break;
      case 3:
        hideCard3 = !hideCard3;
        break;
      case 4:
        hideCard4 = !hideCard4;
        break;
      case 5:
        hideCard5 = !hideCard5;
        break;
      case 6:
        hideCard6 = !hideCard6;
        break;
      case 7:
        hideCard7 = !hideCard7;
        break;
      case 8:
        hideCard8 = !hideCard8;
        break;
      default:
        hideCard1 = !hideCard1;
    }
  }

  bool isHide(int card) {
    switch (card) {
      case 1:
        return hideCard1;
      case 2:
        return hideCard2;
      case 3:
        return hideCard3;
      case 4:
        return hideCard4;
      case 5:
        return hideCard5;
      case 6:
        return hideCard6;
      case 7:
        return hideCard7;
      case 8:
        return hideCard8;
      default:
        return hideCard1;
    }
  }

  void calculationFormula() {
    print(massaPicnoIsiOil);
    print(massaPicnoKosong);
    print(volumePicno);
    density = (massaPicnoIsiOil - massaPicnoKosong) / volumePicno;
    print(density);
    specificGravity = density / massaJenisWater;
    api = (141.5 / specificGravity) - 131.5;
    gravityOil = 141.5 / (api + 131.5);
    solutionGOR = gravityGas *
        pow(
            ((tekananReservoir * pow(10, (0.0125 * api))) /
                (18 * pow(10, (0.00091 * temperatureReservoir)))),
            1.2048);
    gor = solutionGOR;
    specificGravityGas = gravityGas;
    specificGravityMinyak = api;
    // temperatureReservoir = temperatureReservoir;
    bubblePointPressure = 18.2 *
        ((pow((gor / specificGravityGas), 0.83) *
                pow(
                    10,
                    ((0.00091 * temperatureReservoir) -
                        (0.0125 * specificGravityMinyak))) -
            1.4));
    // tekananReservoir = tekananReservoir;
    specificGravityOil = specificGravity;
    densitasOil = specificGravityOil * densitasWater;
    compresibilitasOil = (pow(10, -6) *
        exp((densitasOil +
                (0.004347 * (tekananReservoir - bubblePointPressure)) -
                79.1) /
            (((7.141 * pow(10, -4)) *
                    (tekananReservoir - bubblePointPressure)) -
                12.938)));
    F = (gor * pow((gravityGas / gravityOil), 0.5)) +
        (1.25 * temperatureReservoir);
    formationVolumeFactor = 0.972 + (0.000147 * pow(F, 1.175));
    formationVolumeFactorAtBubblePoint = formationVolumeFactor;
    formationVolumeFactorAboveBubblePoint = formationVolumeFactorAtBubblePoint *
        exp(compresibilitasOil * (tekananReservoir - bubblePointPressure));
    tekananBubblePoint = bubblePointPressure;
    A = pow(10, (0.43 + (8.33 / api))).toDouble();
    uod = (0.32 + ((1.8 * pow(10, 7)) / pow(api, 4.53))) *
        pow((360 / (temperatureReservoir + 200)), A);
    a = solutionGOR * ((2.2 * pow(10, -7) * solutionGOR) - (7.4 * pow(10, -4)));
    c = 8.62 * pow(10, -5) * solutionGOR;
    d = 1.1 * pow(10, -3) * solutionGOR;
    e = 3.74 * pow(10, -3) * solutionGOR;
    b = (0.68 / pow(10, c)) + (0.25 / pow(10, d)) + (0.062 / pow(10, e));
    uob = pow(10, a) * pow(uod, b).toDouble();
    uo = uob +
        0.001 *
            (tekananReservoir - tekananBubblePoint) *
            ((0.024 * pow(uob, 1.6)) + (0.38 * pow(uob, 0.56)));
  }

  set hideCard1(bool value) {
    _hideCard1 = value;
    notifyListeners();
  }

  set hideCard2(bool value) {
    _hideCard2 = value;
    notifyListeners();
  }

  set hideCard3(bool value) {
    _hideCard3 = value;
    notifyListeners();
  }

  set hideCard4(bool value) {
    _hideCard4 = value;
    notifyListeners();
  }

  set hideCard5(bool value) {
    _hideCard5 = value;
    notifyListeners();
  }

  set hideCard6(bool value) {
    _hideCard6 = value;
    notifyListeners();
  }

  set hideCard7(bool value) {
    _hideCard7 = value;
    notifyListeners();
  }

  set hideCard8(bool value) {
    _hideCard8 = value;
    notifyListeners();
  }

  bool get hideCard1 => _hideCard1;
  bool get hideCard2 => _hideCard2;
  bool get hideCard3 => _hideCard3;
  bool get hideCard4 => _hideCard4;
  bool get hideCard5 => _hideCard5;
  bool get hideCard6 => _hideCard6;
  bool get hideCard7 => _hideCard7;
  bool get hideCard8 => _hideCard8;

  double get massaPicnoKosong => _massaPicnoKosong;

  set massaPicnoKosong(double value) {
    _massaPicnoKosong = value;
    calculationFormula();
    notifyListeners();
  }

  double get massaPicnoIsiOil => _massaPicnoIsiOil;

  set massaPicnoIsiOil(double value) {
    _massaPicnoIsiOil = value;
    calculationFormula();
    notifyListeners();
  }

  double get massaJenisWater => _massaJenisWater;

  set massaJenisWater(double value) {
    _massaJenisWater = value;
    calculationFormula();
    notifyListeners();
  }

  double get volumePicno => _volumePicno;

  set volumePicno(double value) {
    _volumePicno = value;
    calculationFormula();
    notifyListeners();
  }

  double get tpc => _tpc;

  set tpc(double value) {
    _tpc = value;
    calculationFormula();
    notifyListeners();
  }

  double get ppc => _ppc;

  set ppc(double value) {
    _ppc = value;
    calculationFormula();
    notifyListeners();
  }

  double get tekananReservoir => _tekananReservoir;

  set tekananReservoir(double value) {
    _tekananReservoir = value;
    calculationFormula();
    notifyListeners();
  }

  double get gravityGas => _gravityGas;

  set gravityGas(double value) {
    _gravityGas = value;
    calculationFormula();
    notifyListeners();
  }

  double get temperatureReservoir => _temperatureReservoir;

  set temperatureReservoir(double value) {
    _temperatureReservoir = value;
    calculationFormula();
    notifyListeners();
  }

  double get densitasWater => _densitasWater;

  set densitasWater(double value) {
    _densitasWater = value;
    calculationFormula();
    notifyListeners();
  }
}
