import { GoogleGenerativeAI } from "@google/generative-ai";
import * as dotenv from "dotenv";
import * as path from "path";

dotenv.config({ path: path.resolve(__dirname, ".env") });

async function checkGeminiLimits() {
    const key = process.env.GEMINI_API_KEY;
    if (!key) {
        console.log("No GEMINI_API_KEY found in .env");
        process.exit(1);
    }

    const genAI = new GoogleGenerativeAI(key);
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

    console.log("Testing Gemini API rate limit...");
    try {
        const result = await model.generateContent("Hello, are you there?");
        console.log("Success! API is working.");
        console.log("Response:", result.response.text());
    } catch (error: any) {
        console.error("API Request Failed!");
        console.error("Status:", error?.status);
        console.error("Message:", error?.message);
        if (error?.status === 429 || error?.message?.includes("429")) {
            console.log("RATE LIMIT EXCEEDED.");
        }
    }
}

checkGeminiLimits();
