class LogUtils {
  static const String logTag = "KomaLog";

  static final LogUtils singleton = LogUtils.internal();

  LogUtils.internal();

  factory LogUtils() {
    return singleton;
  }

  d(String message) {
    print("$logTag----$message");
  }
}
