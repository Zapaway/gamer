/// Migrated from https://github.com/varamsky/google_play_store_scraper_dart
/// to include null sound safety. Legal under the MIT license.

import 'package:gamer/services/scrapers/scraper.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:html/parser.dart' as parser;

/// Goes onto the Google Play website and scrapes the information from it.
class GooglePlayScraper extends Scraper {
  static const String domain = "https://play.google.com";
  static final WebScraper scraper = WebScraper(domain);

  const GooglePlayScraper();

  /// Parses through HTML to get
  /// details about an app from the Google Play Store using an URL.
  @override
  Future<Map<String, dynamic>> appFromUrl(
      {required String url}) async {
    final Uri uri = Uri.parse(url);
    var res = <String, dynamic>{};

    final String? appID = uri.queryParameters["id"];
    final String? gl = uri.queryParameters["gl"];
    if (appID != null) {
      res = await app(appID: appID, gl: gl);
    } else {
      throw InvalidGooglePlayGameURLException();
    }

    return res;
  }

  /// Get details about an app from the Google Play Store.
  ///
  /// * [appID] is the appID for a particular app on the Google Play Store.
  /// * [gl] is an optional parameter for providing the geographical location.
  /// By default, this value is set to "us" for the United States.
  @override
  Future<Map<String, dynamic>> app(
      {required String appID, String? gl}) async {
    gl ??= "us";

    final endpoint = "/store/apps/details?id=$appID&gl=$gl";
    final result = <String, dynamic>{};

    if (await scraper.loadWebPage(endpoint)) {
      try {
        final pageContent = scraper.getPageContent();
        final doc = parser.parse(pageContent);

        final title = (scraper
          .getElement("title", [])
          .first["title"] as String).replaceFirst(" - Apps on Google Play", "");
        final description = doc.getElementsByClassName("DWPxHb")[0]
          .children[0]
          .children[0]
          .innerHtml

        // split at any extra new line separating paragraphs and use the first paragraph
          .split(RegExp(r"<br>\s*<br>"))[0].trim()

          .replaceAll("<br>", "\n")
          .replaceAll(RegExp(r"</*.*?>"), "");  // get rid of any remaining tags

        final additionalInfo =
        scraper.getElement("div.IQ1z0d > span.htlgb", []);
        final String updated = additionalInfo[0]["title"];
        final String size = additionalInfo[1]["title"];
        final String installs = additionalInfo[2]["title"];
        final String version = additionalInfo[3]["title"];
        final String androidVersion = additionalInfo[4]["title"];
        final String contentRating = scraper
          .getElement("div.KmO8jd", ["text"])[0]["title"];
        final String developer =
        (additionalInfo[additionalInfo.length - 2]["title"]);
        final devElement = scraper.getElement(
            "div.hAyfc > span.htlgb > div.IQ1z0d > span.htlgb > div > a",
            ["href"]);

        String developerWebsite = "", developerEmail = "", privacyPolicy = "";
        for (int i = 0; i < devElement.length; i++) {
          if (devElement[i]["title"] == "Visit website") {
            developerWebsite = devElement[i]["attributes"]["href"];
            developerEmail = devElement[i + 1]["title"];
            privacyPolicy = devElement[i + 2]["attributes"]["href"];
          }
        }

        final developerAddress = scraper
            .getElement("div.IQ1z0d > span.htlgb > div", []).last["title"];
        final ratingsScoreText = scraper.getElement(
            "div.W4P4ne > c-wiz > div.K9wGie > div.BHMmbe", []).first["title"];
        final dataFromScripts = scraper.getAllScripts();

        String ratingsScore = "",
            ratingsCount = "",
            price = "",
            priceCurrency = "";
        bool free = false;
        for (var scriptData in dataFromScripts) {
          if (scriptData.contains("ratingValue")) {
            var dataList = scriptData.split('",');

            for (var listElement in dataList) {
              if (listElement.contains("ratingValue")) {
                ratingsScore = listElement.split(':"')[1];
              }
              if (listElement.contains("ratingCount")) {
                ratingsCount = listElement.split(':"")[1].split(""},')[0];
              }
              if (listElement.contains('"price"')) {
                price = listElement.split(':"')[1];
                if (price == "0") free = true;
              }
              if (listElement.contains('"priceCurrency"')) {
                priceCurrency = listElement.split(':"')[1];
              }
            }
          }
        }

        String developerID = "", genre = "", genreID = "";
        final genreElement = scraper.getElement(
            "div.jdjqLd > div.ZVWMWc > div.qQKdcc > span > a", ["href"]);
        for (var genreEle in genreElement) {
          if ((genreEle["attributes"]["href"]).toString().contains("id")) {
            developerID =
            ((genreEle["attributes"]["href"]).toString().split("id=")[1]);
          }
          if ((genreEle["attributes"]["href"])
              .toString()
              .contains("category")) {
            genre = genreEle["title"];
            genreID = (genreEle["attributes"]["href"])
                .toString()
                .split("category/")[1];
          }
        }
        if (genreID.isEmpty || !genreID.startsWith("GAME_")) {
          throw InvalidGooglePlayGameURLException();
        }

        final iconElement = scraper.getElement(
            "div.oQ6oV > div.hkhL9e > div.xSyT2c > img", ["src", "alt"]);
        String icon = "";

        for (var element in iconElement) {
          if ((element["attributes"]["alt"])
              .toString()
              .toLowerCase() == "cover art") {
            icon = element["attributes"]["src"];
          }
        }

        result.addAll(
          {
            "title": title,
            "description": description,
            "updated": updated,
            "size": size,
            "installs": installs,
            "ratingsScore": ratingsScore,
            "ratingsScoreText": ratingsScoreText,
            "ratingsCount": ratingsCount,
            "price": price,
            "free": free,
            "priceCurrency": priceCurrency,
            "version": version,
            "androidVersion": androidVersion,
            "contentRating": contentRating,
            "developer": developer,
            "developerID": developerID,
            "developerEmail": developerEmail,
            "developerWebsite": developerWebsite,
            "developerAddress": developerAddress,
            "privacyPolicy": privacyPolicy,
            "genre": genre,
            "genreID": genreID,
            "icon": icon,
            "appID": appID,
            "url": domain + endpoint,
          },
        );
      } catch (e) {
        rethrow;
      }
    } else {
      throw CannotAccessException();
    }

    return result;
  }
}

/// The URL given is not a valid Google Play Store game link.
class InvalidGooglePlayGameURLException implements Exception {}

/// Cannot access the Internet or not available
/// in the given geographical location.
class CannotAccessException implements Exception {}