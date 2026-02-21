# Claude Code in Docker

Run [Claude Code](https://claude.ai/code) inside a local Docker container — isolated from your main system, reproducible, and easy to update.

---

## Why run Claude Code in Docker?

Running Claude Code inside a container gives you a layer of isolation between the AI agent and your host machine:

- **Filesystem isolation** — Claude can only read and write files inside the `workspace/` folder you mount. It cannot browse your Documents, Desktop, or other drives unless you explicitly share them.
- **No system-level changes** — Claude cannot install packages on your host OS, modify system files, or change environment variables outside the container.
- **Reproducible environment** — The container always starts with the same Node.js version, tools, and Claude Code version. Easy to reset or share.
- **Easy to wipe and restart** — If something goes wrong, delete the container and rebuild in minutes. Your `workspace/` files are untouched.

> **What it cannot protect against:** Claude Code still has internet access and can make API calls. It also has full access to anything inside the `workspace/` folder. Review Claude's actions before confirming anything destructive.

---

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Windows, Mac, or Linux. Must be running before setup. |
| Anthropic API key | Get one at [console.anthropic.com](https://console.anthropic.com/). Requires a paid account. |
| ~2 GB disk space | For the container image. Your project files are separate. |

---

## Setup (first time only)

### Option A — Guided setup (Windows, recommended)

1. **Download or clone this folder** to your machine.
2. **Double-click `setup.bat`**.
3. Follow the prompts — it will check Docker, ask for your API key, build the image, and launch Claude Code.

That's it. Skip to [Daily Use](#daily-use) below.

---

### Option B — One-command setup (Mac / Linux)

1. **Download or clone this folder** to your machine.
2. In Terminal, run:

```bash
./setup.sh
```

The script checks Docker, asks for your API key (hidden input), builds the image, starts the container, and can launch Claude immediately.

That's it. Skip to [Daily Use](#daily-use) below.

---

### Option C — Manual setup (Mac, Linux, or Windows terminal)

**1. Copy the environment file and add your API key:**

```bash
cp .env.example .env
```

Open `.env` in any text editor and replace `your-api-key-here` with your actual key:

```
ANTHROPIC_API_KEY=sk-ant-...
```

> Keep `.env` private — it is listed in `.gitignore` and will not be committed to git.

**2. Build the container image:**

```bash
docker compose build
```

This downloads the base image and installs Claude Code natively inside it. First build takes a few minutes. Subsequent builds are fast.

**3. Start the container:**

```bash
docker compose up -d
```

The container starts in the background and stays running (`sleep infinity`). It will restart automatically when Docker starts.

**4. Launch Claude Code:**

```bash
docker exec -it claude-code claude
```

Or on Windows, double-click **`claude.bat`** — it handles starting the container and updating Claude Code automatically.

---

## Daily use

### Windows
Double-click **`claude.bat`** — it starts the container if needed, checks for updates, and opens Claude Code in a new terminal window.

### Mac / Linux

```bash
./claude.sh
```

`./claude.sh` starts the container if needed, checks for Claude updates, and opens Claude in your current terminal.

If you prefer the direct command:

```bash
docker exec -it claude-code claude
```

Or add this alias to your shell profile for convenience:

```bash
alias claude-docker='docker exec -it claude-code claude'
```

---

## Your workspace

The `workspace/` folder in this directory is mounted inside the container at `/workspace`. This is the **only folder Claude can access**.

```
claude-docker-starter/
└── workspace/        ← put your projects here
    └── my-project/   ← Claude sees this as /workspace/my-project
```

**To work on an existing project:**
- Copy or move it into `workspace/`
- Or clone it: `docker exec -it claude-code bash -c "cd /workspace && git clone <url>"`

**To open a shell in the container** (without launching Claude Code):

```bash
docker exec -it claude-code bash
```

---

## Updating Claude Code

Claude Code updates itself automatically in the background while it runs.

To manually update:

```bash
docker exec claude-code claude update
```

Windows users: `claude.bat` does this automatically on every launch.

---

## Stopping and starting

```bash
docker compose stop    # stop the container (workspace and settings preserved)
docker compose start   # start it again
docker compose down    # stop and remove the container (workspace still safe)
docker compose up -d   # recreate and start
```

---

## Starting completely fresh

If you want to wipe everything and start over:

```bash
docker compose down
docker volume rm claude-docker-starter_claude_home   # deletes Claude settings/history
docker compose up -d
```

Your `workspace/` files are **not** affected — they live on your host machine.

---

## File reference

```
claude-docker-starter/
├── Dockerfile            Container definition — Node 20 + Claude Code native install
├── docker-compose.yaml   Service config — volumes, env file, restart policy
├── .env.example          Template for your API key (copy to .env)
├── .env                  Your API key — created by setup, never committed to git
├── .gitignore            Excludes .env and workspace contents from git
├── setup.bat             First-time setup wizard (Windows)
├── claude.bat            Daily launcher (Windows)
├── setup.sh              First-time setup script (Mac/Linux)
├── claude.sh             Daily launcher script (Mac/Linux)
└── workspace/            Your project files — mounted at /workspace in the container
```

---

## Security notes

| What Claude can access | What Claude cannot access |
|------------------------|---------------------------|
| Everything in `workspace/` | Your host filesystem outside `workspace/` |
| The internet (for API calls, npm, git) | Other Docker containers on your machine |
| Environment variables in `.env` | Your host OS, registry, system files |

**Your API key** is passed into the container via the `.env` file and is never baked into the image. Do not share your `.env` file or commit it to a public repository.

**To restrict internet access** (advanced): add `--network none` to the container in `docker-compose.yaml`. Note this will break `git clone`, `npm install`, and Claude's web search tool.

---

## Troubleshooting

**`Docker is not running`** — Open Docker Desktop and wait for it to finish starting before running setup (`setup.bat` / `setup.sh`) or launch (`claude.bat` / `claude.sh`).

**`claude: command not found` inside the container** — The PATH may not include `~/.local/bin`. Run:
```bash
docker exec claude-code bash -c "export PATH=$HOME/.local/bin:$PATH && claude --version"
```
If that works, the container needs to be rebuilt: `docker compose build --no-cache && docker compose up -d`.

**API key errors** — Check your `.env` file contains the correct key with no extra spaces. Test it:
```bash
docker exec claude-code bash -c "echo \$ANTHROPIC_API_KEY"
```

**Container won't start** — Check Docker Desktop is running and has enough memory allocated (4 GB minimum recommended).
