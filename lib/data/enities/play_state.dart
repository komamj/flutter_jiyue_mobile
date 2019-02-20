class PlayState {
  final int code;
  final String userId;
  final String action;
  final dynamic data;
  final String message;

  PlayState(this.code, this.userId, this.action, this.data, this.message);

  PlayState.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        userId = json['store'],
        action = json['action'],
        data = json['data'],
        message = json['message'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'code': code,
        'store': userId,
        'action': action,
        'data': data,
        'message': message
      };
}
