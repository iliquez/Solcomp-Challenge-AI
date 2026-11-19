# Verifica SHA-256, bytes y filas de cada archivo contra MANIFIESTO.json.
# Uso: .\verificar_hashes.ps1 -Base <carpeta con MANIFIESTO.json>
# Lee por bloques (sin cargar archivos completos en memoria). Salida 1 si algo no coincide.
param([string]$Base = ".")

$Base = (Resolve-Path $Base).Path
$man = Get-Content (Join-Path $Base "MANIFIESTO.json") -Raw -Encoding UTF8 | ConvertFrom-Json
$fallas = 0

foreach ($a in $man.archivos) {
    $ruta = Join-Path $Base $a.ruta
    if (-not (Test-Path $ruta)) { Write-Host "FALTA     $($a.ruta)"; $fallas++; continue }

    $sha = [System.Security.Cryptography.SHA256]::Create()
    $fs = [System.IO.File]::OpenRead($ruta)
    $buf = New-Object byte[] (4MB)
    $total = 0L; $saltos = 0L; $ultimo = 0
    try {
        while (($n = $fs.Read($buf, 0, $buf.Length)) -gt 0) {
            [void]$sha.TransformBlock($buf, 0, $n, $null, 0)
            $total += $n
            if ($null -ne $a.filas_datos) {
                $i = 0
                while (($i = [Array]::IndexOf($buf, [byte]10, $i, $n - $i)) -ge 0) { $saltos++; $i++; if ($i -ge $n) { break } }
                $ultimo = $buf[$n - 1]
            }
        }
        [void]$sha.TransformFinalBlock($buf, 0, 0)
    } finally { $fs.Dispose() }
    $hash = ([BitConverter]::ToString($sha.Hash) -replace '-', '').ToLower()

    $problemas = @()
    if ($hash -ne $a.sha256) { $problemas += "sha256" }
    if ($total -ne $a.bytes) { $problemas += "bytes $total != $($a.bytes)" }
    if ($null -ne $a.filas_datos) {
        $lineas = $saltos + $(if ($total -gt 0 -and $ultimo -ne 10) { 1 } else { 0 })
        $filas = [Math]::Max($lineas - 1, 0)
        if ($filas -ne $a.filas_datos) { $problemas += "filas $filas != $($a.filas_datos)" }
    }
    if ($problemas.Count) { $fallas++; Write-Host "DIFIERE   $($a.ruta): $($problemas -join ', ')" }
    else { Write-Host "OK        $($a.ruta)" }
}

Write-Host ""
Write-Host "$($man.archivos.Count - $fallas)/$($man.archivos.Count) archivos coinciden"
exit $(if ($fallas) { 1 } else { 0 })
