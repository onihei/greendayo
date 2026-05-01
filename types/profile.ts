import type { DocumentData, DocumentSnapshot } from "firebase/firestore";

export type Profile = {
  userId: string;
  nickname: string;
  photoUrl: string | null;
  age?: string | null;
  born?: string | null;
  job?: string | null;
  interesting?: string | null;
  book?: string | null;
  movie?: string | null;
  goal?: string | null;
  treasure?: string | null;
  text?: string | null;
};

export const ANONYMOUS_PROFILE: Profile = {
  userId: "anonymous",
  nickname: "no_name",
  photoUrl: null,
};

export function fromProfileDoc(doc: DocumentSnapshot<DocumentData>): Profile {
  const d = doc.data() ?? {};
  return {
    userId: doc.id,
    nickname: d.nickname ?? "no_name",
    photoUrl: d.photoUrl ?? null,
    age: d.age ?? null,
    born: d.born ?? null,
    job: d.job ?? null,
    interesting: d.interesting ?? null,
    book: d.book ?? null,
    movie: d.movie ?? null,
    goal: d.goal ?? null,
    treasure: d.treasure ?? null,
    text: d.text ?? null,
  };
}

export function toProfileDoc(p: Profile): DocumentData {
  return {
    nickname: p.nickname,
    photoUrl: p.photoUrl,
    age: p.age ?? null,
    born: p.born ?? null,
    job: p.job ?? null,
    interesting: p.interesting ?? null,
    book: p.book ?? null,
    movie: p.movie ?? null,
    goal: p.goal ?? null,
    treasure: p.treasure ?? null,
    text: p.text ?? null,
  };
}
