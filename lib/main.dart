import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'controllers/aeroporto_busca_controller.dart';
import 'controllers/aeroporto_clima_controller.dart';
import 'services/cptec_service.dart';
import 'shared/app_routes.dart';

// A classe de Bindings permanece a mesma
class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CptecService>(() => CptecService(), fenix: true);
    
    Get.lazyPut<AeroportoClimaController>(() => AeroportoClimaController(
      service: Get.find(),
    ), fenix: true);

    Get.lazyPut<AeroportoBuscaController>(() => AeroportoBuscaController(
      climaController: Get.find(),
    ), fenix: true);
  }
}

// O main.dart fica muito mais simples
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  
  // A lógica de qual rota iniciar foi movida para a HomePage
  runApp(const MyApp(initialRoute: '',));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required String initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Clima Aeroportos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // 1. Inicia os bindings
      initialBinding: AppBindings(),
      // 2. Aponta para a rota inicial que é a HomePage
      initialRoute: AppRoutes.home,
      // 3. Usa as rotas que definimos
      getPages: AppRoutes.routes,
    );
  }
}
