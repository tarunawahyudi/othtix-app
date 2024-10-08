import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

PackageInfo _packageInfo = GetIt.I<PackageInfo>();

class Constant {
  static String appName = 'Othtix';
  static String appLabel = _packageInfo.appName;
  static String packageName = _packageInfo.packageName;
  static String version = _packageInfo.version;
  static String buildNumber = _packageInfo.buildNumber;

  static String apiBaseUrl = dotenv.env['API_BASE_URL']!;

  static String googleClientId = dotenv.env['GOOGLE_CLIENT_ID']!;
  static String googleServerClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID']!;

  static String midtransMerchantBaseUrl = dotenv.env['MIDTRANS_MERCHANT_BASE_URL']!;
  static String midtransClientKey = kDebugMode
      ? dotenv.env['MIDTRANS_CLIENT_KEY_SANDBOX']!
      : dotenv.env['MIDTRANS_CLIENT_KEY']!;

  static const String locale = 'id_ID';
  static const String currencyPrefix = 'Rp';

  /// notification
  static Duration shortInterval = const Duration(seconds: 15);
  static Duration mediumInterval = const Duration(seconds: 60);
  static Duration longInterval = const Duration(seconds: 300);
  static int notificationCountLimit = 5;

  static String privacyAndPolicyUrl = 'https://othman.media/kebijakan-privasi';
  static String termAndConditionUrl = 'https://othman.media/syarat-dan-ketentuan';
}
