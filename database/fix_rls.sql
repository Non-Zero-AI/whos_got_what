-- Fix for RLS Forbidden Error on Profile Creation
-- Run this in your Supabase Dashboard SQL Editor

-- Allow users to insert their own profile
-- This is necessary if the automatic trigger failed or for manual profile creation/upsert.
create policy "Users can insert own profile" on profiles for insert with check (auth.uid() = id);
