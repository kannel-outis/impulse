enum ConnectionState {
  //When a user is connected to another user
  connected("Connected"),

  //when a user has not been connected at all
  notConnected("Not Connected"),

  //when a use has been connected before but lost the connection
  //either by canceling or by something else
  disconnected("Disconnected"),

  //this is the first short connection that the Sender have with a receiver before deciding
  //if to accept or decline
  fling("Fling");

  const ConnectionState(this.label);
  final String label;

  @override
  String toString() {
    return label;
  }
}

enum User {
  host,
  client,
  undecided,
}

enum IState {
  failed("Failed"),
  inProgress("In Progress"),
  paused("Paused"),
  pending("Pending"),
  completed("Completed"),
  canceled("Canceled");

  const IState(this.label);
  final String label;
}
