import 'package:get/get.dart';
import '../views/busca_aeroporto_page.dart';
import '../views/detalhe_aeroporto_page.dart';
import '../views/home_page.dart';

class AppRoutes {
  // rotas como constantes estáticas
  static const String home = '/';
  static const String busca = '/busca';
  static const String detalhes = '/detalhes';

  static final routes = [
    // rota raiz aponta para a HomePage
    GetPage(
      name: home,
      page: () => const HomePage(),
    ),
    GetPage(
      name: busca,
      page: () => BuscaAeroportoPage(),
    ),
    GetPage(
      name: detalhes,
      page: () => DetalheAeroportoPage(),
    ),
  ];
}
