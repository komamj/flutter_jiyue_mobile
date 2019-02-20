class Constants {
  //app
  static const String appTitle = "即乐";

  //login
  static const String login = "登录";
  static const String userName = "账号";
  static const String userNameInvalid = "用户名不能为空";
  static const String userNameHint = "请输入您的账号";
  static const String password = "密码";
  static const String passwordInvalid = "密码不能少于6位";
  static const String passwordHint = "请输入您的密码";

  //main page
  static final String home = "首页";
  static final String nowPlaying = "正在播放";
  static final String mine = "我的";

  //network url
  static final String aLiEndpoint = "http://101.132.122.196:8080/";
  static final String aLiWebSocketEndpoint =
      "ws://101.132.122.196:8080/ws/client";
  static final String tencentEndpoint = "http://193.112.0.111:80/";
  static final String tencentWebSocketEndpoint =
      "ws://193.112.0.111:80/ws/client";
  static final String baseUrl = "https://next-song.cn/api/v1/";
  static final String grantType = "password";
  static final String clientId = "STORE_CLIENT";
  static final String clientSecret = "ee6c85b4cf1142fbb9aaf484216af74c";

  static final String keyAccessToken = "access_token";
  static final String keyIsLogin = "is_login";
  static final String keyUserId = "userId";
  static final String keyUserName = "user_name";
  static final String keyPassword = "password";

  //command
  static final String bind = "bind";
  static final String status = "status";
  static final String next = "next";
  static final String stop = "stop";
  static final String pause = "pause";
  static final String play = "play";
  static final String start = "start";
  static final String playing = "playing";
  static final String paused = "paused";
  static final String stopped = "stoped";
  static final String reboot = "reboot";
  static final String playMode = "playmod";
  static final String playState = "playstate";
}
