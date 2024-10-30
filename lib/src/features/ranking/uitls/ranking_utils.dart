import 'package:flutter/material.dart';
import 'package:mind_cows/resources/resources.dart';
import 'package:mind_cows/src/features/ranking/data/model/ranking.dart';

enum PodiumPosition { first, second, third }

abstract class RankingUtils {
  static List<Ranking> podium(List<Ranking> ranking) {
    // If there are less than 3 rankings, return the original list
    if (ranking.length < 3) return ranking;

    // Get the first three elements
    final podium = ranking.sublist(0, 3);

    // Rearrange the list to show 2nd, 1st, and then 3rd
    return [podium[1], podium[0], podium[2]];
  }

  static String getImageRankingByPos(PodiumPosition podiumPosition) {
    return switch (podiumPosition) {
      PodiumPosition.first => AppImages.firstPlace,
      PodiumPosition.second => AppImages.secondPlace,
      _ => AppImages.thirdPlace
    };
  }

  static double getRotationByPos(PodiumPosition podiumPosition) {
    return switch (podiumPosition) {
      PodiumPosition.first => 0,
      PodiumPosition.second => -0.1,
      _ => 0.1,
    };
  }

  static Ranking getRankingByPlayerId(List<Ranking> ranking, String playerId) {
    return ranking.firstWhere((element) => element.player.id == playerId);
  }
}
