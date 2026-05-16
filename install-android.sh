#!/bin/bash
# ╔══════════════════════════════════════════════════════════╗
# ║          WormGPT — Android / Termux Installer           ║
# ║                                                          ║
# ║  Supports: Termux, Kali NetHunter, Ubuntu proot-distro  ║
# ╚══════════════════════════════════════════════════════════╝
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RESET='\033[0m'

echo -e "${CYAN}"
echo "  ██╗    ██╗ ██████╗ ██████╗ ███╗   ███╗ ██████╗ ██████╗ ████████╗"
echo "  ██║    ██║██╔═══██╗██╔══██╗████╗ ████║██╔════╝ ██╔══██╗╚══██╔══╝"
echo "  ██║ █╗ ██║██║   ██║██████╔╝██╔████╔██║██║  ███╗██████╔╝   ██║   "
echo "  ██║███╗██║██║   ██║██╔══██╗██║╚██╔╝██║██║   ██║██╔═══╝    ██║   "
echo "  ╚███╔███╔╝╚██████╔╝██║  ██║██║ ╚═╝ ██║╚██████╔╝██║        ██║   "
echo "   ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝        ╚═╝   "
echo -e "${RESET}"
echo -e "${CYAN}         Android Edition — Samsung / Rooted / Termux${RESET}"
echo ""

# ── Detect environment ────────────────────────────────────────────────────────
IS_TERMUX=false
IS_KALI=false
IS_UBUNTU=false

if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
  IS_TERMUX=true
  echo -e "${GREEN}✓ Detected: Termux${RESET}"
elif [ -f "/etc/kali-release" ]; then
  IS_KALI=true
  echo -e "${GREEN}✓ Detected: Kali Linux${RESET}"
elif [ -f "/etc/lsb-release" ] && grep -q Ubuntu /etc/lsb-release 2>/dev/null; then
  IS_UBUNTU=true
  echo -e "${GREEN}✓ Detected: Ubuntu (proot-distro)${RESET}"
else
  echo -e "${YELLOW}⚠  Unknown environment — assuming Debian/Ubuntu-like${RESET}"
  IS_UBUNTU=true
fi

# ── Install Node.js ───────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}📦 Checking Node.js...${RESET}"

if command -v node &>/dev/null; then
  NODE_MAJOR=$(node -e "console.log(process.versions.node.split('.')[0])")
  if [ "$NODE_MAJOR" -ge 18 ]; then
    echo -e "${GREEN}✓ Node.js $(node -v) already installed${RESET}"
  else
    echo -e "${YELLOW}⚠  Node.js $NODE_MAJOR is too old. Need 18+. Upgrading...${RESET}"
    install_node
  fi
else
  install_node
fi

install_node() {
  if $IS_TERMUX; then
    echo "  Installing via Termux pkg..."
    pkg update -y -q
    pkg install -y nodejs-lts
  elif $IS_KALI || $IS_UBUNTU; then
    echo "  Installing via NodeSource..."
    apt-get update -q
    apt-get install -y -q curl
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y -q nodejs
  fi
}

# ── Install git (needed for simple-git) ───────────────────────────────────────
echo ""
echo -e "${CYAN}📦 Checking git...${RESET}"
if ! command -v git &>/dev/null; then
  if $IS_TERMUX; then
    pkg install -y git
  else
    apt-get install -y -q git
  fi
  echo -e "${GREEN}✓ git installed${RESET}"
else
  echo -e "${GREEN}✓ git already installed${RESET}"
fi

# ── Install frontend dependencies ─────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo ""
echo -e "${CYAN}📦 Installing frontend dependencies...${RESET}"
cd "$SCRIPT_DIR/app"
npm install --silent
echo -e "${GREEN}✓ Frontend deps installed${RESET}"

# ── Build frontend ────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}🔨 Building frontend (React → static files)...${RESET}"
npm run build --silent
echo -e "${GREEN}✓ Frontend built${RESET}"

# ── Install server dependencies ───────────────────────────────────────────────
echo ""
echo -e "${CYAN}📦 Installing server dependencies...${RESET}"
cd "$SCRIPT_DIR/server"
npm install --silent
echo -e "${GREEN}✓ Server deps installed${RESET}"

cd "$SCRIPT_DIR"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║  ✅  Installation Complete!                              ║${RESET}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════╣${RESET}"
echo -e "${GREEN}║                                                          ║${RESET}"
echo -e "${GREEN}║  Run:      ${CYAN}bash start-android.sh${GREEN}                         ║${RESET}"
echo -e "${GREEN}║  Open:     ${CYAN}http://localhost:3001${GREEN}  in your browser        ║${RESET}"
echo -e "${GREEN}║  Password: ${CYAN}Realnojokepplwazy1234${GREEN}                         ║${RESET}"
echo -e "${GREEN}║                                                          ║${RESET}"
echo -e "${GREEN}║  ⚠  Ollama DOES NOT run on ARM (Samsung).               ║${RESET}"
echo -e "${GREEN}║  After opening, go to Settings → 🤖 Backend and pick:  ║${RESET}"
echo -e "${GREEN}║    • Groq Cloud    (free API key, fastest)              ║${RESET}"
echo -e "${GREEN}║    • OpenRouter    (free models available)              ║${RESET}"
echo -e "${GREEN}║    • Remote Ollama (if you have a PC running it)        ║${RESET}"
echo -e "${GREEN}║    • llama.cpp     (ARM-native, runs in Termux)         ║${RESET}"
echo -e "${GREEN}║                                                          ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
