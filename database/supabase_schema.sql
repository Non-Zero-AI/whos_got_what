-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create Enum for User Roles (Drop first to ensure clean state if needed, or handle if exists)
do $$ begin
    create type user_role as enum ('free', 'paid');
exception
    when duplicate_object then null;
end $$;

-- PROFILES TABLE
create table if not exists profiles (
  id uuid references auth.users(id) on delete cascade not null primary key,
  role user_role default 'free'::user_role not null,
  credits int default 0 not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Add new columns safely if they don't exist
alter table profiles add column if not exists username text unique;
alter table profiles add column if not exists full_name text;
alter table profiles add column if not exists avatar_url text;
alter table profiles add column if not exists banner_url text;
alter table profiles add column if not exists bio text;
alter table profiles add column if not exists website text;
alter table profiles add column if not exists social_links jsonb default '{}'::jsonb;
alter table profiles add column if not exists contact_info jsonb default '{}'::jsonb;


-- EVENTS TABLE
create table if not exists events (
  id uuid default uuid_generate_v4() primary key,
  creator_id uuid references profiles(id) on delete cascade not null,
  title text not null,
  description text,
  image_url text,
  start_time timestamp with time zone not null,
  end_time timestamp with time zone not null,
  is_all_day boolean default false not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Add share_count if not exists
alter table events add column if not exists share_count int default 0 not null;


-- BOOKMARKS TABLE
create table if not exists bookmarks (
  user_id uuid references profiles(id) on delete cascade not null,
  event_id uuid references events(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (user_id, event_id)
);


-- LIKES TABLE
create table if not exists likes (
  user_id uuid references profiles(id) on delete cascade not null,
  event_id uuid references events(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (user_id, event_id)
);


-- COMMENTS TABLE
create table if not exists comments (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id) on delete cascade not null,
  event_id uuid references events(id) on delete cascade not null,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);


-- ENABLE RLS
alter table profiles enable row level security;
alter table events enable row level security;
alter table bookmarks enable row level security;
alter table likes enable row level security;
alter table comments enable row level security;


-- RLS POLICIES (DROP First to avoid "already exists" error)

-- PROFILES
drop policy if exists "Users can view own profile" on profiles;
create policy "Users can view own profile" on profiles for select using (auth.uid() = id);

drop policy if exists "Anyone can view profiles" on profiles;
create policy "Anyone can view profiles" on profiles for select using (true);

drop policy if exists "Users can update own profile" on profiles;
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);

-- EVENTS
drop policy if exists "Events are viewable by everyone" on events;
create policy "Events are viewable by everyone" on events for select using (true);

drop policy if exists "Paid users/Credits can insert events" on events;
create policy "Paid users/Credits can insert events" on events for insert with check (
    exists (
      select 1 from profiles
      where id = auth.uid()
      and (role = 'paid' or credits > 0)
    )
);

drop policy if exists "Creators can update own events" on events;
create policy "Creators can update own events" on events for update using (auth.uid() = creator_id);

drop policy if exists "Creators can delete own events" on events;
create policy "Creators can delete own events" on events for delete using (auth.uid() = creator_id);

-- BOOKMARKS
-- Select: Users can view their own
drop policy if exists "Users can view own bookmarks" on bookmarks;
create policy "Users can view own bookmarks" on bookmarks for select using (auth.uid() = user_id);

-- Insert/Delete: Only Non-Anonymous Users
drop policy if exists "Registered users can manage bookmarks" on bookmarks;
create policy "Registered users can manage bookmarks" on bookmarks for insert with check (
    auth.uid() = user_id
    and (auth.jwt() ->> 'is_anonymous')::boolean is not true
);
drop policy if exists "Registered users can delete bookmarks" on bookmarks;
create policy "Registered users can delete bookmarks" on bookmarks for delete using (
    auth.uid() = user_id
    and (auth.jwt() ->> 'is_anonymous')::boolean is not true
);


-- LIKES
-- Select: Everyone sees likes
drop policy if exists "Anyone can view likes" on likes;
create policy "Anyone can view likes" on likes for select using (true);

-- Insert/Delete: Only Non-Anonymous Users
drop policy if exists "Registered users can manage likes" on likes;
create policy "Registered users can manage likes" on likes for insert with check (
    auth.uid() = user_id
    and (auth.jwt() ->> 'is_anonymous')::boolean is not true
);
drop policy if exists "Registered users can delete likes" on likes;
create policy "Registered users can delete likes" on likes for delete using (
    auth.uid() = user_id
    and (auth.jwt() ->> 'is_anonymous')::boolean is not true
);

-- COMMENTS
-- Select: Everyone sees comments
drop policy if exists "Anyone can view comments" on comments;
create policy "Anyone can view comments" on comments for select using (true);

-- Insert/Delete: Only Non-Anonymous Users
drop policy if exists "Registered users can create comments" on comments;
create policy "Registered users can create comments" on comments for insert with check (
    auth.uid() = user_id
    and (auth.jwt() ->> 'is_anonymous')::boolean is not true
);
drop policy if exists "Registered users can delete own comments" on comments;
create policy "Registered users can delete own comments" on comments for delete using (
    auth.uid() = user_id
    and (auth.jwt() ->> 'is_anonymous')::boolean is not true
);


-- TRIGGERS
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, role, credits)
  values (new.id, 'free', 0)
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

-- Drop trigger first to ensure clean recreation
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
