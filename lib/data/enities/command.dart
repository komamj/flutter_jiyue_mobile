class Command {
  final String userId;
  final String action;
  final String data;

  Command(this.userId, this.action, this.data);

  Command.fromJson(Map<String, dynamic> json)
      : userId = json['store'],
        action = json['action'],
        data = json['data'];

  Map<String, dynamic> toJson() => {
        'store': userId,
        'action': action,
        'data': data,
      };
}
