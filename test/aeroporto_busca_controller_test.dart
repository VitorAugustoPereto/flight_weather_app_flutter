import 'package:aeroporto_clima_app/controllers/aeroporto_busca_controller.dart';
import 'package:aeroporto_clima_app/controllers/aeroporto_clima_controller.dart';
import 'package:aeroporto_clima_app/services/cptec_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aeroporto_busca_controller_test.mocks.dart';

@GenerateMocks([CptecService, AeroportoClimaController])
void main() {
  late AeroportoBuscaController buscaController;
  late MockAeroportoClimaController mockClimaController;
  // O mockService é necessário para o mockClimaController
  late MockCptecService mockService; 

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    
    mockService = MockCptecService();
    mockClimaController = MockAeroportoClimaController();

    // --- CORREÇÃO: Injetando o mock no construtor ---
    buscaController = AeroportoBuscaController(climaController: mockClimaController);
    // ------------------------------------------------

    // Registra os mocks e o controller
    Get.put<AeroportoClimaController>(mockClimaController);
    Get.put(buscaController);
  });

  test('buscarAeroporto deve chamar fetchAndSaveClima e navegar em sucesso', () async {
    // Arrange
    buscaController.textController.text = 'SBSP';
    when(mockClimaController.fetchAndSaveClima('SBSP')).thenAnswer((_) async => true);
    
    // Act
    await buscaController.buscarAeroporto();
    
    // Assert
    verify(mockClimaController.fetchAndSaveClima('SBSP')).called(1);
    expect(buscaController.isLoading.value, false);
    expect(buscaController.errorMessage.value, '');
  });
  
  test('buscarAeroporto deve definir erro se o código estiver vazio', () async {
    // Arrange
    buscaController.textController.text = '';
    
    // Act
    await buscaController.buscarAeroporto();
    
    // Assert
    expect(buscaController.errorMessage.value, 'Digite um código ICAO (ex: SBSP).');
    verifyNever(mockClimaController.fetchAndSaveClima(any));
  });
}