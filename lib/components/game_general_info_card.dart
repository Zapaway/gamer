import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gamer/models/game_model.dart';
import 'package:gamer/shared/consts.dart';

/// A card containing all general info about a game.
class GameGeneralInfoCard extends StatelessWidget {
  final VoidCallback onTap;
  final ImageProvider gameIconProvider;
  final String name;
  final String publisher;
  final int amountOfReviews;
  final double averageGameplayStars;
  final double averagePlayabilityStars;
  final double averageVisualsStars;
  final GameCategoriesModel categories;

  double get averageRating => (
    averageGameplayStars + averagePlayabilityStars + averageVisualsStars
  ) / 3;

  const GameGeneralInfoCard({
    Key? key,
    required this.onTap,
    required this.gameIconProvider,
    required this.name,
    required this.publisher,
    required this.amountOfReviews,
    required this.averageGameplayStars,
    required this.averagePlayabilityStars,
    required this.averageVisualsStars,
    required this.categories
  }) : super(key: key);

  /// [Chip] does not handle height well, so making a custom chip
  /// will allow for any size.
  Widget makeCustomCategoryChip(String category) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 20,
        padding:
        const EdgeInsets.symmetric(horizontal: 10),
        color: AppColors.darkTurquoise,
        child: Center(
          child: Text(
            category,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Container(
            height: 145,
            decoration: BoxDecoration(
              color: AppColors.darkGrey.withOpacity(0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundImage: gameIconProvider,
                      radius: 50,
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 2,
                          ),
                          Text(
                            publisher,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis),
                          ),

                          const SizedBox(
                            height: 3,
                          ),

                          // stats
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // rating //
                              SvgPicture.asset(
                                "assets/colored_star.svg",
                                height: 15,
                              ),
                              const SizedBox(
                                width: 1,
                              ),
                              Text(
                                averageRating.toStringAsPrecision(2),
                                style: const TextStyle(color: Colors.white),
                              ),

                              const SizedBox(
                                width: 7.5,
                              ),

                              // amount of reviews //
                              SvgPicture.asset(
                                "assets/pencil.svg",
                                height: 15,
                              ),
                              const SizedBox(
                                width: 2.5,
                              ),
                              Text(
                                amountOfReviews.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // categories
                          Row(
                            children: [
                              makeCustomCategoryChip(categories.genre),
                              const SizedBox(width: 5,),
                              makeCustomCategoryChip(categories.ageRating),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
