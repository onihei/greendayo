import { Timestamp, type DocumentData, type QueryDocumentSnapshot } from "firebase/firestore";

export type Session = {
  id: string;
  members: string[];
  updatedAt: Date;
};

export function membersExclude(session: Session, userId: string): string[] {
  return session.members.filter((id) => id !== userId);
}

export function fromSessionDoc(doc: QueryDocumentSnapshot<DocumentData>): Session {
  const d = doc.data();
  return {
    id: doc.id,
    members: [...(d.members as string[])],
    updatedAt: (d.updatedAt as Timestamp).toDate(),
  };
}

export function toSessionDoc(s: Omit<Session, "id">): DocumentData {
  return {
    members: s.members,
    updatedAt: Timestamp.fromDate(s.updatedAt),
  };
}
