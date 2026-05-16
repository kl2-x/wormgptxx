# WormGPT — Android Edition

Same full app, rewritten to run on Android (Samsung, rooted, Kali NetHunter, Termux, proot-distro Ubuntu).

**Why this exists:** Ollama requires x86/amd64. Samsung phones run ARM. So the server was rewritten to support 6 different AI backends — including free cloud APIs that need zero local model setup.

---

## Quick Install (Termux / Kali / Ubuntu proot)

```bash
bash install-android.sh
bash start-android.sh
```

Then open your phone browser: **http://localhost:3001**  
Password: **Realnojokepplwazy1234**

After opening the app → go to **Settings → 🤖 Backend** and pick your AI source.

---

## Backend Options

| Mode | What it is | Setup needed |
|------|-----------|--------------|
| **Groq Cloud** | Free API, very fast, Llama/Mixtral/Gemma | Get free key at console.groq.com |
| **OpenRouter** | Free models available | Get free key at openrouter.ai |
| **Remote Ollama** | Your x86 PC/VPS running Ollama | Run Ollama on another machine |
| **llama.cpp** | ARM-native, runs in Termux | Compile llama.cpp in Termux |
| **OpenAI** | GPT-4o etc. | Paid API key |
| **Anthropic** | Claude models | Paid API key |

---

## Recommended: Groq (easiest, free)

1. Go to **https://console.groq.com** → sign up → create API key
2. Open WormGPT → Settings → 🤖 Backend → select **Groq Cloud**
3. Paste your API key → Save & Apply
4. Done — you now have fast llama-3.3-70b for free

---

## Remote Ollama (if you have a PC)

On your **PC** (must be on same network or have port forwarded):
```bash
# Install Ollama first: https://ollama.ai
OLLAMA_HOST=0.0.0.0 ollama serve
ollama pull llama3
```

In WormGPT Settings → Backend → Remote Ollama → enter your PC's local IP:
```
http://192.168.1.10:11434
```

---

## llama.cpp in Termux (full offline, ARM-native)

```bash
pkg install cmake git python clang
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
cmake -B build -DGGML_OPENMP=OFF
cmake --build build -j4 --target llama-server

# Download a small model (example: Phi-3 mini ~2GB)
# Put your .gguf model file in llama.cpp/models/

./build/bin/llama-server -m models/yourmodel.gguf --port 8080 -c 2048
```

Then in WormGPT → Settings → Backend → llama.cpp → Save.

**Recommended models for phones (small/fast):**
- `phi-3-mini-4k-instruct.Q4_K_M.gguf` (~2.2GB)
- `gemma-2-2b-it.Q4_K_M.gguf` (~1.5GB)
- `qwen2.5-1.5b-instruct.Q4_K_M.gguf` (~1GB)

Download from: https://huggingface.co/models (filter by GGUF)

---

## Start with backend pre-set (via env vars)

```bash
# Groq
BACKEND_MODE=groq GROQ_API_KEY=gsk_xxx bash start-android.sh

# OpenRouter
BACKEND_MODE=openrouter OPENROUTER_KEY=sk-or-xxx bash start-android.sh

# Remote Ollama
BACKEND_MODE=ollama OLLAMA_URL=http://192.168.1.10:11434 bash start-android.sh

# llama.cpp local
BACKEND_MODE=llamacpp LLAMACPP_URL=http://localhost:8080 bash start-android.sh
```

---

## All features work exactly the same

- Chat with streaming
- Terminal (runs shell commands in Termux)
- Code runner (Python, JS, Bash)
- Website builder
- Project editor / ZIP upload
- Knowledge base (RAG)
- Mind map canvas
- Git integration
- Command palette (Ctrl+K)
- Session restore
- Export/import chat
- 4 parallel response variants
- System prompt customization
- Temperature / context controls

---

## Troubleshooting

**Port already in use:**
```bash
fuser -k 3001/tcp
bash start-android.sh
```

**Node.js not found in Termux:**
```bash
pkg update && pkg install nodejs-lts
```

**Node.js not found in Kali/Ubuntu proot:**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
```

**Frontend not building (memory error):**
```bash
# Increase Node.js heap in Termux
NODE_OPTIONS="--max-old-space-size=512" npm run build
```
