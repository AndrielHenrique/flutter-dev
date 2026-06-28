abstract class DateFormatter {
  static String formatarDataHora(String iso) {
    try {
      final DateTime dt = DateTime.parse(iso).toLocal();
      final String dia = dt.day.toString().padLeft(2, '0');
      final String mes = dt.month.toString().padLeft(2, '0');
      final String hora = dt.hour.toString().padLeft(2, '0');
      final String min = dt.minute.toString().padLeft(2, '0');
      return '$dia/$mes $hora:$min';
    } catch (_) {
      return '—';
    }
  }
}
