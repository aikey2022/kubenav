import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:kubenav/models/plugins/flux/io_fluxcd_toolkit_source_v1beta2_oci_repository.dart';
import 'package:kubenav/models/plugins/flux/io_fluxcd_toolkit_source_v1beta2_oci_repository_list.dart';
import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/utils/resources.dart';
import 'package:kubenav/widgets/plugins/flux/plugin_flux_details.dart';
import 'package:kubenav/widgets/plugins/flux/plugin_flux_list.dart';
import 'package:kubenav/widgets/plugins/flux/resources/plugin_flux_resources.dart';
import 'package:kubenav/widgets/resources/helpers/details_item.dart';
import 'package:kubenav/widgets/resources/helpers/details_item_conditions.dart';
import 'package:kubenav/widgets/resources/helpers/details_item_metadata.dart';
import 'package:kubenav/widgets/resources/helpers/details_resources_preview.dart';
import 'package:kubenav/widgets/resources/resources/resources_events.dart';

final fluxResourceOCIRepository =
    FluxResource<IoFluxcdToolkitSourceV1beta2OCIRepository>(
  category: FluxResourceCategory.sourceController,
  plural: 'OCI Repositories',
  singular: 'OCI Repository',
  description:
      'The OCIRepository API defines a Source to produce an Artifact for an OCI repository',
  path: '/apis/source.toolkit.fluxcd.io/v1beta2',
  resource: 'ocirepositories',
  decodeList: (String data) {
    final parsed = json.decode(data);
    return IoFluxcdToolkitSourceV1beta2OCIRepositoryList.fromJson(parsed)
            ?.items ??
        [];
  },
  decodeItem: (String data) {
    final parsed = json.decode(data);
    return IoFluxcdToolkitSourceV1beta2OCIRepository.fromJson(parsed);
  },
  encodeItem: (dynamic item) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(item);
  },
  listWidget: const ListWidget(),
  detailsWidget: (String name, String namespace) {
    return DetailsWidget(
      name: name,
      namespace: namespace,
    );
  },
);

class ListWidget extends StatelessWidget {
  const ListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PluginFluxList<IoFluxcdToolkitSourceV1beta2OCIRepository>(
      resource: fluxResourceOCIRepository,
      itemBuilder: (dynamic listItem) {
        final item = listItem as IoFluxcdToolkitSourceV1beta2OCIRepository;

        return PluginFluxListItem<IoFluxcdToolkitSourceV1beta2OCIRepository>(
          name: item.metadata?.name ?? '',
          namespace: item.metadata?.namespace ?? '',
          resource: fluxResourceOCIRepository,
          item: item,
          details: [
            'Namespace: ${item.metadata?.namespace ?? '-'}',
            'Ready: ${item.status?.conditions != null && item.status!.conditions!.isNotEmpty ? item.status!.conditions!.where((e) => e.type == 'Ready').first.status : '-'}',
            'Status: ${item.status?.conditions != null && item.status!.conditions!.isNotEmpty ? item.status!.conditions!.where((e) => e.type == 'Ready').first.message : '-'}',
            'Age: ${getAge(item.metadata?.creationTimestamp)}',
          ],
        );
      },
    );
  }
}

class DetailsWidget extends StatelessWidget {
  const DetailsWidget({
    super.key,
    required this.name,
    required this.namespace,
  });

  final String name;
  final String namespace;

  @override
  Widget build(BuildContext context) {
    return PluginFluxDetails<IoFluxcdToolkitSourceV1beta2OCIRepository>(
      name: name,
      namespace: namespace,
      resource: fluxResourceOCIRepository,
      itemBuilder: (dynamic detailsItem) {
        final item = detailsItem as IoFluxcdToolkitSourceV1beta2OCIRepository;

        return Column(
          children: [
            DetailsItemMetadata(metadata: item.metadata),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItemConditions(conditions: item.status?.conditions),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: 'Configuration',
              details: [
                DetailsItemModel(
                  name: 'Url',
                  values: item.spec?.url,
                ),
                DetailsItemModel(
                  name: 'Provider',
                  values: item.spec?.interval,
                ),
                DetailsItemModel(
                  name: 'Interval',
                  values: item.spec?.interval,
                ),
                DetailsItemModel(
                  name: 'Suspended',
                  values: item.spec?.suspend == true ? 'True' : 'False',
                ),
                DetailsItemModel(
                  name: 'Timeout',
                  values: item.spec?.timeout,
                ),
              ],
            ),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: 'OCI Repository Reference',
              details: [
                DetailsItemModel(
                  name: 'Tag',
                  values: item.spec?.ref?.tag,
                ),
                DetailsItemModel(
                  name: 'SemVer',
                  values: item.spec?.ref?.semver,
                ),
                DetailsItemModel(
                  name: 'Digest',
                  values: item.spec?.ref?.digest,
                ),
              ],
            ),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsItem(
              title: 'Artifact',
              details: [
                DetailsItemModel(
                  name: 'Path',
                  values: item.status?.artifact?.path,
                ),
                DetailsItemModel(
                  name: 'Url',
                  values: item.status?.artifact?.url,
                ),
                DetailsItemModel(
                  name: 'Revision',
                  values: item.status?.artifact?.revision,
                ),
                DetailsItemModel(
                  name: 'Digest',
                  values: item.status?.artifact?.digest,
                ),
                DetailsItemModel(
                  name: 'Last Update',
                  values: getAge(item.status?.artifact?.lastUpdateTime),
                ),
                DetailsItemModel(
                  name: 'Size',
                  values: item.status?.artifact?.size != null
                      ? formatBytes(item.status!.artifact!.size!)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: Constants.spacingMiddle),
            DetailsResourcesPreview(
              resource: resourceEvent,
              namespace: item.metadata?.namespace,
              selector:
                  'fieldSelector=involvedObject.name=${item.metadata?.name ?? ''}',
              filter: null,
            ),
            const SizedBox(height: Constants.spacingMiddle),
          ],
        );
      },
    );
  }
}
