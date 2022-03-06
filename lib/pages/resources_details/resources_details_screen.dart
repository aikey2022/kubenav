import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:kubenav/models/resource_model.dart';
import 'package:kubenav/pages/resources_details/resources_details_controller.dart';
import 'package:kubenav/widgets/app_actions_header_widget.dart';
import 'package:kubenav/widgets/app_bottom_navigation_bar_widget.dart';
import 'package:kubenav/widgets/app_error_widget.dart';
import 'package:kubenav/pages/resources_details/widgets/details_item_conditions_widget.dart';
import 'package:kubenav/pages/resources_details/widgets/details_item_metadata_widget.dart';
import 'package:kubenav/pages/resources_details/widgets/details_resources_preview_widget.dart';
import 'package:kubenav/utils/constants.dart';

class ResourcesDetails extends GetView {
  const ResourcesDetails({Key? key}) : super(key: key);

  /// [buildDetailsItem] is responsible for showing the correct details item for the selected resource. If we do not
  /// have a dedicated item for a resource (e.g. Custom Resources) we are showing the events for the resource.
  Widget buildDetailsItem(
    String? title,
    String? resource,
    String? path,
    ResourceScope? scope,
    String? name,
    String? namespace,
    dynamic item,
  ) {
    if (resource != null &&
        path != null &&
        Resources.map.containsKey(resource) &&
        Resources.map[resource]!.resource == resource &&
        Resources.map[resource]!.path == path &&
        Resources.map[resource]!.buildDetailsItem != null) {
      return Resources.map[resource]!.buildDetailsItem!(item);
    }

    return DetailsResourcesPreviewWidget(
      title: Resources.map['events']!.title,
      resource: Resources.map['events']!.resource,
      path: Resources.map['events']!.path,
      scope: Resources.map['events']!.scope,
      namespace: item['metadata']['namespace'],
      selector: 'fieldSelector=involvedObject.name=${item['metadata']['name']}',
    );
  }

  @override
  Widget build(BuildContext context) {
    ResourcesDetailsController controller = Get.put(
      ResourcesDetailsController(
        title: Get.parameters['title'],
        resource: Get.parameters['resource'],
        path: Get.parameters['path'],
        scope: resourceScopeFromString(Get.parameters['scope']),
        name: Get.parameters['name'],
        namespace: Get.parameters['namespace'],
      ),
      tag:
          '${Get.parameters['title']} ${Get.parameters['resource']} ${Get.parameters['path']} ${Get.parameters['scope']} ${Get.parameters['name']} ${Get.parameters['namespace']}',
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              Characters(controller.name ?? 'Unknown Resource')
                  .replaceAll(Characters(''), Characters('\u{200B}'))
                  .toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              Characters(controller.namespace ?? 'No Namespace')
                  .replaceAll(Characters(''), Characters('\u{200B}'))
                  .toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBarWidget(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(
              () {
                if (controller.loading.value) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(Constants.spacingMiddle),
                        child: CircularProgressIndicator(
                            color: Constants.colorPrimary),
                      ),
                    ],
                  );
                }

                if (controller.error.value != '') {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(Constants.spacingMiddle),
                          child: AppErrorWidget(
                            message: 'Could not load ${controller.title}',
                            details: controller.error.value,
                            icon: Resources.map.containsKey(controller.resource)
                                ? 'assets/resources/image108x108/${controller.resource}.png'
                                : null,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    AppActionsHeaderWidget(
                      actions: [
                        AppActionsHeaderModel(
                          title: 'Yaml',
                          icon: Icons.description,
                          onTap: () {
                            controller.showYaml();
                          },
                        ),
                        AppActionsHeaderModel(
                          title: 'Edit',
                          icon: Icons.edit,
                          onTap: () {
                            controller.editResource();
                          },
                        ),
                        AppActionsHeaderModel(
                          title: 'Delete',
                          icon: Icons.delete,
                          onTap: () {
                            controller.deleteResource();
                          },
                        ),
                        AppActionsHeaderModel(
                          title: 'Refresh',
                          icon: Icons.refresh,
                          onTap: () {
                            controller.getResource();
                          },
                        ),
                        AppActionsHeaderModel(
                          title: 'Bookmark',
                          icon: Icons.bookmark_border,
                          onTap: () {},
                        ),
                      ],
                    ),
                    DetailsItemMetadataWidget(
                      item: controller.item,
                    ),
                    DetailsItemConditionsWidget(
                      item: controller.item,
                    ),
                    const SizedBox(height: Constants.spacingMiddle),
                    buildDetailsItem(
                      controller.title,
                      controller.resource,
                      controller.path,
                      controller.scope,
                      controller.name,
                      controller.namespace,
                      controller.item,
                    ),
                    const SizedBox(height: Constants.spacingExtraLarge),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
