"use client";

import { type ReactNode } from "react";
import { useAuthSubscriber } from "@/lib/hooks/use-auth";

export function AuthProvider({ children }: { children: ReactNode }) {
  useAuthSubscriber();
  return <>{children}</>;
}
