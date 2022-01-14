import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gamer/models/game_model.dart';
import 'package:gamer/models/game_review_relationship_model.dart';
import 'package:gamer/models/user_model.dart';
import 'package:gamer/models/user_review_model.dart';
import 'package:gamer/services/storage_service.dart';

/// For interacting with the Firestore database.
class DatabaseService {
  final UserModel userModel;
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  DatabaseService({required this.userModel});

  // collections
  static final CollectionReference userDataCollection = db.collection("userData");
  static final CollectionReference gamesCollection = db.collection("games");

  // getters (streams)
  Stream<UserDataModel> get userDataStream => userDataCollection
    .doc(userModel.uid)
    .snapshots()
    .map((event) => UserDataModel.fromFirestore(event));

  Stream<List<UserReviewModel>> getAllUserReviewsStream() {
    return userDataCollection.doc(userModel.uid).collection("reviews")
      .snapshots().map((event) => [
        for (final e in event.docs)
          UserReviewModel.fromFirestore(e)
    ]);
  }

  Stream<UserReviewModel> getUserReviewDataStream(String userReviewID) {
    return userDataCollection.doc(userModel.uid).collection("reviews")
      .doc(userReviewID)
      .snapshots()
      .map((event) => UserReviewModel.fromFirestore(event));
  }

  static Stream<GameModel> getGameDataStream(String gameID) {
    return gamesCollection.doc(gameID).snapshots().map(
      (event) => GameModel.fromFirestore(event)
    );
  }

  /// The keys represent the userID -- [GameReviewRelationshipModel] doc id.
  static Stream<Map<String, GameReviewRelationshipModel>> getGameReviewRelationshipStream(
    String gameID
  ) {
    // get all reviews and cast them into a big map
    return gamesCollection
      .doc(gameID)
      .collection("reviews")
      .snapshots()
      .map(_gameReviewRelationshipQueryToMap);
  }

  // getters (values)
  Future<UserDataModel> getUserData() async {
    return UserDataModel.fromFirestore(await userDataCollection
      .doc(userModel.uid).get()
    );
  }

  Future<UserReviewModel> getUserReviewData(String userReviewID) async {
    return UserReviewModel.fromFirestore(await userDataCollection
      .doc(userModel.uid)
      .collection("reviews")
      .doc(userReviewID)
      .get()
    );
  }

  Future<UserReviewModel?> getUserReviewDataOnGame(String gameID) async {
    final gameReviewRelationships = await getGameReviewRelationships(gameID);
    final relationship = gameReviewRelationships[userModel.uid];
    if (relationship == null) return null;

    return await getUserReviewData(relationship.userReviewID);
  }

  static Future<GameModel> getGameData(String gameID) async {
    return GameModel.fromFirestore(await gamesCollection
        .doc(gameID).get()
    );
  }

  static Future<Map<String, GameReviewRelationshipModel>> getGameReviewRelationships(String gameID) async {
    final query = await gamesCollection
      .doc(gameID)
      .collection("reviews")
      .get();

    return _gameReviewRelationshipQueryToMap(query);
  }

  // setters & updaters (entire)
  Future<void> setUserData(UserDataModel userData, {String? googlePfpUrl}) async {
    // upload photo to firebase storage and add to userData
    if (googlePfpUrl != null) {
      try {
        final filePath =
          await StorageService()
            .uploadUserPfpFromGooglePfpUrl(userData.user.uid, googlePfpUrl);

        userData = UserDataModel(
          username: userData.username,
          level: userData.level,
          desc: userData.desc,
          userPfpPath: filePath
        )..user = userData.user;
      }
      catch (e) {
        print(e);
      }
    }

    await userDataCollection.doc(userModel.uid).set(userData.toJson());
  }

  Future<void> setUserReview(UserReviewModel userReview) async {
    final uid = userReview.userID;

    final userReviewDoc = userDataCollection
      .doc(uid)
      .collection("reviews")
      .doc(userReview.id);
    await userReviewDoc.set(userReview.toJson());

    if (userReview.id == null) {  // if this is a brand new review
      await setGameReviewRelationship(
        gameID: userReview.gameID,
        relationship: GameReviewRelationshipModel(userReviewID: userReviewDoc.id),
      );
    }
  }

  /// If [gameIconUrl] is supplied, it will override [gameData.iconImagePath].
  static Future<String> setGameData(GameModel gameData, {String? gameIconUrl}) async {
    final doc = gamesCollection.doc(gameData.id);

    if (gameIconUrl != null) {
      final filePath =
        await StorageService()
          .uploadGameIconFromGoogleContentUrl(doc.id, gameIconUrl);

      gameData = GameModel(
        name: gameData.name,
        nameLower: gameData.nameLower,
        publisher: gameData.publisher,
        desc: gameData.desc,
        iconImagePath: filePath,
        categories: gameData.categories
      )..id = doc.id;
    }

    await doc.set(gameData.toJson());
    return doc.id;
  }

  // setters and updaters (individual)
  Future<void> setGameReviewRelationship({
    required String gameID,
    required GameReviewRelationshipModel relationship,
  }) async {
    await gamesCollection.doc(gameID).collection("reviews").doc(userModel.uid)
      .set(relationship.toJson());
  }

  // helpers
  /// Translates a query snapshot of game review relationships into
  /// a map safely.
  static Map<String, GameReviewRelationshipModel> _gameReviewRelationshipQueryToMap(
    QuerySnapshot<Map<String, dynamic>> querySnapshot
  ) {
    final Map<String, GameReviewRelationshipModel> res = {};

    for (final doc in querySnapshot.docs) {
      if (doc.data().containsKey("userReviewID")) {
        res[doc.id] = GameReviewRelationshipModel.fromFirestore(doc);
      }
    }

    return res;
  }
}