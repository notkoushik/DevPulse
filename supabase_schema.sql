-- 1. Create a table for public profiles
create table profiles (
    id uuid references auth.users not null primary key,
    github_username text,
    leetcode_username text,
    wakatime_api_key text,
    updated_at timestamp with time zone
);
-- 2. Set up Row Level Security (RLS)
alter table profiles enable row level security;
create policy "Public profiles are viewable by everyone." on profiles for
select using (true);
create policy "Users can insert their own profile." on profiles for
insert with check (auth.uid() = id);
create policy "Users can update own profile." on profiles for
update using (auth.uid() = id);
-- 3. Automatically create a profile entry when a new user signs up
create function public.handle_new_user() returns trigger as $$ begin
insert into public.profiles (id)
values (new.id);
return new;
end;
$$ language plpgsql security definer;
create trigger on_auth_user_created
after
insert on auth.users for each row execute procedure public.handle_new_user();