// ============================================================
// Supabase-Zugangsdaten
// ============================================================
// Nach dem Anlegen deines Supabase-Projekts (supabase.com):
// Settings → API → "Project URL" und "anon public" Key hier eintragen.
//
// Wichtig: Der "anon" Key ist bewusst öffentlich im Browser-Code sichtbar –
// das ist bei Supabase so vorgesehen. Der eigentliche Schutz kommt über
// Row Level Security (siehe supabase/schema.sql), NICHT über Geheimhaltung
// dieses Keys. Trage hier niemals den "service_role" Key ein!
// ============================================================

window.SUPABASE_URL = 'https://DEIN-PROJEKT.supabase.co';
window.SUPABASE_ANON_KEY = 'DEIN-ANON-PUBLIC-KEY';
