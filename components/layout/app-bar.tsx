"use client";

import Link from "next/link";
import { useAuth } from "@/lib/hooks/use-auth";
import { useUiStore } from "@/stores/ui";
import { signOut } from "firebase/auth";
import { auth } from "@/lib/firebase";

export function AppBar({ title }: { title: string }) {
  const { user } = useAuth();
  const openLogin = useUiStore((s) => s.openLoginDialog);
  const setDrawerOpen = useUiStore((s) => s.setDrawerOpen);

  return (
    <header className="sticky top-0 z-40 flex items-center gap-3 bg-surface px-3 py-2 shadow">
      {user && (
        <button
          type="button"
          onClick={() => setDrawerOpen(true)}
          aria-label="メニュー"
          className="rounded p-2 text-foreground hover:bg-surface-variant"
        >
          ☰
        </button>
      )}
      <h1 className="flex-1 text-base font-bold">
        <Link href="/">{title}</Link>
      </h1>
      {!user ? (
        <button
          type="button"
          onClick={openLogin}
          className="rounded px-3 py-1 text-sm text-primary hover:bg-surface-variant"
        >
          ログイン
        </button>
      ) : (
        <button
          type="button"
          onClick={() => signOut(auth)}
          className="rounded px-3 py-1 text-sm text-muted hover:bg-surface-variant"
        >
          ログアウト
        </button>
      )}
    </header>
  );
}
