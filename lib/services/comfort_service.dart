import '../models/weather_model.dart';
import 'package:flutter/material.dart';

class ComfortLevel {
  final double score; // 0.0-1.0
  final String emoji;
  final String titleTR;
  final String titleEN;
  final String descTR;
  final String descEN;
  final Color color;

  const ComfortLevel({
    required this.score,
    required this.emoji,
    required this.titleTR,
    required this.titleEN,
    required this.descTR,
    required this.descEN,
    required this.color,
  });
}

class ComfortService {
  /// Calculate thermal comfort based on weather and outfit layers
  static ComfortLevel calculateComfort(WeatherData weather, int layerCount) {
    final temp = weather.temperature;
    final wind = weather.windSpeed;
    final humidity = weather.humidity;

    // Wind chill effect
    double feelsLike = temp;
    if (temp <= 10 && wind > 4.8) {
      feelsLike = 13.12 + 0.6215 * temp - 11.37 * (wind * 3.6) + 0.3965 * temp * (wind * 3.6);
    } else if (temp >= 27 && humidity > 40) {
      feelsLike = temp + (humidity - 40) * 0.1;
    }

    // Ideal layer count for temperature
    int idealLayers;
    if (feelsLike > 30) {
      idealLayers = 1;
    } else if (feelsLike > 20) {
      idealLayers = 2;
    } else if (feelsLike > 10) {
      idealLayers = 3;
    } else if (feelsLike > 0) {
      idealLayers = 4;
    } else {
      idealLayers = 5;
    }

    final layerDiff = (layerCount - idealLayers).abs();
    final score = (1.0 - layerDiff * 0.25).clamp(0.0, 1.0);

    if (score >= 0.8) {
      return ComfortLevel(
        score: score, emoji: '😊', titleTR: 'Çok Rahat', titleEN: 'Very Comfortable',
        descTR: 'Katman sayın hava için ideal! Hissedilen sıcaklık: ${feelsLike.round()}°C',
        descEN: 'Your layer count is ideal! Feels like: ${feelsLike.round()}°C',
        color: const Color(0xFF4CAF50),
      );
    } else if (score >= 0.5) {
      final tip = layerCount > idealLayers ? 'Biraz fazla giyindin' : 'Biraz daha kat ekle';
      return ComfortLevel(
        score: score, emoji: '😐', titleTR: 'Fena Değil', titleEN: 'Decent',
        descTR: '$tip. Hissedilen sıcaklık: ${feelsLike.round()}°C',
        descEN: '${layerCount > idealLayers ? 'Slightly overdressed' : 'Add a layer'}. Feels like: ${feelsLike.round()}°C',
        color: const Color(0xFFFFC107),
      );
    } else {
      final tip = layerCount > idealLayers ? 'Çok kalın giyindin, terleme riski var!' : 'Çok ince giyindin, üşüme riski var!';
      return ComfortLevel(
        score: score, emoji: '😰', titleTR: 'Rahatsız', titleEN: 'Uncomfortable',
        descTR: '$tip Hissedilen sıcaklık: ${feelsLike.round()}°C',
        descEN: '${layerCount > idealLayers ? 'Too many layers, overheating risk!' : 'Too few layers, freezing risk!'} Feels like: ${feelsLike.round()}°C',
        color: const Color(0xFFF44336),
      );
    }
  }

  /// Get recommended layer count for weather
  static int getRecommendedLayers(WeatherData weather) {
    final temp = weather.temperature;
    if (temp > 30) return 1;
    if (temp > 20) return 2;
    if (temp > 10) return 3;
    if (temp > 0) return 4;
    return 5;
  }

  /// Get layer suggestions
  static List<String> getLayerSuggestions(WeatherData weather) {
    final temp = weather.temperature;
    if (temp > 30) return ['👕 Tek kat ince tişört yeterli'];
    if (temp > 25) return ['👕 İnce tişört', '🩳 Kısa alt'];
    if (temp > 20) return ['👕 Tişört', '👖 Uzun pantolon'];
    if (temp > 15) return ['👕 Tişört', '🧥 Hırka/İnce ceket', '👖 Pantolon'];
    if (temp > 10) return ['👕 Uzun kollu üst', '🧥 Ceket', '👖 Kalın pantolon'];
    if (temp > 5) return ['👕 Termal iç', '👕 Kazak', '🧥 Kalın mont', '👖 Kalın pantolon'];
    if (temp > 0) return ['👕 Termal iç', '👕 Polar', '🧥 Kışlık mont', '🧣 Atkı/Bere', '👖 Kalın pantolon'];
    return ['👕 Termal iç çamaşır', '👕 Polar kazak', '🧥 Kaz tüyü mont', '🧣 Atkı + Bere + Eldiven', '👖 Kalın pantolon'];
  }
}
