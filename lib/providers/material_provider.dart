import 'package:flutter/foundation.dart';
import '../api/material_api.dart';

class MaterialProvider with ChangeNotifier {
  final MaterialApi _materialApi;

  bool _isLoading = false;
  String? _error;
  List<dynamic> _materials = [];
  Map<String, dynamic>? _materialDetail;

  MaterialProvider(this._materialApi);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get materials => _materials;
  Map<String, dynamic>? get materialDetail => _materialDetail;

  Future<void> fetchMaterials() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _materials = await _materialApi.getMaterials();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchMaterialDetail(int materialId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _materialDetail =
          await _materialApi.getMaterialDetail(materialId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

