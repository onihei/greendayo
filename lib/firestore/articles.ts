import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  limit,
  onSnapshot,
  orderBy,
  query,
  type Unsubscribe,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import { fromArticleDoc, toArticleDoc, type Article, type ArticleInput } from "@/types/article";

const articlesCol = () => collection(db, "articles");

export function observeArticles(
  onChange: (articles: Article[]) => void,
  onError?: (e: unknown) => void,
): Unsubscribe {
  const q = query(articlesCol(), orderBy("createdAt"), limit(100));
  return onSnapshot(
    q,
    (snap) => onChange(snap.docs.map(fromArticleDoc)),
    (err) => onError?.(err),
  );
}

export async function createArticle(input: ArticleInput): Promise<string> {
  const ref = await addDoc(articlesCol(), toArticleDoc(input));
  return ref.id;
}

export async function deleteArticle(id: string): Promise<void> {
  await deleteDoc(doc(articlesCol(), id));
}
