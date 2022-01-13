import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamer/components/forms/five_stars_form_field.dart';
import 'package:gamer/components/forms/submit_form_button.dart';
import 'package:gamer/components/wrappers/keyboard_dismissible.dart';
import 'package:gamer/components/forms/text_form_field.dart';
import 'package:gamer/components/drag_bar.dart';
import 'package:gamer/components/wrappers/no_scrollable_indicator_config.dart';
import 'package:gamer/models/user_model.dart';
import 'package:gamer/models/user_review_model.dart';
import 'package:gamer/providers/user_review_data_on_game_provider_wrapper.dart';
import 'package:gamer/providers/user_related_providers.dart';
import 'package:gamer/services/database_service.dart';
import 'package:gamer/shared/consts.dart';

class CurrUserReviewSubmitForm extends ConsumerStatefulWidget {
  final String gameID;

  const CurrUserReviewSubmitForm({
    Key? key,
    required this.gameID,
  }) : super(key: key);

  @override
  _CurrUserReviewSubmitFormState createState() => _CurrUserReviewSubmitFormState();
}

class _CurrUserReviewSubmitFormState extends ConsumerState<CurrUserReviewSubmitForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();
  static const _starsLabelStyle = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static const _reviewCharacterCap = 500;

  // form values
  int _gameplayStars = 0;
  int _playabilityStars = 0;
  int _visualsStars = 0;
  String? _review;

  // check if the user review can be posted/updated
  // (do not let the user post with invalid values, or update with same values
  // as prev review)
  bool _canSubmit = false;
  bool? _inPostMode;  // if false, it is update mode; if null, in no mode

  /// Sees if the form can be submitted based on the mode and
  /// changes [_canSubmit] accordingly.
  void _checkIfCanSubmit(UserReviewModel? currReview) {
    bool _starsExactlyMatch(UserReviewModel currReview) => (
      _gameplayStars == currReview.gameplayStars &&
      _playabilityStars == currReview.playabilityStars &&
      _visualsStars == currReview.visualsStars
    );
    bool _starsAreEmpty() => (
      _gameplayStars < 1 ||
      _playabilityStars < 1 ||
      _visualsStars < 1
    );

    if (_inPostMode == null) {
      _canSubmit = false;
    }
    else if (_inPostMode!) {  // currReview would have to be null
      _canSubmit = !_starsAreEmpty();
    }
    else {
      // handling the update mode / curr (currReview should not be null here)
      currReview = currReview!;

      if (currReview.review == null || (currReview.review?.isEmpty ?? true)) {
        if (_review == null || (_review?.isEmpty ?? true)) {
          // if there is no review, as long as the stars do not match
          _canSubmit = !_starsExactlyMatch(currReview);
        }
        else {
          // if there is a review & before there wasn't, then it is ok
          _canSubmit = true;
        }
      }
      else {
        // either the amount of stars or the exact text has to change
        _canSubmit = _review != currReview.review
          || !_starsExactlyMatch(currReview);
      }

      // ensure that the user cannot submit an empty form
      _canSubmit = _canSubmit && !_starsAreEmpty();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currUserDataModel = ref.watch(currUserDataStreamProvider);
    final currUserReviewModel = ref.watch(alwaysUpdateCurrUserReviewFutureProvider(
        widget.gameID));

    final cachedUserPfp = ref.watch(currUserPfpIconFutureProvider);

    // create a five star form field with auto validation
    Widget _createFiveStarFormField(
        String label, void Function(int?)? updater, {int initStars = 0}
        ) {
      return SizedBox(
        height: 35,
        child: FiveStarsFormField(
          spacing: 3,
          width: 35,
          initStars: initStars,
          label: Flexible(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  label,
                  style: _starsLabelStyle,
                ),
              ),
            ),
          ),
          rowAxisAlignment: MainAxisAlignment.spaceBetween,
          onSavedCallback: (x) {
            updater?.call(x);
            // curr review at the time
            _checkIfCanSubmit(currUserReviewModel.asData?.value);
          },
        ),
      );
    }

    return KeyboardDismissible(
      child: Scaffold(
        appBar: AppBarWithOnlyDragBar(),
        backgroundColor: Colors.grey[900],
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10,),
          child: NoScrollableIndicatorConfig(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: CircleAvatar(
                      backgroundImage: cachedUserPfp.asData?.value
                        ?? UserDataModel.defaultPfpProvider,
                      radius: 50,
                    ),
                  ),

                  const SizedBox(height: 25,),

                  Form(
                    key: _formKey,
                    onChanged: () {
                      _formKey.currentState?.save();
                      setState(() {});
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _createFiveStarFormField("Gameplay", (value) {
                                _gameplayStars = value ?? 0;
                              }, initStars: _gameplayStars),
                              const SizedBox(height: 5,),
                              _createFiveStarFormField("Playability", (value) {
                                _playabilityStars = value ?? 0;
                              }, initStars: _playabilityStars),
                              const SizedBox(height: 5,),
                              _createFiveStarFormField("Visuals", (value) {
                                _visualsStars = value ?? 0;
                              }, initStars: _visualsStars),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25,),

                        RawScrollbar(
                          crossAxisMargin: 10,
                          mainAxisMargin: 15,
                          radius: const Radius.circular(25),
                          controller: _scrollCtrl,
                          child: AppTextFormField(
                            initValue: _review,
                            scrollController: _scrollCtrl,
                            hintText: "Enter description here (optional)",
                            darkMode: false,
                            autoCorrect: true,
                            lines: 5,
                            onChanged: (x) {
                              if (x?.isEmpty ?? true) {
                                _review = null;
                              } else {
                                _review = x;
                              }
                            },
                            counterLabel: "/$_reviewCharacterCap",
                            formatters: [
                              LengthLimitingTextInputFormatter(
                                _reviewCharacterCap
                              ),
                            ],
                            validator: (x) {

                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: UserReviewDataOnGameProviderWrapper(
                          userDataModelAsync: currUserDataModel,
                          userReviewModelAsync: currUserReviewModel,
                          gameID: widget.gameID,

                          success: (userData, currReview) {
                            final userModel = userData.user;

                            // either in post or update mode
                            _inPostMode = currReview == null;
                            _checkIfCanSubmit(currReview);

                            return AppSubmitFormButton(
                              text: _inPostMode! ? "Post" : "Update",
                              color: Colors.green,
                              disabledColor: AppColors.grey,
                              isBolded: true,
                              onPressed: !_canSubmit ? null : () async {
                                DatabaseService(
                                    userModel: userModel
                                ).setUserReview(
                                  UserReviewModel(
                                      createdOn: DateTime.now(),
                                      gameID: widget.gameID,
                                      userID: userModel.uid,
                                      gameplayStars: _gameplayStars,
                                      playabilityStars: _playabilityStars,
                                      visualsStars: _visualsStars,
                                      review: _review
                                  )..id = currReview?.id,
                                );
                              },
                            );
                          },
                          error: () {
                            _inPostMode = null;
                            return const Text(
                              "An error has occurred. Please try again later.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            );
                          },
                          loading: () {
                            _inPostMode = null;
                            return const Text(
                              "Loading...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
