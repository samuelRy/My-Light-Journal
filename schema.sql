-- MyLight: run this in Supabase > SQL Editor
create table thoughts (
  id bigint generated always as identity primary key,
  mood text not null,
  text text not null,
  author text
);
create index on thoughts (mood);

create table entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  entry_date date not null default current_date,
  mood text not null,
  category text not null,
  text text not null,
  thought text,
  thought_author text,
  created_at timestamptz default now()
);

alter table thoughts enable row level security;
alter table entries enable row level security;
create policy "read thoughts" on thoughts for select to authenticated using (true);
create policy "own entries select" on entries for select to authenticated using (user_id = auth.uid());
create policy "own entries insert" on entries for insert to authenticated with check (user_id = auth.uid());
create policy "own entries delete" on entries for delete to authenticated using (user_id = auth.uid());

-- API: one random thought for a mood
create function random_thought(p_mood text)
returns table (text text, author text)
language sql stable as $$
  select t.text, t.author from thoughts t where t.mood = p_mood order by random() limit 1
$$;

insert into thoughts (mood, text, author) values
('Calm','Nothing can disturb a quiet mind.','Proverb'),
('Calm','Peace begins with a single breath.','Unknown'),
('Calm','Stillness is where clarity lives.','Unknown'),
('Happy','Joy shared is joy doubled.','Proverb'),
('Happy','Let today be remembered for its smile.','Unknown'),
('Happy','Happiness grows when you notice it.','Unknown'),
('Motivated','If you never shoot, you’ll never miss.','Spicyuuu, TikTok'),
('Motivated','Start where you are. Use what you have.','Arthur Ashe'),
('Motivated','Momentum begins with one small step.','Unknown'),
('Tired','Rest is part of the work.','Unknown'),
('Tired','You don’t have to carry everything today.','Unknown'),
('Tired','Even the sun sets to rise again.','Proverb'),
('Sad','This too shall pass.','Persian proverb'),
('Sad','Even the darkest night will end.','Victor Hugo'),
('Sad','It’s okay to feel what you feel.','Unknown'),
('Frustrated','Breathe. The problem will still be solvable in a minute.','Unknown'),
('Frustrated','Obstacles are often the path in disguise.','Unknown'),
('Frustrated','Progress is rarely a straight line.','Unknown'),
('Other','Every feeling is a signal, not a verdict.','Unknown'),
('Other','Showing up today is enough.','Unknown'),
('Other','Small lights still push back the dark.','Unknown');
