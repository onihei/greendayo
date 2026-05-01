"use client";

import { useEffect, useRef, useState } from "react";
import clsx from "clsx";
import { useTalks } from "@/lib/hooks/use-talks";
import { useMyProfile } from "@/lib/hooks/use-my-profile";
import { postTalk, startSessionWith } from "@/lib/talk-use-case";

export function TalkView({
  sessionId: initialSessionId,
  destinationUserId,
  onSessionCreated,
}: {
  sessionId: string | null;
  destinationUserId?: string;
  onSessionCreated?: (id: string) => void;
}) {
  const { profile } = useMyProfile();
  const [sessionId, setSessionId] = useState<string | null>(initialSessionId);
  const { talks } = useTalks(sessionId);
  const [text, setText] = useState("");
  const [busy, setBusy] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => setSessionId(initialSessionId), [initialSessionId]);
  useEffect(() => {
    scrollRef.current?.scrollTo({
      top: scrollRef.current.scrollHeight,
      behavior: "smooth",
    });
  }, [talks.length]);

  const onSend = async () => {
    if (!profile) return;
    const value = text.trim();
    if (value.length === 0) return;
    setBusy(true);
    try {
      if (sessionId) {
        await postTalk({ sessionId, senderUserId: profile.userId, text: value });
      } else if (destinationUserId) {
        const newId = await startSessionWith({
          myUserId: profile.userId,
          destinationUserId,
          text: value,
        });
        setSessionId(newId);
        onSessionCreated?.(newId);
      }
      setText("");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="flex h-full flex-col">
      <div ref={scrollRef} className="flex-1 overflow-y-auto p-4">
        {talks.map((t) => {
          const mine = t.sender === profile?.userId;
          return (
            <div
              key={t.id}
              className={clsx("my-2 flex", mine ? "justify-end" : "justify-start")}
            >
              <div
                className={clsx(
                  "max-w-[70%] rounded-3xl px-4 py-2 text-base",
                  mine
                    ? "rounded-tr-none bg-primary-container text-on-primary-container"
                    : "rounded-tl-none bg-surface-variant text-foreground",
                )}
              >
                {t.content}
              </div>
            </div>
          );
        })}
      </div>
      <div className="flex items-center gap-2 bg-primary-container p-2">
        <textarea
          value={text}
          onChange={(e) => setText(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter" && (e.metaKey || e.ctrlKey)) {
              e.preventDefault();
              onSend();
            }
          }}
          rows={1}
          className="flex-1 resize-none rounded bg-surface px-3 py-2 text-sm outline-none"
          placeholder="メッセージを入力 (⌘+Enter で送信)"
        />
        <button
          type="button"
          onClick={onSend}
          disabled={busy}
          aria-label="送信"
          className="rounded bg-primary px-4 py-2 font-bold text-on-primary disabled:opacity-50"
        >
          ▶
        </button>
      </div>
    </div>
  );
}
