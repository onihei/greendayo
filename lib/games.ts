export type Game = {
  id: string;
  title: string;
  subtitle: string;
  description: string;
  url: string;
  icon: string;
  color: string;
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
    color: "#7B4DFF",
  },
  {
    id: "kaeru",
    title: "ケロ雀",
    subtitle: "対戦麻雀ソリティア",
    description:
      "ペアを取り合うスピードバトル！CPUより先にタッチして、8人のライバルをケロッとぶっちぎれ。",
    url: "https://susipero.com/kaeru/",
    icon: "🐸",
    color: "#34C759",
  },
  {
    id: "sumomo",
    title: "すもも",
    subtitle: "新聞クロスワード",
    description:
      "自動生成パズルをサクッと一問。マスを埋めて、答え合わせまでひと息で。",
    url: "https://susipero.com/sumomo/",
    icon: "🟪",
    color: "#E91E63",
  },
];
