#!/bin/bash
#
# preparer.sh — Prepare le depot de l'evaluation Git (git-eval01)
# A executer SUR LE POSTE, en utilisateur normal (pas de sudo), UNE SEULE FOIS :
#     ~/eval-git/git-eval01/scripts/preparer.sh
#
# Cree ~/eval-git/eval01-git : un depot de documentation reseau avec un
# historique de 6 commits, laisse « en desordre » par l'equipe precedente.
#

export LC_ALL=C

DEPOT="$HOME/eval-git/eval01-git"

if [ "$(id -u)" -eq 0 ]; then
    echo "Ne lancez pas ce script avec sudo : relancez-le en utilisateur normal." >&2
    exit 1
fi

if [ -e "$DEPOT" ]; then
    echo "$DEPOT existe déjà : le dépôt a déjà été préparé." >&2
    echo "Si vous voulez vraiment repartir de zéro (tout votre travail sera perdu) :" >&2
    echo "    rm -rf $DEPOT   puis relancez ce script." >&2
    exit 1
fi

mkdir -p "$DEPOT" && cd "$DEPOT" || exit 1
git init -q -b main

# commit <auteur> <email> <date> <message>
# Commit avec une identite et une date fixees (et non celles de l'etudiant).
commit() {
    git add -A
    GIT_AUTHOR_NAME="$1"    GIT_AUTHOR_EMAIL="$2"    GIT_AUTHOR_DATE="$3" \
    GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" \
        git -c commit.gpgsign=false commit -q -m "$4"
}

SAM=("Sam Leroy" "sam.leroy@exemple.fr")
ALEX=("Alex Morel" "alex.morel@exemple.fr")
INES=("Inès Haddad" "ines.haddad@exemple.fr")

# --- 1 : README ------------------------------------------------------------------
cat > README.md <<EOF
# Documentation réseau — salle D116

Ce dépôt rassemble la documentation réseau de la salle D116 :
plan d'adressage et inventaire des postes.

Copie de travail préparée pour : $USER
EOF
commit "${SAM[@]}" "2026-09-01T09:12:00+02:00" "Création du README"

# --- 2 : plan d'adressage --------------------------------------------------------
cat > plan-adressage.md <<'EOF'
# Plan d'adressage — salle D116

| Élément | Valeur |
| --- | --- |
| Réseau | 10.116.0.0/24 |
| Passerelle | 10.116.0.1 |
| Postes | 10.116.0.101 à 10.116.0.120 |
EOF
commit "${SAM[@]}" "2026-09-01T09:30:00+02:00" "Plan d'adressage initial"

# --- 3 : inventaire --------------------------------------------------------------
cat > machines.csv <<'EOF'
nom;adresse_ip;adresse_mac
d116-01;10.116.0.101;52:54:00:16:01:01
d116-02;10.116.0.102;52:54:00:16:01:02
d116-03;10.116.0.103;52:54:00:16:01:03
d116-04;10.116.0.104;52:54:00:16:01:04
d116-05;10.116.0.105;52:54:00:16:01:05
d116-06;10.116.0.106;52:54:00:16:01:06
EOF
commit "${ALEX[@]}" "2026-09-08T14:05:00+02:00" "Inventaire des postes"

# --- 4 : serveurs DNS et NTP -----------------------------------------------------
cat >> plan-adressage.md <<'EOF'
| Serveur DNS | 10.116.0.53 |
| Serveur NTP | 10.116.0.123 |
EOF
commit "${SAM[@]}" "2026-09-15T10:20:00+02:00" "Compléments au plan d'adressage"

# --- 5 : nouvelle passerelle -----------------------------------------------------
sed -i 's/| Passerelle | 10\.116\.0\.1 |/| Passerelle | 10.116.0.254 |/' plan-adressage.md
commit "${ALEX[@]}" "2026-09-22T16:40:00+02:00" "Changement de passerelle"

# --- 6 : retrait d'un poste ------------------------------------------------------
sed -i '/^d116-05;/d' machines.csv
commit "${INES[@]}" "2026-09-29T11:02:00+02:00" "Mise à jour de l'inventaire"

# Reference de l'historique d'origine, pour le script de verification
git rev-parse HEAD > .git/eval01-origine

# --- Le desordre laisse par l'equipe precedente ----------------------------------
echo "d116-11;10.116.0.111;52:54:00:16:01:11" >> machines.csv
echo "oups" > plan-adressage.md
printf 'SSID : D116-ETUDIANTS\nCle WPA2 : Rascol-D116-%s!\n' "$RANDOM" > motdepasse-wifi.txt
git add motdepasse-wifi.txt
echo "à faire : vérifier les adresses MAC des postes 07 à 10" > brouillon.txt
printf 'PING 10.116.0.254 56(84) bytes of data.\n64 bytes from 10.116.0.254: icmp_seq=1 ttl=64 time=0.41 ms\n' > ping.log
printf '12:04:51.118 ARP, Request who-has 10.116.0.254 tell 10.116.0.101\n' > capture.log

echo "Dépôt préparé : $DEPOT"
echo "Placez-vous dedans pour commencer :"
echo "    cd $DEPOT"
