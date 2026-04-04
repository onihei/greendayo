import express from 'express'
import {createServer} from 'http';
import {Server} from 'socket.io';
import dayjs from "dayjs";
import timezone from "dayjs/plugin/timezone.js";
import utc from "dayjs/plugin/utc.js";
import { Anthropic } from "@anthropic-ai/sdk";
import multer from 'multer';
import path from 'path';
import fs from 'fs';
const anthropic = new Anthropic({
    apiKey: process.env.CLAUDE_API_KEY,
});

dayjs.extend(timezone);
dayjs.extend(utc);
dayjs.tz.setDefault("Asia/Tokyo");

const app = express();
app.use((req, res, next) => {
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type');
    if (req.method === 'OPTIONS') return res.sendStatus(204);
    next();
});
const httpServer = createServer(app);
const io = new Server(httpServer, {path: "/greendayo.io/"});

const UPLOADS_DIR = path.resolve('uploads');

// multer: アップロード先をリクエストパスに基づいて決定
const storage = multer.diskStorage({
    destination: (req, _file, cb) => {
        const dest = path.join(UPLOADS_DIR, path.dirname(req.params[0]));
        fs.mkdirSync(dest, {recursive: true});
        cb(null, dest);
    },
    filename: (_req, file, cb) => {
        cb(null, path.basename(_req.params[0]));
    },
});
const upload = multer({storage, limits: {fileSize: 10 * 1024 * 1024}}); // 10MB上限

// POST /storage/upload/* — ファイルアップロード
app.post('/storage/upload/*', upload.single('file'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({error: 'No file uploaded'});
    }
    const filePath = req.params[0];
    // メタ情報をサイドカーファイルに保存
    const metaPath = path.join(UPLOADS_DIR, path.dirname(filePath), path.basename(filePath) + '.meta.json');
    const meta = {
        mimetype: req.file.mimetype,
        size: req.file.size,
        originalName: req.file.originalname,
        uploadedAt: new Date().toISOString(),
    };
    fs.writeFileSync(metaPath, JSON.stringify(meta));
    const url = `/storage/${filePath}`;
    res.json({url});
});

// GET /storage/* — ファイル配信
app.get('/storage/*', (req, res) => {
    const filePath = path.join(UPLOADS_DIR, req.params[0]);
    if (!fs.existsSync(filePath)) {
        return res.status(404).json({error: 'Not found'});
    }
    const metaPath = filePath + '.meta.json';
    if (fs.existsSync(metaPath)) {
        const meta = JSON.parse(fs.readFileSync(metaPath, 'utf-8'));
        if (meta.mimetype) res.set('Content-Type', meta.mimetype);
    }
    res.set('Cache-Control', 'public, max-age=315360000');
    res.sendFile(filePath);
});

// DELETE /storage/* — ファイル削除
app.delete('/storage/*', (req, res) => {
    const filePath = path.join(UPLOADS_DIR, req.params[0]);
    if (!fs.existsSync(filePath)) {
        return res.status(404).json({error: 'Not found'});
    }
    fs.unlinkSync(filePath);
    // メタ情報も削除
    const metaPath = filePath + '.meta.json';
    if (fs.existsSync(metaPath)) fs.unlinkSync(metaPath);
    res.json({deleted: req.params[0]});
});

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
