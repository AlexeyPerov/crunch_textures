extension ListExtension<K> on List<K> {
  K getValueOrDefault(int index, K defaultValue) {
    if (this == null) {
      return defaultValue;
    }

    if (index < 0 || index >= this.length) {
      return defaultValue;
    }

    return this[index];
  }
}
