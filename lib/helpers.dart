import 'package:intl/intl.dart';

String formatCurrency(num amount, {String locale = 'es_MX', String symbol = '4'}) {
  return NumberFormat.currency(locale: locale, symbol: symbol).format(amount);
}
