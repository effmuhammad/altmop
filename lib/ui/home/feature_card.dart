import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeatureCard extends StatelessWidget {
  FeatureCard(
      {super.key,
      required this.title,
      required this.iconPath,
      required this.onPressed});
  String title;
  String iconPath;
  Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.r,
      width: 140.r,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0.r),
          ),
        ),
        onPressed: onPressed,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150.r,
                  height: 100.r,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(100.r),
                      bottomRight: Radius.circular(100.r),
                    ),
                  ),
                ),
                SizedBox(
                  height: 60.r,
                  width: 60.r,
                  child: Image.asset(iconPath),
                ),
              ],
            ),
            const Expanded(child: SizedBox()),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                color: Colors.black87,
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}
