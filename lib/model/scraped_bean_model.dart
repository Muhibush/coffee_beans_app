/// Dart mirror of the Go `ScrapedBean` struct.
/// Represents the normalized output from the scraper `/scrape` endpoint.
class ScrapedBean {
  final String cleanName;
  final String? imageUrl;
  final String? process;
  final String? roastLevel;
  final List<String> variety;
  final List<String> notes;
  final String? origin;
  final String? altitude;
  final String? description;
  final Map<String, ScrapedVariant> variants;
  final String source;
  final String sourceUrl;

  const ScrapedBean({
    required this.cleanName,
    this.imageUrl,
    this.process,
    this.roastLevel,
    this.variety = const [],
    this.notes = const [],
    this.origin,
    this.altitude,
    this.description,
    this.variants = const {},
    required this.source,
    required this.sourceUrl,
  });

  factory ScrapedBean.fromJson(Map<String, dynamic> json) {
    final rawVariants = json['variants'] as Map<String, dynamic>? ?? {};
    final parsedVariants = rawVariants.map(
      (key, value) => MapEntry(
        key,
        ScrapedVariant.fromJson(value as Map<String, dynamic>),
      ),
    );

    final varietyRaw = json['variety'];
    final notesRaw = json['notes'];

    return ScrapedBean(
      cleanName: json['clean_name'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      process: json['process'] as String?,
      roastLevel: json['roast_level'] as String?,
      variety: varietyRaw is List ? varietyRaw.cast<String>() : [],
      notes: notesRaw is List ? notesRaw.cast<String>() : [],
      origin: json['origin'] as String?,
      altitude: json['altitude'] as String?,
      description: json['description'] as String?,
      variants: parsedVariants,
      source: json['source'] as String? ?? '',
      sourceUrl: json['source_url'] as String? ?? '',
    );
  }
}

/// Dart mirror of Go `Variant` struct from scraper response.
class ScrapedVariant {
  final int price;
  final String buyUrl;
  final String marketplace;
  final String? grindType;

  const ScrapedVariant({
    required this.price,
    required this.buyUrl,
    required this.marketplace,
    this.grindType,
  });

  factory ScrapedVariant.fromJson(Map<String, dynamic> json) {
    return ScrapedVariant(
      price: (json['price'] as num?)?.toInt() ?? 0,
      buyUrl: json['buy_url'] as String? ?? '',
      marketplace: json['marketplace'] as String? ?? '',
      grindType: json['grind_type'] as String?,
    );
  }
}
