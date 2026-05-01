"use client";

import { useEffect, useState } from "react";
import { observeSessions } from "@/lib/firestore/sessions";
import type { Session } from "@/types/session";

export function useSessions(userId: string | null): {
  sessions: Session[];
  ready: boolean;
} {
  const [sessions, setSessions] = useState<Session[]>([]);
  const [ready, setReady] = useState(false);
  useEffect(() => {
    if (!userId) {
      setSessions([]);
      setReady(true);
      return;
    }
    const unsub = observeSessions(userId, (next) => {
      setSessions(next);
      setReady(true);
    });
    return unsub;
  }, [userId]);
  return { sessions, ready };
}
