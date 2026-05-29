import '../../domain/entities/stats_entity.dart';

class StatsModel extends StatsEntity {
  StatsModel({
    required super.dailyRequests,
    required super.clientTrust,
    required super.activeNurses,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      dailyRequests: json['daily_requests'] ?? 0,
      clientTrust: json['client_trust'] ?? 0,
      activeNurses: json['active_nurses'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_requests': dailyRequests,
      'client_trust': clientTrust,
      'active_nurses': activeNurses,
    };
  }
}
