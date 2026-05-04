class AccountBalance {
  final int accountId;
  final String accountName;
  final String totalValue;

  AccountBalance({
    required this.accountId,
    required this.accountName,
    required this.totalValue,
  });

  factory AccountBalance.fromJson(Map<String, dynamic> json) {
    return AccountBalance(
      accountId: json['account_id'] ?? 0,
      accountName: json['account_name'] ?? '',
      totalValue: json['total_value_b'] ?? '0.00',
    );
  }
}

class CourseEnrollment {
  final String courseName;
  final int enrollmentCount;

  CourseEnrollment({
    required this.courseName,
    required this.enrollmentCount,
  });

  factory CourseEnrollment.fromJson(Map<String, dynamic> json) {
    return CourseEnrollment(
      courseName: json['Course_Name'] ?? '',
      enrollmentCount: json['Enrollment_Count'] ?? 0,
    );
  }
}

class StudentCount {
  final String month;
  final int count;

  StudentCount({
    required this.month,
    required this.count,
  });

  factory StudentCount.fromJson(Map<String, dynamic> json) {
    return StudentCount(
      month: json['Month'] ?? '',
      count: json['Student_Count'] ?? 0,
    );
  }
}

class LeadCount {
  final String month;
  final int count;

  LeadCount({
    required this.month,
    required this.count,
  });

  factory LeadCount.fromJson(Map<String, dynamic> json) {
    return LeadCount(
      month: json['Month'] ?? '',
      count: json['Lead_Count'] ?? 0,
    );
  }
}

class DashboardResponseModel {
  final List<AccountBalance> accounts;
  final List<CourseEnrollment> courses;
  final List<StudentCount> studentCounts;
  final List<LeadCount> leadCounts;

  DashboardResponseModel({
    required this.accounts,
    required this.courses,
    required this.studentCounts,
    required this.leadCounts,
  });

  factory DashboardResponseModel.fromJson(List<dynamic> jsonList) {
    List<AccountBalance> parsedAccounts = [];
    List<CourseEnrollment> parsedCourses = [];
    List<StudentCount> parsedStudents = [];
    List<LeadCount> parsedLeads = [];

    // Safety checks for indices
    if (jsonList.isNotEmpty && jsonList[0] is List) {
      parsedAccounts = (jsonList[0] as List)
          .map((e) => AccountBalance.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    
    if (jsonList.length > 1 && jsonList[1] is List) {
      parsedCourses = (jsonList[1] as List)
          .map((e) => CourseEnrollment.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (jsonList.length > 2 && jsonList[2] is List) {
      parsedStudents = (jsonList[2] as List)
          .map((e) => StudentCount.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (jsonList.length > 4 && jsonList[4] is List) {
      parsedLeads = (jsonList[4] as List)
          .map((e) => LeadCount.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return DashboardResponseModel(
      accounts: parsedAccounts,
      courses: parsedCourses,
      studentCounts: parsedStudents,
      leadCounts: parsedLeads,
    );
  }
}
