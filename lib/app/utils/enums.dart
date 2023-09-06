enum ConnectionState {
  //When a user is connected to another user
  connected("Connected"),

  //when a user has not been connected at all or after connection request has been rejected
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

  bool get isConnected => this == ConnectionState.connected;
  bool get isFling => this == ConnectionState.fling;
  bool get isDisConnected => this == ConnectionState.disconnected;
  bool get isNotConnected => this == ConnectionState.notConnected;
}

enum UserType {
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
  canceled("Canceled"),
  waiting("Waiting");

  /// this is only used on the server side
  // waiting("Waiting");

  const IState(this.label);
  final String label;

  bool get isPaused => this == IState.paused;
  bool get isCompleted => this == IState.completed;
  bool get isInProgress => this == IState.inProgress;
  bool get isCanceled => this == IState.canceled;
  bool get isPending => this == IState.pending;
  bool get isWaiting => this == IState.waiting;
  bool get isFailed => this == IState.failed;
}
