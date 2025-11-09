import 'package:http/http.dart' as http;
import '../models/aeroporto_clima_model.dart';

class CptecService {
  final String _apiKey = '94595a45b97e4157b50e8ccc5422f8e8';

  // URL base da CheckWX
  final String _baseUrl = 'https://api.checkwx.com/metar';

  // Busca um aeroporto específico
  Future<AeroportoClima> fetchClimaAeroporto(String icaoCode) async {
    final Uri url = Uri.parse('$_baseUrl/$icaoCode/decoded');
    
    // Adiciona o Header com a chave da API
    final Map<String, String> headers = {
      'X-API-Key': _apiKey
    };

    try {
      // Faz a chamada GET com os headers
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return AeroportoClima.fromCheckWxJson(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Chave de API inválida ou não autorizada.');
      } else if (response.statusCode == 404) {
        throw Exception('Código ICAO não encontrado na CheckWX.');
      } else if (response.statusCode == 429) {
        throw Exception('Limite de chamadas da API atingido. Tente mais tarde.');
      } else {
        throw Exception('Falha ao carregar dados (Erro: ${response.statusCode})');
      }
    } 
    on http.ClientException {
      throw Exception('Erro de conexão: Verifique sua internet.');
    } on FormatException {
      throw Exception('A API retornou uma resposta inválida.');
    } catch (e) {
      throw Exception('Ocorreu um erro desconhecido: $e');
    }
  }
}