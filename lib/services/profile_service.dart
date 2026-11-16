import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileData {
  final String name;
  final String style; // 'male', 'female', 'unisex'
  final Map<String, double> bodyProportions;
  final int skinColor;
  final int hairColor;

  ProfileData({
    required this.name,
    required this.style,
    this.bodyProportions = const {},
    this.skinColor = 0xFFD2A679,
    this.hairColor = 0xFF3D2314,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'style': style,
        'bodyProportions': bodyProportions,
        'skinColor': skinColor,
        'hairColor': hairColor,
      };

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
        name: json['name'] as String? ?? 'Profil',
        style: json['style'] as String? ?? 'unisex',
        bodyProportions: (json['bodyProportions'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
            {},
        skinColor: json['skinColor'] as int? ?? 0xFFD2A679,
        hairColor: json['hairColor'] as int? ?? 0xFF3D2314,
      );
}

class ProfileService {
  static const _profilesKey = 'profiles_list';
  static const _activeKey = 'active_profile';

  static Future<List<ProfileData>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_profilesKey);
    if (raw == null || raw.isEmpty) {
      return [ProfileData(name: 'Ben', style: 'unisex')];
    }
    return raw
        .map((e) => ProfileData.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveProfiles(List<ProfileData> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _profilesKey,
      profiles.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  static Future<int> getActiveIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_activeKey) ?? 0;
  }

  static Future<void> setActiveIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_activeKey, index);
  }

  static Future<ProfileData> getActiveProfile() async {
    final profiles = await getProfiles();
    final index = await getActiveIndex();
    if (index >= 0 && index < profiles.length) return profiles[index];
    return profiles.first;
  }

  static Future<void> addProfile(ProfileData profile) async {
    final profiles = await getProfiles();
    profiles.add(profile);
    await saveProfiles(profiles);
  }

  static Future<void> removeProfile(int index) async {
    final profiles = await getProfiles();
    if (profiles.length <= 1) return; // En az 1 profil kalmalı
    profiles.removeAt(index);
    await saveProfiles(profiles);
    final active = await getActiveIndex();
    if (active >= profiles.length) {
      await setActiveIndex(profiles.length - 1);
    }
  }

  static Future<void> updateProfile(int index, ProfileData profile) async {
    final profiles = await getProfiles();
    if (index >= 0 && index < profiles.length) {
      profiles[index] = profile;
      await saveProfiles(profiles);
    }
  }
}
