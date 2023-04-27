import express from 'express'
import {createServer} from 'http';
import {Server} from 'socket.io';
import dayjs from "dayjs";
import timezone from "dayjs/plugin/timezone.js";
import utc from "dayjs/plugin/utc.js";
import { Configuration, OpenAIApi } from "openai";
const configuration = new Configuration({
    apiKey: process.env.OPENAI_API_KEY,
});
const openai = new OpenAIApi(configuration);

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
        const response = await openai.createCompletion({
            model: "text-davinci-003",
            prompt: `次の情報を使って他人に興味を持ってもらえる自己紹介文を作成してください。結果だけで良いです。nullの値は無視してください。各キーの意味の対応は次の通りです。nickname:名前, born:出身地, age:年齢, job:仕事, interesting: 趣味: book: 好きな本, movie:好きな映画, goal:目標, treasure:人生の宝物。${JSON.stringify(param)}`,
            max_tokens: 2048,
            temperature: 0.9,
            stream: false,
            logprobs: null,
        });
        ack(response.data.choices[0].text);
    });

    socket.on('disconnecting', () => {
        console.log('disconnecting');
    });
});
