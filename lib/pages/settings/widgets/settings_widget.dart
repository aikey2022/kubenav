import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:kubenav/controllers/global_settings_controller.dart';
import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/utils/custom_icons.dart';
import 'package:kubenav/utils/helpers.dart';
import 'package:kubenav/widgets/app_vertical_list_simple_widget.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalSettingsController globalSettingsController = Get.find();

    return AppVertialListSimpleWidget(
      title: 'Settings',
      items: [
        AppVertialListSimpleModel(
          onTap: () {
            Get.toNamed('/settings/providers');
          },
          children: [
            const Icon(
              CustomIcons.kubernetes,
              color: Constants.colorPrimary,
            ),
            const SizedBox(width: Constants.spacingSmall),
            Expanded(
              flex: 1,
              child: Text(
                'Provider Configurations',
                style: noramlTextStyle(
                  context,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[300],
              size: 16,
            ),
          ],
        ),
        AppVertialListSimpleModel(
          children: [
            const Icon(
              Icons.dark_mode,
              color: Constants.colorPrimary,
            ),
            const SizedBox(width: Constants.spacingSmall),
            Expanded(
              flex: 1,
              child: Text(
                'Dark Mode',
                style: noramlTextStyle(
                  context,
                ),
              ),
            ),
            Obx(
              () => Switch(
                activeColor: Constants.colorPrimary,
                onChanged: (val) => globalSettingsController.isDarkTheme.value =
                    !globalSettingsController.isDarkTheme.value,
                value: globalSettingsController.isDarkTheme.value,
              ),
            )
          ],
        ),
      ],
    );
  }
}
