import { Timestamp, type DocumentData, type QueryDocumentSnapshot } from "firebase/firestore";

export type Article = {
  id: string;
  content: string;
  signature: string;
  left: number;
  top: number;
  width: number;
  createdAt: Date;
  createdBy: string;
};

export type ArticleInput = Omit<Article, "id" | "createdAt"> & {
  createdAt: Date;
};

export function articleIsPhoto(content: string): boolean {
  return content.includes("<img");
}

export function articleRotation(content: string): number | null {
  if (!articleIsPhoto(content)) return null;
  const m = content.match(/<img src="(.+?)" data-rotation="([^"]+)"/);
  if (!m) return null;
  const r = Number(m[2]);
  return Number.isFinite(r) ? r : null;
}

export function fromArticleDoc(doc: QueryDocumentSnapshot<DocumentData>): Article {
  const d = doc.data();
  return {
    id: doc.id,
    content: d.content,
    signature: d.signature,
    left: d.left,
    top: d.top,
    width: d.width,
    createdAt: (d.createdAt as Timestamp).toDate(),
    createdBy: d.createdBy,
  };
}

export function toArticleDoc(input: ArticleInput): DocumentData {
  return {
    content: input.content,
    signature: input.signature,
    left: input.left,
    top: input.top,
    width: input.width,
    createdAt: Timestamp.fromDate(input.createdAt),
    createdBy: input.createdBy,
  };
}
