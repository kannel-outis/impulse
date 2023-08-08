import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenericProviderRef<T> {
  final T _ref;

  const GenericProviderRef(this._ref);
  K read<K>(ProviderListenable<K> provider) {
    if (_ref is Ref) {
      final ref = _ref as Ref;
      return ref.read<K>(provider);
    } else {
      final ref = _ref as WidgetRef;
      return ref.read<K>(provider);
    }
  }
}
