Future milliseconds(int milliseconds) {
  return Future.delayed(new Duration(milliseconds: milliseconds));
}