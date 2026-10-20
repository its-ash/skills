---
name: bash-scripting
description: "Write production-ready Bash scripts with safe patterns: set -euo pipefail, trap cleanup, functions, arrays, and parameter expansion. Use when writing .sh files, shebang scripts, cron jobs, systemd units, Docker entrypoints, CI pipelines, backup rotation with rsync tar gzip, user management useradd usermod chmod chown, firewall iptables ufw, monitoring df du free top journalctl, automation ssh scp find xargs awk sed grep jq, error handling exit codes signals SIGINT SIGTERM, debugging set -x PS4 BASH_XTRACEFD."
---

# Bash Scripting

Write reliable Bash scripts for Linux/macOS. Use this skill when you need to automate system tasks, manage files, monitor resources, handle users, or create production‑grade scripts.

## When to use
- You need a quick script to back up data, rotate logs, or sync directories.
- You want to monitor CPU, disk, or network status and trigger alerts.
- You must manage users, passwords, or encrypt files.
- You are building cron jobs, package installers, or deployment helpers.
- You require safe Bash patterns: strict error handling, variable quoting, and reusable functions.

---

## Core Bash Patterns

### Command Chaining
- `cmd1; cmd2` – run sequentially.
- `cmd1 && cmd2` – run `cmd2` only if `cmd1` succeeds.
- `cmd1 || cmd2` – run `cmd2` only if `cmd1` fails.
- `cmd1 | cmd2` – pipe output of `cmd1` to `cmd2`.

### Safe Script Options
```bash
set -euo pipefail   # exit on error, undefined var, or pipe failure
set -x               # optional: print each command (debug)
```

### Common Functions
```bash
log_info()  { echo -e "\033[0;32m[INFO]\033[0m $*"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $*" >&2; }
```

### Traps for Cleanup
```bash
cleanup() { rm -f /tmp/tempfile; log_info "Cleaned up"; }
trap cleanup EXIT
```

---

## Essential Commands
| Task | Command |
|------|---------|
| List files (including hidden) | `ls -la` |
| Find files by pattern | `find . -type f -name "*.sh"` |
| Show file content | `cat file.txt` |
| First/last N lines | `head -n 20 file.txt` / `tail -n 20 file.txt` |
| Follow log | `tail -f /var/log/syslog` |
| Search recursively | `grep -rn "TODO" src/` |
| Disk usage per dir | `du -sh *` |
| Overall disk free | `df -h` |
| Process list | `ps aux` |
| Find process by name | `pgrep -fl node` |
| Kill by PID | `kill -9 $PID` |
| Open port check | `nc -zv localhost 3000` |
| Download file | `curl -O https://example.com/file.tar.gz` |
| HTTP GET/POST | `curl -X GET URL` / `curl -X POST -H "Content-Type: application/json" -d '{"k":"v"}' URL` |
| Network interface info | `ip addr show eth0` or `ifconfig eth0` |
| Make script executable | `chmod +x script.sh` |
| Run script | `./script.sh` |
| Run in background | `nohup ./script.sh &` |
| Edit cron jobs | `crontab -e` |
| Source script in current shell | `source script.sh` |

---

## Text Processing Toolbox
- **grep** – pattern search. Example: `grep -i "error" logfile.txt`.
- **sed** – in‑place replace. Example: `sed -i 's/old/new/g' file.txt`.
- **awk** – column extraction. Example: `awk '{print $1,$3}' file.txt`.
- **cut** – field cutting. Example: `cut -d',' -f1 data.csv`.
- **sort** / **uniq** – sorting and deduplication. Example: `sort file.txt | uniq -c`.
- **wc** – count lines/words/bytes. Example: `wc -l file.txt`.

---

## Environment Variables
```bash
# View all
printenv
# View one
echo "$PATH"
# Set temporary for a command
VAR="value" command
# Export for the script
export VAR="value"
# Append to PATH
export PATH="$PATH:/opt/bin"
```

---

## Common Script Patterns
- **Check command existence**
  ```bash
  if command -v git &>/dev/null; then
    log_info "Git is installed"
  else
    log_error "Git not found"
  fi
  ```
- **Default argument value**
  ```bash
  BACKUP_DIR=${1:-/backup}
  ```
- **Read file line‑by‑line**
  ```bash
  while IFS= read -r line; do
    log_info "$line"
  done < "$FILE"
  ```
- **Loop over files**
  ```bash
  for f in *.log; do
    gzip "$f"
  done
  ```

---

## Production‑Ready Script Templates
### 1. Directory Backup (local)
```bash
#!/usr/bin/env bash
set -euo pipefail
backup_dir="/backups"
source_dir="/data"
timestamp=$(date +%Y%m%d_%H%M%S)
archive="$backup_dir/backup_${timestamp}.tar.gz"
log_info "Creating backup $archive"
 tar -czf "$archive" -C "$source_dir" .
log_info "Backup completed"
```

### 2. Remote Rsync Backup
```bash
#!/usr/bin/env bash
set -euo pipefail
src="/var/www"
remote="user@remote:/backups/www"
log_info "Syncing $src to $remote"
rsync -avz --progress "$src/" "$remote/"
log_info "Remote backup finished"
```

### 3. Backup Rotation
```bash
#!/usr/bin/env bash
set -euo pipefail
backup_dir="/backups"
max=5
while [ $(ls -1 "$backup_dir" | wc -l) -gt $max ]; do
  oldest=$(ls -1t "$backup_dir" | tail -n 1)
  rm -rf "$backup_dir/$oldest"
  log_info "Removed old backup $oldest"
done
log_info "Rotation complete"
```

### 4. CPU Usage Alert
```bash
#!/usr/bin/env bash
set -euo pipefail
threshold=90
cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
if (( cpu > threshold )); then
  log_error "High CPU: ${cpu}%"
  # Example: mail -s "CPU Alert" admin@example.com <<< "CPU at $cpu%"
fi
```

### 5. Disk Space Alert
```bash
#!/usr/bin/env bash
set -euo pipefail
threshold=90
partition="/dev/sda1"
usage=$(df -h "$partition" | awk 'NR==2 {print $5}' | tr -d '%')
if (( usage > threshold )); then
  log_error "Disk $partition at ${usage}%"
fi
```

### 6. User Creation
```bash
#!/usr/bin/env bash
set -euo pipefail
username=${1:?Provide username}
if id "$username" &>/dev/null; then
  log_info "User $username already exists"
else
  sudo useradd -m -s /bin/bash "$username"
  log_info "User $username created"
  sudo passwd "$username"
fi
```

### 7. Password Generator
```bash
#!/usr/bin/env bash
set -euo pipefail
len=${1:-16}
password=$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9!@#$%^&*' | head -c "$len")
echo "Generated password: $password"
```

### 8. File Encryption / Decryption
```bash
#!/usr/bin/env bash
set -euo pipefail
file=${1:?File required}
action=${2:-encrypt}
if [[ "$action" == encrypt ]]; then
  openssl enc -aes-256-cbc -salt -pbkdf2 -in "$file" -out "$file.enc"
  log_info "Encrypted to $file.enc"
else
  out=${file%.enc}
  openssl enc -aes-256-cbc -d -pbkdf2 -in "$file" -out "$out"
  log_info "Decrypted to $out"
fi
```

### 9. Log Error Extractor
```bash
#!/usr/bin/env bash
set -euo pipefail
logfile=${1:-/var/log/syslog}
out="error_$(date +%Y%m%d).txt"
grep -iE "error|fail|critical" "$logfile" > "$out"
log_info "Extracted $(wc -l < "$out") errors to $out"
```

### 10. Cron Job Installer
```bash
#!/usr/bin/env bash
set -euo pipefail
script_path="/usr/local/bin/cleanup.sh"
schedule="0 2 * * *"   # daily at 02:00
(crontab -l 2>/dev/null; echo "$schedule $script_path") | crontab -
log_info "Cron job installed: $schedule $script_path"
```

---

## Checklist for Production Bash Scripts
- [ ] Start with `#!/usr/bin/env bash` and `set -euo pipefail`.
- [ ] Quote all variable expansions: `"$var"`.
- [ ] Use absolute paths for files and commands.
- [ ] Validate required arguments (`${1:?msg}`).
- [ ] Check for required commands with `command -v`.
- [ ] Log progress with a consistent function (`log_info`, `log_error`).
- [ ] Add a `trap` for cleanup on EXIT, INT, TERM.
- [ ] Test script with `bash -x script.sh` before production.
- [ ] Run in a non‑privileged environment first; add `sudo` only where needed.
- [ ] Document usage at the top of the script (purpose, arguments, examples).
- [ ] Ensure the script is executable (`chmod +x`).

---

## Quick Reference Table
| Pattern | Example |
|---------|---------|
| Shebang | `#!/usr/bin/env bash` |
| Date stamp | `$(date +%Y%m%d_%H%M%S)` |
| Arithmetic | `$((a + b))` |
| Default value | `${var:-default}` |
| All args | `"$@"` |
| Loop array | `for i in "${arr[@]}"; do …; done` |
| Exit on error | `set -e` |
| Debug | `set -x` |

---

**Remember:** Always test scripts on a non‑critical system, use absolute paths, and keep logs for troubleshooting.

## Related skills

Load these when the task spans more than this skill.

- [`devops-iac`](../devops-iac/SKILL.md) — DevOps IaC skill provides a step-by-step workflow for designing, implementing, and operating cloud infrastruct…
- [`docker`](../docker/SKILL.md) — Provides expert guidance for Dockerfile optimization, multi‑stage builds, image size reduction, container secu…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
- [`secrets-management`](../secrets-management/SKILL.md) — Manage secrets for CI/CD and runtime systems with Vault, AWS Secrets Manager, GitHub/GitLab variables, Kuberne…
- [`workflow-automation`](../workflow-automation/SKILL.md) — Architect and implement reliable automation using n8n, Zapier, Make, and durable execution platforms. Use for…
- [`slash-command-development`](../slash-command-development/SKILL.md) — Defines how to create, configure, and organize Claude Code slash commands. Covers file locations, YAML frontma…
- [`ai-cli-delegation`](../ai-cli-delegation/SKILL.md) — Delegates user requests to AI command‑line tools (Gemini CLI or Codex CLI). Choose the appropriate model, sand…
