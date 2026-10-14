# Lexique des commandes Git

Aide-mémoire autorisé pendant l'évaluation. Il rappelle **la syntaxe** des commandes vues au TP01, mais pas ce qu'il faut en faire : à vous de choisir la bonne commande, les bonnes options et les bonnes valeurs.

Les exemples utilisent des noms fictifs (`station-meteo`, `capteurs.csv`, `3f9a1c2`…) qui ne sont pas ceux du sujet.

Pour le détail d'une commande : `git help commande` (quitter avec `q`).

---

## Se repérer dans le terminal

| Commande | Rôle |
| --- | --- |
| `pwd` | Affiche le dossier courant |
| `ls -la` | Liste le contenu du dossier, fichiers cachés compris (`.git`, `.gitignore`…) |
| `mkdir -p dossier` | Crée un dossier (sans erreur s'il existe déjà) |
| `cd dossier` | Se déplacer dans un dossier |
| `cat fichier` | Affiche le contenu d'un fichier |
| `nano fichier` | Édite un fichier (`Ctrl`+`O` puis `Entrée` : enregistrer, `Ctrl`+`X` : quitter) |
| `commande \| wc -l` | Compte les lignes renvoyées par `commande` |
| `~/chemin/vers/script.sh` | Lance un script exécutable |

**Chemins** : `~` = votre dossier personnel, `.` = dossier courant, `..` = dossier parent.

## Configuration

| Commande | Rôle |
| --- | --- |
| `git config --global user.name` | Affiche le nom utilisé pour vos commits |
| `git config --global user.email` | Affiche l'e-mail utilisé pour vos commits |
| `git config --list --global` | Affiche toute votre configuration globale |
| `git config --global pull.rebase false` | `git pull` fusionne les historiques divergents (au lieu de demander quoi faire) |

## Les trois zones

```text
Répertoire de travail ──git add──> Zone de préparation ──git commit──> Dépôt local
          <──git restore──                 <──git restore --staged──
```

## État du dépôt

| Commande | Rôle |
| --- | --- |
| `git status` | État des fichiers : non suivis, modifiés, préparés. **Lisez-le en entier** : il indique souvent la commande suivante |
| `git diff` | Modifications du répertoire de travail **pas encore** préparées |
| `git diff fichier` | Idem, pour un seul fichier |
| `git diff --staged` | Modifications **préparées**, qui partiront dans le prochain commit |

Lire une sortie de `git diff` :

```text
--- a/capteurs.csv          ← version enregistrée
+++ b/capteurs.csv          ← version actuelle
@@ -3,2 +3,3 @@
 temp-02;salle-b;actif      ← ligne inchangée
-temp-03;salle-c;actif      ← ligne supprimée
+temp-03;salle-c;HS         ← ligne ajoutée
```

## Enregistrer

| Commande | Rôle |
| --- | --- |
| `git add fichier` | Prépare un fichier (nouveau ou modifié) pour le prochain commit |
| `git add fichier1 fichier2` | Prépare plusieurs fichiers |
| `git add .` | Prépare **tout** ce qui a changé dans le dossier : à utiliser avec prudence |
| `git commit -m "Message clair"` | Enregistre dans le dépôt ce qui est dans la zone de préparation |

Un bon message de commit dit **ce que fait** le commit : `Ajout du capteur temp-07`, et non `modif` ou `ok`. Un commit = une idée.

## Annuler

| Commande | Rôle |
| --- | --- |
| `git restore fichier` | Remet le fichier dans l'état de son **dernier commit** : les modifications non commitées sont **perdues** |
| `git restore --staged fichier` | Retire le fichier de la zone de préparation ; il reste **intact sur le disque** |

## Ignorer des fichiers : `.gitignore`

Fichier texte nommé exactement **`.gitignore`**, à la **racine** du dépôt, une règle par ligne :

```text
# Commentaire
secret.txt        ← un fichier précis
*.tmp             ← tous les fichiers qui finissent par .tmp
sauvegardes/      ← tout un dossier
```

## Explorer l'historique

| Commande | Rôle |
| --- | --- |
| `git log` | Historique complet : hash, auteur, date, message |
| `git log --oneline` | Historique condensé, un commit par ligne (hash court + message) |
| `git log -- fichier` | Seulement les commits qui ont modifié ce fichier |
| `git log --oneline -- fichier` | Idem, condensé |
| `git show 3f9a1c2` | Détail d'un commit : auteur, date, message **et** modifications (diff) |
| `git show 3f9a1c2:capteurs.csv` | Contenu du fichier **tel qu'il était** dans ce commit |
| `git diff 3f9a1c2 HEAD -- capteurs.csv` | Différences d'un fichier entre un ancien commit et le dernier |

**Hash** : 40 caractères hexadécimaux ; les **7 premiers** suffisent pour désigner un commit. **`HEAD`** désigne le dernier commit de la branche courante.

Lire une sortie de `git log` :

```text
commit 3f9a1c2e8b47d0a6c5f1e2d3b4a59687c0e1f2a3     ← hash
Author: Camille Durand <camille@exemple.fr>         ← auteur
Date:   Mon Sep 7 10:15:00 2026 +0200               ← date

    Ajout du capteur temp-07                        ← message
```

## Travailler avec GitHub

| Commande | Rôle |
| --- | --- |
| `ssh -T git@github.com` | Teste votre clé SSH auprès de GitHub (réponse attendue : `Hi pseudo!…`) |
| `git clone URL` | Copie un dépôt distant (tout l'historique) dans un nouveau dossier du même nom |
| `git clone URL dossier` | Idem, dans le dossier de votre choix |
| `git remote -v` | Affiche les dépôts distants liés au dépôt local |
| `git remote add origin URL` | Lie le dépôt local à un dépôt distant nommé `origin` |
| `git remote set-url origin URL` | Change l'URL d'un dépôt distant existant |
| `git push -u origin main` | Envoie la branche `main` sur `origin` **et** mémorise le lien (première fois) |
| `git push` | Envoie les nouveaux commits (une fois le lien mémorisé) |
| `git pull` | Récupère et intègre les commits présents sur le dépôt distant |

Les deux formes d'URL :

| Protocole | Forme | Pour pousser |
| --- | --- | --- |
| SSH | `git@github.com:pseudo/station-meteo.git` | Clé SSH, automatique |
| HTTPS | `https://github.com/pseudo/station-meteo.git` | Lecture libre si le dépôt est public ; pousser demande un jeton |

---

*Licence [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.fr) — BTS CIEL option IR, Lycée Louis Rascol, Albi.*
