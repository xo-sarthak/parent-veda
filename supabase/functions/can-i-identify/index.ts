// =============================================================================
//  can-i-identify — what is in this photo? A NAME, never a verdict.
// -----------------------------------------------------------------------------
//  2026-09-19, the Is it safe? door. The app sends one photo (JPEG, ≤1024px,
//  base64); this function asks a vision model for the plain name of the
//  food, drink, medicine or activity in it and returns that name. The app
//  then looks the name up in its OWN reviewed data. The model never says
//  whether a thing is safe — that stays ParentVeda's, clinically reviewed,
//  in can_i_data.dart. Identification is the only thing outsourced.
//
//  WHY A FUNCTION AND NOT THE APP. The vision key cannot ship in an APK:
//  anything in the app can be pulled out with a decompiler and then
//  strangers run up the bill. The key lives here, as a Supabase secret,
//  and the app never sees it. The function is stateless — one request in,
//  one name out — which is why it does not need a server of its own.
//
//  PROVIDER-AGNOSTIC. One secret picks the provider; the prompt and the
//  response shape are the same for all three, so the pricing decision
//  (docs/STILL-OPEN.md §68) is a `supabase secrets set`, not a deploy.
//
//  NOT CONFIGURED IS A REAL ANSWER. With no key set the function returns
//  503 { error: "not_configured" } and the app says "switching on soon" and
//  hands her the field. It never pretends.
//
//  DEPLOY:
//    supabase functions deploy can-i-identify
//  SECRETS (pick one provider; set its key):
//    supabase secrets set CAN_I_VISION_PROVIDER=groq
//    supabase secrets set GROQ_API_KEY=...
//      — or —
//    supabase secrets set CAN_I_VISION_PROVIDER=anthropic
//    supabase secrets set ANTHROPIC_API_KEY=...
//      — or —
//    supabase secrets set CAN_I_VISION_PROVIDER=google
//    supabase secrets set GOOGLE_AI_API_KEY=...
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const PROVIDER = (Deno.env.get("CAN_I_VISION_PROVIDER") ?? "").toLowerCase();
const GROQ_KEY = Deno.env.get("GROQ_API_KEY") ?? "";
const ANTHROPIC_KEY = Deno.env.get("ANTHROPIC_API_KEY") ?? "";
const GOOGLE_KEY = Deno.env.get("GOOGLE_AI_API_KEY") ?? "";

// Models: the cheapest vision-capable tier of each, as of 2026-09.
const GROQ_MODEL = Deno.env.get("CAN_I_VISION_MODEL") ?? "meta-llama/llama-4-scout-17b-16e-instruct";
const ANTHROPIC_MODEL = Deno.env.get("CAN_I_VISION_MODEL") ?? "claude-haiku-4-5-20251001";
const GOOGLE_MODEL = Deno.env.get("CAN_I_VISION_MODEL") ?? "gemini-2.5-flash";

const PROMPT =
  "This photo was taken by a pregnant woman in India who wants to know if the thing in it " +
  "is safe for her. Name the ONE main food, drink, medicine, cosmetic or activity in the " +
  "photo in one to four plain English words, as a shopper would say it (for example " +
  "'papaya', 'masala chai', 'paracetamol tablets', 'hair dye', 'pani puri'). If it is a " +
  "packaged product, name the generic thing, not the brand. If you cannot tell, reply " +
  "exactly 'unknown'. Reply with the name only, no punctuation, no sentence.";

const MAX_BYTES = 1_600_000; // ~1.2MB of JPEG once base64 is decoded

function json(status: number, body: unknown) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

function clean(s: string): string {
  const t = s.trim().toLowerCase().replace(/^["'`\s]+|["'`.\s]+$/g, "").split("\n")[0];
  return t.length === 0 || t.length > 60 ? "unknown" : t;
}

async function askGroq(b64: string, mime: string, prompt: string): Promise<string> {
  const r = await fetch("https://api.groq.com/openai/v1/chat/completions", {
    method: "POST",
    headers: { Authorization: `Bearer ${GROQ_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      model: GROQ_MODEL,
      max_tokens: 20,
      temperature: 0,
      messages: [{
        role: "user",
        content: [
          { type: "text", text: prompt },
          { type: "image_url", image_url: { url: `data:${mime};base64,${b64}` } },
        ],
      }],
    }),
  });
  if (!r.ok) throw new Error(`groq ${r.status} ${await r.text()}`);
  const j = await r.json();
  return j.choices?.[0]?.message?.content ?? "unknown";
}

async function askAnthropic(b64: string, mime: string, prompt: string): Promise<string> {
  const r = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "x-api-key": ANTHROPIC_KEY,
      "anthropic-version": "2023-06-01",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: ANTHROPIC_MODEL,
      max_tokens: 20,
      messages: [{
        role: "user",
        content: [
          { type: "image", source: { type: "base64", media_type: mime, data: b64 } },
          { type: "text", text: prompt },
        ],
      }],
    }),
  });
  if (!r.ok) throw new Error(`anthropic ${r.status} ${await r.text()}`);
  const j = await r.json();
  return j.content?.find((c: { type: string }) => c.type === "text")?.text ?? "unknown";
}

async function askGoogle(b64: string, mime: string, prompt: string): Promise<string> {
  const r = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${GOOGLE_MODEL}:generateContent?key=${GOOGLE_KEY}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }, { inline_data: { mime_type: mime, data: b64 } }] }],
        generationConfig: { maxOutputTokens: 20, temperature: 0 },
      }),
    },
  );
  if (!r.ok) throw new Error(`google ${r.status} ${await r.text()}`);
  const j = await r.json();
  return j.candidates?.[0]?.content?.parts?.[0]?.text ?? "unknown";
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json(405, { error: "method" });

  const configured =
    (PROVIDER === "groq" && GROQ_KEY) ||
    (PROVIDER === "anthropic" && ANTHROPIC_KEY) ||
    (PROVIDER === "google" && GOOGLE_KEY);
  if (!configured) return json(503, { error: "not_configured" });

  let body: { image?: string; mime?: string; hint?: string };
  try {
    body = await req.json();
  } catch {
    return json(400, { error: "bad_json" });
  }
  const b64 = (body.image ?? "").replace(/^data:[^,]+,/, "");
  const mime = body.mime === "image/png" ? "image/png" : "image/jpeg";
  if (!b64) return json(400, { error: "no_image" });
  if (b64.length > MAX_BYTES * 1.37) return json(413, { error: "too_large" });
  // Her word, when she gave one. It goes to the model as context, capped
  // and quoted so it reads as data, not as a new instruction.
  const hint = (body.hint ?? "").toString().trim().slice(0, 80).replace(/["\n]/g, " ");

  try {
    const prompt = hint
      ? `${PROMPT} The person who took the photo says it is: "${hint}". Use that to ` +
        "disambiguate; if the photo clearly shows something else, name what the photo shows."
      : PROMPT;
    const raw = PROVIDER === "groq"
      ? await askGroq(b64, mime, prompt)
      : PROVIDER === "anthropic"
      ? await askAnthropic(b64, mime, prompt)
      : await askGoogle(b64, mime, prompt);
    const name = clean(raw);
    console.log(`[can-i-identify] ${PROVIDER} -> ${name}`);
    return json(200, { name, provider: PROVIDER });
  } catch (e) {
    // The provider's refusal is the diagnosis; log it, hand the app a
    // plain "unknown" so the sheet offers the field and Ask Veda.
    console.error("[can-i-identify]", String(e));
    return json(502, { error: "provider", detail: String(e).slice(0, 200) });
  }
});
