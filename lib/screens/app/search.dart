import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer/components/game_general_info_card.dart';
import 'package:gamer/components/wrappers/keyboard_dismissible.dart';
import 'package:gamer/models/game_model.dart';
import 'package:gamer/models/non_json_annotated/all_game_general_info_data_model.dart';
import 'package:gamer/providers/game_related_providers.dart';
import 'package:gamer/providers/game_reviews_notifier.dart';
import 'package:gamer/services/database_service.dart';
import 'package:gamer/services/scrapers/game_already_exists_exception.dart';
import 'package:gamer/services/scrapers/google_play_scraper.dart';
import 'package:gamer/services/storage_service.dart';
import 'package:gamer/shared/consts.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'game_info/game_info.dart';

/// Screen providing the user the ability to search for the game
/// they want to review.
class Search extends ConsumerStatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  ConsumerState<Search> createState() => _SearchState();
}

class _SearchState extends ConsumerState<Search> {
  final _searchBarCtrl = FloatingSearchBarController();

  // keep track of search history
  static const _historyLimit = 10;
  String _currSearchQuery = ""; // keeps track of what's in the search bar
  final _searchHistory = <String>[];

  void _addToHistory(String query) {
    if (_searchHistory.length == _historyLimit) {
      _searchHistory.removeLast();
    }
    _searchHistory.insert(0, query);
    _searchBarCtrl.close();
    setState(() {});
    ref.read(_queryStateProvider.notifier).state = query;
  }

  // used for notifying when to search for results
  final _queryStateProvider = StateProvider<String?>((ref) => null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppColors.reverseBackgroundGradient,
        child: FloatingSearchBar(
          controller: _searchBarCtrl,
          isScrollControlled: true,
          accentColor: Colors.white,
          backgroundColor: AppColors.darkGrey,
          backdropColor: AppColors.darkGrey,
          margins: const EdgeInsets.fromLTRB(22, 20, 22, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 50,
          borderRadius: BorderRadius.circular(36),
          hint: "Search by game title",
          hintStyle: const TextStyle(fontSize: 18, color: Colors.white),
          queryStyle: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
          iconColor: Colors.white,
          transition: ExpandingFloatingSearchBarTransition(),
          transitionDuration: const Duration(milliseconds: 500),
          clearQueryOnClose: false,
          leadingActions: [
            FloatingSearchBarAction.back(),
            if (ref.read(_queryStateProvider.notifier).state != null)
              FloatingSearchBarAction.icon(
                  // go back to main menu
                  showIfClosed: true,
                  showIfOpened: false,
                  icon: Icons.home,
                  onTap: () {
                    ref.read(_queryStateProvider.notifier).state = null;
                    setState(() {});
                  }),
          ],
          actions: [
            FloatingSearchBarAction.icon(
              // search icon to open search
              showIfClosed: true,
              showIfOpened: false,
              icon: Icons.search,
              onTap: () => _searchBarCtrl.open(),
            ),
            if (_currSearchQuery.isNotEmpty)
              FloatingSearchBarAction.icon(
                // clear icon to clear query
                showIfClosed: false,
                showIfOpened: true,
                icon: Icons.clear,
                onTap: () => _searchBarCtrl.clear(),
              ),
          ],

          onQueryChanged: (query) => setState(() => _currSearchQuery = query),
          onSubmitted: (_) {
            _currSearchQuery = _currSearchQuery.trim();
            if (_currSearchQuery.isEmpty) return; // needs to be valid

            final index = _searchHistory.indexOf(_currSearchQuery);
            if (index != -1) {
              // reorder the history
              _searchHistory.removeAt(index);
            }

            _addToHistory(_currSearchQuery);
          },

          // search history
          builder: (context, transition) {
            return KeyboardDismissible(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                  child: ListView.builder(
                      itemCount:
                          _currSearchQuery.isEmpty ? _searchHistory.length : 0,
                      itemBuilder: (context, i) {
                        return ListTile(
                          onTap: () {
                            _currSearchQuery = _searchHistory[i];
                            _searchHistory.removeAt(i);

                            _searchBarCtrl.query = _currSearchQuery;
                            _addToHistory(_currSearchQuery);
                          },
                          leading: const Icon(
                            Icons.history,
                            color: AppColors.grey,
                          ),
                          title: Text(
                            _searchHistory[i],
                            style: const TextStyle(
                                fontSize: 20, color: AppColors.grey),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.grey,
                            ),
                            onPressed: () {
                              _searchHistory.removeAt(i);
                              setState(() {});
                            },
                          ),
                        );
                      }),
                ),
              ),
            );
          },

          body: FloatingSearchBarScrollNotifier(
            child: Container(
              decoration: AppColors.reverseBackgroundGradient,
              child: _SearchResults(
                queryStateProvider: _queryStateProvider,
                searchBarController: _searchBarCtrl,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchBarCtrl.dispose();
    super.dispose();
  }
}

/// Search results that can be refreshed to update.
class _SearchResults extends ConsumerWidget {
  final StateProvider<String?> queryStateProvider;
  final FloatingSearchBarController searchBarController;

  /// Performs a game collection query one time.
  /// Uses basic search technique where it checks if the game title
  /// starts with the query.
  /// In the future, use advanced text-search using services like Algolia.
  final queryResultsFutureProvider = FutureProvider.autoDispose
      .family<List<GameModel>, String>((ref, query) async {
    final queryLower = query.replaceAll(RegExp(r"\s"), "").toLowerCase();

    final queryResult = await DatabaseService.gamesCollection
        .where("nameLower", isGreaterThanOrEqualTo: queryLower)
        .where("nameLower", isLessThan: queryLower + "\uf7ff")
        .get();
    return queryResult.docs.map((e) => GameModel.fromFirestore(e)).toList();
  });
  final gameGeneralInfoFutureProvider = FutureProvider.autoDispose
      .family<AllGameGeneralInfoDataModel, String>((ref, gameID) async {
    final gameIconFut = ref.watch(gameIconFutureProvider(gameID).future);
    final gameDataFut = ref.watch(gameDataStreamProvider(gameID).future);
    final userReviewsFut =
        ref.watch(userReviewModelsOnGameFutureProvider(gameID).future);

    final gameReviews = GameReviews(allReviews: await userReviewsFut);
    return AllGameGeneralInfoDataModel(
      gameIconProvider: await gameIconFut,
      gameModel: await gameDataFut,
      amountOfReviews: gameReviews.amountOfReviews,
      averageGameplayStars: gameReviews.averageGameplayStars,
      averagePlayabilityStars: gameReviews.averagePlayabilityStars,
      averageVisualsStars: gameReviews.averageVisualsStars,
    );
  });

  _SearchResults({
    Key? key,
    required this.queryStateProvider,
    required this.searchBarController,
  }) : super(key: key);

  /// Wrapper that performs the query [queryResultsFutureProvider] again
  /// if it refreshes.
  Widget wrapWithRefresher({
    required Widget child,
    required WidgetRef ref,
    required String query,
    bool hideSearchBar = false,
  }) {
    return RefreshIndicator(
      color: AppColors.turquoise,
      edgeOffset: 45,
      onRefresh: () async {
        // visual effect
        if (hideSearchBar) searchBarController.hide();
        await Future.delayed(const Duration(seconds: 2));
        if (hideSearchBar) searchBarController.show();

        await ref.refresh(queryResultsFutureProvider(query).future);
      },
      child: child,
    );
  }

  /// Wrapper that enables scroll behavior for widgets that only take up
  /// the entire screen (bounded height of the screen's height).
  Widget wrapWithScrollBehavior(
      {required BuildContext context, required Widget child}) {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: child,
        ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(queryStateProvider);

    if (query == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(
            Icons.search,
            size: 100,
            color: Colors.white,
          ),
          Text(
            "Search for a game",
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          _AddGameButton(),
        ],
      );
    } else {
      final listOfGameModelsAsync =
          ref.watch(queryResultsFutureProvider(query));

      return listOfGameModelsAsync.when(data: (gameModels) {
        return wrapWithRefresher(
          ref: ref,
          query: query,
          child: gameModels.isEmpty
              ? wrapWithScrollBehavior(
                  context: context,
                  child: Column(
                    // do not display a list but a no results widget
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.error,
                        size: 100,
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "No results. Please try different keywords",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: gameModels.length,
                  padding: const EdgeInsets.only(
                      // used to avoid the search bar covering it
                      top: 80,

                      // the height of the bottom nav bar in app.dart
                      bottom: 100),
                  itemBuilder: (context, i) {
                    final gameID = gameModels[i].id!;
                    final gameInfoAsync =
                        ref.watch(gameGeneralInfoFutureProvider(gameID));

                    return gameInfoAsync.when(
                      data: (gameInfo) {
                        final gameModel = gameInfo.gameModel;
                        return GameGeneralInfoCard(
                          onTap: () async {
                            // setState() error will appear but this is normal
                            await pushNewScreen(context,
                                screen: GameInfo(
                                  gameID: gameID,
                                ),
                                withNavBar: false);
                          },
                          gameIconProvider: gameInfo.gameIconProvider,
                          name: gameModel.name,
                          publisher: gameModel.publisher,
                          amountOfReviews: gameInfo.amountOfReviews,
                          averageGameplayStars: gameInfo.averageGameplayStars,
                          averagePlayabilityStars:
                              gameInfo.averagePlayabilityStars,
                          averageVisualsStars: gameInfo.averageVisualsStars,
                          categories: gameModel.categories,
                        );
                      },
                      // TODO Add error and loading widgets
                      error: (_, __) => const CircularProgressIndicator(),
                      loading: () => const CircularProgressIndicator(),
                    );
                  },
                  separatorBuilder: (context, i) {
                    return const SizedBox(
                      height: 10,
                    );
                  },
                ),
        );
      }, error: (_, __) {
        return wrapWithRefresher(
          ref: ref,
          query: query,
          child: wrapWithScrollBehavior(
            context: context,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.broken_image,
                  size: 100,
                  color: Colors.white,
                ),
                Text(
                  "An error occurred. Try refreshing",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        );
      }, loading: () {
        return const Center(
          child: SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 10,
            ),
          ),
        );
      });
    }
  }
}

enum _AddingGameDialogState { Start, Loading, Error, Success }

/// Button that allows the user to add a game for anyone to review.
/// Currently only supports Google Play Store games.
class _AddGameButton extends StatefulWidget {
  static const fontSizeDesc = 16.0;
  static const accentColor = Colors.white;

  const _AddGameButton({
    Key? key,
  }) : super(key: key);

  @override
  State<_AddGameButton> createState() => _AddGameButtonState();
}

class _AddGameButtonState extends State<_AddGameButton> {
  _AddingGameDialogState _dialogState = _AddingGameDialogState.Start;
  String _googlePlayUrl = "";

  // if the dialog state is succeed, then allow the user to see the newly
  // formed game page
  String _gameNameResult = "";
  String _gameIDResult = "";

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(
        Icons.add,
      ),
      label: const Text(
        "Or add a game",
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return KeyboardDismissible(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    final Widget dialogScreen;
                    final List<Widget> dialogActions;

                    switch (_dialogState) {
                      case _AddingGameDialogState.Start:
                        dialogScreen = Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text.rich(TextSpan(children: [
                              TextSpan(
                                  text:
                                      "Please enter a Google Play game link! ",
                                  style: TextStyle(
                                    color: _AddGameButton.accentColor,
                                    fontSize: _AddGameButton.fontSizeDesc,
                                  )),
                              TextSpan(
                                  text: "More options will be coming soon.",
                                  style: TextStyle(
                                      color: _AddGameButton.accentColor,
                                      fontSize: _AddGameButton.fontSizeDesc,
                                      fontStyle: FontStyle.italic)),
                            ])),
                            const SizedBox(
                              height: 5,
                            ),
                            Form(
                                child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  child: const FaIcon(
                                    FontAwesomeIcons.googlePlay,
                                    size: 20,
                                    color: _AddGameButton.accentColor,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    style: const TextStyle(
                                        color: _AddGameButton.accentColor),
                                    decoration: const InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: _AddGameButton
                                                    .accentColor))),
                                    onChanged: (x) => _googlePlayUrl = x,
                                  ),
                                ),
                              ],
                            ))
                          ],
                        );
                        dialogActions = [
                          TextButton(
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            onPressed: () async {
                              setState(() => _dialogState =
                                  _AddingGameDialogState.Loading);

                              const googlePlayScraper = GooglePlayScraper();
                              try {
                                // attempt to get the data
                                final gameData = await googlePlayScraper
                                    .appFromUrl(url: _googlePlayUrl);
                                _gameNameResult = gameData["title"];

                                // check if it isn't already a duplicate
                                final queryRes = await DatabaseService
                                    .gamesCollection
                                    .where("name", isEqualTo: _gameNameResult)
                                    .get();
                                if (queryRes.docs.isNotEmpty) {
                                  throw GameAlreadyExistsException();
                                }

                                // upload to db
                                _gameIDResult =
                                    await DatabaseService.setGameData(
                                        GameModel(
                                            name: _gameNameResult,
                                            nameLower: _gameNameResult
                                                .split(" ")
                                                .join()
                                                .replaceFirst(
                                                    RegExp("[^a-zA-Z0-9]"), "")
                                                .toLowerCase(),
                                            publisher: gameData["developer"],
                                            desc: gameData["description"],
                                            iconImagePath: "",
                                            categories: GameCategoriesModel(
                                              genre: gameData["genre"],
                                              ageRating:
                                                  gameData["contentRating"],
                                            ))
                                          ..id = null,
                                        gameIconUrl: gameData["icon"]);

                                setState(() => _dialogState =
                                    _AddingGameDialogState.Success);
                              } catch (e) {
                                print(e); // TODO Work on error state.
                              }
                            },
                          ),
                        ];
                        break;
                      case _AddingGameDialogState.Loading:
                        dialogScreen = const LinearProgressIndicator(
                          color: _AddGameButton.accentColor,
                        );
                        dialogActions = [];
                        break;
                      case _AddingGameDialogState.Error:
                        // TODO: Handle this case.
                        dialogScreen = Container();
                        dialogActions = [];
                        break;
                      case _AddingGameDialogState.Success:
                        // TODO: Handle this case.
                        dialogScreen = Container();
                        dialogActions = [];
                        break;
                    }

                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      backgroundColor: AppColors.darkGrey,
                      title: const Text(
                        "Add a game",
                        style: TextStyle(
                            color: _AddGameButton.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      content: dialogScreen,
                      actions: dialogActions,
                    );
                  },
                ),
              );
            });
      },
    );
  }
}
