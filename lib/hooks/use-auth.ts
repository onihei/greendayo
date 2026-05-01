"use client";

import { useEffect } from "react";
import { onAuthStateChanged } from "firebase/auth";
import { auth } from "@/lib/firebase";
import { useAuthStore } from "@/stores/auth";

export function useAuthSubscriber(): void {
  const setUser = useAuthStore((s) => s.setUser);
  useEffect(() => {
    const unsub = onAuthStateChanged(auth, (user) => setUser(user));
    return unsub;
  }, [setUser]);
}

export function useAuth() {
  return useAuthStore();
}
