import { GoogleGenerativeAI } from '@google/generative-ai';
import axios from 'axios';

function getGroqKey() { return process.env.GROQ_API_KEY?.trim(); }
function getGeminiKey() { return process.env.GEMINI_API_KEY?.trim(); }

export async function generateContent(prompt: string, requireJSON: boolean = false): Promise<string> {
    // 1. Primary: Groq (Llama 3 70B Fast)
    const groqKey = getGroqKey();
    if (groqKey) {
        try {
            const modelName = process.env.GROQ_MODEL?.trim() || 'llama-3.3-70b-versatile';
            console.log("Diag: Attempting Groq for content. Key starts with:", groqKey.substring(0, 10));

            const payload: any = {
                model: modelName,
                messages: [{ role: "user", content: prompt }]
            };

            if (requireJSON) {
                payload.response_format = { type: "json_object" };
            }

            const response = await axios.post(
                "https://api.groq.com/openai/v1/chat/completions",
                payload,
                {
                    headers: {
                        "Authorization": `Bearer ${groqKey}`,
                        "Content-Type": "application/json"
                    },
                    timeout: 8000 // 8s timeout for high speed
                }
            );
            if (response.data?.choices?.[0]?.message?.content) {
                return response.data.choices[0].message.content.trim();
            }
        } catch (error: any) {
            console.error("Groq generateContent Failed, falling back to Gemini...");
            console.error("Groq Actual Error:", error.response?.data || error.message);
        }
    }

    // 2. Secondary: Gemini Direct
    const geminiKey = getGeminiKey();
    if (geminiKey) {
        console.log("Using Gemini Fallback for generateContent...");
        const genAI = new GoogleGenerativeAI(geminiKey);
        const modelDesc: any = { model: process.env.GEMINI_MODEL?.trim() || 'gemini-2.5-flash' };
        if (requireJSON) modelDesc.generationConfig = { responseMimeType: 'application/json' };

        const model = genAI.getGenerativeModel(modelDesc);
        const result = await model.generateContent(prompt);
        return result.response.text().trim();
    }

    throw new Error("No valid AI API Key configured for DevPulse.");
}

export type ChatMessage = { role: "system" | "user" | "assistant" | "model", content: string };

export async function generateChat(messages: ChatMessage[]): Promise<string> {
    // 1. Primary: Groq
    const groqKey = getGroqKey();
    if (groqKey) {
        try {
            const groqMessages = messages.map(m => ({
                role: m.role === 'model' ? 'assistant' : m.role,
                content: m.content
            }));
            const modelName = process.env.GROQ_MODEL?.trim() || 'llama-3.3-70b-versatile';
            console.log("Diag: Attempting Groq for chat. Key starts with:", groqKey.substring(0, 10));

            const response = await axios.post(
                "https://api.groq.com/openai/v1/chat/completions",
                {
                    model: modelName,
                    messages: groqMessages
                },
                {
                    headers: {
                        "Authorization": `Bearer ${groqKey}`,
                        "Content-Type": "application/json"
                    },
                    timeout: 10000
                }
            );
            if (response.data?.choices?.[0]?.message?.content) {
                return response.data.choices[0].message.content.trim();
            }
        } catch (error: any) {
            console.error("Groq generateChat Failed, falling back to Gemini...");
            console.error("Groq Actual Error:", error.response?.data || error.message);
        }
    }

    // 2. Secondary: Gemini
    const geminiKey = getGeminiKey();
    if (geminiKey) {
        console.log("Using Gemini Fallback for chat...");
        const genAI = new GoogleGenerativeAI(geminiKey);
        const model = genAI.getGenerativeModel({ model: process.env.GEMINI_MODEL?.trim() || 'gemini-2.5-flash' });

        const history: any[] = [];
        messages.slice(0, messages.length - 1).forEach((m) => {
            if (m.role === 'system') {
                history.push({ role: 'user', parts: [{ text: m.content }] });
                history.push({ role: 'model', parts: [{ text: "Understood, I am ready." }] });
            } else {
                history.push({
                    role: m.role === 'user' ? 'user' : 'model',
                    parts: [{ text: m.content }]
                });
            }
        });

        const lastMessage = messages[messages.length - 1];

        const chat = model.startChat({ history });
        const result = await chat.sendMessage(lastMessage.content);
        return result.response.text().trim();
    }

    throw new Error("No valid AI configuration found.");
}
