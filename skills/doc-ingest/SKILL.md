---
name: doc-ingest
description: >
  Amène des documents (PDF, DOCX, PPTX, XLSX, images) dans le contexte agent
  en markdown propre via markitdown. Use when: l'utilisateur donne un PDF ou
  un document Office à lire, analyser, résumer ou convertir, ou veut « ce
  PDF en contexte / en markdown ».
license: MIT
---

# Doc Ingest

Décision d'abord, conversion ensuite :

| Cas | Faire |
|---|---|
| PDF court (≤ ~20 pages), usage unique dans la conversation | Lecture native du PDF (outil Read, param `pages`) — pas de conversion. |
| PDF long, document Office (docx/pptx/xlsx), lot de fichiers, ou réutilisation prévue (grep, sessions futures, autres agents) | Convertir en `.md` avec markitdown, puis travailler sur le `.md`. |

## Conversion

```bash
uvx "markitdown[all]" <fichier> -o <même-nom>.md
```

- Sortie par défaut : à côté de la source, même nom en `.md`. Un `.md` déjà
  présent se compare avant d'écraser (la source a pu changer).
- Lot : une sortie par fichier source, mêmes règles.
- **Contrôler la sortie** : un `.md` quasi vide pour un PDF non vide = PDF
  scanné (images). markitdown n'a pas d'OCR fiable seul → le signaler et
  basculer sur la lecture native du PDF (Read rend les pages visuellement,
  images comprises).
- **XLSX** : sortie = une table markdown par feuille. Au-delà de quelques
  centaines de lignes, parser (pandas/csv) au lieu d'ingérer la table brute
  en contexte.

## Après conversion

Travailler sur le `.md` (Read/Grep), citer le document d'origine dans les
livrables, et laisser le `.md` en place : c'est le cache réutilisable pour
les prochaines sessions et les autres agents.
