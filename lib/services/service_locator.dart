import 'package:jogodavelha/services/navigation_service.dart';

final getIt = Locator();

setupServiceLocator() {
  _registerSingleton<NavigationService>(instance: NavigationService());
}

void _registerSingleton<T extends Object>({required T instance}) {
  getIt.registerSingleton<T>(instance);
}

// void _registerLazySingleton<T extends Object>({required T instance}) {
//   getIt.registerSingleton<T>(instance);
// }

class Locator {
  final Map<String, dynamic> _instances = {};

  final Map<String, Function> _factories = {};

  final Map<String, Map<String, dynamic>> _scopes = {};

  String _getKey<T>({String? instanceName}) {
    return '$T${instanceName ?? ''}';
  }

  T call<T>({String? instanceName, String? scope}) {
    return get<T>(instanceName: instanceName, scope: scope);
  }

  T get<T>({String? instanceName, String? scope}) {
    final key = _getKey<T>(instanceName: instanceName);

    if (scope != null && scope.isNotEmpty) {
      if (_scopes.containsKey(scope)) {
        if (_scopes[scope]!.containsKey(key)) {
          return _scopes[scope]![key];
        }
      }
    }

    if (_instances.containsKey(key)) {
      return _instances[key];
    }

    if (_factories.containsKey(key)) {
      final instance = _factories[key]!();
      _factories.remove(key);
      _instances[key] = instance;
      return instance;
    }

    throw Exception('Tipo $T não está registrado');
  }

  void registerSingleton<T>(T instance, {String? instanceName, String? scope}) {
    final key = _getKey<T>(instanceName: instanceName);

    if (scope != null && scope.isNotEmpty) {
      if (!_scopes.containsKey(scope)) {
        _scopes[scope] = {};
      }

      _scopes[scope]!.addAll({key: instance});
      return;
    }

    if (isRegistered<T>(instanceName: instanceName)) {
      throw Exception('Tipo $T já está registrado');
    }

    _instances[key] = instance;
  }

  void registerLazySingleton<T>(T Function() factory, {String? instanceName}) {
    final key = _getKey<T>(instanceName: instanceName);

    _factories[key] = factory;
  }

  void unregister<T>({String? instanceName, String? scope}) {
    final key = _getKey<T>(instanceName: instanceName);

    if (scope != null && scope.isNotEmpty) {
      _scopes[scope]?.remove(key);
      return;
    }

    _instances.remove(key);
  }

  void unregisterAllScope(String scope) {
    if (_scopes.containsKey(scope)) {
      _scopes[scope] = {};
    }
  }

  bool isRegistered<T>({String? instanceName, String? scope}) {
    final key = _getKey<T>(instanceName: instanceName);

    if (scope != null && scope.isNotEmpty) {
      return _scopes[scope]?.containsKey(key) ?? false;
    }

    return _instances.containsKey(key);
  }
}
