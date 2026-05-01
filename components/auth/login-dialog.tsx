"use client";

import { useState } from "react";
import { GoogleAuthProvider, signInWithPopup } from "firebase/auth";
import { auth } from "@/lib/firebase";
import { useUiStore } from "@/stores/ui";

export function LoginDialog() {
  const open = useUiStore((s) => s.loginDialogOpen);
  const close = useUiStore((s) => s.closeLoginDialog);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (!open) return null;

  const onGoogle = async () => {
    setBusy(true);
    setError(null);
    try {
      await signInWithPopup(auth, new GoogleAuthProvider());
      close();
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  };

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
        <button
          type="button"
          disabled={busy}
          onClick={onGoogle}
          className="w-full rounded-md bg-primary px-4 py-2 font-bold text-on-primary disabled:opacity-50"
        >
          {busy ? "処理中…" : "Google でログイン"}
        </button>
        {error && <p className="mt-3 text-sm text-danger">{error}</p>}
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
