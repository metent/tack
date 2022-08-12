String exactDate(DateTime x) {
  final curDT = DateTime.now();
  if (x.day < curDT.day && x.month == curDT.month && x.year == curDT.year) {
    return 'Missed ' +
        x.toString().substring(8, 10) +
        "-" +
        x.toString().substring(5, 7) +
        "-" +
        x.toString().substring(0, 4);
  } else if (x.day == curDT.day &&
      x.month == curDT.month &&
      x.year == curDT.year) {
    return 'Today ' + x.toString().substring(11, 16);
  } else if (x.day - 1 == curDT.day &&
      x.month == curDT.month &&
      x.year == curDT.year) {
    return 'Tomorrow ' + x.toString().substring(11, 16);
  } else {
    return x.toString().substring(8, 10) +
        "-" +
        x.toString().substring(5, 7) +
        "-" +
        x.toString().substring(0, 4);
  }
}
