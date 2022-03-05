import 'package:kubenav/models/kubernetes/api.dart'
    show IoK8sApimachineryPkgApisMetaV1LabelSelector, IoK8sApiRbacV1PolicyRule;

/// [getAge] returns the age of a Kubernetes resources in a human readable format. This is mostly used to dertermine the
/// age of a resource via the `metadata.creationTimestamp` field. If the given [timestamp] is `null` we return a dash as
/// placceholder for the age.
String getAge(DateTime? timestamp) {
  if (timestamp == null) {
    return '-';
  }

  return timeDiff(timestamp, DateTime.now());
}

String timeDiff(DateTime? start, DateTime? end) {
  if (start == null || end == null) {
    return '-';
  }

  final age = end.difference(start);

  if (age.inDays > 3) {
    return '${age.inDays}d';
  }

  if (age.inHours > 3) {
    return '${age.inHours}h';
  }

  if (age.inMinutes > 3) {
    return '${age.inMinutes}m';
  }

  return '${age.inSeconds}s';
}

/// [getSelector] returns a selector string which can be used in a Kubernetes API request to the the all resources,
/// which are matching the given selector. For example this can be used to get all Pods for a Deployment by using the
/// `deployment.spec.selector` field.
///
/// TODO: Currently we only have implemented this function for the `matchLabels` field in the selector. in the future we
/// should also implement it for `matchExpressions`.
String getSelector(IoK8sApimachineryPkgApisMetaV1LabelSelector? selector) {
  if (selector == null) {
    return '';
  }

  if (selector.matchLabels.isNotEmpty) {
    return getMatchLabelsSelector(selector.matchLabels);
  }

  return '';
}

/// [getMatchLabelsSelector] builds the selector the [matchLabels] values of a selector. The [matchLabels] argument must
/// be of type `Map<String, String>`.
String getMatchLabelsSelector(Map<String, String> matchLabels) {
  if (matchLabels.isEmpty) {
    return '';
  }

  List<String> labelSelectors = [];
  matchLabels.forEach((key, value) => labelSelectors.add('$key=$value'));

  return 'labelSelector=${Uri.encodeComponent(labelSelectors.join(','))}';
}

/// [formatTime] formats the given `DateTime` parameter. The returned `String` is the in the form `YYYY-MM-DD HH:mm:SS`.
String formatTime(DateTime? timestamp) {
  if (timestamp == null) {
    return '-';
  }

  return '${timestamp.year.toString()}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
}

/// [Rule] is our internal format of a rule in a ClusterRole or Role. It contains the [resource] name and a list of all
/// [nonResourceURLs], [resourceNames] and [verbs]. The [resource] consists of the `resource` name and `apiGroup`.
class Rule {
  String resource;
  List<String> nonResourceURLs;
  List<String> resourceNames;
  List<String> verbs;

  Rule({
    required this.resource,
    required this.nonResourceURLs,
    required this.resourceNames,
    required this.verbs,
  });
}

/// [formatRules] returns a `List` of rules in our internal [Rule] format from the given [rules] list from a ClusterRole
/// or Role.
List<Rule> formatRules(List<IoK8sApiRbacV1PolicyRule> rules) {
  final List<Rule> formattedRules = [];

  for (var rule in rules) {
    for (var apiGroup in rule.apiGroups) {
      for (var resource in rule.resources) {
        formattedRules.add(
          Rule(
            resource: '$resource${apiGroup != '' ? '.$apiGroup' : ''}',
            nonResourceURLs: rule.nonResourceURLs,
            resourceNames: rule.resourceNames,
            verbs: rule.verbs,
          ),
        );
      }
    }
  }

  return formattedRules;
}

/// [cpuMetricsStringToInt] converts the given [metric] `String` into an `int` value. The `int` value uses the smallest
/// unit for CPU `n`.
int cpuMetricsStringToInt(String metric) {
  if (metric == '') {
    return 0;
  }

  if (metric.endsWith('n')) {
    return int.parse(metric.substring(0, metric.length - 1));
  }

  if (metric.endsWith('m')) {
    return int.parse(metric.substring(0, metric.length - 1)) * 1000 * 1000;
  }

  return int.parse(metric) * 1000 * 1000 * 1000;
}

/// [memoryMetricsStringToInt] converts the given [metric] `String` into an `int` value. The `int` value uses the
/// smalles unit for Memory `Ki`.
int memoryMetricsStringToInt(String metric) {
  if (metric == '') {
    return 0;
  }

  if (metric.endsWith('Ki') || metric.endsWith('ki')) {
    return int.parse(metric.substring(0, metric.length - 2));
  }

  if (metric.endsWith('Mi') || metric.endsWith('mi')) {
    return int.parse(metric.substring(0, metric.length - 2)) * 1024;
  }

  if (metric.endsWith('Gi') || metric.endsWith('gi')) {
    return int.parse(metric.substring(0, metric.length - 2)) * 1024 * 1024;
  }

  return 0;
}

/// [formatCpuMetric] format a CPU metric value as it is returned by the [cpuMetricsStringToInt] function.
String formatCpuMetric(int size, [int round = 2]) {
  int divider = 1000;

  if (size < divider) {
    return '${size}n';
  }

  if (size < divider * divider * divider && size % divider == 0) {
    return '${(size / (divider * divider)).toStringAsFixed(0)}m';
  }

  if (size < divider * divider * divider) {
    return '${(size / divider / divider).toStringAsFixed(round)}m';
  }

  if (size < divider * divider * divider * divider && size % divider == 0) {
    return (size / (divider * divider * divider)).toStringAsFixed(0);
  }

  return (size / divider / divider / divider).toStringAsFixed(round);
}

/// [formatMemoryMetric] format a Memory metric value as it is returned by the [memoryMetricsStringToInt] function.
String formatMemoryMetric(int size, [int round = 2]) {
  int divider = 1024;

  if (size < divider) {
    return '${size}Ki';
  }

  if (size < divider * divider && size % divider == 0) {
    return '${(size / divider).toStringAsFixed(0)}Mi';
  }

  if (size < divider * divider) {
    return '${(size / divider).toStringAsFixed(round)}Mi';
  }

  if (size < divider * divider * divider && size % divider == 0) {
    return '${(size / (divider * divider)).toStringAsFixed(0)}Gi';
  }

  return '${(size / divider / divider).toStringAsFixed(round)}Gi';
}
