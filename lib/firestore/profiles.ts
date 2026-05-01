import { doc, getDoc, onSnapshot, setDoc, type Unsubscribe } from "firebase/firestore";
import type { User } from "firebase/auth";
import { db } from "@/lib/firebase";
import { fromProfileDoc, toProfileDoc, type Profile } from "@/types/profile";

const profileRef = (userId: string) => doc(db, "profiles", userId);

export async function getProfile(userId: string): Promise<Profile | null> {
  const snap = await getDoc(profileRef(userId));
  if (!snap.exists()) return null;
  return fromProfileDoc(snap);
}

export function observeProfile(
  userId: string,
  onChange: (profile: Profile | null) => void,
  onError?: (e: unknown) => void,
): Unsubscribe {
  return onSnapshot(
    profileRef(userId),
    (snap) => onChange(snap.exists() ? fromProfileDoc(snap) : null),
    (err) => onError?.(err),
  );
}

export async function saveProfile(profile: Profile): Promise<void> {
  await setDoc(profileRef(profile.userId), toProfileDoc(profile));
}

export async function createOrGetProfile(user: User): Promise<Profile> {
  const existing = await getProfile(user.uid);
  if (existing) return existing;
  const profile: Profile = {
    userId: user.uid,
    nickname: user.displayName ?? "名無し",
    photoUrl: user.photoURL ?? null,
  };
  await saveProfile(profile);
  return profile;
}
