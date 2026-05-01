"use client";

export async function uploadFile(blob: Blob, storagePath: string): Promise<string> {
  const fd = new FormData();
  fd.append("file", blob);
  fd.append("path", storagePath);
  const res = await fetch("/api/upload", { method: "POST", body: fd });
  if (!res.ok) {
    throw new Error(`upload failed: ${res.status}`);
  }
  const json = (await res.json()) as { url: string };
  return json.url;
}

export async function deleteUploaded(storagePathOrUrl: string): Promise<void> {
  let rel = storagePathOrUrl;
  if (rel.startsWith("http")) {
    try {
      rel = new URL(rel).pathname;
    } catch {
      // ignore
    }
  }
  rel = rel.replace(/^\/?(storage\/)?/, "");
  await fetch(`/api/upload/${rel}`, { method: "DELETE" });
}
