class Command {
  final String userId;
  final String action;
  final String data;

  Command({this.userId, this.action, this.data});

  factory Command.fromJson(Map<String, dynamic> json) {
    return Command(
        userId: json['store'], action: json['action'], data: json['data']);
  }

  Map<String, dynamic> toJson() => {
        'store': userId,
        'action': action,
        'data': data,
      };
}
