import 'dart:math';

import 'package:fast_noise/fast_noise.dart';

mixin SketchMathRandom {
  Random _random = Random();

  /// Sets the seed value for all [random()] invocations to the given
  /// [seed].
  ///
  /// To return to a natural seed value, pass [null] for [seed].
  void randomSeed(int? seed) {
    _random = Random(seed);
  }

  double random(num bound1, [num? bound2]) {
    final lowerBound = bound2 != null ? bound1 : 0;
    final upperBound = bound2 != null ? bound2 : bound1;

    if (upperBound < lowerBound) {
      throw Exception('random() lower bound must be less than upper bound');
    }

    return _random.nextDouble() * (upperBound - lowerBound) + lowerBound;
  }

  int _perlinNoiseSeed = 1337;
  int _perlinNoiseOctaves = 4;
  double _perlinNoiseFalloff = 0.5;
  PerlinNoise? _perlinNoise;

  /// Sets the seed value for all [noise()] invocations to the given
  /// [seed].
  ///
  /// To return to a natural seed value, pass `null` for [seed].
  void noiseSeed(int? seed) {
    _perlinNoiseSeed = seed ?? 1337;
    _initializePerlinNoise();
  }

  /// Sets the number of [octaves] and the [falloff] for each octave
  /// for values generated by [noise()].
  ///
  /// Omitting a value for [octaves] resets the octaves value to the
  /// global default.
  ///
  /// Omitting a value for [falloff] resets the falloff value to the
  /// global default.
  void noiseDetail({
    int? octaves,
    double? falloff,
  }) {
    _perlinNoiseOctaves = octaves ?? 4;
    _perlinNoiseFalloff = falloff ?? 0.5;

    _initializePerlinNoise();
  }

  /// Generates a random value with a Perlin noise algorithm.
  ///
  /// Returns values are in [-1.0, 1.0].
  double noise({
    required double x,
    double y = 0,
    double z = 0,
  }) {
    if (_perlinNoise == null) {
      _initializePerlinNoise();
    }

    return _perlinNoise!.getPerlin3(x, y, z);
  }

  void _initializePerlinNoise() {
    _perlinNoise = PerlinNoise(
      seed: _perlinNoiseSeed,
      octaves: _perlinNoiseOctaves,
      gain: _perlinNoiseFalloff,
    );
  }

  double? _previousGaussian;

  /// Returns a `double` from a random series of numbers having the given
  /// [mean] and the given [standardDeviation].
  ///
  /// By default, the [mean] is `0.0`, and the [standardDeviation] is `1`.
  double randomGaussian({
    num mean = 0.0,
    num standardDeviation = 1.0,
  }) {
    // The random Gaussian is calculated using the Marsaglia polar method
    // which generates TWO independent standard normal random variables,
    // so one is stored and used the next time the function is called.
    double y1, x1, x2, w;
    if (_previousGaussian != null) {
      y1 = _previousGaussian!;
      _previousGaussian = null;
    } else {
      do {
        x1 = this.random(2) - 1;
        x2 = this.random(2) - 1;
        w = x1 * x1 + x2 * x2;
      } while (w >= 1);
      w = sqrt(-2 * log(w) / w);
      y1 = x1 * w;
      _previousGaussian = x2 * w;
    }

    return y1 * standardDeviation + mean;
  }
}