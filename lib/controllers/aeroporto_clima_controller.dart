import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/aeroporto_clima_model.dart';
import '../services/cptec_service.dart';

class AeroportoClimaController extends GetxController {
  final CptecService service;
  AeroportoClimaController({required this.service});

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Cache do clima carregado (Rxn permite que seja nulo)
  var climaCache = Rxn<AeroportoClima>();

  // Chave da persistência
  static const String _icaoKey = 'saved_icao_code';

  @override
  void onInit() {
    super.onInit();
    // Ao iniciar o app, tenta carregar o clima do ICAO salvo
    loadSavedClima();
  }

  // 1. Busca da API e salva na persistência
  Future<bool> fetchAndSaveClima(String icaoCode) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final clima = await service.fetchClimaAeroporto(icaoCode.toUpperCase());
      climaCache.value = clima; // Salva em cache no GetX

      // Salva na persistência
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_icaoKey, icaoCode.toUpperCase());
      return true; // Sucesso
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false; // Falha
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Carrega da persistência
  Future<void> loadSavedClima() async {
    final prefs = await SharedPreferences.getInstance();
    final icaoCode = prefs.getString(_icaoKey);

    if (icaoCode != null) {
      // Se encontrou um código, busca a previsão para ele
      await fetchAndSaveClima(icaoCode);
    }
  }

  // 3. Limpa o salvo e volta para a busca
  Future<void> clearSavedClima() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_icaoKey);
    climaCache.value = null; // Limpa o cache
    Get.offAllNamed('/busca'); // Envia o usuário de volta para a tela de busca
  }
}