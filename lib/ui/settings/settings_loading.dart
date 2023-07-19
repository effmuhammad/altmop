import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:altmop/helpers/sizes_helper.dart';

class SettingsLoading extends StatefulWidget {
  const SettingsLoading({super.key});

  @override
  State<SettingsLoading> createState() => _SettingsLoadingState();
}

class _SettingsLoadingState extends State<SettingsLoading> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          LoadingAnimationWidget.discreteCircle(
            color: Theme.of(context).primaryColor,
            size: displayWidth(context) / 4,
          ),
          const SizedBox(height: 80),
          const Text(
            'Connecting to Device',
            style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: const [
                Text('Make sure the device is in Setting Mode'),
                SizedBox(height: 5),
                Text(
                  '(In the device go to screen [6.Mode] enter setting mode by clicking OK button)',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
