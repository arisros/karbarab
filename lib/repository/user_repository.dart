import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:karbarab/core/config/score_value.dart';
import 'package:karbarab/model/user.dart';
import 'package:karbarab/utils/logger.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const USER_ID_PREFERENCES = 'user_id';
const USER_FCMTOKEN_PREFERENCES = 'user_fcmtoken';
const USER_NAME_PREFERENCES = 'user_username';
const USER_AVATAR_PREFERENCES = 'user_avatar';
const USER_IS_GOOGLEAUTH = 'user_is_googleauth';
const USER_MAIL_PREFERENCES = 'user_email';
const USER_FULLNAME_PREFERENCES = 'user_fullname';
const SEND_CARD_LIMIT_PREFERRENCE = 'send_card_limit';

class UserRepository {
  static const ID = 'id';
  static const AVATAR = 'avatar';
  static const EMAIL = 'email';
  static const FULLNAME = 'fullname';
  static const IS_GOOGLE_AUTH = 'isGoogleAuth';
  static const PASSWORD = 'password';
  static const TOKEN_FCM = 'tokenFCM';
  static const USERNAME = 'username';
  static const SEND_CARD_LIMIT = 'sendCardLimit';

  static User fromDoc(DocumentSnapshot document) {
    return User(
      (u) => u
        ..id = document[ID]
        ..avatar = document[AVATAR]
        ..email = document[EMAIL]
        ..fullname = document[FULLNAME]
        ..isGoogleAuth = document[IS_GOOGLE_AUTH]
        ..tokenFCM = document[TOKEN_FCM]
        ..sendCardLimit = document[SEND_CARD_LIMIT]
        ..username = document[USERNAME],
    );
  }

  static User fromJson(Map<String, dynamic> json) {
    return User((u) => u
      ..id = json[ID]
      ..avatar = json[AVATAR]
      ..email = json[EMAIL]
      ..fullname = json[FULLNAME]
      ..isGoogleAuth = json[IS_GOOGLE_AUTH]
      ..tokenFCM = json[TOKEN_FCM]
      ..sendCardLimit = json[SEND_CARD_LIMIT]
      ..username = json[USERNAME]);
  }

  static Map<String, dynamic> toMap(User user) {
    return {
      ID: user.id,
      AVATAR: user.avatar,
      EMAIL: user.email,
      FULLNAME: user.fullname,
      IS_GOOGLE_AUTH: user.isGoogleAuth,
      TOKEN_FCM: user.tokenFCM,
      USERNAME: user.username,
      SEND_CARD_LIMIT: user.sendCardLimit,
    };
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final CollectionReference _usersCollection =
      Firestore.instance.collection('users');

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();

  Future<void> saveUserToLocal(User user) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(USER_ID_PREFERENCES, user.id);
    await prefs.setString(USER_FCMTOKEN_PREFERENCES, user.tokenFCM);
    await prefs.setString(USER_NAME_PREFERENCES, user.username);
    await prefs.setString(USER_AVATAR_PREFERENCES, user.avatar);
    await prefs.setBool(USER_IS_GOOGLEAUTH, user.isGoogleAuth);
    await prefs.setString(USER_MAIL_PREFERENCES, user.email);
    await prefs.setString(USER_FULLNAME_PREFERENCES, user.fullname);
    await prefs.setInt(SEND_CARD_LIMIT_PREFERRENCE, user.sendCardLimit);
  }

  Future<FirebaseUser> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
      return _firebaseAuth.currentUser();
    } catch (e) {
      Logger.e('Sign in With Google', e: e, s: StackTrace.current);
      throw Exception;
    }
  }

  Future<User> updateUserWithGoogle(String username) async {
    final updateData = _usersCollection.document(username).updateData;
    final email = await getEmailFirebase();
    final avatar = await getAvatarFirebase();
    final displayName = (await _firebaseAuth.currentUser()).displayName;
    final id = await getUserId();
    final tokenFCM = await _firebaseMessaging.getToken();
    final User userData = User((u) => u
      ..id = id
      ..avatar = avatar
      ..email = email
      ..fullname = displayName
      ..isGoogleAuth = true
      ..tokenFCM = tokenFCM
      ..sendCardLimit = SEND_CARD_LIMIT_DEFAULT
      ..username = username);

    await updateData(toMap(userData));
    return userData;
  }

  Future<void> updateToLimitLocal(limit) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt(SEND_CARD_LIMIT_PREFERRENCE, limit);
  }

  Future<void> updateUserTokenFCM(username, newToken) async {
    final updateData = _usersCollection.document(username).updateData;
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(USER_FCMTOKEN_PREFERENCES, newToken);
    return await updateData({'tokenFCM': newToken});
  }

  Future<void> saveUser({
    @required String username,
    @required bool isGoogleAuth,
  }) async {
    final save = _usersCollection.document(username).setData;
    final tokenFCM = await _firebaseMessaging.getToken();
    final id = Uuid().v4();
    if (isGoogleAuth) {
      final email = await getEmailFirebase();
      final avatar = await getAvatarFirebase();
      final displayName = (await _firebaseAuth.currentUser()).displayName;
      final User userData = User((u) => u
        ..id = id
        ..avatar = avatar
        ..email = email
        ..fullname = displayName
        ..isGoogleAuth = isGoogleAuth
        ..tokenFCM = tokenFCM
        ..sendCardLimit = SEND_CARD_LIMIT_DEFAULT
        ..username = username);
      await save(toMap(userData));
      return saveUserToLocal(userData);
    }
    final User userData = User((u) => u
      ..id = id
      ..isGoogleAuth = isGoogleAuth
      ..tokenFCM = tokenFCM
      ..sendCardLimit = SEND_CARD_LIMIT_DEFAULT
      ..username = username);
    await save(toMap(userData));
    return await saveUserToLocal(userData);
  }

  Future<List<DocumentSnapshot>> getAllUsers() async {
    return (await _usersCollection.limit(10000).getDocuments()).documents;
  }

  Future<DocumentSnapshot> getUserFromUsername(username) {
    return _usersCollection.document(username).get();
  }

  Future<int> getUserSendCardLimit() async {
    final username = await getUser();
    final data = await _usersCollection.document(username).get();
    return data.data[SEND_CARD_LIMIT];
  }

  Future<int> addSendCardLimit() async {
    final username = await getUser();
    final data = await _usersCollection.document(username).get();
    final oldLimit = data.data[SEND_CARD_LIMIT];
    final update = _usersCollection.document(username).updateData;
    await update({ SEND_CARD_LIMIT: oldLimit + SEND_CARD_LIMIT_DEFAULT });
    return oldLimit + SEND_CARD_LIMIT_DEFAULT;
  }

  Future<int> decreaseSendCardLimit() async {
    final username = await getUser();
    final data = await _usersCollection.document(username).get();
    final oldLimit = data.data[SEND_CARD_LIMIT];
    final update = _usersCollection.document(username).updateData;
    await update({ SEND_CARD_LIMIT: oldLimit - 1 });
    return oldLimit - 1 ;
  }

  Future<Iterable<DocumentSnapshot>> getUserFromEmail(String email) async {
    final QuerySnapshot user = await _usersCollection
        .where('isGoogleAuth', isEqualTo: true)
        .where('email', isEqualTo: email)
        .getDocuments();

    return user.documents;
  }

  Future<void> signInWithCredentials(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp({String email, String password}) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    final SharedPreferences prefs = await _prefs;
    await _firebaseMessaging.deleteInstanceID();
    await prefs.remove(USER_ID_PREFERENCES);
    await prefs.remove(USER_FCMTOKEN_PREFERENCES);
    await prefs.remove(USER_NAME_PREFERENCES);
    await prefs.remove(USER_AVATAR_PREFERENCES);
    await prefs.remove(USER_IS_GOOGLEAUTH);
    await prefs.remove(USER_MAIL_PREFERENCES);
    await prefs.remove(USER_FULLNAME_PREFERENCES);
    return Future.wait([
      prefs.clear(),
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> signOutGoogleOnly() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final SharedPreferences prefs = await _prefs;
    final currentUser = prefs.getString(USER_ID_PREFERENCES);
    return currentUser != null;
  }

  Future<bool> isUserGoogleAuth() async {
    final SharedPreferences prefs = await _prefs;
    final isGoogle = prefs.getBool(USER_IS_GOOGLEAUTH);
    return isGoogle;
  }

  Future<String> getUser() async {
    final SharedPreferences prefs = await _prefs;
    final username = prefs.getString(USER_NAME_PREFERENCES);
    return username;
  }

  Future<String> getUserId() async {
    final SharedPreferences prefs = await _prefs;
    final userId = prefs.getString(USER_ID_PREFERENCES);
    return userId;
  }

  Future<String> getUserTokenFCM() async {
    final SharedPreferences prefs = await _prefs;
    final token = prefs.getString(USER_FCMTOKEN_PREFERENCES);
    return token;
  }

  Future<String> getUserFullname() async {
    final SharedPreferences prefs = await _prefs;
    final String fullname = prefs.getString(USER_FULLNAME_PREFERENCES);
    return fullname;
  }

  Future<String> getAvatar() async {
    final SharedPreferences prefs = await _prefs;
    final String avatar = prefs.getString(USER_AVATAR_PREFERENCES);
    return avatar;
  }

  Future<String> getEmail() async {
    final SharedPreferences prefs = await _prefs;
    final String email = prefs.getString(USER_AVATAR_PREFERENCES);
    return email;
  }

  Future<User> getUserMeta() async {
    final SharedPreferences prefs = await _prefs;
    final String id = prefs.getString(USER_ID_PREFERENCES);
    final String fcmtoken = prefs.getString(USER_FCMTOKEN_PREFERENCES);
    final String username = prefs.getString(USER_NAME_PREFERENCES);
    final String avatar = prefs.getString(USER_AVATAR_PREFERENCES);
    final bool isGoogleAuth = prefs.getBool(USER_IS_GOOGLEAUTH);
    final String email = prefs.getString(USER_MAIL_PREFERENCES);
    final String fullname = prefs.getString(USER_FULLNAME_PREFERENCES);
    final int sendCardLimit = prefs.getInt(SEND_CARD_LIMIT_PREFERRENCE);
    return User((u) => u
      ..id = id
      ..avatar = avatar
      ..email = email
      ..fullname = fullname
      ..sendCardLimit = sendCardLimit
      ..isGoogleAuth = isGoogleAuth
      ..tokenFCM = fcmtoken
      ..username = username);
  }

  // firebase account data

  Future<String> getEmailFirebase() async {
    final email = (await _firebaseAuth.currentUser()).email;
    return email;
  }

  Future<String> getFullnameFirebase() async {
    final email = (await _firebaseAuth.currentUser()).displayName;
    return email;
  }

  Future<String> getAvatarFirebase() async {
    final avatar = (await _firebaseAuth.currentUser()).photoUrl;
    return avatar;
  }
}
