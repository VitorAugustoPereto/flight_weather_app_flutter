import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/aeroporto_busca_controller.dart';

// --- LISTA ESTÁTICA ---
// Mapa com os principais aeroportos do Brasil (ICAO: Nome)
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
// -----------------------

class BuscaAeroportoPage extends StatelessWidget {
  BuscaAeroportoPage({super.key});

  final AeroportoBuscaController controller = Get.find<AeroportoBuscaController>();
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
          // --- ÁREA DE BUSCA (TEXTFIELD) ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: controller.textController,
                  decoration: const InputDecoration(
                    labelText: 'Digite o código ICAO (ex: SBSP)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.flight),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => controller.buscarAeroporto(),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.isLoading.value) {
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
                    onPressed: controller.buscarAeroporto,
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
                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Text(
                        controller.errorMessage.value,
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
          
          // --- DIVISOR E TÍTULO DA LISTA ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("ou selecione", style: TextStyle(color: Colors.grey[600])),
              ),
              const Expanded(child: Divider()),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Principais Aeroportos do Brasil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
            ),
          ),

          // --- LISTA ESTÁTICA ---
          Expanded(
            child: ListView.builder(
              itemCount: aeroportosBrasil.length,
              itemBuilder: (context, index) {
                final icao = aeroportosBrasil.keys.elementAt(index);
                final nome = aeroportosBrasil.values.elementAt(index);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Icon(Icons.flight_takeoff, color: primaryColor),
                    title: Text(nome),
                    subtitle: Text(icao),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Ao clicar, define o texto e busca
                      controller.textController.text = icao;
                      controller.buscarAeroporto();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}