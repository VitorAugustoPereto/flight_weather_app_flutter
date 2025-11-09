import 'package:aeroporto_clima_app/controllers/aeroporto_busca_controller.dart';
import 'package:aeroporto_clima_app/controllers/aeroporto_clima_controller.dart';
import 'package:aeroporto_clima_app/models/aeroporto_clima_model.dart';
import 'package:aeroporto_clima_app/views/busca_aeroporto_page.dart';
import 'package:aeroporto_clima_app/services/cptec_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aeroporto_clima_controller_test.mocks.dart';

void main() {
  // CORREÇÃO: Usa o mesmo padrão de setup do outro teste, deixando o GetX criar os controllers
  Future<void> setupWidget(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();

    final mockService = MockCptecService();
    Get.put<CptecService>(mockService);
    Get.put(AeroportoClimaController(service: mockService));
    Get.put(AeroportoBuscaController(climaController: Get.find()));

    await tester.pumpWidget(
      GetMaterialApp(
        home: BuscaAeroportoPage(),
        getPages: [GetPage(name: '/detalhes', page: () => const Scaffold(body: Text('Página de Detalhes')))],
      ),
    );
  }

  testWidgets('BuscaAeroportoPage deve exibir componentes corretamente', (WidgetTester tester) async {
    await setupWidget(tester);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Digite o código ICAO (ex: SBSP)'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('Interação de busca deve navegar em sucesso', (WidgetTester tester) async {
    await setupWidget(tester);
    final mockService = Get.find<CptecService>() as MockCptecService;
    
    when(mockService.fetchClimaAeroporto(any)).thenAnswer((_) async => AeroportoClima(
      codigoIcao: 'SBSP', atualizadoEm: '', pressaoAtmosferica: 0, visibilidade: '', 
      vento: 0, direcaoVento: 0, umidade: 0, condicaoDesc: '', temp: 0, 
      nomeAeroporto: '', cidadeAeroporto: '', rawMetar: ''
    ));

    await tester.enterText(find.byType(TextField), 'SBSP');
    await tester.tap(find.byType(ElevatedButton));
    
    await tester.pumpAndSettle();

    // Verifica se a chamada no mock foi feita
    verify(mockService.fetchClimaAeroporto('SBSP')).called(1);
    // Verifica se a navegação ocorreu e a nova página está visível
    expect(find.text('Página de Detalhes'), findsOneWidget);
    expect(find.byType(BuscaAeroportoPage), findsNothing);
  });
}
