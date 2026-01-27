import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const supabaseClient = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_ANON_KEY") ?? "",
            {
                global: {
                    headers: { Authorization: req.headers.get("Authorization")! },
                },
            }
        );

        const {
            data: { user },
        } = await supabaseClient.auth.getUser();

        if (!user) {
            throw new Error("No user found");
        }

        const { productId, purchaseToken, status, payload } = await req.json();

        // 1. Get product details
        const { data: product, error: productError } = await supabaseClient
            .from("iap_products")
            .select("*")
            .eq("id", productId)
            .single();

        if (productError || !product) {
            throw new Error(`Product not found: ${productId}`);
        }

        // 2. Record purchase
        const { error: purchaseError } = await supabaseClient
            .from("iap_purchases")
            .insert({
                user_id: user.id,
                product_id: productId,
                purchase_token: purchaseToken,
                status: status || "verified",
                payload: payload || {},
            });

        if (purchaseError) {
            // If it's a duplicate token, we might want to handle it (e.g., successful but already recorded)
            if (purchaseError.code !== "23505") {
                throw purchaseError;
            }
        }

        // 3. Update Profile
        const { data: profile, error: profileError } = await supabaseClient
            .from("profiles")
            .select("*")
            .eq("id", user.id)
            .single();

        if (profileError) throw profileError;

        let updatedRole = profile.role;
        let updatedCredits = profile.credits;

        if (productId === "Pro_User") {
            updatedRole = "paid";
        } else if (productId === "UNLIMITED_TIER") {
            updatedRole = "unlimited";
        } else if (productId === "SINGLE_EVENT_CREDIT") {
            updatedCredits = (profile.credits || 0) + (product.credits || 1);
        }

        const { error: updateError } = await supabaseClient
            .from("profiles")
            .update({
                role: updatedRole,
                credits: updatedCredits,
            })
            .eq("id", user.id);

        if (updateError) throw updateError;

        return new Response(
            JSON.stringify({ success: true, role: updatedRole, credits: updatedCredits }),
            {
                headers: { ...corsHeaders, "Content-Type": "application/json" },
                status: 200,
            }
        );
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
            status: 400,
        });
    }
});
