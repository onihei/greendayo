import { AppShell } from "@/components/layout/app-shell";
import { GAMES } from "@/lib/games";

export default function GamesPage() {
  return (
    <AppShell title="ゲーム">
      <div className="mx-auto max-w-3xl p-4">
        <header className="flex items-baseline justify-between border-b border-surface-variant pb-3">
          <p className="font-mono text-[11px] font-bold tracking-[0.35em] text-muted">
            GAME SELECT
          </p>
          <p className="font-mono text-[11px] tracking-widest text-muted">
            {String(GAMES.length).padStart(2, "0")} TITLES
          </p>
        </header>
        <ul className="mt-4 grid gap-3 sm:grid-cols-2">
          {GAMES.map((g, i) => (
            <li key={g.id}>
              <a
                href={g.url}
                target={g.id}
                rel="noopener"
                className="group relative flex h-full flex-col rounded-xl border border-surface-variant bg-surface p-4 transition-colors hover:border-primary/70 hover:bg-surface-variant/50"
              >
                <span
                  aria-hidden
                  className="absolute right-4 top-3 font-mono text-xs text-muted/60"
                >
                  {String(i + 1).padStart(2, "0")}
                </span>
                <div className="flex items-center gap-3">
                  <div
                    aria-hidden
                    className="flex h-12 w-12 shrink-0 items-center justify-center rounded-lg bg-surface-variant text-2xl transition-transform group-hover:scale-110"
                  >
                    {g.icon}
                  </div>
                  <div className="min-w-0">
                    <h2 className="truncate text-base font-bold">{g.title}</h2>
                    <p className="truncate text-xs text-primary">{g.subtitle}</p>
                  </div>
                </div>
                <p className="mt-3 flex-1 text-sm leading-relaxed text-foreground/80">
                  {g.description}
                </p>
                <div className="mt-3 self-end text-sm font-bold text-primary">
                  <span className="inline-block transition-transform group-hover:translate-x-1">
                    遊ぶ ▶
                  </span>
                </div>
              </a>
            </li>
          ))}
        </ul>
      </div>
    </AppShell>
  );
}
