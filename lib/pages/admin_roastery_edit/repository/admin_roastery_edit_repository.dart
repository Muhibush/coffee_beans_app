import '../../../model/roastery.dart';

class AdminRoasteryEditRepository {
  /// Fetches a Roastery from the backend.
  /// If [id] is null, it signifies adding a new Roastery, returning an empty template.
  Future<Roastery> getRoastery(String? id) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate network

    if (id == null) {
      return const Roastery(
        id: 'new',
        name: '',
        city: '',
        beanCount: 0,
        isActive: false,
        bio: '',
        socialLinks: {},
      );
    }

    // Mock an existing roastery
    return Roastery(
      id: id,
      name: 'Roastery A',
      city: 'Jakarta',
      beanCount: 12,
      isActive: true,
      bio: 'Specialty coffee roastery focusing on Indonesian single origin beans. Established 2021, curated for the modern enthusiast.',
      socialLinks: {
        'instagram': '@roastery_a',
        'tokopedia': 'tokopedia.com/roasterya',
        'website': 'www.roasterya.com',
      },
      logoUrl: 'https://via.placeholder.com/300x300.png?text=Roastery+A',
    );
  }

  /// Saves a Roastery to the backend (insert/update).
  Future<void> saveRoastery(Roastery roastery) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
    // TODO: integrate Supabase upsert
  }

  /// Deletes a Roastery.
  Future<void> deleteRoastery(String id) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
    // TODO: integrate Supabase delete
  }
}
