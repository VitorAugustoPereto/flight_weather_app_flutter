import 'dart:convert';
import 'package:aeroporto_clima_app/models/aeroporto_clima_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // CORREÇÃO: Grupo de teste agora reflete o construtor de fábrica real
  group('AeroportoClima.fromCheckWxJson', () {

    test('deve fazer o parse da pressão atmosférica a partir do campo aninhado quando presente', () {
      // Arrange
      // CORREÇÃO: A estrutura do mock agora corresponde exatamente à API da CheckWX
      final mockData = {
        'data': [
          {
            'station': {
              'name': 'Aeroporto de Congonhas',
              'location': 'São Paulo'
            },
            'temperature': {'celsius': 20},
            'visibility': {'meters': '9999'},
            'humidity': {'percent': 72},
            'pressure': {'mb': 1015}, // <-- Pressão está presente
            'wind': {'speed_kph': 9, 'degrees': 120},
            'conditions': [ {'text': 'Parcialmente nublado'} ],
            'raw_text': 'SBSP 241800Z 12005KT 9999 SCT030 20/14 Q1015',
            'observed': '2024-07-24T18:00:00Z',
            'icao': 'SBSP'
          }
        ]
      };
      // CORREÇÃO: Converte o mapa em uma string JSON
      final jsonString = jsonEncode(mockData);

      // Act
      // CORREÇÃO: Chama o construtor de fábrica correto
      final clima = AeroportoClima.fromCheckWxJson(jsonString);

      // Assert
      expect(clima.pressaoAtmosferica, 1015);
    });

    test('deve usar o fallback para o METAR se o campo de pressão estiver ausente', () {
       // Arrange
      final mockData = {
        'data': [
          {
            'station': {
              'name': 'Aeroporto de Congonhas',
              'location': 'São Paulo'
            },
            'temperature': {'celsius': 20},
            'visibility': {'meters': '9999'},
            'humidity': {'percent': 72},
            'pressure': {'mb': null}, // <-- Pressão está ausente/nula
            'wind': {'speed_kph': 9, 'degrees': 120},
            'conditions': [ {'text': 'Parcialmente nublado'} ],
            // O METAR contém a pressão correta (Q1018)
            'raw_text': 'SBSP 241800Z 12005KT 9999 SCT030 20/14 Q1018',
            'observed': '2024-07-24T18:00:00Z',
            'icao': 'SBSP'
          }
        ]
      };
      final jsonString = jsonEncode(mockData);

      // Act
      final clima = AeroportoClima.fromCheckWxJson(jsonString);

      // Assert
      // Deve usar o fallback e extrair 1018 do METAR
      expect(clima.pressaoAtmosferica, 1018);
    });

  });
}
