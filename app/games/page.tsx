import { AppShell } from "@/components/layout/app-shell";
import { GAMES } from "@/lib/games";

export default function GamesPage() {
  return (
    <AppShell title="ゲーム">
      <ul className="mx-auto flex max-w-2xl flex-col gap-4 p-4">
        {GAMES.map((g) => (
          <li key={g.id}>
            <a
              href={g.url}
              target={g.id}
              rel="noopener"
              className="block rounded-lg bg-surface p-4 hover:bg-surface-variant"
            >
              <div className="flex items-start gap-4">
                <div
                  aria-hidden
                  className="flex h-16 w-16 shrink-0 items-center justify-center rounded-full text-3xl"
                  style={{ backgroundColor: `${g.color}26` }}
                >
                  {g.icon}
                </div>
                <div className="flex-1">
                  <h2 className="text-lg font-bold">{g.title}</h2>
                  <p className="text-sm" style={{ color: g.color }}>
                    {g.subtitle}
                  </p>
                  <p className="mt-2 text-sm text-foreground/90">
                    {g.description}
                  </p>
                  <div className="mt-3 text-right">
                    <span className="inline-block rounded bg-primary px-3 py-1 text-sm font-bold text-on-primary">
                      ▶ 遊ぶ
                    </span>
                  </div>
                </div>
              </div>
            </a>
          </li>
        ))}
      </ul>
    </AppShell>
  );
}
