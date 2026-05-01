"use client";

import { useRef, useState } from "react";
import { useAuth } from "@/lib/hooks/use-auth";
import { useMyProfile } from "@/lib/hooks/use-my-profile";
import { createArticle } from "@/lib/firestore/articles";
import { resizeImageToJpegBlob, ulid } from "@/lib/image-resize";
import { uploadFile } from "@/lib/upload-client";
import { useBbsStore } from "./store";

export function BbsForm() {
  const enabled = useBbsStore((s) => s.formEnabled);
  const setEnabled = useBbsStore((s) => s.setFormEnabled);
  const form = useBbsStore((s) => s.form);
  const setText = useBbsStore((s) => s.setText);
  const setPhoto = useBbsStore((s) => s.setPhoto);
  const resetForm = useBbsStore((s) => s.resetForm);
  const offsetX = useBbsStore((s) => s.offsetX);
  const offsetY = useBbsStore((s) => s.offsetY);
  const fileRef = useRef<HTMLInputElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const formRef = useRef<HTMLDivElement>(null);
  const { user } = useAuth();
  const { profile } = useMyProfile();
  const [busy, setBusy] = useState(false);

  if (!user || !enabled || !profile) return null;

  const onPickPhoto = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const blob = await resizeImageToJpegBlob(file, 500, 0.8);
    setPhoto(blob);
    e.target.value = "";
  };

  const onPost = async () => {
    if (busy) return;
    setBusy(true);
    try {
      let content: string;
      if (form.photoBlob) {
        const path = `bbs/photo/${ulid()}`;
        const url = await uploadFile(form.photoBlob, path);
        content = `<img src="${url}" data-rotation="${form.rotation}" />`;
      } else {
        if (form.text.trim().length === 0) {
          alert("投稿内容を記入してください");
          return;
        }
        content = form.text;
      }

      const stack = containerRef.current?.parentElement?.getBoundingClientRect();
      const fb = formRef.current?.getBoundingClientRect();
      const fx = fb && stack ? fb.left - stack.left : 0;
      const fy = fb && stack ? fb.top - stack.top : 0;

      await createArticle({
        content,
        signature: profile.nickname,
        left: -offsetX + fx,
        top: -offsetY + fy,
        width: form.width,
        createdAt: new Date(),
        createdBy: profile.userId,
      });
      resetForm();
      setEnabled(false);
    } finally {
      setBusy(false);
    }
  };

  return (
    <div
      ref={containerRef}
      className="pointer-events-none absolute inset-0 z-20 flex items-start justify-center pt-[20%]"
    >
      <div ref={formRef} className="pointer-events-auto">
        {form.photoBlob ? (
          <div
            style={{
              width: form.width,
              height: form.width + 16,
              transform: `rotate(${form.rotation}rad)`,
            }}
            className="rounded bg-white p-4 pb-8 shadow-lg"
          >
            {form.photoPreviewUrl && (
              // eslint-disable-next-line @next/next/no-img-element
              <img
                src={form.photoPreviewUrl}
                alt=""
                className="h-full w-full object-cover"
              />
            )}
          </div>
        ) : (
          <div
            style={{ width: form.width }}
            className="rounded bg-primary-container p-2 text-on-primary-container"
          >
            <textarea
              value={form.text}
              maxLength={200}
              onChange={(e) => setText(e.target.value)}
              placeholder="投稿内容をここに書いてください。"
              className="h-32 w-full resize-none bg-transparent text-sm outline-none placeholder:text-muted"
            />
            <div className="flex justify-between text-xs text-muted">
              <span>
                {form.text.length} / 200
              </span>
              <span>{profile.nickname}</span>
            </div>
          </div>
        )}
      </div>

      <div className="pointer-events-auto absolute bottom-0 left-0 right-0 flex items-center justify-end gap-3 bg-primary-container px-4 py-2">
        <input
          ref={fileRef}
          type="file"
          accept="image/*"
          onChange={onPickPhoto}
          className="hidden"
        />
        <button
          type="button"
          onClick={() => fileRef.current?.click()}
          aria-label="写真を選ぶ"
          className="rounded p-2 text-on-primary-container hover:bg-surface-variant"
        >
          📷
        </button>
        <button
          type="button"
          onClick={onPost}
          disabled={busy}
          className="rounded bg-primary px-4 py-2 text-sm font-bold text-on-primary disabled:opacity-50"
        >
          {busy ? "投稿中…" : "投稿する"}
        </button>
        <button
          type="button"
          onClick={() => {
            resetForm();
            setEnabled(false);
          }}
          className="rounded px-4 py-2 text-sm text-on-primary-container hover:bg-surface-variant"
        >
          キャンセル
        </button>
      </div>
    </div>
  );
}
