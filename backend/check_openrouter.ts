import axios from 'axios';

const OPENROUTER_API_KEY = "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";

async function testOpenRouter() {
    console.log("Testing OpenRouter API with llama-3-8b-instruct:free...");
    try {
        const response = await axios.post(
            "https://openrouter.ai/api/v1/chat/completions",
            {
                model: "google/gemini-2.5-flash:free",
                messages: [{ role: "user", content: "Hello, what model are you?" }]
            },
            {
                headers: {
                    "Authorization": `Bearer ${OPENROUTER_API_KEY}`,
                    "Content-Type": "application/json"
                }
            }
        );
        console.log("Success! OpenRouter API is working.");
        console.log("Response:", response.data.choices[0].message.content);
    } catch (error: any) {
        console.error("OpenRouter API Request Failed!");
        if (error.response) {
            console.error("Status:", error.response.status);
            console.error("Data:", error.response.data);
        } else {
            console.error(error.message);
        }
    }
}

testOpenRouter();
