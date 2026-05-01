"use client";

import { AppShell } from "@/components/layout/app-shell";
import { SessionList } from "@/components/messenger/session-list";
import { useAuth } from "@/lib/hooks/use-auth";
import { useUiStore } from "@/stores/ui";

export default function MessengerPage() {
  const { user, loading } = useAuth();
  const openLogin = useUiStore((s) => s.openLoginDialog);

  return (
    <AppShell title="メッセージ">
      {loading ? null : !user ? (
        <div className="flex h-[60dvh] flex-col items-center justify-center gap-4 text-muted">
          <p>メッセージ機能を使うにはログインしてください</p>
          <button
            type="button"
            onClick={openLogin}
            className="rounded bg-primary px-4 py-2 font-bold text-on-primary"
          >
            ログイン
          </button>
        </div>
      ) : (
        <div className="h-[calc(100dvh-7rem)] overflow-y-auto">
          <SessionList selectedSessionId={null} />
        </div>
      )}
    </AppShell>
  );
}
