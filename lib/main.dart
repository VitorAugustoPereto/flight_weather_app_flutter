import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'controllers/aeroporto_busca_controller.dart';
import 'controllers/aeroporto_clima_controller.dart';
import 'services/cptec_service.dart';
import 'shared/app_routes.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  
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
      // Inicia os bindings
      initialBinding: AppBindings(),
      // Aponta para a rota inicial que é a HomePage
      initialRoute: AppRoutes.home,
      getPages: AppRoutes.routes,
    );
  }
}
