import 'package:aeroporto_clima_app/controllers/aeroporto_busca_controller.dart';
import 'package:aeroporto_clima_app/controllers/aeroporto_clima_controller.dart';
import 'package:aeroporto_clima_app/services/cptec_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aeroporto_busca_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CptecService>(),
  MockSpec<AeroportoClimaController>(),
])
void main() {
  late AeroportoBuscaController buscaController;
  late MockAeroportoClimaController mockClimaController;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset(); // Resets GetX bindings between tests

    // --- CORREÇÃO: Habilitar o modo de teste DEPOIS do reset ---
    Get.testMode = true;
    // ----------------------------------------------------------

    mockClimaController = MockAeroportoClimaController();
    buscaController = AeroportoBuscaController(climaController: mockClimaController);
    Get.put(buscaController);
  });

  test('buscarAeroporto deve chamar fetchAndSaveClima em sucesso', () async {
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
