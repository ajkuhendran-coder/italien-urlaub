#!/bin/bash
# -----------------------------------------------------------------------------
# Italien-Urlaub · Ein-Klick-GitHub-Setup
# Doppelklick auf diese Datei im Finder, um zu starten.
# -----------------------------------------------------------------------------

set -e

# Sicherstellen, dass das Skript im eigenen Ordner läuft
cd "$(dirname "$0")"
clear

echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║   🇮🇹  Italien-Urlaub · GitHub-Setup            ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

REPO_NAME="italien-urlaub"

# -----------------------------------------------------------------------------
# 1. Lock-Dateien aufräumen (Reste vom Sandbox-Commit)
# -----------------------------------------------------------------------------
echo "▶ 1/7  Aufräumen …"
rm -f .git/index.lock .git/HEAD.lock 2>/dev/null || true
find .git -name "tmp_obj_*" -type f -delete 2>/dev/null || true
echo "   ✓ erledigt"

# -----------------------------------------------------------------------------
# 2. Git-Identität setzen (falls noch nicht gesetzt)
# -----------------------------------------------------------------------------
echo ""
echo "▶ 2/7  Git-Identität prüfen …"
if ! git config user.name >/dev/null 2>&1; then
  git config user.name "Ajanth"
fi
if ! git config user.email >/dev/null 2>&1; then
  git config user.email "kuhendran@me.com"
fi
echo "   ✓ Name:  $(git config user.name)"
echo "   ✓ Email: $(git config user.email)"

# -----------------------------------------------------------------------------
# 3. Offene Änderungen committen
# -----------------------------------------------------------------------------
echo ""
echo "▶ 3/7  Änderungen sichern …"
git add -A
if git diff --cached --quiet; then
  echo "   ✓ nichts Neues zu committen"
else
  git commit -m "Italien-Urlaub Dashboard (iOS-Karten-Fix)"
  echo "   ✓ Commit erstellt"
fi

# Branch sicherstellen
git branch -M main 2>/dev/null || true

# -----------------------------------------------------------------------------
# 4. Prüfen ob GitHub CLI (gh) installiert ist
# -----------------------------------------------------------------------------
echo ""
echo "▶ 4/7  GitHub CLI prüfen …"
if ! command -v gh >/dev/null 2>&1; then
  echo ""
  echo "   ⚠  Die GitHub-CLI (\"gh\") ist noch nicht installiert."
  echo "      Das Skript kann dann nicht voll automatisieren."
  echo ""
  echo "   → Schnellste Installation (Homebrew):"
  echo "        brew install gh"
  echo ""
  echo "   → Oder über den Installer: https://cli.github.com"
  echo ""
  echo "   Nach der Installation: dieses Skript einfach noch mal doppelklicken."
  echo ""
  echo "   (Zum Schließen eine Taste drücken …)"
  read -n 1
  exit 0
fi
echo "   ✓ gh $(gh --version | head -n1 | awk '{print $3}')"

# -----------------------------------------------------------------------------
# 5. Login prüfen (einmalig Browser-Popup)
# -----------------------------------------------------------------------------
echo ""
echo "▶ 5/7  GitHub-Login prüfen …"
if ! gh auth status >/dev/null 2>&1; then
  echo "   → Jetzt öffnet sich der Browser für die einmalige Anmeldung."
  gh auth login -h github.com -p https -w
fi
GH_USER=$(gh api user -q .login)
echo "   ✓ eingeloggt als: $GH_USER"

# -----------------------------------------------------------------------------
# 6. Repo erstellen (falls noch nicht existent) & pushen
# -----------------------------------------------------------------------------
echo ""
echo "▶ 6/7  Repository aufsetzen …"

if gh repo view "$GH_USER/$REPO_NAME" >/dev/null 2>&1; then
  echo "   ✓ Repo existiert bereits: $GH_USER/$REPO_NAME"
  if ! git remote get-url origin >/dev/null 2>&1; then
    git remote add origin "https://github.com/$GH_USER/$REPO_NAME.git"
  fi
  git push -u origin main
else
  echo "   → erstelle Repo + push …"
  gh repo create "$REPO_NAME" --public --source=. --push --description "Italien-Urlaub 2026 – Reise-Dashboard"
fi
echo "   ✓ Code auf GitHub"

# -----------------------------------------------------------------------------
# 7. GitHub Pages aktivieren
# -----------------------------------------------------------------------------
echo ""
echo "▶ 7/7  GitHub Pages aktivieren …"
gh api -X POST "repos/$GH_USER/$REPO_NAME/pages" \
  -f "source[branch]=main" \
  -f "source[path]=/" \
  >/dev/null 2>&1 || true

# Kurz warten, bis Pages bereit ist
sleep 2

URL="https://$GH_USER.github.io/$REPO_NAME/"

echo "   ✓ Pages aktiviert"
echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║                  ✅  FERTIG!                      ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "   Deine Seite ist (nach ca. 30–60 Sek. Build-Zeit) hier live:"
echo ""
echo "     👉  $URL"
echo ""
echo "   Tipp für iPhone: In Safari öffnen → Teilen → "Zum Home-Bildschirm""
echo "   → Dashboard liegt wie eine App auf dem Handy."
echo ""

# Automatisch im Browser öffnen
sleep 2
open "$URL" 2>/dev/null || true

echo "   (Zum Schließen eine Taste drücken …)"
read -n 1
