import 'package:aeroporto_clima_app/controllers/aeroporto_clima_controller.dart';
import 'package:aeroporto_clima_app/models/aeroporto_clima_model.dart';
import 'package:aeroporto_clima_app/services/cptec_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aeroporto_clima_controller_test.mocks.dart';

@GenerateMocks([CptecService])
void main() {
  late AeroportoClimaController controller;
  late MockCptecService mockService;

  final mockClimaSBSP = AeroportoClima(
      codigoIcao: 'SBSP',
      atualizadoEm: '2025-01-01T12:00:00Z',
      pressaoAtmosferica: 1010,
      visibilidade: '>10000',
      vento: 10,
      direcaoVento: 130,
      umidade: 80,
      condicaoDesc: 'Nublado',
      temp: 20,
      nomeAeroporto: 'Aeroporto de Congonhas',
      cidadeAeroporto: 'São Paulo',
      rawMetar: 'METAR SBSP 011200Z 13010KT 9999 SCT025 20/18 Q1010');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.testMode = true;
    
    mockService = MockCptecService();
    controller = AeroportoClimaController(service: mockService);
    
    Get.put<CptecService>(mockService);
    Get.put(controller);
  });

  test('fetchAndSaveClima deve buscar dados e salvar no cache', () async {
    when(mockService.fetchClimaAeroporto('SBSP')).thenAnswer((_) async => mockClimaSBSP);
    final sucesso = await controller.fetchAndSaveClima('SBSP');
    expect(sucesso, true);
    expect(controller.climaCache.value?.codigoIcao, 'SBSP');
  });

  test('fetchAndSaveClima deve retornar falso e erro em caso de falha', () async {
    when(mockService.fetchClimaAeroporto('XXXX')).thenThrow(Exception('Código ICAO não encontrado.'));
    final sucesso = await controller.fetchAndSaveClima('XXXX');
    expect(sucesso, false);
    expect(controller.errorMessage.value, 'Código ICAO não encontrado.');
  });

  test('fetchAndSaveClima deve salvar ICAO e histórico no SharedPreferences', () async {
    when(mockService.fetchClimaAeroporto('SBSP')).thenAnswer((_) async => mockClimaSBSP);
    await controller.fetchAndSaveClima('SBSP');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('last_saved_icao'), 'SBSP');
    expect(prefs.getStringList('search_history'), ['SBSP']);
  });

  test('_initializeApp deve carregar o último ICAO salvo e buscar o clima', () async {
    Get.reset(); // Reinicia para um ambiente limpo
    SharedPreferences.setMockInitialValues({'last_saved_icao': 'SBGR'});
    
    final localMockService = MockCptecService();
    final mockClimaSBGR = AeroportoClima(codigoIcao: 'SBGR', atualizadoEm: '', pressaoAtmosferica: 0, visibilidade: '', vento: 0, direcaoVento: 0, umidade: 0, condicaoDesc: '', temp: 0, nomeAeroporto: '', cidadeAeroporto: '', rawMetar: '');
    when(localMockService.fetchClimaAeroporto('SBGR')).thenAnswer((_) async => mockClimaSBGR);

    final newController = Get.put(AeroportoClimaController(service: localMockService));
    
    // CORREÇÃO: Aguarda o event loop para garantir que o onInit e suas chamadas async sejam processadas
    await Future.delayed(Duration.zero);

    verify(localMockService.fetchClimaAeroporto('SBGR')).called(1);
    expect(newController.climaCache.value, isNotNull);
    expect(newController.climaCache.value?.codigoIcao, 'SBGR');
  });
  
  test('fetchAndSaveClima deve adicionar ao histórico e respeitar o limite de 5', () async {
    when(mockService.fetchClimaAeroporto(any)).thenAnswer((_) async => mockClimaSBSP);
    await controller.fetchAndSaveClima('AAAA');
    await controller.fetchAndSaveClima('BBBB');
    await controller.fetchAndSaveClima('CCCC');
    await controller.fetchAndSaveClima('DDDD');
    await controller.fetchAndSaveClima('EEEE');
    await controller.fetchAndSaveClima('FFFF');
    
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('search_history');
    
    expect(history, isNotNull);
    expect(history!.length, 5);
    expect(history.first, 'FFFF');
    expect(history.last, 'BBBB');
  });

  test('clearSavedClima deve remover o ICAO do SharedPreferences', () async {
    when(mockService.fetchClimaAeroporto('SBSP')).thenAnswer((_) async => mockClimaSBSP);
    await controller.fetchAndSaveClima('SBSP');
    
    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('last_saved_icao'), 'SBSP');

    await controller.clearSavedClima();

    prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('last_saved_icao'), isNull);
    expect(controller.climaCache.value, isNull);
  });
}
