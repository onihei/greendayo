import {
  addDoc,
  collection,
  doc,
  onSnapshot,
  orderBy,
  query,
  type Unsubscribe,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import { fromTalkDoc, toTalkDoc, type Talk, type TalkInput } from "@/types/talk";

const talksCol = (sessionId: string) =>
  collection(doc(db, "sessions", sessionId), "talks");

export function observeTalks(
  sessionId: string,
  onChange: (talks: Talk[]) => void,
  onError?: (e: unknown) => void,
): Unsubscribe {
  const q = query(talksCol(sessionId), orderBy("createdAt"));
  return onSnapshot(
    q,
    (snap) => onChange(snap.docs.map(fromTalkDoc)),
    (err) => onError?.(err),
  );
}

export async function createTalk(sessionId: string, input: TalkInput): Promise<string> {
  const ref = await addDoc(talksCol(sessionId), toTalkDoc(input));
  return ref.id;
}
