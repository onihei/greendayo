export type LabItem = {
  id: string;
  title: string;
  subtitle: string;
  description: string;
  url: string;
  icon: string;
};

export const LAB_ITEMS: LabItem[] = [
  {
    id: "yomipoyo",
    title: "よみぽよ",
    subtitle: "縦書き電子書籍リーダー",
    description:
      "パブリックドメインの名作を独自翻訳で。縦書きのページをめくって、ブラウザでそのまま読める。",
    url: "https://susipero.com/yomipoyo/",
    icon: "📖",
  },
];
