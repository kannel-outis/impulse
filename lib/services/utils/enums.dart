enum TransferState {
  failed("Failed"),
  inProgress("In Progress"),
  paused("Paused"),
  pending("Pending"),
  canceled("Canceled");

  const TransferState(this.label);
  final String label;
}
