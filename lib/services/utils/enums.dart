enum DownloadState {
  failed("Failed"),
  inProgress("In Progress"),
  paused("Paused"),
  pending("Pending"),
  completed("Completed"),
  canceled("Canceled");

  const DownloadState(this.label);
  final String label;
}
