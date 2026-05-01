import {
  Timestamp,
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDoc,
  onSnapshot,
  orderBy,
  query,
  updateDoc,
  where,
  type Unsubscribe,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import { fromSessionDoc, toSessionDoc, type Session } from "@/types/session";

const sessionsCol = () => collection(db, "sessions");

export async function getSession(sessionId: string): Promise<Session | null> {
  const snap = await getDoc(doc(sessionsCol(), sessionId));
  if (!snap.exists()) return null;
  return fromSessionDoc(snap);
}

export function observeSessions(
  userId: string,
  onChange: (sessions: Session[]) => void,
  onError?: (e: unknown) => void,
): Unsubscribe {
  const q = query(
    sessionsCol(),
    orderBy("updatedAt", "desc"),
    where("members", "array-contains", userId),
  );
  return onSnapshot(
    q,
    (snap) => onChange(snap.docs.map(fromSessionDoc)),
    (err) => onError?.(err),
  );
}

export async function createSession(members: string[]): Promise<string> {
  const ref = await addDoc(
    sessionsCol(),
    toSessionDoc({ members, updatedAt: new Date() }),
  );
  return ref.id;
}

export async function touchSession(sessionId: string): Promise<void> {
  await updateDoc(doc(sessionsCol(), sessionId), {
    updatedAt: Timestamp.fromDate(new Date()),
  });
}

export async function deleteSession(sessionId: string): Promise<void> {
  await deleteDoc(doc(sessionsCol(), sessionId));
}
