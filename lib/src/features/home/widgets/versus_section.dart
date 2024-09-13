import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/src/core/ui/colors.dart';
import 'package:my_app/src/core/ui/device.dart';
import 'package:my_app/src/core/ui/typography.dart';

class VersusSection extends StatelessWidget {
  const VersusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.responsiveContentPadding.copyWith(top: 50),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const GutterTiny(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Username',
                style: AppTextStyle().body.copyWith(
                    fontWeight: FontWeight.w600, color: AppColor.titleText,),
              ),
              Text(
                'Rank: 1',
                style: AppTextStyle()
                    .body
                    .copyWith(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
