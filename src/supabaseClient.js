import { createClient } from "@supabase/supabase-js";

// ⚠️ REMPLACE CES DEUX LIGNES par TES valeurs Supabase
// (Supabase → Project Settings → API)
const SUPABASE_URL = "COLLE_ICI_TON_URL";        // ex: https://abcxyz.supabase.co
const SUPABASE_ANON_KEY = "COLLE_ICI_TA_CLE";    // ex: eyJhbGciOi...

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
