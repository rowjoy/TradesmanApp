/// A period-separated, non-negative numeric application version.
///
/// Store marketing versions are compared component-by-component instead of as
/// text, so `1.10` is newer than `1.9` and `1.2` equals `1.2.0`. Malformed
/// versions fail closed through [tryParse] rather than creating a false update
/// prompt.
class NumericAppVersion implements Comparable<NumericAppVersion> {
  NumericAppVersion._(this._components);

  final List<BigInt> _components;

  static NumericAppVersion? tryParse(String source) {
    final value = source.trim();
    if (value.isEmpty || !RegExp(r'^\d+(?:\.\d+)*$').hasMatch(value)) {
      return null;
    }

    final components = value.split('.').map(BigInt.parse).toList();
    while (components.length > 1 && components.last == BigInt.zero) {
      components.removeLast();
    }
    return NumericAppVersion._(List.unmodifiable(components));
  }

  static NumericAppVersion parse(String source) {
    final parsed = tryParse(source);
    if (parsed == null) {
      throw FormatException('Invalid numeric application version', source);
    }
    return parsed;
  }

  @override
  int compareTo(NumericAppVersion other) {
    final length = _components.length > other._components.length
        ? _components.length
        : other._components.length;
    for (var index = 0; index < length; index++) {
      final left = index < _components.length
          ? _components[index]
          : BigInt.zero;
      final right = index < other._components.length
          ? other._components[index]
          : BigInt.zero;
      final comparison = left.compareTo(right);
      if (comparison != 0) return comparison;
    }
    return 0;
  }

  @override
  bool operator ==(Object other) =>
      other is NumericAppVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hashAll(_components);

  @override
  String toString() => _components.join('.');
}

/// Returns `null` when either input is not a numeric store version.
int? compareNumericAppVersions(String left, String right) {
  final leftVersion = NumericAppVersion.tryParse(left);
  final rightVersion = NumericAppVersion.tryParse(right);
  if (leftVersion == null || rightVersion == null) return null;
  return leftVersion.compareTo(rightVersion);
}

bool isAvailableVersionNewer({
  required String installedVersion,
  required String availableVersion,
}) {
  final comparison = compareNumericAppVersions(
    availableVersion,
    installedVersion,
  );
  return comparison != null && comparison > 0;
}
