import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import fs from "node:fs/promises";
import { safeJoin } from "@/lib/uploads";

export const runtime = "nodejs";

export async function DELETE(
  _req: NextRequest,
  ctx: { params: Promise<{ path: string[] }> },
): Promise<Response> {
  const { path: parts } = await ctx.params;
  const rel = parts.join("/");
  const full = safeJoin(rel);
  if (!full) {
    return NextResponse.json({ error: "invalid path" }, { status: 400 });
  }
  try {
    await fs.unlink(full);
    await fs.unlink(full + ".meta.json").catch(() => undefined);
    return NextResponse.json({ deleted: rel });
  } catch (e) {
    const code = (e as NodeJS.ErrnoException).code;
    if (code === "ENOENT") {
      return NextResponse.json({ error: "not found" }, { status: 404 });
    }
    return NextResponse.json({ error: "delete failed" }, { status: 500 });
  }
}
