# Nano-style — la barre de qualité de la couche 2

Référence extraite du canon Karpathy : micrograd (94 lignes pour un moteur
d'autograd complet), nanoGPT (`model.py`, 330 lignes pour GPT-2 entier),
minbpe. À lire au début de la couche 2 : c'est à ça que doit ressembler le
code d'arrivée.

## La cible

1. **Lisible de haut en bas** : un fichier = un sujet, l'ordre de définition
   suit l'ordre de compréhension, docstring de fichier qui annonce le
   périmètre (« all of it in this single file ») et cite ses références.
2. **Cœur minimal, dérivés dérivés** : micrograd définit add/mul/pow, puis
   `sub = add(neg)`, `div = mul(pow(-1))`. Tout ce qui est exprimable via les
   primitives est exprimé via elles, jamais dupliqué.
3. **Une abstraction n'existe que justifiée — et se justifie dans sa
   docstring** : `LayerNorm` de nanoGPT existe uniquement parce que
   « PyTorch doesn't support simply bias=False », et sa docstring le dit.
   Une classe sans état propre est une fonction ; un wrapper à un seul
   appelant s'inline ; une closure remplace un pattern Strategy/Visitor.
4. **Pipeline vertical** : une transformation par ligne, réassignation de la
   même variable (`x = self.c_fc(x)` → `x = self.gelu(x)` → …). L'astuce
   one-liner se déplie en étapes nommées.
5. **Les commentaires portent ce que le code ne peut pas dire** : formes des
   données `# (B, nh, T, hs)`, tradeoffs `# padded up to nearest multiple of
   64 for efficiency`, contraintes d'environnement `# requires PyTorch >=
   2.0`. La paraphrase de la ligne n'existe pas.
6. **assert = contrat exécutable** sur les invariants internes :
   `assert isinstance(other, (int, float)), "only supporting int/float
   powers for now"` — vérifie ET documente la limite en une ligne.
7. **Config = dataclass à plat en tête de fichier**, chaque défaut commenté
   avec sa raison (`bias: bool = True # True: like GPT-2. False: a bit
   better and faster`). Pas de framework de config.
8. **Surface publique minuscule** : `_prefix` pour l'interne, `__repr__`
   pour déboguer, `print` pour avertir dans un petit outil.
9. **Chaque import gagne sa place** : stdlib d'abord, dépendance seulement
   si elle paie son poids.

## Les gestes de couche 2 qui en découlent

| Odeur trouvée | Geste nano |
|---|---|
| Classe sans état propre, ou à une seule méthode | → fonction |
| Wrapper / indirection / interface à un seul appelant | → inliner |
| Deux blocs identiques à un paramètre près | → dériver l'un de l'autre (petit cœur) |
| Enchaînement clever illisible en une ligne | → pipeline vertical nommé |
| Config éclatée ou framework pour 5 valeurs | → dataclass à plat, défauts commentés |
| Commentaire-paraphrase | → supprimer ; pourquoi/forme/contrainte → garder |
| if/raise verbeux sur un invariant **purement interne** | → assert avec message — seulement si aucun appelant ne dépend du type d'exception ; au moindre doute → rapport (changer la classe d'erreur = changer le comportement) |

Deux limites : le formatage cosmétique du canon (alignements verticaux des
`=`) n'est pas repris — la couche 1 (prettier/ruff) fait autorité. Et chaque
geste reste soumis au gate et au « comprendre avant de toucher » du SKILL.md.
