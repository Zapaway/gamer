import 'package:flutter/material.dart';
import 'package:gamer/shared/consts.dart';
import 'forms/five_stars_form_field.dart';

/// UI for all game reviews.
/// Automatically determines if the review is fresh or not.
class GameReviewCard extends StatelessWidget {
  final ImageProvider leadingImage;
  final double leadingImageWidth;
  final String? title;
  final int gameplayStars;
  final int playabilityStars;
  final int visualsStars;
  final String? review;
  final double categoryWidth;
  final double categoryHeight;
  final double starWidth;

  const GameReviewCard({
    Key? key,
    required this.leadingImage,
    required this.gameplayStars,
    required this.playabilityStars,
    required this.visualsStars,
    this.title,
    this.review,
    this.leadingImageWidth = 35,
    this.categoryWidth = 177.5,
    this.categoryHeight = 22.5,
    this.starWidth = 20,
  }) : super(key: key);

  bool get freshReview => gameplayStars < 1
    && playabilityStars < 1
    && visualsStars < 1;

  Widget _createStarsForReview(String label, int stars, Color color) {
    return SizedBox(
      width: categoryWidth,
      height: categoryHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: color,
                  padding: const EdgeInsets.all(5),
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          FiveStarsFormField(
            enabled: false,
            initStars: stars,
            width: starWidth,
            spacing: 1,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: CircleAvatar(
            backgroundImage: leadingImage,
            minRadius: leadingImageWidth,
          ),
        ),

        const SizedBox(width: 10,),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) Text(
                title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 5,),

              Column(
                children: [
                  _createStarsForReview("Gameplay", gameplayStars, Colors.red),
                  _createStarsForReview("Playability", playabilityStars, Colors.yellow.shade800),
                  _createStarsForReview("Visuals", visualsStars, AppColors.turquoise),
                ],
              ),

              const SizedBox(height: 5,),

              Text(
                review ?? (
                  freshReview ? "You have not posted a review yet." : "None."),
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: review != null
                    ? FontStyle.normal
                    : FontStyle.italic,
                  color: Colors.white,
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
