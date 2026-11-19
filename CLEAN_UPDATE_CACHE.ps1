$ErrorActionPreference = 'Stop'
try {
    $coreRoot = [IO.Path]::GetFullPath([string]$PSScriptRoot).TrimEnd('\')
    $updatesRoot = [IO.Path]::Combine($coreRoot, 'Updates')
    $cache = [IO.Path]::Combine($updatesRoot, 'blobs')
    if (-not (Test-Path -LiteralPath $cache)) {
        Write-Host 'No duplicated update cache exists. Nothing to remove.' -ForegroundColor Green
        exit 0
    }
    foreach ($directory in @($coreRoot, $updatesRoot, $cache)) {
        $item = Get-Item -LiteralPath $directory
        if (-not $item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw 'Refusing a redirected or invalid update cache directory.'
        }
    }
    $resolvedCache = [IO.Path]::GetFullPath([string](Resolve-Path -LiteralPath $cache).Path).TrimEnd('\')
    if (-not $resolvedCache.Equals([IO.Path]::Combine($updatesRoot, 'blobs'), [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Unexpected removal path. Nothing was deleted.'
    }
    $settings = Get-Content -LiteralPath ([IO.Path]::Combine($coreRoot, 'Config', 'client-updates.json')) -Raw | ConvertFrom-Json
    $source = [string]$settings.source
    if ([string]::IsNullOrWhiteSpace($source)) { throw 'Configure the existing client repair source first.' }
    $clientRoot = if ([IO.Path]::IsPathRooted($source)) { [IO.Path]::GetFullPath($source) } else { [IO.Path]::GetFullPath([IO.Path]::Combine($coreRoot, $source)) }
    $clientRoot = $clientRoot.TrimEnd('\')
    $envelope = Get-Content -LiteralPath ([IO.Path]::Combine($updatesRoot, 'manifest.json')) -Raw | ConvertFrom-Json
    $payload = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String([string]$envelope.payload)) | ConvertFrom-Json
    $protection = [IO.Path]::Combine($clientRoot, 'CLIENT_PROTECTED_FILES.json')
    if ((Get-FileHash -LiteralPath $protection -Algorithm SHA256).Hash.ToLowerInvariant() -ne [string]$payload.integrity_manifest_sha256) {
        throw 'The client folder does not match the signed release. Nothing was deleted.'
    }
    $count = 0
    foreach ($row in $payload.files) {
        $relative = [string]$row.path
        if ([IO.Path]::IsPathRooted($relative) -or $relative.Contains('..') -or $relative.Contains(':') -or $relative.Contains('\')) {
            throw 'Invalid approved client path. Nothing was deleted.'
        }
        $file = [IO.Path]::GetFullPath([IO.Path]::Combine($clientRoot, $relative.Replace('/', '\')))
        if (-not $file.StartsWith($clientRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Client path escaped its folder.' }
        $item = Get-Item -LiteralPath $file
        if ($item.PSIsContainer -or $item.Length -ne [long]$row.size -or (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant() -ne [string]$row.sha256) {
            throw ('Client source differs from the approved release: ' + $relative + '. Nothing was deleted.')
        }
        $count++
        if ($count % 100 -eq 0) { Write-Host ('Verified client files: ' + $count) }
    }
    $entries = @(Get-ChildItem -LiteralPath $resolvedCache -Force)
    foreach ($entry in $entries) {
        if ($entry.PSIsContainer -or $entry.Name -notmatch '^[0-9a-f]{64}$' -or ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw 'Unexpected cache contents. Nothing was deleted.'
        }
    }
    $bytes = ($entries | Measure-Object -Property Length -Sum).Sum
    Write-Host ('Removing only: ' + $resolvedCache)
    Write-Host ('Client, databases and signed manifest will be preserved. Cache size: {0:N2} GiB.' -f ($bytes / 1GB))
    Remove-Item -LiteralPath $resolvedCache -Recurse -Force
    Write-Host ('Removed {0} duplicate cache files ({1:N2} GiB).' -f $entries.Count, ($bytes / 1GB)) -ForegroundColor Green
    Write-Host 'Keep your existing client ZIP and upload. Client files were not changed.'
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
