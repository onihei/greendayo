import path from "node:path";

const DEFAULT_DIR = "/var/lib/susipero/uploads";

export const UPLOADS_DIR = process.env.SUSIPERO_UPLOADS_DIR
  ? path.resolve(process.env.SUSIPERO_UPLOADS_DIR)
  : DEFAULT_DIR;

export const MAX_UPLOAD_BYTES = 10 * 1024 * 1024;

export function safeJoin(rel: string): string | null {
  const normalized = path
    .normalize(rel)
    .replace(/^([./\\])+/, "")
    .replace(/^\/+/, "");
  if (!normalized || normalized.startsWith("..") || normalized.includes("\0")) {
    return null;
  }
  const full = path.join(UPLOADS_DIR, normalized);
  const root = UPLOADS_DIR.endsWith(path.sep) ? UPLOADS_DIR : UPLOADS_DIR + path.sep;
  if (!full.startsWith(root) && full !== UPLOADS_DIR) {
    return null;
  }
  return full;
}
