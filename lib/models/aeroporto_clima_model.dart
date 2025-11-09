import 'dart:convert';

// --- FUNÇÕES HELPER ---
int _parseIntSafe(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

dynamic _getNestedValue(Map? data, List<String> keys) {
  dynamic current = data;
  for (String key in keys) {
    if (current is Map && current.containsKey(key)) {
      current = current[key];
    } else {
      return null;
    }
  }
  return current; 
}

String _parseVisibilidade(dynamic value) {
  if (value == null) return 'Indisponível';
  if (value.toString() == '9999') return '10 km ou mais'; 
  return value.toString();
}

String _getConditions(Map? data) {
  var conditions = _getNestedValue(data, ['conditions']);
  if (conditions == null || (conditions as List).isEmpty) {
    return 'Céu limpo';
  }
  return (conditions as List).map((c) => c['text']).join(', ');
}

// --- CORREÇÃO DA PRESSÃO (NOVA FUNÇÃO HELPER) ---
// Esta função "lê" o texto cru do METAR (ex: "Q1011")
int _parsePressureFromMetar(String rawMetar) {
  // Regex para encontrar "Q" seguido por 4 dígitos
  final regex = RegExp(r'Q(\d{4})');
  final match = regex.firstMatch(rawMetar);
  
  if (match != null && match.group(1) != null) {
    // Encontrou! match.group(1) será "1011"
    return int.tryParse(match.group(1)!) ?? 0;
  }
  return 0; // Não encontrou
}
// ------------------------------------------------


class AeroportoClima {
  final String codigoIcao;
  final String atualizadoEm;
  final int pressaoAtmosferica;
  final String visibilidade;
  final int vento;
  final int direcaoVento; 
  final int umidade;
  final String condicaoDesc;
  final int temp;
  final String nomeAeroporto;
  final String cidadeAeroporto;
  final String rawMetar;

  AeroportoClima({
    required this.codigoIcao,
    required this.atualizadoEm,
    required this.pressaoAtmosferica,
    required this.visibilidade,
    required this.vento,
    required this.direcaoVento,
    required this.umidade,
    required this.condicaoDesc,
    required this.temp,
    required this.nomeAeroporto,
    required this.cidadeAeroporto,
    required this.rawMetar,
  });


  // --- FACTORY ATUALIZADO ---
  factory AeroportoClima.fromCheckWxJson(String source) {
    final Map<String, dynamic> json = jsonDecode(source);
    
    if (json['data'] == null || (json['data'] as List).isEmpty) {
      throw FormatException('A resposta da CheckWX não contém dados (data).');
    }
    
    final Map<String, dynamic> data = json['data'][0];
    
    // Pegamos o METAR cru primeiro, pois ele é nosso backup
    final String rawMetar = _getNestedValue(data, ['raw_text']) as String? ?? '';

    // --- CORREÇÃO DA PRESSÃO (LÓGICA ATUALIZADA) ---
    // 1. Tenta pegar o valor decodificado
    int pressao = _parseIntSafe(_getNestedValue(data, ['pressure', 'mb']));
    
    // 2. Se falhar (der 0), usa nosso parser manual como fallback
    if (pressao == 0 && rawMetar.isNotEmpty) {
      pressao = _parsePressureFromMetar(rawMetar);
    }
    // ------------------------------------------------

    return AeroportoClima(
      codigoIcao: _getNestedValue(data, ['icao']) as String? ?? '-',
      atualizadoEm: _getNestedValue(data, ['observed']) as String? ?? '-',
      temp: _parseIntSafe(_getNestedValue(data, ['temperature', 'celsius'])),
      umidade: _parseIntSafe(_getNestedValue(data, ['humidity', 'percent'])),
      
      pressaoAtmosferica: pressao, // <-- Usa o valor corrigido
      
      vento: _parseIntSafe(_getNestedValue(data, ['wind', 'speed_kph'])),
      direcaoVento: _parseIntSafe(_getNestedValue(data, ['wind', 'degrees'])),
      visibilidade: _parseVisibilidade( 
        _getNestedValue(data, ['visibility', 'meters'])
      ),
      condicaoDesc: _getConditions(data),
      nomeAeroporto: _getNestedValue(data, ['station', 'name']) as String? ?? 'Nome indisponível',
      cidadeAeroporto: _getNestedValue(data, ['station', 'location']) as String? ?? 'Local indisponível',
      rawMetar: rawMetar,
    );
  }
}