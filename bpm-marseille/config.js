// Connexion à la base Supabase de l'annuaire.
// Ces deux valeurs se trouvent dans Supabase > Project Settings > API.
// La clé « anon / publishable » est faite pour être visible : ce sont les règles d'accès
// de la base (réservée aux membres) qui protègent les données, pas cette clé.
window.ANNUAIRE_CONFIG = {
  supabaseUrl: "",      // ex. "https://abcdxyz.supabase.co"
  supabaseAnonKey: "",  // ex. "eyJhbGciOi..." ou "sb_publishable_..."
  contactAcces: ""      // facultatif : qui contacter pour obtenir l'accès, ex. "Julien (chef de service)"
};
