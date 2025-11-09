import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/aeroporto_clima_controller.dart';
import 'busca_aeroporto_page.dart';
import 'detalhe_aeroporto_page.dart';

class HomePage extends GetView<AeroportoClimaController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Caso 1: Se o app está carregando os dados iniciais (do disco)
      // e ainda não tem um clima em cache, mostra a tela de loading.
      if (controller.isLoading.value && controller.climaCache.value == null) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      // Caso 2: Se já existe um clima em cache (seja do loading inicial ou de uma busca),
      // mostra a tela de detalhes.
      if (controller.climaCache.value != null) {
        return DetalheAeroportoPage();
      }
      // Caso 3: Se não está carregando e não tem nada em cache, 
      // mostra a tela de busca.
      return BuscaAeroportoPage();
    });
  }
}
