class UserModel {
  final int id;
  final String firstName;
  final String email;
  final String phoneNumber;
  final int userTypeId;

  UserModel({
    required this.id,
    required this.firstName,
    required this.email,
    required this.phoneNumber,
    required this.userTypeId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['Id'] ?? 0,
      firstName: json['First_Name'] ?? '',
      email: json['Email'] ?? '',
      phoneNumber: json['PhoneNumber'] ?? '',
      userTypeId: json['User_Type_Id'] ?? 0,
    );
  }
}

class LoginResponseModel {
  final String? token;
  final String? error;
  final bool success;
  final UserModel? user;

  LoginResponseModel({this.token, this.error, required this.success, this.user});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    UserModel? parsedUser;
    if (json['0'] != null) {
      parsedUser = UserModel.fromJson(json['0']);
    }

    return LoginResponseModel(
      token: json['token'],
      error: json['error'],
      success: json['token'] != null, // Success if token is present
      user: parsedUser,
    );
  }
}
