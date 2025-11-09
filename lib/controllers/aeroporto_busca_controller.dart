import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'aeroporto_clima_controller.dart';

class AeroportoBuscaController extends GetxController {
  
  // --- INÍCIO DA CORREÇÃO ---
  // 1. Declaramos a dependência
  final AeroportoClimaController climaController;
  
  // 2. Recebemos a dependência no construtor
  AeroportoBuscaController({required this.climaController});
  // --- FIM DA CORREÇÃO ---

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

    // --- INÍCIO DA CORREÇÃO ---
    // 3. Adicionamos um try/catch para segurança
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 4. NÃO usamos Get.find() - usamos a variável injetada
      final bool sucesso = await climaController.fetchAndSaveClima(icaoCode);

      if (sucesso) {
        Get.offAllNamed('/detalhes');
      } else {
        errorMessage.value = climaController.errorMessage.value;
      }
    } catch (e) {
      errorMessage.value = "Erro inesperado: ${e.toString()}";
    } finally {
      // 5. Garante que o loading sempre termine
      isLoading.value = false;
    }
    // --- FIM DA CORREÇÃO ---
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}