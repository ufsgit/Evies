import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    final response = await dio.get(
      'https://6sq169pz-3520.inc1.devtunnels.ms/user/Get_Enquiry_Conversion_Summary',
    );
    print('Response status: ${response.statusCode}');
    print('Response data: ${response.data}');
  } on DioException catch (e) {
    print('Error: ${e.message}');
    if (e.response != null) {
      print('Error data: ${e.response?.data}');
    }
  }
}
