import 'package:flutter/material.dart';
import 'package:greendayo/features/games/game.dart';

class GameRepository {
  List<Game> getAll() => const [
        Game(
          id: 'nasbi',
          title: 'ナスビ',
          subtitle: 'オンライン4人麻雀',
          description:
              '3Dの牌をジャラっと動かして、4人でガチ対戦！空いてる卓に飛び込んで打とう。',
          url: 'https://susipero.com/nasbi/',
          icon: Icons.casino,
          color: Color(0xFF7B4DFF),
        ),
        Game(
          id: 'kaeru',
          title: 'ケロ雀',
          subtitle: '対戦麻雀ソリティア',
          description:
              'ペアを取り合うスピードバトル！CPUより先にタッチして、8人のライバルをケロッとぶっちぎれ。',
          url: 'https://susipero.com/kaeru/',
          icon: Icons.spa,
          color: Color(0xFF34C759),
        ),
      ];
}
