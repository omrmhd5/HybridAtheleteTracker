const { GoogleGenerativeAI } = require("@google/generative-ai");
const { supabaseAdmin } = require("../config/supabase");
const { tipToApi } = require("../utils/mappers");
const dashboardService = require("./dashboard.service");
const env = require("../config/env");

class TipsService {
  constructor() {
    if (env.GEMINI_API_KEY) {
      this.genAI = new GoogleGenerativeAI(env.GEMINI_API_KEY);
      this.model = this.genAI.getGenerativeModel({
        model: "gemini-3.1-flash-lite",
      });
    }
  }

  async getWeeklyTip(userId) {
    const now = new Date();
    // Week start is Monday
    const weekStart = new Date(now);
    weekStart.setDate(
      now.getDate() - now.getDay() + (now.getDay() === 0 ? -6 : 1),
    );
    weekStart.setHours(0, 0, 0, 0);

    // Check if we already generated a tip for this week
    const { data: existingTip } = await supabaseAdmin
      .from("tips")
      .select("*")
      .eq("user_id", userId)
      .gte("week_start_date", weekStart.toISOString())
      .order("week_start_date", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (existingTip) {
      return tipToApi(existingTip);
    }

    // Generate new tip
    const summary = await dashboardService.getWeeklySummary(userId);
    let tipText =
      "Keep up the good work! Track your workouts, food, and cardio to get personalized tips.";

    if (
      this.model &&
      (summary.lifting.sessionsCount > 0 || summary.cardio.sessionsCount > 0)
    ) {
      try {
        const prompt = `
          You are a friendly sports coach. Analyze this athlete's last 7 days:

          Lifting: ${summary.lifting.sessionsCount} sessions, ${summary.lifting.totalVolume} total volume lifted.
          Cardio: ${summary.cardio.sessionsCount} sessions, ${summary.cardio.totalMinutes} minutes total.
          Food: Hit protein goal on ${summary.food.daysGoalMet} out of ${summary.food.logsCount} tracked days.

          Give 1-3 short, friendly, evidence-based observations (max 3 sentences each).
          Focus on connections between categories. Use second person ("Your lifts...").
          Do not be prescriptive. End with one encouraging sentence.
        `;
        console.log("--- GEMINI: Generating insight for user", userId, "---");
        console.log("Prompt:", prompt);

        const result = await this.model.generateContent(prompt);
        tipText = result.response.text();

        console.log("--- GEMINI: Insight generated successfully ---");
        console.log("Result:", tipText);
      } catch (error) {
        console.error("--- GEMINI API ERROR ---", error);
      }
    }

    const { data: newTip, error } = await supabaseAdmin
      .from("tips")
      .insert({
        user_id: userId,
        week_start_date: weekStart.toISOString(),
        tip_text: tipText,
        data_snapshot: summary,
      })
      .select("*")
      .single();

    if (error) throw new Error(error.message);
    return tipToApi(newTip);
  }

  async getTipHistory(userId) {
    const { data, error } = await supabaseAdmin
      .from("tips")
      .select("*")
      .eq("user_id", userId)
      .order("week_start_date", { ascending: false });
    if (error) throw new Error(error.message);
    return data.map(tipToApi);
  }

  async chatWithCoach(userId, message, history = []) {
    if (!this.model) {
      return "AI Coach is currently unavailable (No API Key).";
    }

    try {
      const summary = await dashboardService.getWeeklySummary(userId);

      const contextPrompt = `
        You are a highly motivating, friendly, and expert fitness coach.
        The user you are talking to has the following stats from the last 7 days:
        - Lifting: ${summary.lifting.sessionsCount} sessions, ${summary.lifting.totalVolume} total volume.
        - Cardio: ${summary.cardio.sessionsCount} sessions, ${summary.cardio.totalMinutes} minutes.
        - Food: Met protein goal ${summary.food.daysGoalMet} out of ${summary.food.logsCount} days.

        Use this context to give personalized, concise, and helpful advice. Keep answers relatively short (1-4 paragraphs) and engaging.
      `;

      // If history is empty, inject context as a system instruction (by prepending it to history)
      const chatHistory = [...history];
      if (chatHistory.length === 0) {
        chatHistory.push({
          role: "user",
          parts: [{ text: contextPrompt }],
        });
        chatHistory.push({
          role: "model",
          parts: [
            {
              text: "Got it! I am ready to help coach you based on your latest stats.",
            },
          ],
        });
      }

      const chat = this.model.startChat({
        history: chatHistory,
      });

      console.log("--- GEMINI: Sending chat message ---", message);
      const result = await chat.sendMessage(message);
      return result.response.text();
    } catch (error) {
      console.error("--- GEMINI API CHAT ERROR ---", error);
      throw new Error("Failed to generate AI response");
    }
  }
}

module.exports = new TipsService();
