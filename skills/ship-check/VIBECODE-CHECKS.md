# Les 10 trous récurrents du vibecode — checklist de revue statique

Référence de la section 5 de ship-check. Source : captures de bonnes
pratiques collectées par l'utilisateur (audit informel Express/Expo +
carrousel « Security holes I find in almost every vibecoded app ») —
extraites le 03/09/2026. Chaque item se vérifie dans le code, avec son test.

## 1. IDOR — autorisation par ressource

Le backend vérifie que l'utilisateur connecté a le droit sur CET
enregistrement — jamais confiance à l'ID de l'URL/du body. Le fix vit dans
l'autorisation backend, pas dans le frontend qui cache un bouton.
**Test** : connecté, changer l'ID dans l'URL (`/invoice/1045` → `/1047`).

## 2. Enforcement côté serveur

Prix, rôles, feature gates décidés côté serveur. Si le checkout envoie
`amount: 4900` et que le serveur facture tel quel, quelqu'un enverra
`amount: 1`. « The frontend is a suggestion, never the authority. »
**Test** : onglet Network sur le flux de paiement/permission — que se
passe-t-il si on modifie le payload ?

## 3. Rate limiting

- Par **utilisateur** + hard cap sur tout endpoint coûteux (LLM, génération
  d'images, API payante).
- Par **IP** sur les endpoints **pré-auth** qui coûtent (signup, « try it
  free », reset email touchant une API payante) — la limite par user est
  inutile si créer un compte est gratuit et instantané.
**Test** : « what happens if someone calls this 10,000 times? »

## 4. Auth/JWT

Auth de plateforme (Supabase Auth, Clerk, Auth0, Firebase Auth) plutôt que
JWT maison. Si maison : signature vérifiée, expiration, secret jamais côté
client, présence du secret vérifiée au boot. Entropie des codes d'invitation
(8 alphanumériques ≈ brute-forçable) ; validation email réelle (pas juste
« contient @ »).

## 5. SSRF

Toute feature où le SERVEUR télécharge une URL utilisateur (« import from
link », « screenshot this site ») : bloquer IP privées/internes et
**allowlister** les destinations — sinon l'endpoint de métadonnées cloud
livre les credentials de l'infra.

## 6. Uploads

Le `mimetype` déclaré par le client est bypassable : valider le fichier
lui-même. Un `.html`/`.svg` déguisé en `image/jpeg` servi statiquement =
XSS stocké. Servir les uploads avec security headers (le SVG exécute du JS).
URLs fournies par l'utilisateur (avatar…) validées avant rendu.

## 7. CORS

Verrouillé sur ses propres domaines — ouvert = requêtes au nom de tout
utilisateur connecté depuis n'importe quelle origine.

## 8. Limites d'entrée

Longueur maximale sur chaque champ ; body JSON borné (~1 Mo suffit à tout
payload normal, 50 Mo est un DoS offert) ; pagination sur toute liste
(jamais « tout charger en mémoire »).

## 9. PII dans les logs

Aucun log d'IP, email ou donnée personnelle en clair dans le logging
applicatif.

## 10. Actions d'agent IA

Si l'IA peut agir (outils, DB, emails) : chaque action dangereuse gatée par
un **vrai check de permission côté serveur** dans le tool handler — « not
just a line in the prompt ». (Le jailbreak-test du bot est runtime → section
« Au-delà du ship-check » du rapport.)
