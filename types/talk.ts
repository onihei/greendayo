import { Timestamp, type DocumentData, type QueryDocumentSnapshot } from "firebase/firestore";

export type Talk = {
  id: string;
  content: string;
  sender: string;
  createdAt: Date;
};

export type TalkInput = Omit<Talk, "id">;

export function fromTalkDoc(doc: QueryDocumentSnapshot<DocumentData>): Talk {
  const d = doc.data();
  return {
    id: doc.id,
    content: d.content,
    sender: d.sender,
    createdAt: (d.createdAt as Timestamp).toDate(),
  };
}

export function toTalkDoc(t: TalkInput): DocumentData {
  return {
    content: t.content,
    sender: t.sender,
    createdAt: Timestamp.fromDate(t.createdAt),
  };
}
