import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_360/core/utils/grade_math.dart';

void main() {
  test('bimester weights total 100', () {
    expect(GradeMath.bimesterWeights.values.reduce((a, b) => a + b), 100);
  });

  test('annual average applies 20/30/20/30', () {
    final result = GradeMath.annualAverage({
      1: (earned: 80, maximum: 100),
      2: (earned: 90, maximum: 100),
      3: (earned: 70, maximum: 100),
      4: (earned: 100, maximum: 100),
    });
    expect(result, closeTo(87, 0.001));
  });
}
