class EnquirySummarySource {
  final int id;
  final String name;

  EnquirySummarySource({required this.id, required this.name});

  factory EnquirySummarySource.fromJson(Map<String, dynamic> json) {
    return EnquirySummarySource(
      id: json['Enquiry_Source_Id'] ?? 0,
      name: json['Enquiry_Source_Name'] ?? '',
    );
  }
}

class EnquirySummaryStatus {
  final int id;
  final String name;
  final String color;

  EnquirySummaryStatus({
    required this.id,
    required this.name,
    required this.color,
  });

  factory EnquirySummaryStatus.fromJson(Map<String, dynamic> json) {
    return EnquirySummaryStatus(
      id: json['Status_Id'] ?? 0,
      name: json['Status_Name'] ?? '',
      color: json['Status_Color'] ?? '#6B7280',
    );
  }
}

class EnquirySummaryData {
  final int sourceId;
  final int statusId;
  final int count;

  EnquirySummaryData({
    required this.sourceId,
    required this.statusId,
    required this.count,
  });

  factory EnquirySummaryData.fromJson(Map<String, dynamic> json) {
    return EnquirySummaryData(
      sourceId: json['Enquiry_Source_Id'] ?? 0,
      statusId: json['Status_Id'] ?? 0,
      count: json['Count'] ?? 0,
    );
  }
}

class EnquirySummaryResponse {
  final List<EnquirySummarySource> sources;
  final List<EnquirySummaryStatus> statuses;
  final List<EnquirySummaryData> data;

  EnquirySummaryResponse({
    required this.sources,
    required this.statuses,
    required this.data,
  });

  factory EnquirySummaryResponse.fromJson(List<dynamic> json) {
    List<EnquirySummarySource> sources = [];
    List<EnquirySummaryStatus> statuses = [];
    List<EnquirySummaryData> data = [];

    if (json.isNotEmpty && json[0] is List) {
      sources = (json[0] as List)
          .map((e) => EnquirySummarySource.fromJson(e))
          .toList();
    }

    if (json.length > 1 && json[1] is List) {
      statuses = (json[1] as List)
          .map((e) => EnquirySummaryStatus.fromJson(e))
          .toList();
    }

    if (json.length > 2 && json[2] is List) {
      data = (json[2] as List)
          .map((e) => EnquirySummaryData.fromJson(e))
          .toList();
    }

    return EnquirySummaryResponse(
      sources: sources,
      statuses: statuses,
      data: data,
    );
  }
}
