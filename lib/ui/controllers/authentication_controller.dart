import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/random_user.dart';
import '../../domain/use_case/authentication.dart';

// the controller does not have business logic, it sends the request to the corresponding use case
class AuthenticationController extends GetxController {
  final _logged = false.obs;
  final _storeUser = false.obs;
  final _storeUserEmail = "".obs;
  final _storeUserPassword = "".obs;

  final Authentication _authentication = Get.find<Authentication>();

  AuthenticationController() {
    initializeLoggedState();
  }

  // it updated logged according to the data on sharedPrefs
  void initializeLoggedState() async {
    logged = await _authentication.init;
  }

  String get storeUserPassword => _storeUserPassword.value;
  String get storeUserEmail => _storeUserEmail.value;
  bool get storeUser => _storeUser.value;

  // it returns _logged, if it is true it calls getStoredUser
  bool get logged {
    if (_logged.isTrue) {
      getStoredUser();
    }
    return _logged.value;
  }

  // besides updating _storeUser, if false it clears stored user
  set storeUser(bool mode) {
    if (_storeUser.isFalse) {
      clearStoredUser();
    }
    _storeUser.value = mode;
  }

  // updates _logged
  set logged(bool mode) {
    _logged.value = mode;
  }

  // this method should clean the user data on sharedPrefs and controller
  Future<void> clearStoredUser() async {
    _authentication.clearStoredUser();
  }

  // this method gets the stored user on sharedPrefs and updates the data on
  // the controller
  Future<void> getStoredUser() async {
    User user = await _authentication.getStoredUser();
    _storeUserEmail.value = user.email;
    _storeUserPassword.value = user.password;
    logInfo(
        'AuthenticationController getStoredUser and got <${user.email}> <${user.password}>');
  }

  // this method clears all stored data
  clearAll() async {
    _authentication.clearAll();
  }

  // used to send login data, if user data is ok and if storeUser is true
  // it also stores the user on controller
  Future<bool> login(String user, String password) async {
    bool success = await _authentication.login(storeUser, user, password);
    if (success) {
      logged = true;
      if (storeUser) {
        _storeUserEmail.value = user;
        _storeUserPassword.value = user;
      }
    }
    return success;
  }

  // used to send signup data
  Future<bool> signup(String user, String password) async {
    await _authentication.signup(user, password);
    return true;
  }

  // used to logout the current user
  void logout() async {
    await _authentication.logout();
    logged = false;
  }
}
