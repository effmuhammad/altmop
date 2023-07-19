class HourProduction {
  HourProduction(
      {required this.hour,
      required this.grossProduction,
      required this.pressure,
      required this.temperature});
  int hour;
  double grossProduction;
  double pressure;
  double temperature;
}

class DailyProduction {
  DailyProduction(
      {required this.date,
      required this.grossProduction,
      required this.pressure,
      required this.temperature});
  DateTime date;
  double grossProduction;
  double pressure;
  double temperature;
}
