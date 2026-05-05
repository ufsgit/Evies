class ApiEndpoints {
  // Remote backend URL via Dev Tunnels
  static const String baseUrl = 'https://6sq169pz-3520.inc1.devtunnels.ms';

  // Authentication Endpoints
  static const String login = '$baseUrl/Login/Login_Check';

  // Dashboard Endpoints
  static const String dashboard = '$baseUrl/user/Get_Dashboard/';

  // Student Endpoints
  static const String getStudentLeads = '$baseUrl/student/Search_student_lead/';
  static const String getFollowupStatus =
      '$baseUrl/student/Get_Followup_Status/';
  static const String branchDropdown = '$baseUrl/Student/Branch_Dropdown/';
  static const String userDropdown = '$baseUrl/Student/User_Dropdown/';
  static const String departmentDropdown =
      '$baseUrl/Student/Department_Dropdown/';
  static const String enquirySourceDropdown =
      '$baseUrl/student/Get_All_Enquiry/';
  static const String saveStudent = '$baseUrl/student/Save_student/';
  static const String getStudentCurrentFollowup =
      '$baseUrl/Student/Get_student_current_followup/';
  static const String saveStudentFollowup = '$baseUrl/student/Save_student_followup/';
}
