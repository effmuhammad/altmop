import 'package:flutter/material.dart';
import 'package:altmop/models/well_selected.dart';
import 'package:altmop/ui/feature/tank_on_site/tos_information.dart';
import 'package:altmop/ui/feature/tank_on_site/tos_hourly.dart';
import 'package:altmop/ui/feature/tank_on_site/tos_daily.dart';

class TankOnSiteMonitoring extends StatefulWidget {
  final WellSelected wellsel;
  const TankOnSiteMonitoring({super.key, required this.wellsel});

  @override
  State<TankOnSiteMonitoring> createState() => _TankOnSiteMonitoringState();
}

class _TankOnSiteMonitoringState extends State<TankOnSiteMonitoring> {
  bool isEdit = false;

  Widget formattedCard(Widget icon, Widget title, {bool loading = false}) {
    return Container(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        // color: Colors.blueGrey.shade100,
        elevation: 3,
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade100,
                Colors.blueGrey.shade100,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: ListTile(
              horizontalTitleGap: 18.0,
              leading: icon,
              trailing: loading
                  ? SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(),
                    )
                  : null,
              title: title,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // pos level max 180 min 0
    double posLevel = 20;
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
          title: Text('Tank On Site Monitoring'),
          centerTitle: true,
        ),
        body: TabBarView(
          children: [
            TOSInfo(
              wellsel: widget.wellsel,
            ),
            TOSHourly(
              wellsel: widget.wellsel,
            ),
            TOSDaily(
              wellsel: widget.wellsel,
            ),
          ],
        ),
      ),
    );
  }
}
