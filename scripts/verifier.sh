#!/bin/bash
#
# verifier.sh — Validation des missions de l'evaluation Git (git-eval01)
# A executer SUR LE POSTE, en utilisateur normal (pas de sudo) :
#     ~/eval-git/git-eval01/scripts/verifier.sh N        (N = numero de mission, 1 a 5)
#
# Le script ne modifie rien : il lit la configuration Git et les depots.
# Seule action reseau (missions 4 et 5) : un « git fetch » pour comparer avec GitHub.
#

# Sorties des commandes en anglais, quelle que soit la langue du poste
export LC_ALL=C

BASE="$HOME/eval-git"
SUJET="$BASE/git-eval01"
DEPOT="$BASE/eval01-git"
MAISON="$BASE/eval01-git-maison"

MISSION="$1"
SCORE=0
TOTAL=0

VERT="\033[0;32m"
ROUGE="\033[0;31m"
JAUNE="\033[0;33m"
GRAS="\033[1m"
RAZ="\033[0m"

if [ "$(id -u)" -eq 0 ]; then
    echo "Ne lancez pas ce script avec sudo : relancez-le en utilisateur normal." >&2
    exit 1
fi

case "$MISSION" in
    1|2|3|4|5) ;;
    *) echo "Usage : $0 N     (N = numéro de la mission, de 1 à 5)" >&2; exit 1 ;;
esac

titre() {
    echo
    echo -e "${GRAS}=== $1 ===${RAZ}"
}

# ok <description> <commande...>  -> +1 si la commande reussit
ok() {
    local desc="$1"; shift
    TOTAL=$((TOTAL + 1))
    if "$@" >/dev/null 2>&1; then
        echo -e "  [${VERT}OK${RAZ}]     $desc"
        SCORE=$((SCORE + 1))
    else
        echo -e "  [${ROUGE}ECHEC${RAZ}]  $desc"
    fi
}

info() { echo -e "  [${JAUNE}INFO${RAZ}]   $1"; }

bilan() {
    echo
    if [ "$SCORE" -eq "$TOTAL" ]; then
        echo -e "${VERT}${GRAS}MISSION $MISSION VALIDEE${RAZ} ($SCORE / $TOTAL) — appelez l'enseignant pour la faire constater."
    else
        echo -e "${ROUGE}${GRAS}MISSION $MISSION NON VALIDEE${RAZ} ($SCORE / $TOTAL) — corrigez les points en ECHEC, puis relancez le script."
    fi
    exit 0
}

# --- Fonctions de test ---------------------------------------------------------

g() { git -C "$DEPOT" "$@"; }

config_definie()   { [ -n "$(git config --global "$1")" ]; }
sujet_clone()      { git -C "$SUJET" config --get remote.origin.url | grep -Eq 'ciel-ir-rascol/git-eval01(\.git)?$'; }
depot_prepare()    { [ -s "$DEPOT/.git/eval01-origine" ] && g cat-file -e "$(origine)^{commit}"; }
origine()          { cat "$DEPOT/.git/eval01-origine" 2>/dev/null; }
historique_intact(){ g merge-base --is-ancestor "$(origine)" HEAD; }
arbre_propre()     { [ -z "$(g status --porcelain)" ]; }
fichier_suivi()    { g ls-files --error-unmatch "$1"; }
fichier_ignore()   { g check-ignore -q --no-index "$1"; }

# reponse <N> : texte apres « QN : » dans REPONSES.md (copie de travail)
reponse() {
    [ -f "$DEPOT/REPONSES.md" ] || return
    sed -E -n "s/^[[:space:]#*>-]*Q$1[*[:space:]]*:[[:space:]]*//p" "$DEPOT/REPONSES.md" \
        | head -1 | tr -d '`*' | sed -E 's/[[:space:]]+$//'
}

# Q1 : nombre de commits de l'historique d'origine
q1_ok() {
    local attendu donne
    attendu=$(g rev-list --count "$(origine)")
    donne=$(reponse 1 | grep -oE '[0-9]+' | head -1)
    [ -n "$donne" ] && [ "$donne" -eq "$attendu" ]
}

# Q2 : hash (7 caracteres ou plus) du commit qui a ajoute le serveur DNS
q2_ok() {
    local attendu donne
    attendu=$(g log --format=%H --reverse -S'Serveur DNS' "$(origine)" -- plan-adressage.md | head -1)
    donne=$(reponse 2 | tr 'A-F' 'a-f' | grep -oE '\b[0-9a-f]{7,40}\b' | head -1)
    [ -n "$donne" ] && [ "${attendu#"$donne"}" != "$attendu" ]
}

# Q3 : adresse de la passerelle dans la toute premiere version de plan-adressage.md
q3_ok() {
    local premier attendu donne
    premier=$(g rev-list --reverse "$(origine)" -- plan-adressage.md | head -1)
    attendu=$(g show "$premier:plan-adressage.md" | grep -i passerelle | grep -oE '[0-9]+(\.[0-9]+){3}')
    donne=$(reponse 3 | grep -oE '[0-9]+(\.[0-9]+){3}' | head -1)
    [ -n "$donne" ] && [ "$donne" = "$attendu" ]
}

# Q4 : auteur du commit qui a retire le poste d116-05 de l'inventaire
q4_ok() {
    local attendu donne
    attendu=$(g log --format=%an -S'd116-05;' "$(origine)" -- machines.csv | head -1 | awk '{print tolower($NF)}')
    donne=$(reponse 4 | tr 'A-Z' 'a-z')
    [ -n "$attendu" ] && [[ "$donne" == *"$attendu"* ]]
}

# Q5 : une vraie phrase
q5_ok() { [ "$(reponse 5 | wc -m)" -ge 20 ]; }

plan_restaure()    { g diff --quiet "$(origine)" -- plan-adressage.md; }
mdp_sur_disque()   { [ -f "$DEPOT/motdepasse-wifi.txt" ]; }
mdp_jamais_commite(){ [ -z "$(g log --all --format=%H -- motdepasse-wifi.txt)" ] && ! fichier_suivi motdepasse-wifi.txt; }
d116_11_commite()  { g show HEAD:machines.csv | grep -q '^d116-11;'; }

# Un commit ajoute depuis l'origine qui ne touche QUE machines.csv et ajoute d116-11
commit_machines_seul() {
    local c
    for c in $(g rev-list "$(origine)"..HEAD); do
        [ "$(g show --format= --name-only "$c")" = "machines.csv" ] \
            && g show --format= "$c" | grep -q '^+d116-11;' && return 0
    done
    return 1
}

# Commits ajoutes par l'etudiant (auteur = son e-mail Git), hors commits web
nb_commits_etudiant() {
    g log --format='%ae' "$(origine)"..HEAD | grep -cxF "$(git config --global user.email)"
}
au_moins_3_commits() { [ "$(nb_commits_etudiant)" -ge 3 ]; }

# Messages tous differents et d'au moins 10 caracteres
messages_clairs() {
    local msgs
    msgs=$(g log --format='%s' "$(origine)"..HEAD)
    [ -n "$msgs" ] \
        && [ "$(echo "$msgs" | wc -l)" -eq "$(echo "$msgs" | sort -u | wc -l)" ] \
        && [ -z "$(echo "$msgs" | awk 'length($0) < 10')" ]
}

remote_ssh()       { g config --get remote.origin.url | grep -Eq '^git@github\.com:[^/]+/eval01-git(\.git)?$'; }
remote_accessible(){ g fetch --quiet origin; }
upstream_main()    { [ "$(g rev-parse --abbrev-ref 'main@{upstream}')" = "origin/main" ]; }
travail_sur_github(){ g cat-file -e origin/main:REPONSES.md && g cat-file -e origin/main:.gitignore; }
tout_pousse()      { [ "$(g rev-parse HEAD)" = "$(g rev-parse origin/main)" ]; }

# Un commit fait dans l'interface web de GitHub, sur README.md, recupere en local
commit_web() {
    local c
    for c in $(g rev-list "$(origine)"..HEAD); do
        [ "$(g log -1 --format=%cn "$c")" = "GitHub" ] \
            && g show --format= --name-only "$c" | grep -qx README.md && return 0
    done
    return 1
}

m() { git -C "$MAISON" "$@"; }
maison_clone()     { [ -d "$MAISON/.git" ] && [ "$(m config --get remote.origin.url)" = "$(g config --get remote.origin.url)" ]; }
commit_maison()    { m reflog --format=%gs | grep -q '^commit'; }
maison_propre()    { [ -z "$(m status --porcelain)" ]; }
maison_a_jour()    { m fetch --quiet origin && [ "$(m rev-parse HEAD)" = "$(m rev-parse origin/main)" ]; }
lycee_a_jour()     { [ "$(g rev-parse HEAD)" = "$(m rev-parse HEAD)" ]; }

# --- Verifications ---------------------------------------------------------------

echo -e "${GRAS}Évaluation Git — vérification de la mission $MISSION${RAZ}"

# Prerequis communs aux missions 2 a 5 : le depot prepare existe
if [ "$MISSION" -ge 2 ] && ! depot_prepare; then
    echo -e "  [${ROUGE}ECHEC${RAZ}]  $DEPOT n'existe pas ou n'a pas été créé par preparer.sh : terminez d'abord la mission 1."
    TOTAL=1
    bilan
fi

case "$MISSION" in
1)
    titre "Mission 1 — Préparer son poste"
    ok "Nom configuré dans Git (user.name)"            config_definie user.name
    ok "E-mail configuré dans Git (user.email)"        config_definie user.email
    ok "Sujet cloné dans ~/eval-git/git-eval01"        sujet_clone
    ok "Dépôt ~/eval-git/eval01-git préparé"           depot_prepare
    config_definie user.name && info "Vos commits seront signés : $(git config --global user.name) <$(git config --global user.email)>"
    ;;
2)
    titre "Mission 2 — Enquête dans l'historique"
    ok "REPONSES.md existe dans le dépôt"              test -f "$DEPOT/REPONSES.md"
    ok "Q1 — nombre de commits"                        q1_ok
    ok "Q2 — hash du commit qui a ajouté le serveur DNS" q2_ok
    ok "Q3 — passerelle du premier plan d'adressage"   q3_ok
    ok "Q4 — auteur du retrait du poste d116-05"       q4_ok
    ok "Historique d'origine intact"                   historique_intact
    ;;
3)
    titre "Mission 3 — Remettre de l'ordre"
    ok "Historique d'origine intact"                   historique_intact
    ok "plan-adressage.md restauré"                    plan_restaure
    ok "motdepasse-wifi.txt jamais commité"            mdp_jamais_commite
    ok "motdepasse-wifi.txt toujours présent sur le disque" mdp_sur_disque
    ok ".gitignore est suivi"                          fichier_suivi .gitignore
    ok "motdepasse-wifi.txt est ignoré"                fichier_ignore motdepasse-wifi.txt
    ok "brouillon.txt est ignoré"                      fichier_ignore brouillon.txt
    ok "Tous les fichiers .log sont ignorés"           fichier_ignore nimporte-quoi.log
    ok "Poste d116-11 commité dans machines.csv"       d116_11_commite
    ok "Un commit ne contenant que machines.csv"       commit_machines_seul
    ok "REPONSES.md est suivi"                         fichier_suivi REPONSES.md
    ok "Au moins 3 commits à votre nom"                au_moins_3_commits
    ok "Messages de commit différents et explicites (10 caractères ou plus)" messages_clairs
    ok "Aucune modification en attente (git status propre)" arbre_propre
    info "Commits à votre nom : $(nb_commits_etudiant)"
    ;;
4)
    titre "Mission 4 — Publier sur GitHub"
    ok "Dépôt distant origin en SSH (git@github.com:…/eval01-git.git)" remote_ssh
    ok "Dépôt distant accessible (git fetch)"          remote_accessible
    ok "main suit origin/main (push -u)"               upstream_main
    ok "REPONSES.md et .gitignore présents sur GitHub" travail_sur_github
    ok "Un commit fait dans l'interface web de GitHub, récupéré en local" commit_web
    ok "Aucune modification en attente (git status propre)" arbre_propre
    ok "Dépôt local et GitHub identiques"              tout_pousse
    ;;
5)
    titre "Mission 5 — Travailler depuis deux endroits"
    ok "Clone ~/eval-git/eval01-git-maison du même dépôt GitHub" maison_clone
    ok "Un commit fait dans le clone"                  commit_maison
    ok "Q5 — réponse rédigée dans REPONSES.md"         q5_ok
    ok "Clone propre (git status)"                     maison_propre
    ok "Clone et GitHub identiques"                    maison_a_jour
    ok "Dépôt du lycée propre (git status)"            arbre_propre
    ok "Dépôt du lycée à jour (même commit que le clone)" lycee_a_jour
    ;;
esac

bilan
