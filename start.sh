#!/bin/bash
# WormGPT Enhanced — Linux Start Script
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RESET='\033[0m'

echo -e "${CYAN}"
echo "  🐛 WormGPT Enhanced"
echo -e "${RESET}"

# ── Check Node.js ──────────────────────────────────────────────────────────
if ! command -v node &>/dev/null; then
  echo -e "${RED}❌ Node.js not found. Run ./install-linux.sh first${RESET}"
  exit 1
fi
NODE_VER=$(node -e "process.exit(parseInt(process.versions.node.split('.')[0]))" 2>/dev/null; echo $?)
# Better version check
NODE_MAJOR=$(node -e "console.log(process.versions.node.split('.')[0])")
if [ "$NODE_MAJOR" -lt 18 ]; then
  echo -e "${RED}❌ Node.js 18+ required (found v$NODE_MAJOR). Run ./install-linux.sh${RESET}"
  exit 1
fi

# ── Check frontend is built ────────────────────────────────────────────────
if [ ! -d "$SCRIPT_DIR/app/dist" ]; then
  echo -e "${YELLOW}⚠  Frontend not built. Building now...${RESET}"
  cd "$SCRIPT_DIR/app"
  npm install --silent
  npm run build --silent
  cd "$SCRIPT_DIR"
  echo -e "${GREEN}✅ Frontend built${RESET}"
fi

# ── Check server deps ──────────────────────────────────────────────────────
if [ ! -d "$SCRIPT_DIR/server/node_modules" ]; then
  echo -e "${YELLOW}⚠  Server deps missing. Installing...${RESET}"
  cd "$SCRIPT_DIR/server"
  npm install --silent
  cd "$SCRIPT_DIR"
  echo -e "${GREEN}✅ Server deps installed${RESET}"
fi

# ── Start Ollama if not running ────────────────────────────────────────────
if command -v ollama &>/dev/null; then
  if ! pgrep -x "ollama" &>/dev/null; then
    echo -e "${CYAN}🦙 Starting Ollama service...${RESET}"
    ollama serve &>/dev/null &
    OLLAMA_PID=$!

    # Wait up to 15 seconds for Ollama to be ready
    echo -n "   Waiting for Ollama"
    for i in $(seq 1 15); do
      if curl -sf http://localhost:11434/api/tags &>/dev/null; then
        echo -e " ${GREEN}✅${RESET}"
        break
      fi
      echo -n "."
      sleep 1
    done
    echo ""
  else
    echo -e "${GREEN}✅ Ollama already running${RESET}"
  fi
else
  echo -e "${YELLOW}⚠  Ollama not found — install from https://ollama.ai${RESET}"
fi

# ── Kill any existing server on port 3001 ─────────────────────────────────
if lsof -ti:3001 &>/dev/null; then
  echo -e "${YELLOW}⚠  Port 3001 in use — killing old process...${RESET}"
  kill $(lsof -ti:3001) 2>/dev/null || true
  sleep 1
fi

# ── Start server ───────────────────────────────────────────────────────────
echo -e "${GREEN}🚀 Starting WormGPT server...${RESET}"
echo ""
echo -e "  ${CYAN}URL      →  http://localhost:3001${RESET}"
echo -e "  ${CYAN}Password →  Realnojokepplwazy1234${RESET}"
echo ""
echo "  Press Ctrl+C to stop."
echo ""

cd "$SCRIPT_DIR/server"
exec node index.js
