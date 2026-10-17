# Annuaire Bus 31/32 (accès réservé à l'équipe)

Adresse : https://julienaron.github.io/annuaire-sante-mentale/bus3132/

Annuaire des partenaires de l'équipe du Bus 31/32 : recherche, appel en un clic,
modification à plusieurs (avec détection des modifications simultanées), historique de 7 jours.

**Aucun contact n'est stocké dans ce dépôt public.** Les fiches sont dans une base Supabase
dont l'accès est limité aux adresses e-mail de la table `membres`.

## Mise en place (une seule fois)

1. Créer un compte sur https://supabase.com puis un projet gratuit (région : Europe).
2. *SQL Editor* > *New query* : coller `supabase-schema.sql`, puis *Run*.
3. *SQL Editor* > *New query* : coller le fichier d'import confidentiel (envoyé à part, jamais sur GitHub), puis *Run*.
4. *Authentication* > *URL Configuration* :
   - *Site URL* : `https://julienaron.github.io/annuaire-sante-mentale/bus3132/`
   - *Redirect URLs* : ajouter la même adresse.
5. Facultatif, utile sur iPhone : *Authentication* > *Emails* > *Magic Link*, ajouter `{{ .Token }}` dans le message.
   Le mail contiendra alors un code à 6 chiffres, à taper dans l'appli si le lien s'ouvre dans un autre navigateur.
6. *Project Settings* > *API* : copier l'*URL* et la clé *anon / publishable* dans `config.js`.

## Ajouter ou retirer un membre de l'équipe

*Table Editor* > `membres` > *Insert row* : son adresse e-mail et son prénom.
Pour retirer l'accès : supprimer la ligne.

## Bon à savoir

- L'offre gratuite de Supabase envoie peu d'e-mails de connexion par heure : connecter les collègues un par un.
  Une fois connecté, on le reste sur l'appareil.
- Un projet gratuit se met en pause après 7 jours sans aucune visite ; il se relance depuis le tableau de bord Supabase.
- Sauvegarde : menu ⋯ de l'appli > « Télécharger l'annuaire (CSV) ».
