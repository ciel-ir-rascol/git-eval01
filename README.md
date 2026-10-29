# Évaluation — Git et GitHub

**1CIEL-IR — Durée : 1h — Validation par missions successives.**

> *L'équipe qui documentait le réseau de la salle **D116** vient de vous passer le relais. Elle vous laisse un dépôt Git avec tout son historique… et un beau désordre dans la copie de travail : un fichier écrasé, des journaux qui traînent, et même un mot de passe Wi-Fi sur le point d'être commité. À vous de mener l'enquête, de remettre de l'ordre et de publier le tout sur GitHub.*

Cette évaluation porte sur les notions du **TP01 — Découverte de Git et GitHub** : `status`, `add`, `commit`, `log`, `show`, `diff`, `restore`, `.gitignore`, `remote`, `push`, `pull` et `clone`. **Elle ne contient rien qui n'ait été vu dans ce TP.**

---

## 🧭 Comment se déroule l'évaluation

> [!IMPORTANT]
> **Validation par missions successives**
>
> Un script de validation, `verifier.sh`, est fourni dans ce dépôt (vous le clonez en mission 1). À la fin de **chaque mission**, lancez-le avec le numéro de la mission :
> ```bash
> ~/eval-git/git-eval01/scripts/verifier.sh 2       # exemple pour la mission 2
> ```
> - Tant qu'il affiche `NON VALIDEE`, corrigez les points marqués `[ECHEC]` et relancez-le, autant de fois que nécessaire : ce n'est pas pénalisé.
> - Dès qu'il affiche **`MISSION N VALIDEE`**, **appelez l'enseignant** pour lui montrer le résultat : c'est lui qui reporte les points. **Une mission validée à l'écran mais jamais montrée ne compte pas.**
>
> Le script vérifie **l'état final** de vos dépôts, pas la façon dont vous y êtes arrivé. Lors de la validation, l'enseignant peut vous poser une question courte sur ce que vous venez de faire.

### Environnement de travail

| | |
| --- | --- |
| **Poste** | Ubuntu Desktop 24.04 LTS du lycée, **dans votre session** |
| **Git** | Déjà configuré (nom et e-mail, depuis le TP01) |
| **GitHub** | Votre compte, avec la clé SSH déclarée pendant le TP01 |
| **Éditeur** | `nano` (ou l'éditeur de votre choix) |

### Règles

- Vous avez droit à vos notes, au document à trous du cours, au **sujet du TP01**, à votre dépôt `tp01-git`, à l'aide de Git (`git help commit`…) et au **[lexique des commandes](LEXIQUE.md)** fourni dans ce dépôt : on évalue votre capacité à choisir et appliquer la bonne commande, pas votre mémoire de sa syntaxe.
- Travail **individuel**.
- Les noms de dossiers, de fichiers et de dépôts doivent être respectés **à la lettre** : le script ne fait pas d'approximation.
- **Interdit** : supprimer le dépôt `eval01-git` pour le recréer, ou réécrire son historique. Le script le détecte.

---

## Sommaire et barème

| Mission | Objectif | Durée conseillée | Points | Observables |
| :---: | --- | :---: | :---: | --- |
| **1** | Récupérer le sujet et préparer le dépôt | 5 min | 2 | C08.2.1 |
| **2** | Enquêter dans l'historique | 15 min | 6 | C08.2.2 |
| **3** | Remettre de l'ordre et commiter proprement | 15 min | 6 | C08.2.3, C09.4.4 |
| **4** | Publier sur GitHub | 15 min | 4 | C03.3.2 |
| **5** | Travailler depuis deux endroits | 10 min | 2 | C08.2.2 |
| | **Total** | **1h** | **/20** |  |

**Observables du référentiel** (suivi des compétences du BTS CIEL) travaillés dans cette évaluation :

- `C03.3.2` — La mise en œuvre de l'espace collaboratif est démontrée. *(mission 4)*
- `C08.2.1` — Un outil de versionnement est en place *(mission 1)*
- `C08.2.2` — Le fonctionnement de l'outil de versionnement est démontré *(missions 2, 5)*
- `C08.2.3` — Chaque composant est versionné. *(mission 3)*
- `C09.4.4` — Les documents sont protégés, les accès systèmes sont surveillés et protégés. *(mission 3)*

Les missions se font **dans l'ordre**.

---

## Mission 1 — Récupérer le sujet et préparer le dépôt *(2 pts)*

1. Créez le dossier `~/eval-git` et placez-vous dedans.
2. Clonez-y **ce dépôt** (le sujet), en HTTPS : `https://github.com/ciel-ir-rascol/git-eval01.git`. Vous devez obtenir le dossier `~/eval-git/git-eval01`.
3. Lancez **une seule fois** le script qui prépare votre dépôt de travail :
   ```bash
   ~/eval-git/git-eval01/scripts/preparer.sh
   ```
   Il crée le dépôt **`~/eval-git/eval01-git`** : c'est là que se passe toute la suite.

**✅ Validation :** `verifier.sh 1`

---

## Mission 2 — Enquêter dans l'historique *(6 pts)*

Placez-vous dans `~/eval-git/eval01-git`. **Ne touchez encore à aucun fichier existant** : cette mission se fait uniquement en **lisant** l'historique.

Créez à la racine du dépôt un fichier **`REPONSES.md`**, en respectant exactement ce format (une réponse par ligne, après `Qn :`) :

```markdown
# Réponses — évaluation Git

- Q1 : ...
- Q2 : ...
- Q3 : ...
- Q4 : ...
```

| Question | Énoncé |
| :---: | --- |
| **Q1** | Combien de commits contient l'historique laissé par l'équipe précédente ? |
| **Q2** | Donnez le **hash** (7 premiers caractères au moins) du commit qui a ajouté le **serveur DNS** au plan d'adressage. |
| **Q3** | Le plan d'adressage a changé depuis sa création. Quelle était l'adresse de la **passerelle** dans la **toute première version** de `plan-adressage.md` ? |
| **Q4** | Le poste **`d116-05`** a disparu de `machines.csv`. Quel est le **nom de la personne** qui l'a retiré ? |

> [!TIP]
> Vos hashs sont **différents de ceux de vos voisins** : le dépôt est préparé à votre nom. Inutile de comparer.

> [!NOTE]
> `plan-adressage.md` a été abîmé dans la copie de travail (vous le réparerez en mission 3) : c'est dans l'**historique** qu'il faut chercher, pas dans le fichier actuel.

**✅ Validation :** `verifier.sh 2` (le fichier `REPONSES.md` n'a pas besoin d'être commité pour cette mission).

---

## Mission 3 — Remettre de l'ordre *(6 pts)*

Commencez par un `git status` et lisez-le **en entier** : il vous montre le désordre laissé par l'équipe précédente. Voici ce que vous savez :

- **Un fichier suivi a été écrasé par erreur.** Il doit retrouver le contenu de son **dernier commit**.
- **La ligne ajoutée à `machines.csv`** pour le nouveau poste `d116-11` est correcte : elle doit être conservée et commitée.
- **`motdepasse-wifi.txt`** a été ajouté à la zone de préparation par erreur. Il ne doit **jamais** entrer dans un commit, mais il doit **rester sur le disque** (l'équipe en a besoin).
- **`brouillon.txt`** et les journaux **`.log`** n'ont rien à faire dans le dépôt.

Votre travail :

1. Réparez le fichier écrasé.
2. Retirez `motdepasse-wifi.txt` de la zone de préparation.
3. Créez un fichier **`.gitignore`** pour que Git ignore `motdepasse-wifi.txt`, `brouillon.txt` et **tous** les fichiers `.log`, présents et futurs.
4. Faites **des commits séparés, un par idée** : au minimum un commit qui ne contient **que** `machines.csv`, un pour le `.gitignore` et un pour `REPONSES.md`. Chaque commit a un **message clair et différent** des autres.
5. Terminez avec un `git status` qui annonce une copie de travail **propre**.

> [!WARNING]
> Une fois commité, un mot de passe reste **dans l'historique**, même si on supprime le fichier ensuite. Vérifiez bien `git status` avant chaque `git commit`.

**✅ Validation :** `verifier.sh 3`

---

## Mission 4 — Publier sur GitHub *(4 pts)*

1. Sur GitHub, créez un dépôt **vide** nommé **`eval01-git`** sur votre compte (public, sans README, sans `.gitignore`, sans licence).
2. Reliez votre dépôt local à ce dépôt distant sous le nom **`origin`**, avec l'URL **SSH**.
3. Poussez la branche `main` en mémorisant le lien avec `origin` (pour que les `git push` suivants n'aient besoin d'aucun argument).
4. Sur la page GitHub du dépôt, modifiez `README.md` **directement dans le navigateur** : ajoutez la ligne `Relu sur GitHub par VOTRE_PSEUDO.`, puis commitez.
5. Récupérez ce commit dans votre dépôt local.

**✅ Validation :** `verifier.sh 4`

---

## Mission 5 — Travailler depuis deux endroits *(2 pts)*

On simule votre ordinateur de la maison.

1. Clonez votre dépôt GitHub `eval01-git` (en SSH) dans **`~/eval-git/eval01-git-maison`**.
2. **Dans ce clone**, ajoutez à la fin de `REPONSES.md` la réponse à la question suivante, puis commitez et poussez :

   | Question | Énoncé |
   | :---: | --- |
   | **Q5** | Pourquoi faut-il prendre l'habitude de faire `git pull` **en début de séance** ? Répondez par une phrase. |

   ```markdown
   - Q5 : ...
   ```

3. **De retour au « lycée »** (`~/eval-git/eval01-git`), récupérez ce commit.

**✅ Validation :** `verifier.sh 5`

---

## 🆘 En cas de problème

| Symptôme | Cause probable | Solution |
| --- | --- | --- |
| `fatal: not a git repository` | Vous n'êtes pas dans le bon dossier | `cd ~/eval-git/eval01-git` puis `pwd` |
| `preparer.sh` : `existe déjà` | Le script a déjà été lancé | Rien à faire, le dépôt est prêt ; ne le supprimez pas |
| `Permission denied` en lançant un script | Mauvais chemin, ou fichier copié au lieu d'être cloné | Vérifiez le chemin ; reclonez le sujet si besoin |
| Un éditeur s'ouvre pendant `git commit` | `-m "message"` oublié | Écrire le message, `Ctrl`+`O`, `Entrée`, `Ctrl`+`X` |
| `Permission denied (publickey)` | Clé SSH absente ou non déclarée sur GitHub | `ssh -T git@github.com` ; sinon refaire la partie 5 du TP01 |
| `git push` demande un *Username* | `origin` est en HTTPS | `git remote set-url origin git@github.com:PSEUDO/eval01-git.git` |
| `error: remote origin already exists` | `git remote add` déjà fait | `git remote set-url origin …` |
| `! [rejected] main -> main (fetch first)` | GitHub contient des commits que vous n'avez pas | `git pull`, puis `git push` |
| `git pull` parle de *divergent branches* | Stratégie de `pull` non choisie | `git config --global pull.rebase false`, puis relancer `git pull` |
| `GH007: Your push would publish a private email address` | Confidentialité de l'e-mail activée sur GitHub | *Settings → Emails* : décocher **Block command line pushes that expose my email** |

---

*Licence [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.fr) — BTS CIEL option IR, Lycée Louis Rascol, Albi.*
