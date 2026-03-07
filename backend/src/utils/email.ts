import { Resend } from 'resend';

const resendApiKey = process.env.RESEND_API_KEY || '';
const resend = new Resend(resendApiKey);

/**
 * Sends a generic email using Resend.
 */
export async function sendEmail({
    to,
    subject,
    html,
    text,
}: {
    to: string;
    subject: string;
    html?: string;
    text?: string;
}) {
    if (!resendApiKey) {
        console.warn('RESEND_API_KEY is not set. Skipping email send.');
        return null;
    }

    try {
        const options: any = {
            from: 'DevPulse <notifications@devpulse.com>', // Replace with your verified domain
            to: [to],
            subject: subject,
        };
        if (html) options.html = html;
        if (text) options.text = text;

        const data = await resend.emails.send(options);

        console.log(`Email sent successfully to ${to}`, data);
        return data;
    } catch (error) {
        console.error('Failed to send email via Resend:', error);
        throw error;
    }
}

/**
 * Sends a streak warning email to a user.
 */
export async function sendStreakWarning(userEmail: string, daysLeft: number) {
    const subject = `🔥 DevPulse: Don't lose your streak!`;
    const html = `
        <div style="font-family: sans-serif; color: #333;">
            <h2>Your coding streak is at risk!</h2>
            <p>You have <strong>${daysLeft} day(s)</strong> left to code before your streak resets.</p>
            <p>Log in to <a href="https://devpulse.com">DevPulse</a> and write some code today!</p>
        </div>
    `;

    return sendEmail({
        to: userEmail,
        subject,
        html,
    });
}
