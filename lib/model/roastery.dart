/// Lightweight model representing a roastery entry in the admin dashboard.
///
/// This is a presentation-layer model; the full Supabase-backed model will
/// be added later when the database layer is integrated.
class Roastery {
  const Roastery({
    required this.id,
    required this.name,
    required this.city,
    required this.beanCount,
    required this.isActive,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String city;
  final int beanCount;
  final bool isActive;
  final String? logoUrl;
}
