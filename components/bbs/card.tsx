"use client";

import { useState } from "react";
import Link from "next/link";
import clsx from "clsx";
import { useAuth } from "@/lib/hooks/use-auth";
import { deleteArticle as deleteArticleDoc } from "@/lib/firestore/articles";
import { deleteUploaded } from "@/lib/upload-client";
import { articleIsPhoto, articleRotation, type Article } from "@/types/article";

export function ArticleCard({ article }: { article: Article }) {
  const { user } = useAuth();
  const [menuOpen, setMenuOpen] = useState(false);
  const isPhoto = articleIsPhoto(article.content);
  const rotation = articleRotation(article.content) ?? 0;

  const onDelete = async () => {
    setMenuOpen(false);
    if (!confirm("削除しますか?")) return;
    if (isPhoto) {
      const m = article.content.match(/<img src="([^"]+)"/);
      if (m) await deleteUploaded(m[1]);
    }
    await deleteArticleDoc(article.id);
  };

  return (
    <div className="relative">
      <button
        type="button"
        onClick={() => setMenuOpen((v) => !v)}
        style={{ width: article.width }}
        className={clsx(
          "block text-left transition-transform",
          isPhoto ? "" : "rounded shadow",
        )}
      >
        {isPhoto ? (
          <PhotoCard article={article} rotation={rotation} />
        ) : (
          <TextCard article={article} />
        )}
      </button>
      {menuOpen && (
        <div className="absolute left-0 top-full z-10 mt-1 min-w-[160px] rounded bg-surface text-sm shadow-lg">
          <Link
            href={`/profile/${article.createdBy}`}
            onClick={() => setMenuOpen(false)}
            className="block px-4 py-2 hover:bg-surface-variant"
          >
            プロフィールを見る
          </Link>
          {user && (
            <button
              type="button"
              onClick={onDelete}
              className="block w-full px-4 py-2 text-left text-danger hover:bg-surface-variant"
            >
              削除する
            </button>
          )}
        </div>
      )}
    </div>
  );
}

function PhotoCard({ article, rotation }: { article: Article; rotation: number }) {
  const m = article.content.match(/<img src="([^"]+)"/);
  const src = m?.[1] ?? "";
  return (
    <div
      style={{
        width: article.width,
        height: article.width + 16,
        transform: `rotate(${rotation}rad)`,
      }}
      className="bg-white p-4 pb-8 rounded shadow-lg"
    >
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img
        src={src}
        alt=""
        className="h-full w-full object-cover"
        draggable={false}
      />
    </div>
  );
}

function TextCard({ article }: { article: Article }) {
  return (
    <div
      style={{ width: article.width }}
      className="rounded bg-primary-container p-2 text-on-primary-container"
    >
      <p className="whitespace-pre-wrap break-words text-sm">{article.content}</p>
      <div className="mt-1 flex justify-end text-xs text-muted">
        {article.signature}
      </div>
    </div>
  );
}
