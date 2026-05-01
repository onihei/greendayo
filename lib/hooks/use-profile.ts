"use client";

import { useEffect, useState } from "react";
import { observeProfile } from "@/lib/firestore/profiles";
import type { Profile } from "@/types/profile";

export function useProfile(userId: string | null): {
  profile: Profile | null;
  ready: boolean;
} {
  const [profile, setProfile] = useState<Profile | null>(null);
  const [ready, setReady] = useState(false);
  useEffect(() => {
    if (!userId) {
      setProfile(null);
      setReady(true);
      return;
    }
    const unsub = observeProfile(userId, (p) => {
      setProfile(p);
      setReady(true);
    });
    return unsub;
  }, [userId]);
  return { profile, ready };
}
