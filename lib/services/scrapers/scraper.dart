abstract class Scraper {
  const Scraper();

  Future<Map<String, dynamic>> appFromUrl({required String url});
  Future<Map<String, dynamic>> app({required String appID, String? gl});
}