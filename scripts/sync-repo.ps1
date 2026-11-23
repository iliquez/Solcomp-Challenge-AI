# Hook SessionStart: trae los cambios remotos al abrir un chat del proyecto.
# Solo fast-forward: nunca hace merge ni pisa trabajo local. Siempre sale con 0 para no bloquear la sesión.
$env:GIT_TERMINAL_PROMPT = 0   # sin credenciales interactivas: falla en vez de colgarse
Set-Location (Split-Path $PSScriptRoot)
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) { exit 0 }
$out = git pull --ff-only 2>&1
"Sincronizacion automatica del repo (git pull --ff-only): $($out -join ' ')"
exit 0
