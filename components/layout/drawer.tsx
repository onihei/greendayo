"use client";

import Link from "next/link";
import { useUiStore } from "@/stores/ui";
import { useAuth } from "@/lib/hooks/use-auth";
import { useMyProfile } from "@/lib/hooks/use-my-profile";

export function Drawer() {
  const open = useUiStore((s) => s.drawerOpen);
  const setOpen = useUiStore((s) => s.setDrawerOpen);
  const { user } = useAuth();
  const { profile } = useMyProfile();

  if (!open || !user) return null;

  return (
    <div
      className="fixed inset-0 z-50 bg-black/50"
      onClick={() => setOpen(false)}
    >
      <aside
        className="h-full w-[min(80vw,300px)] bg-surface p-4"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="mb-6 flex items-center gap-3">
          {profile?.photoUrl && (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={profile.photoUrl}
              alt=""
              className="h-12 w-12 rounded-full object-cover"
            />
          )}
          <div className="text-sm font-bold">{profile?.nickname ?? user.displayName}</div>
        </div>
        <nav className="flex flex-col gap-2">
          <Link
            href={`/profile/${user.uid}`}
            onClick={() => setOpen(false)}
            className="rounded px-3 py-2 hover:bg-surface-variant"
          >
            プロフィール
          </Link>
          <Link
            href="/profile/me/edit"
            onClick={() => setOpen(false)}
            className="rounded px-3 py-2 hover:bg-surface-variant"
          >
            プロフィール編集
          </Link>
        </nav>
      </aside>
    </div>
  );
}
