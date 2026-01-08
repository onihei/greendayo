import express from 'express'
import {createServer} from 'http';
import {Server} from 'socket.io';
import dayjs from "dayjs";
import timezone from "dayjs/plugin/timezone.js";
import utc from "dayjs/plugin/utc.js";
import { Anthropic } from "@anthropic-ai/sdk";
const anthropic = new Anthropic({
    apiKey: process.env.CLAUDE_API_KEY,
});

dayjs.extend(timezone);
dayjs.extend(utc);
dayjs.tz.setDefault("Asia/Tokyo");

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {path: "/greendayo.io/"});

httpServer.listen(10005, () => {
    console.log('Server started on port 10005');
});
io.on('connection', async (socket) => {
    console.log('A user connected');
    const userId = socket.handshake.query.userId;
    console.log(`userId: ${userId}`);
    if (!userId) {
        socket.disconnect();
        return
    }

    socket.on('generateProfileText', async (param, ack) => {
        const input = {
            '名前': param.nickname,
            '出身地': param.born,
            '年齢': param.age,
            '仕事': param.job,
            '趣味': param.interesting,
            '好きな本': param.book,
            '好きな映画': param.movie,
            '目標': param.goal,
            '人生の宝物': param.treasure,
        };
        // console.log(input);
        const chatCompletion = await anthropic.messages.create({
            model: "claude-haiku-4-5-20251001", // Claudeのモデル名
            max_tokens: 2048,
            temperature: 0.9,
            messages: [
              {
                role: "user",
                content: `次の情報を使って他人に興味を持ってもらえる自己紹介文を作成してください。結果のテキストだけを出力してください。nullは特にないか教えたくないとこを意味しますので無視して良いです。最後に幸せ自慢を加えてください。${JSON.stringify(input)}`
               }
            ],
        });
        // console.log(chatCompletion.content);
        ack(chatCompletion.content[0].text);
    });

    socket.on('disconnecting', () => {
        console.log('disconnecting');
    });
});
