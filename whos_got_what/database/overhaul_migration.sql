-- 1. Update Profiles Role Enum and Table
do $$ begin
    alter type user_role add value 'admin' after 'paid';
    alter type user_role rename value 'free' to 'regular';
    alter type user_role rename value 'paid' to 'business';
exception
    when duplicate_object then null;
    when others then null;
end $$;

-- 2. Subscriptions Table
create table if not exists subscriptions (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id) on delete cascade not null,
  tier_type text check (tier_type in ('business_basic', 'business_pro', 'individual')) not null,
  active_until timestamp with time zone not null,
  payment_method_id text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Payments Table
create table if not exists payments (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id) on delete cascade not null,
  event_id uuid references events(id) on delete set null,
  amount numeric not null,
  transaction_date timestamp with time zone default timezone('utc'::text, now()) not null,
  payment_type text check (payment_type in ('subscription', 'ala_carte')) not null,
  status text default 'completed'
);

-- 4. AI Preferences Table
create table if not exists ai_preferences (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id) on delete cascade not null unique,
  interests_json jsonb default '[]'::jsonb,
  engagement_metrics jsonb default '{}'::jsonb,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. Update Events Table
alter table events add column if not exists lat double precision;
alter table events add column if not exists lng double precision;
alter table events add column if not exists category text;
alter table events add column if not exists business_id uuid references profiles(id); -- If separate from creator

-- 6. RLS for New Tables
alter table subscriptions enable row level security;
alter table payments enable row level security;
alter table ai_preferences enable row level security;

-- Subscriptions Policies
create policy "Users can view own subscriptions" on subscriptions for select using (auth.uid() = user_id);

-- Payments Policies
create policy "Users can view own payments" on payments for select using (auth.uid() = user_id);

-- AI Preferences Policies
create policy "Users can view/update own preferences" on ai_preferences 
  for all using (auth.uid() = user_id);

-- 7. Function to initialize AI preferences on profile creation
create or replace function public.handle_new_profile_extras()
returns trigger as $$
begin
  insert into public.ai_preferences (user_id)
  values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_profile_created_extras on profiles;
create trigger on_profile_created_extras
  after insert on profiles
  for each row execute procedure public.handle_new_profile_extras();
