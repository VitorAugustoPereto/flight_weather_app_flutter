import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/aeroporto_busca_controller.dart';
import '../controllers/aeroporto_clima_controller.dart';

const Map<String, String> aeroportosBrasil = {
  'SBSP': 'Congonhas (São Paulo)',
  'SBGR': 'Guarulhos (São Paulo)',
  'SBRJ': 'Santos Dumont (Rio de Janeiro)',
  'SBGL': 'Galeão (Rio de Janeiro)',
  'SBBR': 'Brasília',
  'SBCF': 'Confins (Belo Horizonte)',
  'SBSV': 'Salvador',
  'SBRF': 'Recife',
  'SBPA': 'Salgado Filho (Porto Alegre)',
  'SBCT': 'Afonso Pena (Curitiba)',
  'SBFZ': 'Pinto Martins (Fortaleza)',
  'SBKP': 'Viracopos (Campinas)',
  'SBBE': 'Val-de-Cans (Belém)',
  'SBEG': 'Eduardo Gomes (Manaus)',
};

class BuscaAeroportoPage extends StatelessWidget {
  BuscaAeroportoPage({super.key});

  final AeroportoBuscaController buscaController = Get.find<AeroportoBuscaController>();
  final AeroportoClimaController climaController = Get.find<AeroportoClimaController>();
  final Color primaryColor = Colors.teal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Aeroporto (CPTEC)'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ÁREA DE BUSCA
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: buscaController.textController,
                  decoration: const InputDecoration(
                    labelText: 'Digite o código ICAO (ex: SBSP)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.flight),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => buscaController.buscarAeroporto(),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (buscaController.isLoading.value) {
                    return ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.grey,
                      ),
                      child: const CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  return ElevatedButton(
                    onPressed: buscaController.buscarAeroporto,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Buscar', style: TextStyle(fontSize: 16)),
                  );
                }),
                const SizedBox(height: 12),
                Obx(() {
                  if (buscaController.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Text(
                        buscaController.errorMessage.value,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return Container();
                }),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              children: [
                // SEÇÃO DE HISTÓRICO
                Obx(() {
                  if (climaController.searchHistory.isEmpty) {
                    return const SizedBox.shrink(); // Não renderiza nada se não houver histórico
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text('Histórico Recente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                      ),
                      ...climaController.searchHistory.map((icao) {
                        final nome = aeroportosBrasil[icao] ?? 'Aeroporto Desconhecido';
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.history, color: Colors.grey),
                            title: Text(icao), 
                            subtitle: Text(nome),
                            onTap: () {
                              buscaController.textController.text = icao;
                              buscaController.buscarAeroporto();
                            },
                          ),
                        );
                      }).toList(),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Divider(),
                      ),
                    ],
                  );
                }),

                // SEÇÃO DE AEROPORTOS PRINCIPAIS
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    'Principais Aeroportos do Brasil',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                    textAlign: TextAlign.center,
                  ),
                ),
                ...aeroportosBrasil.entries.map((entry) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: Icon(Icons.flight_takeoff, color: primaryColor),
                      title: Text(entry.value),
                      subtitle: Text(entry.key),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        buscaController.textController.text = entry.key;
                        buscaController.buscarAeroporto();
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
