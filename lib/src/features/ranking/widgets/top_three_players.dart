import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/utils/widgets/cache_widget.dart';
import 'package:my_app/src/features/player/data/model/player.dart';
import 'package:my_app/src/features/ranking/data/model/ranking.dart';
import 'package:my_app/src/features/ranking/uitls/ranking_utils.dart';

class TopThreePlayers extends StatelessWidget {
  const TopThreePlayers(this.ranking, {super.key});

  final List<Ranking> ranking;

  @override
  Widget build(BuildContext context) {
    final podium = RankingUtils.podium(ranking);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final player = podium[index].player;
        return _PodiumPlayerCard(
          player: player,
          ranking: podium[index],
          podiumPosition: index == 0
              ? PodiumPosition.second
              : index == 1
                  ? PodiumPosition.first
                  : PodiumPosition.third,
        );
      }),
    );
  }
}

class _PodiumPlayerCard extends StatelessWidget {
  const _PodiumPlayerCard({
    required this.player,
    required this.ranking,
    required this.podiumPosition,
    super.key,
  });

  final Player player;
  final Ranking ranking;
  final PodiumPosition podiumPosition;

  @override
  Widget build(BuildContext context) {
    const sizeImageWinner = Size(80, 80);
    const sizeImage = Size(65, 65);
    final isWinner = podiumPosition == PodiumPosition.first;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          if (podiumPosition != PodiumPosition.first) const GutterMedium(),
          Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Transform.rotate(
                angle: RankingUtils.getRotationByPos(podiumPosition),
                child: CacheWidget(
                  size: isWinner ? sizeImageWinner : sizeImage,
                  imageUrl: player.avatarUrl,
                ),
              ),
              Positioned(
                bottom: -15,
                height: 30,
                child: Image.asset(
                  RankingUtils.getImageRankingByPos(podiumPosition),
                ),
              ),
            ],
          ),
          const Gutter(),
          Text(
            player.username,
            style: AppTextStyle().body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.06),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Text(
                ranking.points.toString(),
                style: AppTextStyle().body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
