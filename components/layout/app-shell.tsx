"use client";

import { type ReactNode } from "react";
import { AppBar } from "./app-bar";
import { BottomNav } from "./bottom-nav";
import { Drawer } from "./drawer";
import { LoginDialog } from "@/components/auth/login-dialog";

export function AppShell({
  title,
  children,
}: {
  title: string;
  children: ReactNode;
}) {
  return (
    <div className="flex min-h-full flex-col">
      <AppBar title={title} />
      <main className="flex-1">{children}</main>
      <BottomNav />
      <Drawer />
      <LoginDialog />
    </div>
  );
}
