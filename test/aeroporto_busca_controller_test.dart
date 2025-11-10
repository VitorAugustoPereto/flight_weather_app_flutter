import 'package:aeroporto_clima_app/controllers/aeroporto_busca_controller.dart';
import 'package:aeroporto_clima_app/controllers/aeroporto_clima_controller.dart';
import 'package:aeroporto_clima_app/models/aeroporto_clima_model.dart';
import 'package:aeroporto_clima_app/services/cptec_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aeroporto_clima_controller_test.mocks.dart';

void main() {
  // CORREÇÃO: Remove a inicialização manual das variáveis do controller

  Future<void> setupControllers(WidgetTester tester) async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});

    // Usa Get.put para que o próprio GetX instancie e gerencie o ciclo de vida
    final mockService = MockCptecService();
    Get.put<CptecService>(mockService);
    Get.put(AeroportoClimaController(service: mockService));
    Get.put(AeroportoBuscaController(climaController: Get.find()));

    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(),
        getPages: [
          GetPage(name: '/detalhes', page: () => const Text('Página de Detalhes')),
        ],
      ),
    );
  }

  testWidgets('buscarAeroporto deve navegar em sucesso quando o serviço retorna dados', (tester) async {
    await setupControllers(tester);
    final buscaController = Get.find<AeroportoBuscaController>();
    final mockService = Get.find<CptecService>() as MockCptecService;

    when(mockService.fetchClimaAeroporto(any)).thenAnswer((_) async => AeroportoClima(
        codigoIcao: 'SBSP', atualizadoEm: '', pressaoAtmosferica: 0, visibilidade: '', 
        vento: 0, direcaoVento: 0, umidade: 0, condicaoDesc: '', temp: 0, 
        nomeAeroporto: '', cidadeAeroporto: '', rawMetar: ''
    ));
    buscaController.textController.text = 'SBSP';

    await buscaController.buscarAeroporto();
    await tester.pumpAndSettle();

    verify(mockService.fetchClimaAeroporto('SBSP')).called(1);
    expect(buscaController.errorMessage.value, isEmpty);
    expect(find.text('Página de Detalhes'), findsOneWidget);
  });

  testWidgets('buscarAeroporto deve exibir erro quando o serviço lança uma exceção', (tester) async {
    await setupControllers(tester);
    final buscaController = Get.find<AeroportoBuscaController>();
    final mockService = Get.find<CptecService>() as MockCptecService;
    
    when(mockService.fetchClimaAeroporto(any)).thenThrow(Exception('Aeroporto não encontrado'));
    buscaController.textController.text = 'XXXX';

    await buscaController.buscarAeroporto();
    await tester.pump();

    verify(mockService.fetchClimaAeroporto('XXXX')).called(1);
    expect(buscaController.errorMessage.value, 'Aeroporto não encontrado');
    expect(Get.currentRoute, isNot('/detalhes'));
  });

  testWidgets('buscarAeroporto deve exibir erro se o campo de texto estiver vazio', (tester) async {
    await setupControllers(tester);
    final buscaController = Get.find<AeroportoBuscaController>();
    final mockService = Get.find<CptecService>() as MockCptecService;

    buscaController.textController.text = '';

    await buscaController.buscarAeroporto();
    await tester.pump();

    verifyNever(mockService.fetchClimaAeroporto(any));
    expect(buscaController.errorMessage.value, 'Digite um código ICAO (ex: SBSP).');
  });
}
