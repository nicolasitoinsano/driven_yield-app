// Supabase Edge Function: send-cita-notification
// Se invoca desde el trigger de la BD (fn_notificar_nueva_cita) al crear una cita.
// Manda un push FCM a todos los dispositivos guardados del usuario (cliente o admin).
//
// Variables de entorno requeridas (Project Settings > Edge Functions > Secrets):
//   SUPABASE_URL                (ya viene inyectada por Supabase)
//   SUPABASE_SERVICE_ROLE_KEY   (ya viene inyectada por Supabase)
//   FCM_SERVICE_ACCOUNT_JSON    (contenido completo del JSON del service account de Firebase)
//
// Deploy:  supabase functions deploy send-cita-notification
// Secret:  supabase secrets set FCM_SERVICE_ACCOUNT_JSON="$(cat service-account.json)"

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { create, getNumericDate } from "https://deno.land/x/djwt@v3.0.2/mod.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const FCM_SERVICE_ACCOUNT_JSON = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON")!;

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

async function getAccessToken(): Promise<string> {
  const account = JSON.parse(FCM_SERVICE_ACCOUNT_JSON);

  const keyData = account.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const binaryKey = Uint8Array.from(atob(keyData), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const jwt = await create(
    { alg: "RS256", typ: "JWT" },
    {
      iss: account.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      exp: getNumericDate(60 * 60),
      iat: getNumericDate(0),
    },
    cryptoKey,
  );

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(`OAuth error: ${JSON.stringify(data)}`);
  return data.access_token as string;
}

async function sendPush(projectId: string, accessToken: string, token: string, title: string, body: string) {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          android: { priority: "high" },
        },
      }),
    },
  );
  if (!res.ok) {
    const err = await res.text();
    console.error(`FCM error for token ${token}:`, err);
  }
}

Deno.serve(async (req) => {
  try {
    const { id_usuario, titulo, mensaje } = await req.json();

    const title = titulo ?? "Cita registrada";
    const body = mensaje ?? "Tienes una actualizacion de tu cita.";

    const { data: devices } = await supabase
      .from("dispositivo_push")
      .select("token")
      .eq("id_usuario", id_usuario);

    if (!devices || devices.length === 0) {
      return new Response(JSON.stringify({ ok: true, sent: 0 }), { status: 200 });
    }

    const account = JSON.parse(FCM_SERVICE_ACCOUNT_JSON);
    const accessToken = await getAccessToken();

    await Promise.all(
      devices.map((d) => sendPush(account.project_id, accessToken, d.token, title, body)),
    );

    return new Response(JSON.stringify({ ok: true, sent: devices.length }), { status: 200 });
  } catch (err) {
    console.error(err);
    return new Response(JSON.stringify({ ok: false, error: String(err) }), { status: 500 });
  }
});
