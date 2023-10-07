
String _twoDigits(int n) => n.toString().padLeft(2, '0'); //başına 0 ekliyor

void LOG(String message) {
  final now = DateTime.now();
  final timeString = "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} ${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}";

  final stackTrace = StackTrace.current;
  final stackLines = stackTrace.toString().split('\n');
  final callerLine = stackLines[1].trim();
  final callerParts = callerLine.split(' ');
  final fileNameWithLine = callerParts[callerParts.length - 1];
  final fileNameParts = fileNameWithLine.split('/').last.split(':');
  final fileName = fileNameParts[0];
  final lineNumber = fileNameParts[1];

  var logEntry = 'LOG - $timeString - $fileName Line:$lineNumber => $message';

  print(logEntry);

}
