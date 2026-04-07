import 'package:equatable/equatable.dart';

/// Model representing a roastery profile.
/// Maps directly to the `roasteries` Supabase table.
class Roastery extends Equatable {
  final String id;
  final String name;
  final String city;
  final int beanCount;
  final bool isActive;
  final String? bio;
  final Map<String, String>? socialLinks;
  final String? logoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Roastery({
    required this.id,
    required this.name,
    required this.city,
    this.beanCount = 0,
    this.isActive = true,
    this.bio,
    this.socialLinks,
    this.logoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Roastery.fromJson(Map<String, dynamic> json) {
    // Parse social_links JSONB → Map<String, String>
    final rawLinks = json['social_links'] as Map<String, dynamic>? ?? {};
    final parsedLinks = rawLinks.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    // Bean count can come from a joined aggregate or a separate field
    int beanCount = 0;
    if (json['bean_count'] != null) {
      beanCount = (json['bean_count'] as num).toInt();
    } else if (json['beans'] is List) {
      beanCount = (json['beans'] as List).length;
    }

    return Roastery(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      beanCount: beanCount,
      isActive: json['is_active'] as bool? ?? true,
      bio: json['bio'] as String?,
      socialLinks: parsedLinks.isNotEmpty ? parsedLinks : null,
      logoUrl: json['logo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'city': city,
      'is_active': isActive,
      'bio': bio,
      'social_links': socialLinks ?? {},
      'logo_url': logoUrl,
    };
    if (id.isNotEmpty && id != 'new') {
      map['id'] = id;
    }
    return map;
  }

  Roastery copyWith({
    String? id,
    String? name,
    String? city,
    int? beanCount,
    bool? isActive,
    String? bio,
    Map<String, String>? socialLinks,
    String? logoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Roastery(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      beanCount: beanCount ?? this.beanCount,
      isActive: isActive ?? this.isActive,
      bio: bio ?? this.bio,
      socialLinks: socialLinks ?? this.socialLinks,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, name, city, beanCount, isActive, bio,
        socialLinks, logoUrl, createdAt, updatedAt,
      ];
}
