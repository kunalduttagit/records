String formatDuration(int milliseconds) {
  int seconds = (milliseconds / 1000).floor();
  int minutes = (seconds / 60).floor();
  int remainingSeconds = seconds % 60;
  
  String minutesStr = minutes.toString().padLeft(2, '0');
  String secondsStr = remainingSeconds.toString().padLeft(2, '0');
  
  return '$minutesStr:$secondsStr';
}

String formatDurationHours(int milliseconds) {
  int seconds = (milliseconds / 1000).floor();
  int minutes = (seconds / 60).floor();
  int hours = (minutes / 60).floor();
  
  int remainingMinutes = minutes % 60;
  int remainingSeconds = seconds % 60;
  
  if (hours > 0) {
    return '${hours.toString()} hours ${remainingMinutes.toString()} minutes';
  } else {
    return '${remainingMinutes.toString()} minutes ${remainingSeconds.toString()} seconds';
  }
}