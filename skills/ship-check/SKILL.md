---
name: ship-check
description: >
  Audit pré-publication d'un repo : secrets (historique git compris),
  dépendances, hygiène repo + légal, infra Supabase, et surface applicative
  vibecode (IDOR, RLS, rate limiting, SSRF, uploads…). Verdict GO/NO-GO par
  section, rapport SHIP-REPORT.md. Use when: l'utilisateur demande
  explicitement un ship-check / « peut-on publier/déployer ce repo ? » /
  « passe-le en public ». Uniquement sur demande explicite, avant un passage
  en public ou un deploy.
license: MIT
---

# Ship Check

Contexte : un repo fonctionnel qu'on s'apprête à exposer (public, deploy,
vraie donnée). Le skill établit les **faits** et rend un verdict — il ne
répare presque rien lui-même :

- **Rapport d'abord** : `SHIP-REPORT.md` (non commité), verdict **GO /
  NO-GO par section** + verdict global. Toute réparation au-delà de
  l'inoffensif est une décision de l'utilisateur, listée avec sa commande.
- **Auto-fix limité à l'inoffensif**, sur branche `ship-check/<date>` :
  `.gitignore`, licence manquante, `.env.example`. Rien d'autre.
- **Un secret trouvé n'est JAMAIS réaffiché** ni commité nulle part :
  chemin + type + empreinte tronquée (4 premiers caractères) au rapport ;
  valeurs complètes dans un inventaire local `chmod 600` hors repo, dont le
  chemin est donné à l'utilisateur.

Chaque section est skippable si non applicable (pas de Supabase, pas de
backend…) — le rapport dit alors « N/A » avec la raison, jamais silence.

## Section 1 — Secrets

`uvx gitleaks git` (historique complet) + `uvx gitleaks dir` (working tree).
En plus du scan : secret JWT/session vérifié présent au démarrage (absent =
tokens forgeables), aucune clé **secrète** dans du code servi au client
(seules les clés *publishable* Supabase/Firebase y ont leur place — c'est le
RLS qui protège, pas la clé), aucun token/credential codé en dur.
NO-GO : tout secret actif dans l'historique d'un repo destiné au public.

## Section 2 — Dépendances

`npm audit` / `pip-audit` (via uvx) par package + alertes Dependabot
(`gh api`). NO-GO : vulnérabilité **critical atteignable en prod**
(dépendance runtime, pas devDependency). High : listées avec l'upgrade
proposé. Moderate/low : comptées, sans bloquer. Vérifier aussi qu'aucun
`venv/`, `node_modules/` ou artefact de build n'est commité.

## Section 3 — Hygiène repo & légal

- `.gitignore` couvre env, artefacts, venvs ; variables d'env **documentées**
  (`.env.example` sans valeurs) ; licence présente ; visibilité du repo
  cohérente avec son contenu.
- Légal minimal si l'app a des utilisateurs : Privacy Policy présente et
  sincère — mentionne la collecte de données, l'usage d'IA s'il y en a, les
  collecteurs tiers ; aucun faux témoignage dans le contenu.

## Section 4 — Infra Supabase (si le repo y est lié)

**Lecture seule stricte** — jamais de modification RLS/policy automatique.
Advisors sécurité via l'API Management (curl uniquement, jamais urllib —
WAF ; token : trousseau macOS `security find-generic-password -s "Supabase
CLI" -w` ; sinon dashboard). Vérifier en plus des advisors :

- tables à vraies données sans RLS, policies `USING (true)`, et le piège
  `OR user_id IS NULL` (rend les lignes sans propriétaire publiques) ;
- policies trouées : jointure vers une table à policy ouverte, ou colonne
  vérifiée que l'utilisateur peut définir lui-même ;
- vues `SECURITY DEFINER` exposées à anon ;
- buckets Storage : public ET **listing** autorisé = fichiers « privés »
  simplement non listés.

## Section 5 — Surface applicative (revue statique vibecode)

Passer la checklist de `VIBECODE-CHECKS.md` (à côté de ce fichier) — les 10
trous récurrents des apps vibecodées avec leurs tests concrets : IDOR,
enforcement serveur, rate limiting (par user + par IP sur les endpoints
pré-auth coûteux), JWT, SSRF, uploads, CORS, limites d'entrée, PII dans les
logs, actions d'agent IA. Chaque item : ✅ / ⚠️ / 🕳️ avec fichier:ligne.
La revue ici reste statique — les « Test : » de la checklist s'exécutent
contre une stack locale via `/proof-run --checks` (skill voisin).

## Livrable

1. `SHIP-REPORT.md` (non commité) : verdict par section, verdict global
   (NO-GO si une section NO-GO), findings avec fichier:ligne et commande de
   correction proposée, section finale **« Au-delà du ship-check »** — les
   pratiques runtime/design non vérifiables statiquement (plafond de dépense
   fournisseur, effacement effectif des données, flux d'annulation,
   jailbreak-test du bot, matrice de permissions) en recommandations.
2. Si auto-fixes inoffensifs : branche + PR draft. Sinon aucun commit.
3. Commits sans Co-Authored-By ni mention d'IA.
