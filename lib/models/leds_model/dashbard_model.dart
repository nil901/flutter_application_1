class DashboardCountModel {
  final int todayFollowups;
  final int tomorrowFollowups;
  final int pendingFollowups;
  final int totalLeads;

  DashboardCountModel({
    required this.todayFollowups,
    required this.tomorrowFollowups,
    required this.pendingFollowups,
    required this.totalLeads,
  });

  factory DashboardCountModel.fromJson(Map<String, dynamic> json) {
    return DashboardCountModel(
      todayFollowups: json['todayFollowups'] ?? 0,
      tomorrowFollowups: json['tomorrowFollowups'] ?? 0,
      pendingFollowups: json['pendingFollowups'] ?? 0,
      totalLeads: json['totalLeads'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "todayFollowups": todayFollowups,
      "tomorrowFollowups": tomorrowFollowups,
      "pendingFollowups": pendingFollowups,
      "totalLeads": totalLeads,
    };
  }
}
