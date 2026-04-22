# Guide pas à pas — FacturAI avec Supabase

Ce guide est fait pour quelqu'un qui n'a **jamais** codé. Suis chaque étape dans l'ordre.

---

## Ce qu'on va faire

On va utiliser **Supabase**, un service en ligne gratuit qui fait tout le travail "invisible" du SaaS (base de données + connexion + sécurité) **sans que tu aies à installer quoi que ce soit sur ton ordinateur**.

Résultat à la fin : ton FacturAI fonctionne vraiment, les factures sont sauvegardées en ligne, et tu peux te connecter avec un vrai compte.

**Temps estimé : 30-45 minutes.**

---

## Étape 1 — Créer un compte Supabase (5 min)

1. Va sur https://supabase.com
2. Clique sur **Start your project** (en haut à droite)
3. Inscris-toi avec GitHub ou ton email
4. Une fois connecté, clique sur **New Project**
5. Remplis :
   - **Name** : `facturai`
   - **Database Password** : clique sur "Generate a password" et **copie-le dans un fichier texte** (tu en auras besoin si tu veux accéder directement à la base)
   - **Region** : `West EU (Paris)` ou `Frankfurt`
   - **Pricing Plan** : `Free` (gratuit, largement suffisant)
6. Clique sur **Create new project**
7. Attends 1-2 minutes que Supabase prépare ta base

---

## Étape 2 — Créer les tables (10 min)

Une table = un "tableau" dans la base de données (un pour les factures, un pour les clients, etc.).

1. Dans le menu de gauche de Supabase, clique sur **SQL Editor** (icône `</>`)
2. Clique sur **+ New query**
3. Ouvre le fichier `schema.sql` que je t'ai fourni
4. **Copie tout son contenu** et colle-le dans la grande zone de texte
5. Clique sur **Run** (bouton vert en bas à droite, ou Ctrl+Entrée)
6. Tu dois voir "Success. No rows returned" en bas → c'est bon, tes tables sont créées.

Pour vérifier : dans le menu de gauche, clique sur **Table Editor**. Tu dois voir les tables : `companies`, `clients`, `products`, `invoices`, `invoice_lines`, `quotes`.

---

## Étape 3 — Récupérer tes clés (2 min)

Ce sont les "coordonnées" pour que ton React puisse parler à Supabase.

1. Dans le menu de gauche, clique sur **Project Settings** (icône engrenage en bas)
2. Clique sur **API**
3. Tu vois deux choses importantes :
   - **Project URL** → copie-la (ex: `https://abcxyz.supabase.co`)
   - **anon public key** (juste en dessous) → copie-la aussi (une longue chaîne qui commence par `eyJ...`)
4. Garde ces deux valeurs dans un fichier texte temporaire, tu en as besoin à l'étape suivante.

---

## Étape 4 — Activer l'authentification (2 min)

1. Dans Supabase, menu de gauche → **Authentication** → **Providers**
2. **Email** est déjà activé par défaut → parfait
3. Dans **Authentication** → **URL Configuration** :
   - Mets `http://localhost:3000` dans **Site URL** (tu changeras quand tu publieras)
4. Dans **Authentication** → **Settings** (onglet en haut) :
   - Désactive **"Confirm email"** pour les tests (sinon il faut un vrai serveur mail) — tu le réactiveras plus tard pour la prod.

---

## Étape 5 — Installer le frontend sur CodeSandbox (10 min)

1. Va sur https://codesandbox.io et crée un sandbox **React** (comme vu avant)
2. Remplace les fichiers comme précédemment, **mais** utilise cette fois :
   - `src/App.js` → mon `App.js` dans `facturai-supabase/src/` (version avec Supabase)
   - `src/supabaseClient.js` → **à créer** (clic droit sur `src` → New File → nom : `supabaseClient.js`)
   - `src/styles.css` → le même qu'avant (ou celui que je fournis, identique)
   - `package.json` → celui de `facturai-supabase/` (il contient la dépendance Supabase)
3. Dans `src/supabaseClient.js`, **remplace les 2 lignes** :
   ```js
   const SUPABASE_URL = "COLLE_ICI_TON_URL";
   const SUPABASE_ANON_KEY = "COLLE_ICI_TA_CLE";
   ```
   par les vraies valeurs récupérées à l'étape 3.

---

## Étape 6 — Créer ton premier compte (2 min)

1. Ton sandbox se recompile → tu vois maintenant un écran de connexion
2. Clique sur **Créer un compte**
3. Remplis : nom, email, mot de passe, raison sociale
4. Valide → tu es connecté, tu vois le dashboard vide
5. Crée une facture, un client → retourne dans Supabase → **Table Editor** → tu vois tes données stockées en vrai !

---

## Ce qui fonctionne maintenant

- Inscription / connexion
- Chaque utilisateur voit uniquement **ses** factures (isolation automatique grâce aux "Row Level Security" de Supabase)
- Tout est sauvegardé en ligne (même si tu fermes l'onglet, tu retrouves tes données)
- Tu peux te connecter depuis n'importe quel ordinateur avec le même compte

---

## Limites de cette version

- **Pas d'export PDF** (à rajouter plus tard)
- **Pas d'envoi d'email** (à connecter avec Resend/SendGrid plus tard)
- **Pas de paiement Stripe** (à ajouter quand tu auras des clients payants)
- **IA simulée** (regex) — pour utiliser la vraie IA, il faudra ajouter une "Edge Function" Supabase avec ta clé OpenAI

---

## Problèmes fréquents

**"Invalid API key"** → tu as mal copié la clé, recopie-la sans espaces.

**"Failed to fetch"** → vérifie que tu as bien collé l'URL (avec `https://` devant).

**Les tables n'existent pas** → refais l'étape 2, le SQL n'a pas été exécuté.

**Je ne peux pas me connecter** → vérifie dans Supabase → Authentication → Users que ton compte s'est bien créé. Si "email not confirmed", désactive la confirmation email (étape 4).

---

## Pour publier en ligne (plus tard)

Une fois que ça marche en local :
1. Sur CodeSandbox, clique sur **Deploy** → **Vercel** (ou **Netlify**)
2. Dans Supabase → Authentication → URL Configuration → ajoute l'URL Vercel dans **Site URL**
3. C'est en ligne, partageable à de vrais utilisateurs.

Coût total à ce stade : **0 €** (tant que tu as moins de 50 000 utilisateurs Supabase et tant que ton site Vercel reste sous le quota gratuit).
