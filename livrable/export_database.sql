-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.favorites (
  id integer NOT NULL DEFAULT nextval('favorites_id_seq'::regclass),
  user_id uuid NOT NULL,
  item_id integer NOT NULL,
  type text NOT NULL,
  title text,
  poster_path text,
  added_at timestamp with time zone DEFAULT now(),
  CONSTRAINT favorites_pkey PRIMARY KEY (id),
  CONSTRAINT favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_profiles (
  id uuid NOT NULL,
  username text NOT NULL,
  full_name text,
  profile_picture text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone,
  name text,
  avatar_url text,
  email text NOT NULL,
  CONSTRAINT user_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT user_profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.watch_history (
  id integer NOT NULL DEFAULT nextval('watch_history_id_seq'::regclass),
  user_id uuid NOT NULL,
  item_id integer NOT NULL,
  type text NOT NULL,
  title text,
  poster_path text,
  season_number integer,
  episode_number integer,
  watched_at timestamp with time zone DEFAULT now(),
  CONSTRAINT watch_history_pkey PRIMARY KEY (id),
  CONSTRAINT watch_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.watchlist (
  id integer NOT NULL DEFAULT nextval('watchlist_id_seq'::regclass),
  user_id uuid NOT NULL,
  item_id integer NOT NULL,
  type text NOT NULL,
  title text,
  poster_path text,
  added_at timestamp with time zone DEFAULT now(),
  CONSTRAINT watchlist_pkey PRIMARY KEY (id),
  CONSTRAINT watchlist_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);