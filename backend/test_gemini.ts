import { GoogleGenerativeAI } from '@google/generative-ai';
import * as dotenv from 'dotenv';
dotenv.config();

async function testGemini() {
    try {
        const key = process.env.GEMINI_API_KEY?.trim();
        if (!key) {
            console.log('No API key found in .env');
            return;
        }
        const genAI = new GoogleGenerativeAI(key);
        const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });
        const result = await model.generateContent('Say hello world.');
        console.log('Result:', result.response.text());
    } catch (err: any) {
        console.error('Error testing Gemini:', err.message);
    }
}
testGemini();
