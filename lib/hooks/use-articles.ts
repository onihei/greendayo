"use client";

import { useEffect, useState } from "react";
import { observeArticles } from "@/lib/firestore/articles";
import type { Article } from "@/types/article";

export function useArticles(): { articles: Article[]; ready: boolean } {
  const [articles, setArticles] = useState<Article[]>([]);
  const [ready, setReady] = useState(false);
  useEffect(() => {
    const unsub = observeArticles((next) => {
      setArticles(next);
      setReady(true);
    });
    return unsub;
  }, []);
  return { articles, ready };
}
