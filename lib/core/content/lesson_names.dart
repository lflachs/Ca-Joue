/// Mapping from kebab-case lesson IDs to French display names.
///
/// All 32 lessons across the 4 tiers have a human-readable
/// French name for display in the lesson list.
class LessonNames {
  LessonNames._();

  /// Returns the French display name for the given lesson [id].
  ///
  /// Falls back to converting kebab-case to Title Case if the
  /// lesson ID is not found in the mapping.
  static String of(String id) {
    return _names[id] ?? _kebabToTitleCase(id);
  }

  static String _kebabToTitleCase(String kebab) {
    return kebab
        .split('-')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  static const _names = <String, String>{
    // Tier 1 — La Vallée
    'everyday-greetings': 'Salutations du quotidien',
    'body-feelings': 'Corps et sentiments',
    'daily-errands': 'Courses et commissions',
    'food-drink': 'Manger et boire',
    'household-items': 'Objets de la maison',
    'numbers-time': 'Chiffres et horaires',
    'social-basics': 'Vie sociale',
    'weather-basics': 'La météo',

    // Tier 2 — L'Alpage
    'cooking-cuisine': 'Cuisine et recettes',
    'emotions-reactions': 'Émotions et réactions',
    'household-cleaning': 'Ménage et nettoyage',
    'informal-expressions': 'Expressions familières',
    'insults-teasing': 'Taquineries et moqueries',
    'movement-actions': 'Mouvements et actions',
    'social-gatherings': 'Fêtes et rencontres',
    'weather-nature': 'Météo et nature',
    'workplace-school': 'Travail et école',

    // Tier 3 — Le Sommet
    'advanced-vocabulary': 'Vocabulaire avancé',
    'character-traits': 'Traits de caractère',
    'colorful-language': 'Langage coloré',
    'culture-traditions': 'Culture et traditions',
    'everyday-advanced': 'Quotidien avancé',
    'nature-elements': 'Éléments naturels',
    'regional-sayings': 'Dictons régionaux',

    // Tier 4 — L'Aiguille
    'archaic-daily': "Quotidien d'antan",
    'body-archaic': "Corps d'autrefois",
    'forgotten-words': 'Mots oubliés',
    'old-household': "Maison d'autrefois",
    'patois-heritage': 'Héritage du patois',
    'rare-expressions': 'Expressions rares',
    'rural-traditions': 'Traditions rurales',
    'specialized-terms': 'Termes spécialisés',
  };
}
