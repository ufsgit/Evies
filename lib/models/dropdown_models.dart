class BranchModel {
  final int id;
  final String name;

  BranchModel({required this.id, required this.name});

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }
    return BranchModel(
      id: toInt(json['Branch_ID'] ?? json['Id']) ?? 0,
      name: json['Branch_Name'] ?? json['Name'] ?? '',
    );
  }
}

class StaffModel {
  final int id;
  final String name;

  StaffModel({required this.id, required this.name});

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }
    return StaffModel(
      id: toInt(json['User_ID'] ?? json['Id']) ?? 0,
      name: json['User_Name'] ?? json['First_Name'] ?? '',
    );
  }
}

class FollowupStatusModel {
  final int id;
  final String name;

  FollowupStatusModel({required this.id, required this.name});

  factory FollowupStatusModel.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }
    return FollowupStatusModel(
      id: toInt(json['Status_Id'] ?? json['Id']) ?? 0,
      name: json['Status_Name'] ?? json['Name'] ?? '',
    );
  }
}
