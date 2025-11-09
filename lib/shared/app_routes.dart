import 'package:get/get.dart';
import '../views/busca_aeroporto_page.dart';
import '../views/detalhe_aeroporto_page.dart';
import '../views/home_page.dart'; // 1. Importar a nova HomePage

class AppRoutes {
  // 2. Definir as rotas como constantes estáticas
  static const String home = '/';
  static const String busca = '/busca';
  static const String detalhes = '/detalhes';

  static final routes = [
    // 3. A rota raiz agora aponta para a HomePage
    GetPage(
      name: home,
      page: () => const HomePage(),
    ),
    // Mantemos as rotas nomeadas para possíveis navegações futuras,
    // mas a lógica principal de exibição está na HomePage.
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
