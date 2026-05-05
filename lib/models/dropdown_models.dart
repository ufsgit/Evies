class BranchModel {
  final int id;
  final String name;

  BranchModel({required this.id, required this.name});

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['Branch_ID'] ?? json['Id'] ?? 0,
      name: json['Branch_Name'] ?? json['Name'] ?? '',
    );
  }
}

class StaffModel {
  final int id;
  final String name;

  StaffModel({required this.id, required this.name});

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['User_ID'] ?? json['Id'] ?? 0,
      name: json['User_Name'] ?? json['First_Name'] ?? '',
    );
  }
}

class FollowupStatusModel {
  final int id;
  final String name;

  FollowupStatusModel({required this.id, required this.name});

  factory FollowupStatusModel.fromJson(Map<String, dynamic> json) {
    return FollowupStatusModel(
      id: json['Status_Id'] ?? json['Id'] ?? 0,
      name: json['Status_Name'] ?? json['Name'] ?? '',
    );
  }
}
