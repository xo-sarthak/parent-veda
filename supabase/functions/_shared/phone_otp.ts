// =============================================================================
//  _shared/phone_otp.ts — what phone-otp-send and phone-otp-verify must agree on
// -----------------------------------------------------------------------------
//  Two functions, one hash. If they ever hashed differently no code would ever
//  verify, silently, for everyone. So the hash lives here and both import it.
//  `_shared/` is Supabase's convention for code that is deployed WITH each
//  function but is not a function itself.
// =============================================================================

/// India-first E.164. Mirrors WhatsAppPrefs.normalizePhone in Dart — two
/// copies of one rule is a drift risk, which is why the SQL function holds
/// the final regex and refuses anything that is not +[1-9][0-9]{7,14}.
export function normalizePhone(raw: unknown): string | null {
  if (typeof raw !== "string") return null;
  const t = raw.trim();
  if (!t) return null;
  const hasPlus = t.startsWith("+");
  const digits = t.replace(/[^0-9]/g, "");
  if (!digits) return null;
  if (hasPlus) return `+${digits}`;
  if (digits.length === 10) return `+91${digits}`;
  if (digits.length === 12 && digits.startsWith("91")) return `+${digits}`;
  return `+${digits}`;
}

async function sha256Hex(s: string): Promise<string> {
  const d = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(s));
  return [...new Uint8Array(d)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

/// The hash the SQL side compares against: sha256(user_id ':' code). The user
/// id is the salt — the same code issued to two users hashes differently.
export const hashCode = (userId: string, code: string): Promise<string> =>
  sha256Hex(`${userId}:${code}`);

/// Six digits from a CSPRNG. Math.random is not acceptable for a code that
/// gates a consent — it is seeded per-isolate and predictable in principle.
export function sixDigits(): string {
  const buf = new Uint32Array(1);
  crypto.getRandomValues(buf);
  return String(buf[0] % 1_000_000).padStart(6, "0");
}
