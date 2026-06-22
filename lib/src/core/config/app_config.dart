const golemioBaseUrl = 'https://api.golemio.cz';
const golemioApiTokenEnvironmentKey = 'GOLEMIO_API_TOKEN';

class AppConfig {
  const AppConfig({
    this.baseUrl = golemioBaseUrl,
    this.apiToken = const String.fromEnvironment(golemioApiTokenEnvironmentKey),
  });

  final String baseUrl;
  final String apiToken;

  bool get hasApiToken => apiToken.trim().isNotEmpty;
}
