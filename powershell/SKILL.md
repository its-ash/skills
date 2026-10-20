---
name: powershell
description: "Teaches Windows PowerShell and PowerShell Core best practices for writing, reviewing, and fixing .ps1 scripts, including operator parentheses, ASCII-only source, null checks, string interpolation, try/catch error handling, path and array operations, and JSON parsing. Use when working with PowerShell, pwsh, .ps1 files, cmdlets, Invoke-WebRequest, Get-Content, ConvertFrom-Json, Set-StrictMode, -and/-or operators, encoding issues, null values, or script errors."
---

# PowerShell Windows Patterns

Write reliable Windows PowerShell scripts. Follow the rules below to avoid syntax errors, encoding problems, and runtime failures.

## When to use
When you create automation, administration, or tooling scripts that run on Windows PowerShell.

## Operator Syntax
- Wrap each cmdlet call in parentheses when combined with logical operators.
- Example: `if ((Test-Path "a") -or (Test-Path "b")) { … }`

## Unicode / Emoji Restriction
- Use only ASCII characters in script files.
- Replace emojis with plain text tokens such as `[OK]`, `[WARN]`, `[ERROR]`.

## Null Checks
- Test an object before accessing its members.
- Example: `if ($array -and $array.Count -gt 0) { … }`
- Example: `if ($text) { $text.Length }`

## String Interpolation
- Do not embed complex property chains directly.
- Assign the value to a variable first, then interpolate.
- Example:
```powershell
$value = $obj.prop.sub
Write-Output "Value: $value"
```

## Error Handling
- Set `$ErrorActionPreference` to match the script stage:
  - `"Stop"` for development (fail fast).
  - `"Continue"` for production.
  - `"SilentlyContinue"` when errors are expected.
- Use `try / catch / finally`:
  - Do not `return` inside the `try` block.
  - Place cleanup code in `finally`.
  - Return or exit after the block.

## File Path Handling
- Use literal paths for static files, e.g., `C:\Users\User\file.txt`.
- Build dynamic paths with `Join-Path` to avoid hard‑coded separators.
- Example: `$path = Join-Path $env:USERPROFILE "file.txt"`
- Resolve script‑relative paths with:
```powershell
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
```

## Array Operations
- Create an empty array: `$array = @()`
- Append an item: `$array += $item`
- For large collections, use an `ArrayList`:
```powershell
$list = [System.Collections.ArrayList]::new()
$list.Add($item) | Out-Null
```

## JSON Operations
- Always specify `-Depth` when converting to JSON:
  `ConvertTo-Json -Depth 10`
- Read JSON:
```powershell
Get-Content "file.json" -Raw | ConvertFrom-Json
```
- Write JSON:
```powershell
$data | ConvertTo-Json -Depth 10 | Out-File "file.json" -Encoding UTF8
```

## Common Errors and Fixes
| Error | Typical cause | Fix |
|------|--------------|-----|
| `parameter 'or'` | Missing parentheses around cmdlet calls | Wrap each call in `()` |
| `Unexpected token` | Unicode or emoji character in script | Replace with ASCII characters |
| `Cannot find property` | Null object accessed | Add a null check before property access |
| `Cannot convert` | Type mismatch | Cast with `.ToString()` or use an appropriate conversion cmdlet |

## Script Template
```powershell
# Enable strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# Resolve script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

try {
    # Insert script logic here
    Write-Output "[OK] Done"
    exit 0
}
catch {
    Write-Warning "Error: $_"
    exit 1
}
finally {
    # Optional cleanup code
}
```

## Checklist
- [ ] Enclose each cmdlet in parentheses when using `-and`, `-or`, or `-xor`.
- [ ] Verify the script contains only ASCII characters.
- [ ] Add null checks before accessing properties or methods.
- [ ] Use a variable for complex interpolations.
- [ ] Set `$ErrorActionPreference` to the appropriate level.
- [ ] Apply the `try / catch / finally` pattern; avoid `return` inside `try`.
- [ ] Build file paths with `Join-Path`.
- [ ] Specify `-Depth` for `ConvertTo-Json`.
- [ ] Review the common error table for known patterns.

## Related skills

Load these when the task spans more than this skill.

- [`bash-scripting`](../bash-scripting/SKILL.md) — Bash Scripting – a concise guide for writing safe, production‑ready Bash scripts on Linux/macOS. Includes comm…
- [`devops-iac`](../devops-iac/SKILL.md) — DevOps IaC skill provides a step-by-step workflow for designing, implementing, and operating cloud infrastruct…
- [`it-operations`](../it-operations/SKILL.md) — Manages IT infrastructure, monitoring, incident response, and service reliability. Use this skill for ITIL ser…
- [`systematic-debugging`](../systematic-debugging/SKILL.md) — A step‑by‑step process for diagnosing and fixing bugs, test failures, or unexpected behavior. Use it for any t…
- [`workflow-automation`](../workflow-automation/SKILL.md) — Architect and implement reliable automation using n8n, Zapier, Make, and durable execution platforms. Use for…
