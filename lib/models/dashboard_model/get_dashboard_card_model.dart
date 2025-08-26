class Get_Dashboard_Card_Model {
  int? todayFollowups;
  int? tomorrowFollowups;
  int? pendingFollowups;
  int? totalLeads;
  int? leadsThisMonth;
  int? freshLeads;
  int? freshLeadsThisMonth;
  int? totalABM;
  int? aBMThisMonth;
  int? totalABE;
  int? aBEThisMonth;

  Get_Dashboard_Card_Model(
      {this.todayFollowups,
      this.tomorrowFollowups,
      this.pendingFollowups,
      this.totalLeads,
      this.leadsThisMonth,
      this.freshLeads,
      this.freshLeadsThisMonth,
      this.totalABM,
      this.aBMThisMonth,
      this.totalABE,
      this.aBEThisMonth});

  Get_Dashboard_Card_Model.fromJson(Map<String, dynamic> json) {
    todayFollowups = json['todayFollowups'];
    tomorrowFollowups = json['tomorrowFollowups'];
    pendingFollowups = json['pendingFollowups'];
    totalLeads = json['totalLeads'];
    leadsThisMonth = json['leadsThisMonth'];
    freshLeads = json['freshLeads'];
    freshLeadsThisMonth = json['freshLeadsThisMonth'];
    totalABM = json['totalABM'];
    aBMThisMonth = json['ABMThisMonth'];
    totalABE = json['totalABE'];
    aBEThisMonth = json['ABEThisMonth'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['todayFollowups'] = this.todayFollowups;
    data['tomorrowFollowups'] = this.tomorrowFollowups;
    data['pendingFollowups'] = this.pendingFollowups;
    data['totalLeads'] = this.totalLeads;
    data['leadsThisMonth'] = this.leadsThisMonth;
    data['freshLeads'] = this.freshLeads;
    data['freshLeadsThisMonth'] = this.freshLeadsThisMonth;
    data['totalABM'] = this.totalABM;
    data['ABMThisMonth'] = this.aBMThisMonth;
    data['totalABE'] = this.totalABE;
    data['ABEThisMonth'] = this.aBEThisMonth;
    return data;
  }
}
