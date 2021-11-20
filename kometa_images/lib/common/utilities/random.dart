import 'dart:math';

class RandomUtilities {
  static get(int min, int max) {
    assert(max > min);
    var random = new Random();
    var next = random.nextDouble();
    var result = min + (max - min) * next;
    return result.toInt();
  }

  static hit(double chance) {
    var random = new Random();
    var next = random.nextDouble();
    return next <= chance;
  }
}
