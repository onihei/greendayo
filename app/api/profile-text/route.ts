import { NextResponse } from "next/server";
import Anthropic from "@anthropic-ai/sdk";

export const runtime = "nodejs";

type Body = {
  nickname?: string | null;
  born?: string | null;
  age?: string | null;
  job?: string | null;
  interesting?: string | null;
  book?: string | null;
  movie?: string | null;
  goal?: string | null;
  treasure?: string | null;
};

export async function POST(req: Request): Promise<Response> {
  const apiKey = process.env.CLAUDE_API_KEY;
  if (!apiKey) {
    return NextResponse.json({ error: "CLAUDE_API_KEY not configured" }, { status: 500 });
  }
  const body = (await req.json()) as Body;
  const input = {
    名前: body.nickname,
    出身地: body.born,
    年齢: body.age,
    仕事: body.job,
    趣味: body.interesting,
    好きな本: body.book,
    好きな映画: body.movie,
    目標: body.goal,
    人生の宝物: body.treasure,
  };

  const anthropic = new Anthropic({ apiKey });
  const result = await anthropic.messages.create({
    model: "claude-haiku-4-5-20251001",
    max_tokens: 2048,
    temperature: 0.9,
    messages: [
      {
        role: "user",
        content: `次の情報を使って他人に興味を持ってもらえる自己紹介文を作成してください。結果のテキストだけを出力してください。nullは特にないか教えたくないとこを意味しますので無視して良いです。最後に幸せ自慢を加えてください。${JSON.stringify(input)}`,
      },
    ],
  });

  const block = result.content[0];
  const text = block.type === "text" ? block.text : "";
  return NextResponse.json({ text });
}
