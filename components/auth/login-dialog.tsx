"use client";

import { useEffect, useState } from "react";
import {
  GithubAuthProvider,
  TwitterAuthProvider,
  getAdditionalUserInfo,
  signInWithPopup,
  signOut,
  type AuthProvider,
} from "firebase/auth";
import { FirebaseError } from "firebase/app";
import { auth } from "@/lib/firebase";
import { useUiStore } from "@/stores/ui";

type ProviderId = "github" | "x";

const PROVIDERS: { id: ProviderId; label: string; create: () => AuthProvider }[] = [
  { id: "github", label: "GitHub でログイン", create: () => new GithubAuthProvider() },
  { id: "x", label: "X でログイン", create: () => new TwitterAuthProvider() },
];

// 前回使ったログイン方法 (この端末のみ)。複数アカウント作成の防止用。
const LAST_PROVIDER_KEY = "susipero:lastLoginProvider";

function readLastProvider(): ProviderId | null {
  try {
    const v = localStorage.getItem(LAST_PROVIDER_KEY);
    return v === "github" || v === "x" ? v : null;
  } catch {
    return null;
  }
}

function writeLastProvider(id: ProviderId) {
  try {
    localStorage.setItem(LAST_PROVIDER_KEY, id);
  } catch {
    // 保存できなくてもログイン自体は続行
  }
}

function errorMessage(e: unknown): string | null {
  if (e instanceof FirebaseError) {
    switch (e.code) {
      case "auth/popup-closed-by-user":
      case "auth/cancelled-popup-request":
        return null;
      case "auth/account-exists-with-different-credential":
        return "このメールアドレスは別のログイン方法で登録済みです。以前使った方法でログインしてください。";
      case "auth/popup-blocked":
        return "ポップアップがブロックされました。ブラウザの設定で許可してください。";
    }
  }
  return e instanceof Error ? e.message : String(e);
}

export function LoginDialog() {
  const open = useUiStore((s) => s.loginDialogOpen);
  const close = useUiStore((s) => s.closeLoginDialog);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastProvider, setLastProvider] = useState<ProviderId | null>(null);

  useEffect(() => {
    if (open) setLastProvider(readLastProvider());
  }, [open]);

  if (!open) return null;

  const onLogin = async (id: ProviderId, create: () => AuthProvider) => {
    setBusy(true);
    setError(null);
    try {
      const result = await signInWithPopup(auth, create());
      if (id === "x") {
        const email =
          result.user.email ??
          result.user.providerData.find((p) => p.providerId === "twitter.com")?.email;
        if (!email) {
          // メールアドレスのない X アカウントは受け付けない。
          // 今回新規に作られたアカウントだけ消し、既存アカウントは消さずにログアウトのみ。
          if (getAdditionalUserInfo(result)?.isNewUser) {
            await result.user.delete().catch(() => signOut(auth));
          } else {
            await signOut(auth);
          }
          setError(
            "メールアドレスが登録されていない X アカウントではログインできません。X でメールアドレスを登録するか、GitHub でログインしてください。",
          );
          return;
        }
      }
      writeLastProvider(id);
      close();
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setBusy(false);
    }
  };

  // 前回の方法を先頭に並べる
  const ordered = [...PROVIDERS].sort(
    (a, b) => Number(b.id === lastProvider) - Number(a.id === lastProvider),
  );

  return (
    <div
      role="dialog"
      aria-modal="true"
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/60"
      onClick={close}
    >
      <div
        className="w-[min(92vw,360px)] rounded-xl bg-surface p-6 shadow-xl"
        onClick={(e) => e.stopPropagation()}
      >
        <h2 className="mb-4 text-lg font-bold">ログイン</h2>
        <div className="flex flex-col gap-3">
          {ordered.map((p) => {
            const isLast = p.id === lastProvider;
            return (
              <button
                key={p.id}
                type="button"
                disabled={busy}
                onClick={() => onLogin(p.id, p.create)}
                className={`relative w-full rounded-md px-4 py-2 font-bold disabled:opacity-50 ${
                  isLast || !lastProvider
                    ? "bg-primary text-on-primary"
                    : "bg-surface-variant text-foreground"
                }`}
              >
                {p.label}
                {isLast && (
                  <span className="absolute -top-2 right-2 rounded-full bg-on-primary-container px-2 text-[10px] leading-4 text-on-primary">
                    前回
                  </span>
                )}
              </button>
            );
          })}
        </div>
        {lastProvider && (
          <p className="mt-2 text-xs text-muted">
            前回は{lastProvider === "x" ? " X " : " GitHub "}でログインしました。別の方法だと別アカウントになります。
          </p>
        )}
        {busy && <p className="mt-3 text-sm text-muted">処理中…</p>}
        {error && <p className="mt-3 text-sm text-danger">{error}</p>}
        <p className="mt-3 text-xs text-muted">
          ログインすると
          <a href="/terms.html" target="_blank" className="underline">利用規約</a>
          と
          <a href="/privacy-policy.html" target="_blank" className="underline">プライバシーポリシー</a>
          に同意したものとみなします。
        </p>
        <button
          type="button"
          onClick={close}
          className="mt-3 w-full rounded-md px-4 py-2 text-sm text-muted hover:text-foreground"
        >
          閉じる
        </button>
      </div>
    </div>
  );
}
