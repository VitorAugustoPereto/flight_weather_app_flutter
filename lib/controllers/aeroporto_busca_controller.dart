import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'aeroporto_clima_controller.dart';

class AeroportoBuscaController extends GetxController {
  
 
  // Declara a dependência
  final AeroportoClimaController climaController;
  
  // Recebe a dependência no construtor
  AeroportoBuscaController({required this.climaController});


  final TextEditingController textController = TextEditingController();
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Chamado pelo botão "Buscar"
  Future<void> buscarAeroporto() async {
    final icaoCode = textController.text;
    if (icaoCode.isEmpty) {
      errorMessage.value = 'Digite um código ICAO (ex: SBSP).';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final bool sucesso = await climaController.fetchAndSaveClima(icaoCode);

      if (sucesso) {
        Get.offAllNamed('/detalhes');
      } else {
        errorMessage.value = climaController.errorMessage.value;
      }
    } catch (e) {
      errorMessage.value = "Erro inesperado: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}