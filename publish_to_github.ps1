param(
    [Parameter(Mandatory = $true)]
    [string]$Owner,

    [string]$Repo = "SGF",

    [ValidateSet("public", "private")]
    [string]$Visibility = "public"
)

$ErrorActionPreference = "Stop"

$git = "C:\Program Files\Git\cmd\git.exe"
$gh = "C:\Program Files\GitHub CLI\gh.exe"

if (-not (Test-Path -LiteralPath $git)) {
    throw "Git is not installed at $git"
}

if (-not (Test-Path -LiteralPath $gh)) {
    throw "GitHub CLI is not installed at $gh"
}

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Push-Location $repoRoot
try {
    & $gh auth status | Out-Null

    $hasCommit = $true
    & $git rev-parse --verify HEAD 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        $hasCommit = $false
    }

    if (-not $hasCommit) {
        & $git add .
        & $git commit -m "Initial SGF release assets"
    }

    $remoteExists = $false
    & $git remote get-url origin 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $remoteExists = $true
    }

    if (-not $remoteExists) {
        & $gh repo create "$Owner/$Repo" "--$Visibility" --source . --remote origin --push
    }
    else {
        & $git push -u origin main
    }
}
finally {
    Pop-Location
}
