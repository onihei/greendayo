"use client";

import { useEffect, useState } from "react";
import { useAuthStore } from "@/stores/auth";
import { createOrGetProfile, observeProfile } from "@/lib/firestore/profiles";
import type { Profile } from "@/types/profile";

export function useMyProfile(): { profile: Profile | null; loading: boolean } {
  const user = useAuthStore((s) => s.user);
  const authLoading = useAuthStore((s) => s.loading);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (authLoading) return;
    if (!user) {
      setProfile(null);
      setLoading(false);
      return;
    }
    let unsub: (() => void) | undefined;
    let cancelled = false;
    (async () => {
      await createOrGetProfile(user);
      if (cancelled) return;
      unsub = observeProfile(user.uid, (p) => {
        setProfile(p);
        setLoading(false);
      });
    })();
    return () => {
      cancelled = true;
      unsub?.();
    };
  }, [user, authLoading]);

  return { profile, loading };
}
