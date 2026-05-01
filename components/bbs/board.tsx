"use client";

import { useGesture } from "@use-gesture/react";
import { useRef } from "react";
import { useArticles } from "@/lib/hooks/use-articles";
import { useBbsStore } from "./store";
import { ArticleCard } from "./card";

export function BbsBoard() {
  const { articles, ready } = useArticles();
  const scale = useBbsStore((s) => s.scale);
  const offsetX = useBbsStore((s) => s.offsetX);
  const offsetY = useBbsStore((s) => s.offsetY);
  const setScale = useBbsStore((s) => s.setScale);
  const setOffset = useBbsStore((s) => s.setOffset);
  const shake = useBbsStore((s) => s.shake);
  const startedScale = useRef(1);
  const startedOffset = useRef({ x: 0, y: 0 });

  const bind = useGesture(
    {
      onDragStart: () => {
        startedOffset.current = { x: offsetX, y: offsetY };
      },
      onDrag: ({ movement: [mx, my], pinching }) => {
        if (pinching) return;
        const s = startedScale.current || scale;
        setOffset(startedOffset.current.x + mx / s, startedOffset.current.y + my / s);
      },
      onDragEnd: () => shake(),
      onPinchStart: () => {
        startedScale.current = scale;
      },
      onPinch: ({ offset: [s] }) => setScale(Math.max(0.3, Math.min(3, s))),
      onPinchEnd: () => shake(),
    },
    {
      drag: { from: () => [0, 0] },
      pinch: { scaleBounds: { min: 0.3, max: 3 }, from: () => [scale, 0] },
    },
  );

  return (
    <div
      {...bind()}
      className="absolute inset-0 touch-none overflow-hidden bg-background"
      style={{ touchAction: "none" }}
    >
      <div
        className="absolute left-0 top-0 origin-top-left"
        style={{ transform: `scale(${scale})` }}
      >
        {ready &&
          articles.map((a) => (
            <div
              key={a.id}
              className="absolute"
              style={{
                left: offsetX + a.left,
                top: offsetY + a.top,
              }}
            >
              <ArticleCard article={a} />
            </div>
          ))}
      </div>
    </div>
  );
}
