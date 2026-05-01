"use client";

import { useEffect, useState } from "react";
import { observeTalks } from "@/lib/firestore/talks";
import type { Talk } from "@/types/talk";

export function useTalks(sessionId: string | null): {
  talks: Talk[];
  ready: boolean;
} {
  const [talks, setTalks] = useState<Talk[]>([]);
  const [ready, setReady] = useState(false);
  useEffect(() => {
    if (!sessionId) {
      setTalks([]);
      setReady(true);
      return;
    }
    const unsub = observeTalks(sessionId, (next) => {
      setTalks(next);
      setReady(true);
    });
    return unsub;
  }, [sessionId]);
  return { talks, ready };
}
