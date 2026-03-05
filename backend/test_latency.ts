import axios from 'axios';
import * as dotenv from 'dotenv';

dotenv.config();

const GROQ_API_KEY = process.env.GROQ_API_KEY;
const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY;

const GROQ_MODEL = process.env.GROQ_MODEL || 'llama-3.3-70b-versatile';
const OPENROUTER_MODEL = process.env.OPENROUTER_MODEL || 'stepfun/step-3.5-flash:free';

const prompt = "Please write a simple hello world program in python and return it in JSON format.";

async function testGroq() {
    console.log(`Testing Groq (${GROQ_MODEL})...`);
    const start = Date.now();
    try {
        const response = await axios.post(
            "https://api.groq.com/openai/v1/chat/completions",
            {
                model: GROQ_MODEL,
                messages: [{ role: "user", content: prompt }]
            },
            {
                headers: {
                    "Authorization": `Bearer ${GROQ_API_KEY}`,
                    "Content-Type": "application/json"
                }
            }
        );
        const end = Date.now();
        console.log(`Groq finished in ${end - start}ms.`);
        console.log(`Groq response: ${response.data.choices[0].message.content.substring(0, 50)}...`);
    } catch (err: any) {
        console.error("Groq error:", err.response?.data || err.message);
    }
}

async function testOpenRouter() {
    console.log(`\nTesting OpenRouter (${OPENROUTER_MODEL})...`);
    const start = Date.now();
    try {
        const response = await axios.post(
            "https://openrouter.ai/api/v1/chat/completions",
            {
                model: OPENROUTER_MODEL,
                messages: [{ role: "user", content: prompt }]
            },
            {
                headers: {
                    "Authorization": `Bearer ${OPENROUTER_API_KEY}`,
                    "Content-Type": "application/json"
                }
            }
        );
        const end = Date.now();
        console.log(`OpenRouter finished in ${end - start}ms.`);
        console.log(`OpenRouter response: ${response.data.choices[0].message.content.substring(0, 50)}...`);
    } catch (err: any) {
        console.error("OpenRouter error:", err.response?.data || err.message);
    }
}

async function runTests() {
    await testGroq();
    await testOpenRouter();
}

runTests();
