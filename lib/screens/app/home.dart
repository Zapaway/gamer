import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamer/components/drag_bar.dart';
import 'package:gamer/components/game_review_card.dart';
import 'package:gamer/models/game_model.dart';
import 'package:gamer/models/user_model.dart';
import 'package:gamer/models/user_review_model.dart';
import 'package:gamer/providers/game_related_providers.dart';
import 'package:gamer/providers/user_related_providers.dart';
import 'package:gamer/screens/app/game_info/game_info.dart';
import 'package:gamer/services/auth_service.dart';
import 'package:gamer/shared/consts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/// Shows current user profile and their reviews.
class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  static const _panelRadius = BorderRadius.vertical(top: Radius.circular(20));

  UserDataModel? userDataModel;
  String? get userBio {
    if (userDataModel == null) {
      return "---";  // error or loading
    }
    else {
      return userDataModel!.desc;  // null = no bio
    }
  }

  @override
  Widget build(BuildContext context) {
    final cachedUserPfpAsync = ref.watch(currUserPfpIconFutureProvider);
    userDataModel = ref.watch(currUserDataStreamProvider).asData?.value;

    return Container(
      decoration: AppColors.reverseBackgroundGradient,
      child: SlidingUpPanel(
        minHeight: 200,
        maxHeight: MediaQuery.of(context).size.height * 0.75,
        backdropEnabled: true,
        borderRadius: _panelRadius,
        onPanelSlide: (pos) {
          FocusManager.instance.primaryFocus?.unfocus();
        },

        // Refreshes panel and collapse widget (ensures touches are registered).
        onPanelOpened: () => setState(() {}),

        body: SingleChildScrollView(
          child: Column(
            children: [
              // logout button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.logout_outlined,),
                  iconSize: 50,
                  color: AppColors.darkGreen,
                  padding: const EdgeInsets.only(right: 10, top: 20),
                  onPressed: () async => await AuthService().signOut(),
                ),
              ),

              // profile picture
              CircleAvatar(
                backgroundImage: cachedUserPfpAsync.asData?.value
                  ?? UserDataModel.defaultPfpProvider,
                minRadius: 30,
                maxRadius: 75,
              ),

              const SizedBox(height: 5,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    // username
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        userDataModel?.username ?? "---",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 3,),

                    // bio
                    Text(
                      userBio ?? "No bio yet.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontStyle: userBio != null
                          ? FontStyle.normal
                          : FontStyle.italic
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),

        collapsed: ClipRRect(
          borderRadius: _panelRadius,
          child: Scaffold(
            backgroundColor: AppColors.darkGrey,
            appBar: AppBarWithOnlyDragBar(),
            body: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Your Reviews",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        ),

        isDraggable: userDataModel != null,
        panel: ClipRRect(
          borderRadius: _panelRadius,
          child: userDataModel != null
            ? _CurrentUserReviewsPanel(userModel: userDataModel!.user,)
            : Container()
        ),
      ),
    );
  }
}

class _CurrentUserReviewsPanel extends ConsumerWidget {
  final scrollController = ScrollController();
  final UserModel userModel;

  late final currUserReviewsStreamProvider =
    getUserReviewsStreamProvider(userModel);

  _CurrentUserReviewsPanel({
    Key? key,
    required this.userModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currUserReviewsAsync = ref.watch(currUserReviewsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.darkGrey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,

        title: Column(
          children: const [
            DragBar(),
            SizedBox(height: 10,),
            Text(
              "Reviews",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30
              ),
            )
          ],
        ),
      ),

      body: currUserReviewsAsync.when(
        data: (allCurrUserReviews) {
          if (allCurrUserReviews.isEmpty) {
            return const Center(
              child: Text(
                "Start reviewing some games!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontStyle: FontStyle.italic
                ),
                textAlign: TextAlign.center,
              )
            );
          }

          return RawScrollbar(
            radius: const Radius.circular(10),
            mainAxisMargin: 10,
            crossAxisMargin: 5,
            thickness: 8,
            isAlwaysShown: true,
            interactive: true,
            controller: scrollController,
            child: ListView.separated(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.only(top: 10, right: 30, bottom: 110),
              itemCount: allCurrUserReviews.length,
              itemBuilder: (context, i) {
                return _CustomCurrentUserReviewCard(
                  userReviewModel: allCurrUserReviews[i],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(
                height: 10,
              ),
            ),
          );
        },
        error: (_, __) => const Center(
          child: Text(
            "Could not load in reviews. Please try again later.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontStyle: FontStyle.italic
            ),
          )
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 5,
          )
        )
      ),
    );
  }
}

class _CustomCurrentUserReviewCard extends ConsumerWidget {
  final UserReviewModel userReviewModel;
  String get userID => userReviewModel.userID;
  String get gameID => userReviewModel.gameID;
  String get userReviewID => userReviewModel.id!;

  late final userReviewFutureProvider =
    getUserReviewOnGameStreamProvider(UserModel(uid: userID), userReviewID);

  _CustomCurrentUserReviewCard({
    Key? key,
    required this.userReviewModel
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userReviewAsync = ref.watch(userReviewFutureProvider);

    final cachedGameIconAsync = ref.watch(gameIconFutureProvider(gameID));
    final gameName = ref.watch(gameDataStreamProvider(gameID).select(
      (value) => value.maybeWhen(
        data: (x) => x.name,
        orElse: () => null
      )
    ));

    return GestureDetector(
      onTap: () async => await pushNewScreen(
        context, screen: GameInfo(gameID: gameID), withNavBar: false
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
        child: Container(
          padding: const EdgeInsets.all(10),
          color: AppColors.almostBlack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gameName ?? "(Loading...)",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              ),
              userReviewAsync.when(
                data: (userReview) => GameReviewCard(
                  leadingImage: cachedGameIconAsync.asData?.value
                    ?? GameModel.cannotLoadGameIconProvider,
                  leadingImageWidth: 50,
                  gameplayStars: userReview.gameplayStars,
                  playabilityStars: userReview.playabilityStars,
                  visualsStars: userReview.visualsStars,
                  review: userReview.review,
                  categoryHeight: 25,
                  categoryWidth: double.maxFinite,
                  starWidth: 25,
                ),
                error: (_, __) => const Text(
                  "Could not load review.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                loading: () => const CircularProgressIndicator()
              ),
            ],
          ),
        ),
      ),
    );
  }
}
