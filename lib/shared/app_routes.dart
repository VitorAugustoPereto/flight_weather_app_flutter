import 'package:get/get.dart';
import '../views/busca_aeroporto_page.dart';
import '../views/detalhe_aeroporto_page.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: '/busca',
      page: () => BuscaAeroportoPage(),
    ),
    GetPage(
      name: '/detalhes',
      page: () => DetalheAeroportoPage(),
    ),
  ];
}