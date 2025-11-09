import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/aeroporto_clima_controller.dart';
import '../models/aeroporto_clima_model.dart';

class DetalheAeroportoPage extends StatelessWidget {
  DetalheAeroportoPage({super.key});

  final AeroportoClimaController controller = Get.find<AeroportoClimaController>();
  final Color primaryColor = Colors.teal;

  String _formatarData(String dataIso) {
    if (dataIso == '-') return '-'; 
    try {
      // --- CORREÇÃO DO HORÁRIO (MANUAL) ---
      // 1. Faz o parse da data (que vem como UTC/Zulu "Z")
      final data = DateTime.parse(dataIso); 
      // 2. Converte manualmente para BRT (-3), como você pediu
      final dataBrasilia = data.subtract(const Duration(hours: 3)); 
      // 3. Formata a data
      return '${DateFormat('dd/MM/yyyy \'às\' HH:mm', 'pt_BR').format(dataBrasilia)} (BRT)';
      // -----------------------------------
    } catch (e) {
      return 'Data indisponível'; 
    }
  }

  String _formatarVisibilidade(String metros) {
    if (metros == 'Indisponível') return metros;
    if (metros == '10 km ou mais') return metros; // Já está formatado
    try {
      final metrosInt = int.tryParse(metros.replaceAll('>', '')) ?? 0;
      if (metrosInt >= 10000) return '10 km ou mais';
      return '$metros m';
    } catch (e) {
      return metros;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.climaCache.value?.codigoIcao ?? 'Carregando...')),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final AeroportoClima? capital = controller.climaCache.value;

        if (controller.isLoading.value && capital == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.errorMessage.value.isNotEmpty && capital == null) {
           return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (capital != null) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // --- INFORMAÇÕES DE NOME E LOCAL ---
                Text(
                  capital.nomeAeroporto,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  capital.cidadeAeroporto,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // --- CARD DE TEMPERATURA ---
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          capital.condicaoDesc,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${capital.temp}°C',
                          style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          // Agora mostrará o horário de Brasília
                          'Observado em: ${_formatarData(capital.atualizadoEm)}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- LISTA DE DETALHES ---
                _buildDetalheItem(
                  icone: Icons.arrow_downward,
                  titulo: 'Pressão Atmosférica',
                  // Agora mostrará o valor correto
                  valor: '${capital.pressaoAtmosferica} hPa', 
                ),
                _buildDetalheItem(
                  icone: Icons.opacity,
                  titulo: 'Umidade Relativa',
                  valor: '${capital.umidade}%',
                ),
                _buildDetalheItem(
                  icone: Icons.air,
                  titulo: 'Vento',
                  valor: '${capital.vento} km/h (de ${capital.direcaoVento}°)',
                ),
                _buildDetalheItem(
                  icone: Icons.visibility,
                  titulo: 'Visibilidade',
                  valor: _formatarVisibilidade(capital.visibilidade),
                ),
                
                // --- CARD METAR "CRU" ---
                Card(
                  margin: const EdgeInsets.only(top: 20),
                  color: Colors.grey[900], 
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'METAR (Raw Text)',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          capital.rawMetar,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace', 
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- BOTÃO VOLTAR PARA A BUSCA ---
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar Outro Aeroporto'),
                    onPressed: () {
                      controller.clearSavedClima();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: primaryColor.withOpacity(0.1),
                      foregroundColor: primaryColor,
                      elevation: 0, 
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        return const Center(child: Text('Nenhum aeroporto selecionado.'));
      }),
    );
  }

  // Helper (sem mudanças)
  Widget _buildDetalheItem({required IconData icone, required String titulo, required String valor}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icone, color: primaryColor, size: 30),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(valor, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}