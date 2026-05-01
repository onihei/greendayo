"use client";

import { useAuth } from "@/lib/hooks/use-auth";
import { useBbsStore } from "./store";
import { BbsBoard } from "./board";
import { BbsForm } from "./form";

export function BbsPageContent() {
  const { user } = useAuth();
  const enabled = useBbsStore((s) => s.formEnabled);
  const setEnabled = useBbsStore((s) => s.setFormEnabled);

  return (
    <div className="relative h-[calc(100dvh-7rem)]">
      <BbsBoard />
      <BbsForm />
      {user && !enabled && (
        <button
          type="button"
          onClick={() => setEnabled(true)}
          aria-label="新規投稿"
          className="absolute bottom-6 right-6 z-30 h-14 w-14 rounded-full bg-primary text-2xl text-on-primary shadow-lg"
        >
          ＋
        </button>
      )}
    </div>
  );
}
