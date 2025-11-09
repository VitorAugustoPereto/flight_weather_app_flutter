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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    
    mockService = MockCptecService();
    controller = AeroportoClimaController(service: mockService);
    
    Get.put(controller);
    Get.put<CptecService>(mockService);
  });

  // Mock com dados válidos
  final mockClima = AeroportoClima(
      codigoIcao: 'SBSP',
      atualizadoEm: '2025-01-01T12:00:00Z',
      pressaoAtmosferica: 1010,
      visibilidade: '>10000',
      vento: 10,
      direcaoVento: 'SE',
      umidade: 80,
      condicao: 'nb',
      condicaoDesc: 'Nublado',
      temp: 20);

  test('fetchAndSaveClima deve buscar dados e salvar no cache', () async {
    // Arrange
    when(mockService.fetchClimaAeroporto('SBSP')).thenAnswer((_) async => mockClima);

    // Act
    final sucesso = await controller.fetchAndSaveClima('SBSP');

    // Assert
    expect(sucesso, true);
    expect(controller.isLoading.value, false);
    expect(controller.climaCache.value, isNotNull);
    expect(controller.climaCache.value?.codigoIcao, 'SBSP');
  });

  test('fetchAndSaveClima deve retornar falso e erro em caso de falha', () async {
    // Arrange
    when(mockService.fetchClimaAeroporto('XXXX')).thenThrow(Exception('Código ICAO não encontrado.'));
    
    // Act
    final sucesso = await controller.fetchAndSaveClima('XXXX');
    
    // Assert
    expect(sucesso, false);
    expect(controller.isLoading.value, false);
    expect(controller.climaCache.value, isNull);
    expect(controller.errorMessage.value, 'Código ICAO não encontrado.');
  });
}