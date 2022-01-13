abstract class Scraper {
  Future<Map<String, dynamic>> appFromUrl({required String url});
  Future<Map<String, dynamic>> app({required String appID, String? gl});
}