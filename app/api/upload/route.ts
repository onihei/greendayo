import { NextResponse } from "next/server";
import fs from "node:fs/promises";
import path from "node:path";
import { MAX_UPLOAD_BYTES, safeJoin } from "@/lib/uploads";

export const runtime = "nodejs";

export async function POST(req: Request): Promise<Response> {
  const form = await req.formData();
  const file = form.get("file");
  const rel = form.get("path");
  if (!(file instanceof File)) {
    return NextResponse.json({ error: "file required" }, { status: 400 });
  }
  if (typeof rel !== "string" || rel.length === 0) {
    return NextResponse.json({ error: "path required" }, { status: 400 });
  }
  if (file.size > MAX_UPLOAD_BYTES) {
    return NextResponse.json({ error: "file too large" }, { status: 413 });
  }
  const full = safeJoin(rel);
  if (!full) {
    return NextResponse.json({ error: "invalid path" }, { status: 400 });
  }

  await fs.mkdir(path.dirname(full), { recursive: true });
  const buf = Buffer.from(await file.arrayBuffer());
  await fs.writeFile(full, buf);

  const meta = {
    mimetype: file.type || "application/octet-stream",
    size: file.size,
    originalName: file.name,
    uploadedAt: new Date().toISOString(),
  };
  await fs.writeFile(full + ".meta.json", JSON.stringify(meta));

  const normalized = rel.replace(/^\/+/, "");
  return NextResponse.json({ url: `/storage/${normalized}` });
}
