import 'package:flutter/material.dart';
import 'package:altmop/ui/feature/well_monitoring/wellmo_information.dart';
import 'package:altmop/ui/feature/well_monitoring/wellmo_hourly.dart';
import 'package:altmop/ui/feature/well_monitoring/wellmo_daily.dart';
import 'package:altmop/models/well_selected.dart';

class WellMonitoring extends StatefulWidget {
  final WellSelected wellsel;
  const WellMonitoring({super.key, required this.wellsel});

  @override
  _WellMonitoringState createState() => _WellMonitoringState();
}

class _WellMonitoringState extends State<WellMonitoring> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Information',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Tab(
                child: Text(
                  'Hourly',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Tab(
                child: Text(
                  'Daily',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          title: Text('Well Monitoring'),
          centerTitle: true,
        ),
        body: TabBarView(
          children: [
            WellInfo(
              wellsel: widget.wellsel,
            ),
            HourlyProd(
              wellsel: widget.wellsel,
            ),
            DailyProd(
              wellsel: widget.wellsel,
            ),
          ],
        ),
      ),
    );
  }
}
