///This class contains all tables inside of supabase database
abstract class QuerySupabase {
  static String get player => 'id, username, avatar_url';

  static String get playerNumber =>
      'id, player($player), number, is_turn, time_left';

  static String get game => '''
    id, status!inner($gameStatus), player_number1!inner($playerNumber), player_number2!inner($playerNumber), winner($player)
    ''';

  static String get gameStatus => 'id, status';

  static String ranking = '''
    id, games_won, games_lost, minimum_attempts, player($player)
    ''';

  static String attempt = '''
    id, game($game), number, bulls, cows, number, player($player)
    ''';
}
