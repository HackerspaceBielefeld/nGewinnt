enum GameState { started, stopped }

enum GameTeam { teamA, teamB, noTeam, draw }

class NGewinntModel {
  final int columns;
  final int rows;
  final Map<GameTeam, int> score;
  final NGewinntRoundModel? round;
  final Map<String, dynamic> infos;

  String get phoneRed => infos['phoneRed'] ?? '?';
  String get phoneBlue => infos['phoneBlue'] ?? '?';

  NGewinntModel({required this.columns, required this.rows, required this.score, this.round, required this.infos});

  factory NGewinntModel.fromJSON(dynamic data) {
    return NGewinntModel(
        columns: data['columns'],
        rows: data['rows'],
        score: {
          GameTeam.teamA: data['score']['0'],
          GameTeam.teamB: data['score']['1'],
        },
        round: data['currentRound'] == null ? null : NGewinntRoundModel.fromJSON(data['currentRound']),
        infos: data['infos']);
  }
}

class NGewinntRoundModel {
  final GameState state;
  final GameTeam winner;
  final List<List<GameTeam>> gamefield;
  final int timeConsumed;
  final NGewinntRoundSectionModel? currentSection;

  NGewinntRoundModel(
      {required this.state,
      required this.winner,
      required this.gamefield,
      required this.timeConsumed,
      this.currentSection});

  static List<List<GameTeam>> parseGameField(List<dynamic> data) {
    List<List<GameTeam>> result = [];
    for (int colidx = 0; colidx < data.length; colidx++) {
      List<GameTeam> col = [];
      for (int rowidx = 0; rowidx < data[colidx].length; rowidx++) {
        col.add(GameTeam.values[data[colidx][rowidx]]);
      }
      result.add(col);
    }
    return result;
  }

  factory NGewinntRoundModel.fromJSON(dynamic data) {
    return NGewinntRoundModel(
        state: GameState.values[data['state']],
        winner: GameTeam.values[data['winner']],
        gamefield: NGewinntRoundModel.parseGameField(data['gamefield']),
        timeConsumed: data['timeConsumed'],
        currentSection:
            data['currentSection'] == null ? null : NGewinntRoundSectionModel.fromJSON(data['currentSection']));
  }
}

class NGewinntRoundSectionModel {
  final GameTeam team;
  final int timeLeft;
  final bool started;
  final bool finished;
  final List<int> possible;
  final List<int> vote;

  NGewinntRoundSectionModel(
      {required this.team,
      required this.timeLeft,
      required this.started,
      required this.finished,
      required this.possible,
      required this.vote});

  int overallVoteCount() {
    int result = 0;
    for (int voteidx = 0; voteidx < vote.length; voteidx++) {
      result += vote[voteidx];
    }
    return result;
  }

  double getPercentage(int col) {
    int ovc = overallVoteCount();
    if (ovc == 0) {
      return 0.0;
    }

    return 100 / ovc * vote[col];
  }

  factory NGewinntRoundSectionModel.fromJSON(dynamic data) {
    return NGewinntRoundSectionModel(
      team: GameTeam.values[data['team']],
      timeLeft: data['timeLeft'],
      started: data['started'],
      finished: data['finished'],
      possible: (data['possible'] as List<dynamic>).map((e) => e as int).toList(),
      vote: (data['vote'] as List<dynamic>).map((e) => e as int).toList(),
    );
  }
}
