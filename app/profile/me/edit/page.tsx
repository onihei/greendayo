"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { AppShell } from "@/components/layout/app-shell";
import { useAuth } from "@/lib/hooks/use-auth";
import { useMyProfile } from "@/lib/hooks/use-my-profile";
import { useUiStore } from "@/stores/ui";
import { saveProfile } from "@/lib/firestore/profiles";
import { resizeImageToJpegBlob } from "@/lib/image-resize";
import { uploadFile } from "@/lib/upload-client";
import type { Profile } from "@/types/profile";

const QUESTIONS: Array<{
  key: keyof Omit<Profile, "userId" | "photoUrl" | "text">;
  label: string;
}> = [
  { key: "nickname", label: "名前またはニックネーム" },
  { key: "age", label: "年齢を教えて" },
  { key: "born", label: "出身地はどこ？" },
  { key: "job", label: "どんな仕事？" },
  { key: "interesting", label: "興味のあることは？" },
  { key: "book", label: "好きな本は" },
  { key: "movie", label: "好きな映画は" },
  { key: "goal", label: "目標は" },
  { key: "treasure", label: "人生の宝物は？" },
];

export default function EditMyProfilePage() {
  const { user, loading: authLoading } = useAuth();
  const { profile } = useMyProfile();
  const router = useRouter();
  const openLogin = useUiStore((s) => s.openLoginDialog);
  const fileRef = useRef<HTMLInputElement>(null);
  const [step, setStep] = useState(0);
  const [busy, setBusy] = useState(false);
  const [values, setValues] = useState<Record<string, string>>({});
  const [photoPreview, setPhotoPreview] = useState<string | null>(null);

  useEffect(() => {
    if (!profile) return;
    setValues({
      nickname: profile.nickname ?? "",
      age: profile.age ?? "",
      born: profile.born ?? "",
      job: profile.job ?? "",
      interesting: profile.interesting ?? "",
      book: profile.book ?? "",
      movie: profile.movie ?? "",
      goal: profile.goal ?? "",
      treasure: profile.treasure ?? "",
    });
    setPhotoPreview(profile.photoUrl ?? null);
  }, [profile]);

  if (authLoading) return null;
  if (!user) {
    return (
      <AppShell title="プロフィール編集">
        <div className="flex h-[60dvh] flex-col items-center justify-center gap-4 text-muted">
          <p>ログインしてください</p>
          <button
            type="button"
            onClick={openLogin}
            className="rounded bg-primary px-4 py-2 font-bold text-on-primary"
          >
            ログイン
          </button>
        </div>
      </AppShell>
    );
  }
  if (!profile) {
    return (
      <AppShell title="プロフィール編集">
        <div className="p-6 text-muted">読み込み中…</div>
      </AppShell>
    );
  }

  const onChange = (k: string, v: string) =>
    setValues((prev) => ({ ...prev, [k]: v }));

  const onSave = async () => {
    setBusy(true);
    try {
      let text: string | null = null;
      try {
        const res = await fetch("/api/profile-text", {
          method: "POST",
          headers: { "content-type": "application/json" },
          body: JSON.stringify({
            nickname: values.nickname || null,
            age: values.age || null,
            born: values.born || null,
            job: values.job || null,
            interesting: values.interesting || null,
            book: values.book || null,
            movie: values.movie || null,
            goal: values.goal || null,
            treasure: values.treasure || null,
          }),
        });
        if (res.ok) {
          const j = (await res.json()) as { text: string };
          text = j.text;
        }
      } catch {
        // テキスト生成失敗は致命ではないので続行
      }
      await saveProfile({
        ...profile,
        nickname: values.nickname,
        age: values.age || null,
        born: values.born || null,
        job: values.job || null,
        interesting: values.interesting || null,
        book: values.book || null,
        movie: values.movie || null,
        goal: values.goal || null,
        treasure: values.treasure || null,
        text: text ?? profile.text ?? null,
      });
      router.push(`/profile/${profile.userId}`);
    } finally {
      setBusy(false);
    }
  };

  const onPickPhoto = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setBusy(true);
    try {
      const blob = await resizeImageToJpegBlob(file, 500, 0.8);
      const url = await uploadFile(blob, `users/${profile.userId}/photo`);
      await saveProfile({ ...profile, photoUrl: url });
      setPhotoPreview(url + `?t=${Date.now()}`);
    } finally {
      setBusy(false);
      e.target.value = "";
    }
  };

  const q = QUESTIONS[step];

  return (
    <AppShell title="プロフィール編集">
      <div className="mx-auto max-w-md p-6">
        <div className="mb-6 flex flex-col items-center">
          <button
            type="button"
            onClick={() => fileRef.current?.click()}
            disabled={busy}
            className="overflow-hidden rounded-full"
          >
            {photoPreview ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img
                src={photoPreview}
                alt=""
                className="h-32 w-32 rounded-full object-cover"
              />
            ) : (
              <div className="flex h-32 w-32 items-center justify-center rounded-full bg-surface-variant text-muted">
                写真を追加
              </div>
            )}
          </button>
          <input
            ref={fileRef}
            type="file"
            accept="image/*"
            className="hidden"
            onChange={onPickPhoto}
          />
        </div>

        <div className="rounded-lg bg-surface p-6">
          <p className="mb-2 text-sm text-muted">{step + 1} / {QUESTIONS.length}</p>
          <label className="block text-sm">{q.label}</label>
          <input
            value={values[q.key] ?? ""}
            maxLength={20}
            onChange={(e) => onChange(q.key, e.target.value)}
            className="mt-2 w-full rounded bg-surface-variant px-3 py-2 outline-none"
          />
          <div className="mt-4 flex justify-between">
            <button
              type="button"
              onClick={() => setStep((s) => Math.max(0, s - 1))}
              disabled={step === 0}
              className="rounded px-4 py-2 text-sm disabled:opacity-30"
            >
              前へ
            </button>
            {step < QUESTIONS.length - 1 ? (
              <button
                type="button"
                onClick={() => setStep((s) => s + 1)}
                className="rounded bg-primary px-4 py-2 text-sm font-bold text-on-primary"
              >
                次へ
              </button>
            ) : (
              <button
                type="button"
                onClick={onSave}
                disabled={busy}
                className="rounded bg-primary px-4 py-2 text-sm font-bold text-on-primary disabled:opacity-50"
              >
                {busy ? "保存中…" : "保存して終了"}
              </button>
            )}
          </div>
        </div>
      </div>
    </AppShell>
  );
}
