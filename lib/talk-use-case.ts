"use client";

import { createSession, touchSession } from "@/lib/firestore/sessions";
import { createTalk } from "@/lib/firestore/talks";

export async function postTalk(params: {
  sessionId: string;
  senderUserId: string;
  text: string;
}): Promise<void> {
  const { sessionId, senderUserId, text } = params;
  await createTalk(sessionId, {
    content: text,
    sender: senderUserId,
    createdAt: new Date(),
  });
  await touchSession(sessionId);
}

export async function startSessionWith(params: {
  myUserId: string;
  destinationUserId: string;
  text: string;
}): Promise<string> {
  const { myUserId, destinationUserId, text } = params;
  const sessionId = await createSession([myUserId, destinationUserId]);
  await createTalk(sessionId, {
    content: text,
    sender: myUserId,
    createdAt: new Date(),
  });
  return sessionId;
}
