#!/bin/bash
# WormGPT Android — Start Script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RESET='\033[0m'

echo -e "${CYAN}🐛 WormGPT Android${RESET}"
echo ""

# ── Check Node ────────────────────────────────────────────────────────────────
if ! command -v node &>/dev/null; then
  echo -e "${RED}❌ Node.js not found. Run: bash install-android.sh${RESET}"
  exit 1
fi
NODE_MAJOR=$(node -e "console.log(process.versions.node.split('.')[0])")
if [ "$NODE_MAJOR" -lt 18 ]; then
  echo -e "${RED}❌ Node.js 18+ required. Run: bash install-android.sh${RESET}"
  exit 1
fi

# ── Check frontend is built ───────────────────────────────────────────────────
if [ ! -d "$SCRIPT_DIR/app/dist" ]; then
  echo -e "${YELLOW}⚠  Frontend not built. Building now...${RESET}"
  cd "$SCRIPT_DIR/app"
  npm install --silent && npm run build --silent
  cd "$SCRIPT_DIR"
  echo -e "${GREEN}✓ Built${RESET}"
fi

# ── Check server deps ─────────────────────────────────────────────────────────
if [ ! -d "$SCRIPT_DIR/server/node_modules" ]; then
  echo -e "${YELLOW}⚠  Server deps missing. Installing...${RESET}"
  cd "$SCRIPT_DIR/server" && npm install --silent && cd "$SCRIPT_DIR"
  echo -e "${GREEN}✓ Server deps installed${RESET}"
fi

# ── Kill anything on port 3001 ────────────────────────────────────────────────
if command -v fuser &>/dev/null && fuser 3001/tcp &>/dev/null 2>&1; then
  echo -e "${YELLOW}⚠  Port 3001 in use — killing old process...${RESET}"
  fuser -k 3001/tcp 2>/dev/null || true
  sleep 1
elif command -v lsof &>/dev/null && lsof -ti:3001 &>/dev/null; then
  kill $(lsof -ti:3001) 2>/dev/null || true
  sleep 1
fi

# ── Print info ────────────────────────────────────────────────────────────────
echo ""
echo -e "  ${CYAN}URL      →  http://localhost:3001${RESET}"
echo -e "  ${CYAN}Password →  Realnojokepplwazy1234${RESET}"
echo ""
echo -e "  ${YELLOW}Backend: ${BACKEND_MODE:-ollama}${RESET}"
echo ""
echo -e "  Override backend via env vars:"
echo -e "  ${GREEN}BACKEND_MODE=groq GROQ_API_KEY=gsk_xxx bash start-android.sh${RESET}"
echo -e "  ${GREEN}BACKEND_MODE=ollama OLLAMA_URL=http://192.168.1.10:11434 bash start-android.sh${RESET}"
echo -e "  ${GREEN}BACKEND_MODE=llamacpp bash start-android.sh${RESET}"
echo ""
echo -e "  Press ${RED}Ctrl+C${RESET} to stop."
echo ""

# ── Start server ──────────────────────────────────────────────────────────────
cd "$SCRIPT_DIR/server"
exec node index.js
