import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // This is needed if you're planning to invoke your function from a browser.
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const stripeKey = Deno.env.get("STRIPE_PUB_KEY");
  const mapsKey = Deno.env.get("GOOGLE_MAPS_API");

  return new Response(
    JSON.stringify({
      stripe_publishable_key: stripeKey,
      google_maps_api_key: mapsKey,
    }),
    {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    }
  );
});

