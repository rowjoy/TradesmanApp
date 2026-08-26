import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

abstract interface class IdGenerator {
  String next();
}

final class UuidIdGenerator implements IdGenerator {
  const UuidIdGenerator(this._uuid);

  final Uuid _uuid;

  @override
  String next() => _uuid.v4();
}

final idGeneratorProvider = Provider<IdGenerator>(
  (ref) => const UuidIdGenerator(Uuid()),
);
