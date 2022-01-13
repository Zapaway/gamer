import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gamer/components/game_category_chip.dart';
import 'package:gamer/components/game_review_card.dart';
import 'package:gamer/components/drag_bar.dart';
import 'package:gamer/models/non_json_annotated/all_game_review_data_model.dart';
import 'package:gamer/models/game_model.dart';
import 'package:gamer/models/user_model.dart';
import 'package:gamer/providers/user_review_data_on_game_provider_wrapper.dart';
import 'package:gamer/providers/game_related_providers.dart';
import 'package:gamer/providers/user_related_providers.dart';
import 'package:gamer/screens/app/game_info/curr_user_review_submit_form.dart';
import 'package:gamer/screens/loading.dart';
import 'package:gamer/shared/consts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// TODO fix scrolling issue

class GameInfo extends ConsumerStatefulWidget {
  /// Used for caching expensive game data that needs to be retrieved
  /// quickly on first build.
  final String gameID;

  const GameInfo({
    Key? key,
    required this.gameID,
  }) : super(key: key);

  @override
  _GameInfoState createState() => _GameInfoState();
}

class _GameInfoState extends ConsumerState<GameInfo> {
  static const BorderRadius _panelRadius = BorderRadius.only(
    topLeft: Radius.circular(25),
    topRight: Radius.circular(25),
  );
  static const double _panelPadding = 250;

  final _currUserReviewScrollCtrl = ScrollController();
  final _gameInfoScrollCtrl = ScrollController();
  double _gameInfoScrollPos = 0;

  // when gameModel has data, then switch this off
  bool _isFirstLoading = true;

  // provider to keep track of general game info (e.g. reviews, average stars)
  final _allUserReviewProvider = getUserReviewModelListOnGameController();

  @override
  Widget build(BuildContext context) {
    if (_gameInfoScrollCtrl.hasClients) {
      _gameInfoScrollPos = _gameInfoScrollCtrl.position.pixels;
    }

    // on first load, refresh this to start up the listener
    if (_isFirstLoading) {
      ref.refresh(userReviewModelsOnGameFutureProvider(widget.gameID));
    }

    /// react to any changes in the amount of reviews & individual
    /// review updates
    ref.listen<AsyncValue<List<AllGameReviewDataModel>>>(
      userReviewModelsOnGameFutureProvider(widget.gameID),
      (previous, next) {
        next.when(
          data: (allReviews) {
            ref.read(_allUserReviewProvider.notifier).set(allReviews);
          },

          // do nothing (to keep the previous user reviews)
          error: (_, __) => null,

          // refresh to update the page
          loading: () => ref.refresh(_allUserReviewProvider),
        );
      }
    );

    // current user data
    final currUserDataModel = ref.watch(currUserDataStreamProvider);
    final currUserReviewModel = ref.watch(
      alwaysUpdateCurrUserReviewFutureProvider(widget.gameID));

    // game data
    final gameDataModel = ref.watch(gameDataStreamProvider(widget.gameID));
    final gameReviews = ref.watch(_allUserReviewProvider);

    // cached data that is fetched on change (not on every rebuild)
    final cachedCurrUserPfp = ref.watch(currUserPfpIconFutureProvider);
    final cachedGameIcon = ref.watch(gameIconFutureProvider(widget.gameID));

    if (_isFirstLoading && gameDataModel.asData?.value == null) {
      return const Loading();
    } else {
      _isFirstLoading = false;

      // ensures that the game info scroll position will always be maintained
      // throughout builds
      Future.delayed(Duration.zero, () {
        if (_gameInfoScrollCtrl.hasClients) {
          _gameInfoScrollCtrl.jumpTo(_gameInfoScrollPos);
        }
      });

      return Container(
      decoration: AppColors.reverseBackgroundGradient,
      child: SlidingUpPanel(
        minHeight: _panelPadding,
        maxHeight: MediaQuery.of(context).size.height * 0.70,
        backdropEnabled: true,
        borderRadius: _panelRadius,
        onPanelSlide: (pos) {
          FocusManager.instance.primaryFocus?.unfocus();
        },

        // Refreshes panel and collapse widget (ensures touches are registered).
        onPanelOpened: () => setState(() {}),
        onPanelClosed: () => setState(() {}),

        // user review of the game
        collapsed: ClipRRect(
          borderRadius: _panelRadius,
          child: Scaffold(
            backgroundColor: Colors.grey[900],
            appBar: AppBarWithOnlyDragBar(),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Center(
                child: RawScrollbar(
                  crossAxisMargin: -12.5,
                  mainAxisMargin: 12.5,
                  radius: const Radius.circular(25),
                  controller: _currUserReviewScrollCtrl,
                  isAlwaysShown: true,
                  thumbColor: Colors.white70,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    controller: _currUserReviewScrollCtrl,
                    child: Column(
                      children: [
                        UserReviewDataOnGameProviderWrapper.maybeWhen(
                          userDataModelAsync: currUserDataModel,
                          userReviewModelAsync: currUserReviewModel,
                          gameID: widget.gameID,

                          success: (userData, currUserReview) {
                            return GameReviewCard(
                              leadingImage: cachedCurrUserPfp.asData?.value
                                ?? UserDataModel.defaultPfpProvider,
                              title: userData.username,
                              gameplayStars: currUserReview
                                ?.gameplayStars ?? 0,
                              playabilityStars: currUserReview
                                ?.playabilityStars ?? 0,
                              visualsStars: currUserReview
                                ?.visualsStars ?? 0,
                              review: currUserReview?.review,
                              leadingImageWidth: 45
                            );
                          },
                          orElse: () => const CircularProgressIndicator(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        panel: ClipRRect(
          borderRadius: _panelRadius,
          child: CurrUserReviewSubmitForm(gameID: widget.gameID,)
        ),

        // all game info and its reviews
        body: gameDataModel.maybeWhen(
          data: (gameData) {
            return Padding(
              padding: const EdgeInsets.only(bottom: _panelPadding),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,

                appBar: AppBar(
                  leading: Container(
                    margin: const EdgeInsets.all(10),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      iconSize: 40,
                      padding: const EdgeInsets.all(2.5),
                      color: Colors.black,
                    ),
                  ),
                  title: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: gameData.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                          TextSpan(
                            text: "\n${gameData.publisher}",
                            style: const TextStyle(
                              fontSize: 18,
                              overflow: TextOverflow.clip,
                            ),
                          )
                        ],
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  toolbarHeight: 100,
                ),

                body: SingleChildScrollView(
                  controller: _gameInfoScrollCtrl,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        _GameInfoDescription(
                          thumbnailProvider: cachedGameIcon.asData?.value
                              ?? GameModel.cannotLoadGameIconProvider,
                          desc: gameData.desc,
                          categories: gameData.categories,
                        ),

                        Container(
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            child: _GameRatings(
                              amountOfReviews: gameReviews.amountOfReviews,
                              averageGameplayStars: gameReviews
                                .averageGameplayStars,
                              averagePlayabilityStars: gameReviews
                                .averagePlayabilityStars,
                              averageVisualsStars: gameReviews
                                .averageVisualsStars,
                            )
                        ),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Reviews",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // realtime list of game reviews
                        gameReviews.amountOfReviews == 0
                        ? const Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              "There are currently no reviews.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16
                              ),
                            ),
                          ),
                        )
                        : SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: gameReviews.amountOfReviews,
                            itemBuilder: (context, i) {
                              final userReviewData = gameReviews.allReviews[i];
                              final userReview = userReviewData.userReview;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                child: GameReviewCard(
                                  leadingImage: userReviewData.userPfpProvider,
                                  title: userReviewData.userData.username,
                                  review: userReview.review,
                                  gameplayStars: userReview.gameplayStars,
                                  playabilityStars: userReview.playabilityStars,
                                  visualsStars: userReview.visualsStars,
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          orElse: () => const LinearProgressIndicator(),
        ),
      ),
    );
    }
  }

  @override
  void dispose() {
    _gameInfoScrollCtrl.dispose();
    _currUserReviewScrollCtrl.dispose();
    super.dispose();
  }
}

/// Includes basic information about a game.
class _GameInfoDescription extends StatelessWidget {
  final ImageProvider thumbnailProvider;
  final String desc;
  final GameCategoriesModel categories;
  static const double imageWidth = 135;
  static const double vertSpacingBetweenGameIconAndCategoriesCol = 2.5;

  const _GameInfoDescription({
    Key? key,
    required this.thumbnailProvider,
    required this.desc,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryList = categories
      .toJson()
      .values
      .map((e) => e as String)
      .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            /// game icon
            ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                width: imageWidth,
                child: Image(image: thumbnailProvider,),
              ),
            ),

            const SizedBox(
              height: vertSpacingBetweenGameIconAndCategoriesCol,
            ),

            /// game categories
            SizedBox(
              width: imageWidth,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: vertSpacingBetweenGameIconAndCategoriesCol
                    ),
                    child: GameCategoryChip(category: categoryList[index],),
                  );
                },
              ),
            )
          ],
        ),

        const SizedBox(width: 15,),

        /// game desc
        Expanded(
          flex: 3,
          child: Text(
            desc,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }
}

/// Includes the average amount of stars the game has
/// and its review count.
class _GameRatings extends StatelessWidget {
  static final backgroundDecoration = BoxDecoration(
    color: AppColors.transparentWhite,
    borderRadius: BorderRadius.circular(10),
  );

  final int amountOfReviews;
  final double averageGameplayStars;
  final double averagePlayabilityStars;
  final double averageVisualsStars;

  const _GameRatings({
    Key? key,
    required this.amountOfReviews,
    required this.averageGameplayStars,
    required this.averagePlayabilityStars,
    required this.averageVisualsStars
  }) : super(key: key);

  Widget _averageStarRatingsWidget(double averageRating, String category
      ) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SvgPicture.asset(
            "assets/colored_star.svg",
            width: 50,
          ),
          const SizedBox(height: 5,),
          Text(
            averageRating.toStringAsPrecision(2),
            style: const TextStyle(
              fontSize: 30,
              color: Colors.white
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            category,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _GameRatings.backgroundDecoration,
      height: MediaQuery.of(context).size.height * 0.15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          /// stars
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _averageStarRatingsWidget(averageGameplayStars, "Gameplay"),
                  _averageStarRatingsWidget(averagePlayabilityStars, "Playability"),
                  _averageStarRatingsWidget(averageVisualsStars, "Visuals"),
                ],
              ),
            ),
          ),
          /// number of reviews
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.transparentWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/pencil.svg",
                    width: 50,
                  ),
                  const SizedBox(height: 5,),
                  Text(
                    "$amountOfReviews",
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//
// class _GameRatingsState extends State<_GameRatings> {
//   /// Creates the widget for the rating categories.
//
// }