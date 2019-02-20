class Token {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  Token(this.accessToken, this.refreshToken, this.tokenType);

  Token.fromJson(Map<String, dynamic> json)
      : accessToken = json['access_token'],
        refreshToken = json['refresh_token'],
        tokenType = json['token_type'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'access_token': accessToken,
        'token_type': tokenType,
        'refresh_token': refreshToken
      };
}
