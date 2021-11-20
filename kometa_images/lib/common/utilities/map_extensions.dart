extension MapExtension<K, V> on Map<K, V> {
  V getValueOrDefault(K key, V defaultValue) {
    if (this == null || !this.containsKey(key)) {
      return defaultValue;
    }

    return this[key];
  }
}
