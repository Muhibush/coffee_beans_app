import 'package:equatable/equatable.dart';

/// Variant for a specific weight of a bean product.
/// Maps to a single key inside the `variants` JSONB column.
class BeanVariant extends Equatable {
  final int price;
  final String buyUrl;
  final String marketplace;

  const BeanVariant({
    required this.price,
    required this.buyUrl,
    required this.marketplace,
  });

  factory BeanVariant.fromJson(Map<String, dynamic> json) {
    return BeanVariant(
      price: (json['price'] as num?)?.toInt() ?? 0,
      buyUrl: json['buy_url'] as String? ?? '',
      marketplace: json['marketplace'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'price': price,
        'buy_url': buyUrl,
        'marketplace': marketplace,
      };

  BeanVariant copyWith({
    int? price,
    String? buyUrl,
    String? marketplace,
  }) {
    return BeanVariant(
      price: price ?? this.price,
      buyUrl: buyUrl ?? this.buyUrl,
      marketplace: marketplace ?? this.marketplace,
    );
  }

  @override
  List<Object?> get props => [price, buyUrl, marketplace];
}

/// Core bean model matching the `beans` Supabase table.
class Bean extends Equatable {
  final String id;
  final String roasteryId;
  final String cleanName;
  final String fingerprint;
  final List<String> variety;
  final List<String> notes;
  final String? process;
  final String? roastLevel;
  final String status; // 'published', 'draft', 'unpublished'
  final Map<int, BeanVariant> variants;
  final String? imageUrl;
  final String? origin;
  final String? altitude;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Bean({
    required this.id,
    required this.roasteryId,
    required this.cleanName,
    required this.fingerprint,
    this.variety = const [],
    this.notes = const [],
    this.process,
    this.roastLevel,
    this.status = 'draft',
    this.variants = const {},
    this.imageUrl,
    this.origin,
    this.altitude,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  /// Create an empty bean template for new creation.
  factory Bean.empty(String roasteryId) {
    return Bean(
      id: '',
      roasteryId: roasteryId,
      cleanName: '',
      fingerprint: '',
      status: 'draft',
    );
  }

  factory Bean.fromJson(Map<String, dynamic> json) {
    // Parse variants JSONB → Map<int, BeanVariant>
    final rawVariants = json['variants'] as Map<String, dynamic>? ?? {};
    final parsedVariants = rawVariants.map(
      (key, value) => MapEntry(
        int.tryParse(key) ?? 0,
        BeanVariant.fromJson(value as Map<String, dynamic>),
      ),
    );

    // Parse TEXT[] arrays
    final varietyRaw = json['variety'];
    final notesRaw = json['notes'];

    return Bean(
      id: json['id'] as String? ?? '',
      roasteryId: json['roastery_id'] as String? ?? '',
      cleanName: json['clean_name'] as String? ?? '',
      fingerprint: json['fingerprint'] as String? ?? '',
      variety: varietyRaw is List ? varietyRaw.cast<String>() : [],
      notes: notesRaw is List ? notesRaw.cast<String>() : [],
      process: json['process'] as String?,
      roastLevel: json['roast_level'] as String?,
      status: json['status'] as String? ?? 'draft',
      variants: parsedVariants,
      imageUrl: json['image_url'] as String?,
      origin: json['origin'] as String?,
      altitude: json['altitude'] as String?,
      description: json['description'] as String?,
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
      'roastery_id': roasteryId,
      'clean_name': cleanName,
      'fingerprint': fingerprint,
      'variety': variety,
      'notes': notes,
      'process': process,
      'roast_level': roastLevel,
      'status': status,
      'variants': variants.map((key, v) => MapEntry(key.toString(), v.toJson())),
      'image_url': imageUrl,
      'origin': origin,
      'altitude': altitude,
      'description': description,
    };
    // Only include id if it's a real UUID (not empty / not 'new')
    if (id.isNotEmpty && id != 'new') {
      map['id'] = id;
    }
    return map;
  }

  /// Lowest price across all variants, or null if none.
  int? get lowestPrice {
    if (variants.isEmpty) return null;
    return variants.values.map((v) => v.price).reduce((a, b) => a < b ? a : b);
  }

  /// Formatted price string for display.
  String get displayPrice {
    final price = lowestPrice;
    if (price == null) return '-';
    final formatted = price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  Bean copyWith({
    String? id,
    String? roasteryId,
    String? cleanName,
    String? fingerprint,
    List<String>? variety,
    List<String>? notes,
    String? process,
    String? roastLevel,
    String? status,
    Map<int, BeanVariant>? variants,
    String? imageUrl,
    String? origin,
    String? altitude,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bean(
      id: id ?? this.id,
      roasteryId: roasteryId ?? this.roasteryId,
      cleanName: cleanName ?? this.cleanName,
      fingerprint: fingerprint ?? this.fingerprint,
      variety: variety ?? this.variety,
      notes: notes ?? this.notes,
      process: process ?? this.process,
      roastLevel: roastLevel ?? this.roastLevel,
      status: status ?? this.status,
      variants: variants ?? this.variants,
      imageUrl: imageUrl ?? this.imageUrl,
      origin: origin ?? this.origin,
      altitude: altitude ?? this.altitude,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, roasteryId, cleanName, fingerprint, variety, notes,
        process, roastLevel, status, variants, imageUrl, origin,
        altitude, description, createdAt, updatedAt,
      ];
}
