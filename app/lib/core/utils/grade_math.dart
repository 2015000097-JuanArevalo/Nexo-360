abstract final class GradeMath {
  static const bimesterWeights = <int, double>{1: 20, 2: 30, 3: 20, 4: 30};

  static double percentage(double earned, double maximum) {
    if (maximum <= 0) return 0;
    return earned / maximum * 100;
  }

  static double annualContribution(int bimester, double earned, double maximum) {
    final weight = bimesterWeights[bimester] ?? 0;
    return percentage(earned, maximum) / 100 * weight;
  }

  static double annualAverage(Map<int, ({double earned, double maximum})> periods) {
    var total = 0.0;
    for (final entry in periods.entries) {
      total += annualContribution(entry.key, entry.value.earned, entry.value.maximum);
    }
    return total;
  }
}
