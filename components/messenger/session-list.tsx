"use client";

import Link from "next/link";
import { useSessions } from "@/lib/hooks/use-sessions";
import { useMyProfile } from "@/lib/hooks/use-my-profile";
import { useProfile } from "@/lib/hooks/use-profile";
import { membersExclude, type Session } from "@/types/session";
import { deleteSession } from "@/lib/firestore/sessions";

export function SessionList({
  selectedSessionId,
  onSelect,
}: {
  selectedSessionId: string | null;
  onSelect?: (id: string) => void;
}) {
  const { profile } = useMyProfile();
  const { sessions, ready } = useSessions(profile?.userId ?? null);

  if (!ready) return null;
  if (sessions.length === 0) {
    return <p className="p-6 text-muted">まだ会話はありません。</p>;
  }
  return (
    <ul className="divide-y divide-surface-variant">
      {sessions.map((s) => (
        <SessionTile
          key={s.id}
          session={s}
          myUserId={profile!.userId}
          selected={s.id === selectedSessionId}
          onSelect={onSelect}
        />
      ))}
    </ul>
  );
}

function SessionTile({
  session,
  myUserId,
  selected,
  onSelect,
}: {
  session: Session;
  myUserId: string;
  selected: boolean;
  onSelect?: (id: string) => void;
}) {
  const otherId = membersExclude(session, myUserId)[0] ?? null;
  const { profile: other } = useProfile(otherId);

  const onDelete = async (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (!confirm("この会話を削除しますか?")) return;
    await deleteSession(session.id);
  };

  const Body = (
    <div
      className={
        "flex items-center gap-3 px-3 py-2 " +
        (selected ? "bg-surface-variant" : "hover:bg-surface-variant")
      }
    >
      {other?.photoUrl && (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={other.photoUrl}
          alt=""
          className="h-10 w-10 rounded-full object-cover"
        />
      )}
      <div className="flex-1 truncate">{other?.nickname ?? "…"}</div>
      <button
        type="button"
        onClick={onDelete}
        aria-label="削除"
        className="rounded p-2 text-muted hover:text-danger"
      >
        ✕
      </button>
    </div>
  );

  if (onSelect) {
    return (
      <li>
        <button
          type="button"
          onClick={() => onSelect(session.id)}
          className="w-full text-left"
        >
          {Body}
        </button>
      </li>
    );
  }
  return (
    <li>
      <Link href={`/messenger/${session.id}`}>{Body}</Link>
    </li>
  );
}
