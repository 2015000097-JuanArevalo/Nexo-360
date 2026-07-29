import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final _date = DateFormat("d 'de' MMMM 'de' y", 'es_GT');
final _dateTime = DateFormat("d 'de' MMMM 'de' y, h:mm a", 'es_GT');
final _time = DateFormat('h:mm a', 'es_GT');

DateTime asDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.fromMillisecondsSinceEpoch(0);
}

String formatDate(dynamic value) => _date.format(asDate(value));
String formatDateTime(dynamic value) => _dateTime.format(asDate(value));
String formatTime(dynamic value) => _time.format(asDate(value));
String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
String weekdayName(DateTime date) => DateFormat('EEEE', 'es_GT').format(date);
