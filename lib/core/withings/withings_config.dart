/// Withings 연동 설정값 (하드코딩 금지: 빌드/실행 시 --dart-define 으로 주입)
///
/// flutter run \
///   --dart-define=WITHINGS_CLIENT_ID=xxxx \
///   --dart-define=WITHINGS_CLIENT_SECRET=xxxx \
///   --dart-define=WITHINGS_REDIRECT_URI=https://<아이디>.github.io/<레포명>/
///
/// 또는 프로젝트 최상위 withings.json 에 값을 채운 뒤 (git 제외됨)
/// flutter run --dart-define-from-file=withings.json
class WithingsConfig {
  static const String clientId = String.fromEnvironment('WITHINGS_CLIENT_ID');
  static const String clientSecret = String.fromEnvironment('WITHINGS_CLIENT_SECRET');

  /// GitHub Pages 콜백 중계 페이지 주소 (withings_callback/index.html).
  /// ⚠️ Withings 개발자 대시보드에 등록한 Callback URL과 끝의 '/'까지 정확히 같아야 함.
  ///    한 글자라도 다르면 인증/토큰 교환이 redirect_uri 불일치로 실패함.
  static const String redirectUri = String.fromEnvironment('WITHINGS_REDIRECT_URI');

  /// 중계 페이지가 넘겨주는 앱 커스텀 스킴 (sleepprototype://withings?...).
  /// AndroidManifest.xml 의 CallbackActivity intent-filter, withings_callback/index.html 과 일치해야 함
  static const String callbackScheme = 'sleepprototype';

  static const String authorizeUrl = 'https://account.withings.com/oauth2_user/authorize2';
  static const String apiBase = 'https://wbsapi.withings.net';
  static const String scope = 'user.activity';

  /// 가져올 기간 (최근 N일)
  static const int importDays = 7;

  static bool get isConfigured => clientId.isNotEmpty && clientSecret.isNotEmpty && redirectUri.isNotEmpty;
}
