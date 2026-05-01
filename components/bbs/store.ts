"use client";

import { create } from "zustand";

export type BbsFormState = {
  text: string;
  width: number;
  photoBlob: Blob | null;
  photoPreviewUrl: string | null;
  rotation: number;
};

type Store = {
  scale: number;
  offsetX: number;
  offsetY: number;
  formEnabled: boolean;
  form: BbsFormState;
  setScale: (s: number) => void;
  setOffset: (x: number, y: number) => void;
  setFormEnabled: (b: boolean) => void;
  setText: (t: string) => void;
  setPhoto: (blob: Blob | null) => void;
  shake: () => void;
  resetForm: () => void;
};

const emptyForm: BbsFormState = {
  text: "",
  width: 200,
  photoBlob: null,
  photoPreviewUrl: null,
  rotation: 0,
};

function randomRotation(): number {
  let u1 = 0;
  let u2 = 0;
  while (u1 === 0) u1 = Math.random();
  while (u2 === 0) u2 = Math.random();
  const r = Math.sqrt(-2 * Math.log(u1)) * Math.cos(2 * Math.PI * u2);
  return ((2.71828 - Math.abs(r)) * (Math.random() < 0.5 ? -1 : 1)) / 8;
}

export const useBbsStore = create<Store>((set, get) => ({
  scale: 1,
  offsetX: 0,
  offsetY: 0,
  formEnabled: false,
  form: emptyForm,
  setScale: (scale) => set({ scale }),
  setOffset: (offsetX, offsetY) => set({ offsetX, offsetY }),
  setFormEnabled: (formEnabled) => {
    if (formEnabled) set({ scale: 1, formEnabled });
    else set({ formEnabled });
  },
  setText: (text) => set({ form: { ...get().form, text } }),
  setPhoto: (blob) => {
    const prev = get().form.photoPreviewUrl;
    if (prev) URL.revokeObjectURL(prev);
    set({
      form: {
        ...get().form,
        photoBlob: blob,
        photoPreviewUrl: blob ? URL.createObjectURL(blob) : null,
        rotation: blob ? randomRotation() : 0,
      },
    });
  },
  shake: () => {
    if (!get().form.photoBlob) return;
    set({ form: { ...get().form, rotation: randomRotation() } });
  },
  resetForm: () => {
    const prev = get().form.photoPreviewUrl;
    if (prev) URL.revokeObjectURL(prev);
    set({ form: emptyForm });
  },
}));
