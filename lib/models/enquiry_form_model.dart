class DropdownItem {
  final int id;
  final String name;

  DropdownItem({required this.id, required this.name});

  factory DropdownItem.fromJson(
    Map<String, dynamic> json, {
    String? idKey,
    String? nameKey,
  }) {
    dynamic getValue(String key) {
      if (json.containsKey(key)) return json[key];
      // Try common variations
      String alt = key.endsWith('_ID')
          ? key.replaceAll('_ID', '_Id')
          : key.replaceAll('_Id', '_ID');
      if (json.containsKey(alt)) return json[alt];
      if (json.containsKey(key.toLowerCase())) return json[key.toLowerCase()];
      return null;
    }

    return DropdownItem(
      id:
          (idKey != null
              ? getValue(idKey)
              : (getValue('ID') ?? getValue('Id') ?? getValue('id'))) ??
          0,
      name:
          (nameKey != null
              ? getValue(nameKey)
              : (getValue('Name') ?? getValue('Name') ?? getValue('name'))) ??
          '',
    );
  }
}

class EnquiryFormData {
  int studentId;
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String countryCode;
  String countryCodeName;
  int? branchId;
  String? branchName;
  int? departmentId;
  String? departmentName;
  int? followUpStatusId;
  String? followUpStatusName;
  String? followUpDate;
  String? nextFollowUpDate;
  int? assignedStaffId;
  String? assignedStaffName;
  int? enquirySourceId;
  String remark;
  int age;
  String qualification;
  String qualificationDescription;
  String altPhoneNumber;
  String address;
  double heightCm;
  double weightKg;
  String profilePhotoPath;
  String avatar;
  String guardianType;
  String guardianName;
  String guardianPhone;
  String guardianAltPhone;
  String? admissionDate;
  String rollNo;
  String activeStatus;
  List<dynamic> installments;
  List<int> studentFeesIds;
  bool isRegistering;
  int createdBy;

  EnquiryFormData({
    this.studentId = 0,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phoneNumber = '',
    this.countryCode = '+91',
    this.countryCodeName = 'India',
    this.branchId,
    this.branchName,
    this.departmentId,
    this.departmentName,
    this.followUpStatusId,
    this.followUpStatusName,
    this.followUpDate,
    this.nextFollowUpDate,
    this.assignedStaffId,
    this.assignedStaffName,
    this.enquirySourceId,
    this.remark = '',
    this.age = 0,
    this.qualification = '',
    this.qualificationDescription = '',
    this.altPhoneNumber = '',
    this.address = '',
    this.heightCm = 0,
    this.weightKg = 0,
    this.profilePhotoPath = '',
    this.avatar = '',
    this.guardianType = '',
    this.guardianName = '',
    this.guardianPhone = '',
    this.guardianAltPhone = '',
    this.admissionDate,
    this.rollNo = '',
    this.activeStatus = 'Active',
    this.installments = const [],
    this.studentFeesIds = const [],
    this.isRegistering = false,
    this.createdBy = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'Student_ID': studentId,
      'First_Name': firstName,
      'Last_Name': lastName,
      'Email': email,
      'Phone_Number': phoneNumber,
      'Country_Code': countryCode,
      'Country_Code_Name': countryCodeName,
      'Branch_Id': branchId,
      'Branch_Name': branchName,
      'Department_Id': departmentId,
      'Department_Name': departmentName,
      'Follow_Up_Status_ID': followUpStatusId,
      'Follow_Up_Status_Name': followUpStatusName,
      'Follow_Up_Date': followUpDate,
      'Next_Follow_Up_Date': nextFollowUpDate,
      'Assigned_Staff_ID': assignedStaffId,
      'Assigned_Staff_Name': assignedStaffName,
      'Enquiry_Source_Id': enquirySourceId,
      'Remark': remark,
      'Age': age,
      'Qualification': qualification,
      'Qualification_Description': qualificationDescription,
      'Alt_Phone_Number': altPhoneNumber,
      'Address': address,
      'Height_cm': heightCm,
      'Weight_kg': weightKg,
      'Profile_Photo_Path': profilePhotoPath,
      'Avatar': avatar,
      'Guardian_Type': guardianType,
      'Guardian_Name': guardianName,
      'Guardian_Phone': guardianPhone,
      'Guardian_Alt_Phone': guardianAltPhone,
      'Admission_Date': admissionDate,
      'Roll_No': rollNo,
      'Registration_No': 0, // Ensure integer 0 is sent instead of empty string
      'Active_Status': activeStatus,
      'Installments': installments,
      'Student_Fees_IDs': studentFeesIds,
      'isRegistering': isRegistering,
      'Created_By': createdBy,
    };
  }

  factory EnquiryFormData.fromLead(Map<String, dynamic> json) {
    return EnquiryFormData(
      studentId: json['Student_ID'] ?? 0,
      firstName: json['First_Name'] ?? '',
      lastName: json['Last_Name'] ?? '',
      email: json['Email'] ?? '',
      phoneNumber: json['Phone_Number'] ?? '',
      countryCode: json['Country_Code'] ?? '+91',
      countryCodeName: json['Country_Code_Name'] ?? 'India',
      branchId: json['Branch_Id'] ?? json['Branch_ID'],
      branchName: json['Branch_Name'],
      departmentId: json['Department_Id'] ?? json['Department_ID'],
      departmentName: json['Department_Name'],
      followUpStatusId: json['Follow_Up_Status_ID'] ?? json['Status_Id'],
      followUpStatusName: json['Follow_Up_Status_Name'] ?? json['Status_Name'],
      followUpDate: json['Follow_Up_Date'],
      nextFollowUpDate: json['Next_Follow_Up_Date'],
      assignedStaffId: json['Assigned_Staff_ID'] ?? json['To_User_Id'],
      assignedStaffName: json['Assigned_Staff_Name'] ?? json['To_User_Name'],
      enquirySourceId: json['Enquiry_Source_Id'] ?? json['Enquiry_Source_ID'],
      remark: json['Remark'] ?? '',
      age: json['Age'] ?? 0,
      qualification: json['Qualification'] ?? '',
      qualificationDescription: json['Qualification_Description'] ?? '',
      altPhoneNumber: json['Alt_Phone_Number'] ?? '',
      address: json['Address'] ?? '',
      heightCm: (json['Height_cm'] ?? 0).toDouble(),
      weightKg: (json['Weight_kg'] ?? 0).toDouble(),
      profilePhotoPath: json['Profile_Photo_Path'] ?? '',
      avatar: json['Avatar'] ?? '',
      guardianType: json['Guardian_Type'] ?? '',
      guardianName: json['Guardian_Name'] ?? '',
      guardianPhone: json['Guardian_Phone'] ?? '',
      guardianAltPhone: json['Guardian_Alt_Phone'] ?? '',
      admissionDate: json['Admission_Date'],
      rollNo: json['Roll_No'] ?? '',
      activeStatus: json['Active_Status'] ?? 'Active',
      installments: json['Installments'] ?? [],
      studentFeesIds: List<int>.from(json['Student_Fees_IDs'] ?? []),
      isRegistering: json['isRegistering'] ?? false,
      createdBy: json['Created_By'] ?? 0,
    );
  }
}
