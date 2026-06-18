export type Game = {
  id: string;
  title: string;
  subtitle: string;
  description: string;
  url: string;
  icon: string;
};

export const GAMES: Game[] = [
  {
    id: "nasbi",
    title: "ナスビ",
    subtitle: "オンライン4人麻雀",
    description:
      "3Dの牌をジャラっと動かして、4人でガチ対戦！空いてる卓に飛び込んで打とう。",
    url: "https://susipero.com/nasbi/",
    icon: "🀄",
  },
  {
    id: "kaeru",
    title: "ケロ雀",
    subtitle: "対戦麻雀ソリティア",
    description:
      "ペアを取り合うスピードバトル！CPUより先にタッチして、8人のライバルをケロッとぶっちぎれ。",
    url: "https://susipero.com/kaeru/",
    icon: "🐸",
  },
  {
    id: "sumomo",
    title: "すもも",
    subtitle: "新聞クロスワード",
    description:
      "自動生成パズルをサクッと一問。マスを埋めて、答え合わせまでひと息で。",
    url: "https://susipero.com/sumomo/",
    icon: "🟪",
  },
  {
    id: "kirin",
    title: "キリン",
    subtitle: "コンピュータ将棋",
    description:
      "3Dの駒を動かしてCPUと本将棋。手強さを選んで、待ったもありで気軽に一局。",
    url: "https://susipero.com/kirin/",
    icon: "♛",
  },
  {
    id: "tuberun",
    title: "TUBE RUN",
    subtitle: "ネオン3Dランナー",
    description:
      "光るチューブをくるくる回って障害物を回避！コンボとニアミスでスコアを稼ぐ爽快ランナー。",
    url: "https://susipero.com/tuberun/",
    icon: "🚀",
  },
  {
    id: "tower2",
    title: "百鬼ノ砦",
    subtitle: "和風タワーディフェンス",
    description:
      "夜の山里に湧く百鬼の群れを、侍や陰陽師を並べて迎え撃て！社の結界を守り抜く物量タワーディフェンス。",
    url: "https://susipero.com/tower2/",
    icon: "🏯",
  },
  {
    id: "nigi",
    title: "にぎにぎパニック",
    subtitle: "寿司マッチ3パズル",
    description:
      "隣り合う寿司ネタをドラッグで入れ替えて、縦横3つそろえて消す！大連鎖でスコアを稼ぎ、時間切れ前にノルマをそろえろ。",
    url: "https://susipero.com/nigi/",
    icon: "🍣",
  },
];
