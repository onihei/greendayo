"use client";

export async function resizeImageToJpegBlob(
  file: File,
  maxWidth = 500,
  quality = 0.8,
): Promise<Blob> {
  const bitmap = await createImageBitmap(file);
  const ratio = Math.min(1, maxWidth / bitmap.width);
  const w = Math.round(bitmap.width * ratio);
  const h = Math.round(bitmap.height * ratio);
  const canvas =
    typeof OffscreenCanvas !== "undefined"
      ? new OffscreenCanvas(w, h)
      : Object.assign(document.createElement("canvas"), { width: w, height: h });
  const ctx = (canvas as HTMLCanvasElement).getContext("2d")!;
  ctx.drawImage(bitmap, 0, 0, w, h);
  if (canvas instanceof OffscreenCanvas) {
    return await canvas.convertToBlob({ type: "image/jpeg", quality });
  }
  return await new Promise<Blob>((resolve, reject) =>
    (canvas as HTMLCanvasElement).toBlob(
      (b) => (b ? resolve(b) : reject(new Error("toBlob failed"))),
      "image/jpeg",
      quality,
    ),
  );
}

export function ulid(): string {
  // 26-char Crockford ULID (timestamp ms + random) — minimal impl
  const ENC = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";
  const t = Date.now();
  const tParts: string[] = [];
  let n = t;
  for (let i = 0; i < 10; i++) {
    tParts.unshift(ENC[n % 32]);
    n = Math.floor(n / 32);
  }
  const rParts: string[] = [];
  const rand = new Uint8Array(16);
  crypto.getRandomValues(rand);
  for (let i = 0; i < 16; i++) rParts.push(ENC[rand[i] % 32]);
  return tParts.join("") + rParts.join("");
}
