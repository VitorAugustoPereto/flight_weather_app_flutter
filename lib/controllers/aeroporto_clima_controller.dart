import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/aeroporto_clima_model.dart';
import '../services/cptec_service.dart';
import '../shared/app_routes.dart'; // Importar as rotas

class AeroportoClimaController extends GetxController {
  final CptecService service;
  AeroportoClimaController({required this.service});

  var isLoading = true.obs; // Iniciar como true
  var errorMessage = ''.obs;
  var climaCache = Rxn<AeroportoClima>();

  static const String _lastIcaoKey = 'last_saved_icao';
  static const String _historyKey = 'search_history';
  var searchHistory = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await loadSearchHistory();
    await loadSavedClima();
    isLoading.value = false; // Finaliza o loading inicial
  }

  Future<void> _addToHistory(String icaoCode) async {
    searchHistory.remove(icaoCode);
    searchHistory.insert(0, icaoCode);
    if (searchHistory.length > 5) {
      searchHistory.removeRange(5, searchHistory.length);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, searchHistory.toList());
  }

  Future<void> loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey);
    if (history != null) {
      searchHistory.assignAll(history);
    }
  }

  Future<bool> fetchAndSaveClima(String icaoCode) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final upperIcao = icaoCode.toUpperCase();
      final clima = await service.fetchClimaAeroporto(upperIcao);
      climaCache.value = clima; // Atualiza o cache

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastIcaoKey, upperIcao);
      await _addToHistory(upperIcao);
      
      return true;

    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSavedClima() async {
    final prefs = await SharedPreferences.getInstance();
    final icaoCode = prefs.getString(_lastIcaoKey);
    if (icaoCode != null) {
      await fetchAndSaveClima(icaoCode);
    }
  }

  Future<void> clearSavedClima() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastIcaoKey);
    climaCache.value = null; // Limpa o cache
    Get.offAllNamed(AppRoutes.home);
  }
}
