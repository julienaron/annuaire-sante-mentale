# Annubus (accès réservé à l'équipe)

Adresse : https://julienaron.github.io/annuaire-sante-mentale/bpm-marseille/

Annubus, l'annuaire professionnel des partenaires de l'équipe : recherche, appel en un clic,
modification à plusieurs (avec détection des modifications simultanées), historique de 7 jours.

**Aucun contact n'est stocké dans ce dépôt public.** Les fiches sont dans une base Supabase
dont l'accès est limité aux adresses e-mail de la table `membres`.

## Mise en place (une seule fois)

1. Créer un compte sur https://supabase.com puis un projet gratuit (région : Europe).
2. *SQL Editor* > *New query* : coller `supabase-schema.sql`, puis *Run*.
3. *SQL Editor* > *New query* : coller le fichier d'import confidentiel (envoyé à part, jamais sur GitHub), puis *Run*.
4. *Authentication* > *URL Configuration* :
   - *Site URL* : `https://julienaron.github.io/annuaire-sante-mentale/bpm-marseille/`
   - *Redirect URLs* : ajouter la même adresse.
5. Indispensable pour les iPhone : *Authentication* > *Emails* > *Magic Link*, ajouter `Votre code : {{ .Token }}` dans le message.
   Le mail contiendra alors un code à 6 chiffres, à taper dans l'appli si le lien s'ouvre dans un autre navigateur.
6. *Project Settings* > *API* : copier l'*URL* et la clé *anon / publishable* dans `config.js`.

## Ajouter ou retirer un membre de l'équipe

Dans l'application, un **administrateur** ouvre le bouton « Accès » (ou menu ⋯ > « Gérer les accès ») :
ajout d'une adresse, retrait d'un accès, nomination d'autres administrateurs.
Il reste toujours au moins un administrateur (la base refuse de retirer le dernier).

Le premier administrateur est créé par le fichier d'import confidentiel. En secours, depuis Supabase :
*Table Editor* > `membres`, cocher la colonne `admin` sur la ligne voulue.

Le guide d'installation (bouton « ? ») s'ouvre tout seul à la première visite. Pour y afficher le nom de la personne
à contacter pour obtenir l'accès, ajouter dans `config.js` : `contactAcces: "Prénom Nom (chef de service)"`.

## Bon à savoir

- L'offre gratuite de Supabase envoie peu d'e-mails de connexion par heure : connecter les collègues un par un.
  Une fois connecté, on le reste sur l'appareil.
- Un projet Supabase gratuit se met en pause après 7 jours sans activité. La tâche GitHub
  `.github/workflows/annuaire-bpm-marseille-eveil.yml` interroge la base chaque matin pour l'éviter.
  Si la base ne répond plus, GitHub envoie un e-mail : ouvrir Supabase et cliquer sur « Resume project ».
- Sauvegarde : menu ⋯ de l'appli > « Télécharger l'annuaire (CSV) ».
- La bibliothèque Supabase (version 2.45.4, licence MIT) est copiée dans `vendor/` : l'appli ne dépend que de GitHub et de Supabase.
  Les polices viennent de Google Fonts ; si ce service est indisponible, le téléphone utilise sa police habituelle.
