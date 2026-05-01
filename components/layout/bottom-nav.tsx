"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import clsx from "clsx";

const items = [
  { href: "/", label: "掲示板", icon: "📋" },
  { href: "/messenger", label: "メッセージ", icon: "✉️" },
  { href: "/games", label: "ゲーム", icon: "🎮" },
];

export function BottomNav() {
  const pathname = usePathname();
  return (
    <nav className="sticky bottom-0 z-30 grid grid-cols-3 border-t border-surface-variant bg-surface">
      {items.map((it) => {
        const active =
          it.href === "/" ? pathname === "/" : pathname.startsWith(it.href);
        return (
          <Link
            key={it.href}
            href={it.href}
            className={clsx(
              "flex flex-col items-center justify-center py-2 text-xs",
              active ? "text-primary" : "text-muted",
            )}
          >
            <span className="text-lg" aria-hidden>
              {it.icon}
            </span>
            <span>{it.label}</span>
          </Link>
        );
      })}
    </nav>
  );
}
