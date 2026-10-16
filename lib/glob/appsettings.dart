// lib\glob\appsettings.dart


class AppSettings {
  static String demoDate = '2026-10-07';
  static int deliveryFee = 80;
  static int lateFeeMultiplier = 1;


  static DateTime toDate(String ymd) {
    final p = ymd.split('-');
    return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }


  static String fromDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';


  static String addDays(String ymd, int n) => fromDate(toDate(ymd).add(Duration(days: n)));


  static int daysBetween(String a, String b) {
    final d = toDate(b).difference(toDate(a)).inDays;
    return d < 0 ? 0 : d;
  }


  static String longDate(String ymd) => '${shortDate(ymd)}, ${ymd.split('-')[0]}';

  static String peso(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return '₱$b';
  }


  static String monthYear(String ymd) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final p = ymd.split('-');
    return '${months[int.parse(p[1]) - 1]} ${p[0]}';
  }

  static String shortDate(String ymd) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final p = ymd.split('-');
    return '${months[int.parse(p[1]) - 1]} ${int.parse(p[2])}';
  }
}