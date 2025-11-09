import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/aeroporto_busca_controller.dart';
import 'controllers/aeroporto_clima_controller.dart';
import 'services/cptec_service.dart';
import 'shared/app_routes.dart';

// 1. Criamos a classe de Bindings
class AppBindings extends Bindings {
  @override
  void dependencies() {
    
    // --- CORREÇÃO: 'fenix: true' AQUI TAMBÉM ---
    Get.lazyPut<CptecService>(() => CptecService(), fenix: true); 
    // -------------------------------------------
    
    Get.lazyPut<AeroportoClimaController>(() => AeroportoClimaController(
      service: Get.find(),
    ), fenix: true); 

    Get.lazyPut<AeroportoBuscaController>(() => AeroportoBuscaController(
      climaController: Get.find() 
    ), fenix: true); 
  }
}

// ... (O resto do arquivo 'main.dart' permanece igual) ...
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  final prefs = await SharedPreferences.getInstance();
  final icaoCode = prefs.getString('saved_icao_code');
  final String initialRoute = (icaoCode != null) ? '/detalhes' : '/busca';
  
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Clima Aeroportos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialBinding: AppBindings(),
      initialRoute: initialRoute,
      getPages: AppRoutes.routes,
    );
  }
}