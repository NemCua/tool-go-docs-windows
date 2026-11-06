param(
    [string]$InputFile = "testText",
    [string]$InstallDir = "$env:LOCALAPPDATA\HumanTyper",
    [switch]$Run
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$base = $InstallDir
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$release = Join-Path $base ("releases\" + $stamp + "-" + [guid]::NewGuid().ToString("N").Substring(0, 8))
$temporary = Join-Path $env:TEMP ("HumanTyper-" + [guid]::NewGuid().ToString("N"))
$archive = Join-Path $temporary "source.zip"
$extract = Join-Path $temporary "source"
$dotnetHome = Join-Path $base ".dotnet"

try {
    New-Item -ItemType Directory -Path $temporary -Force | Out-Null
    New-Item -ItemType Directory -Path (Split-Path $release) -Force | Out-Null

    Write-Host "Dang tai ma nguon HumanTyper Windows..."
    Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/NemCua/tool-go-docs-windows/archive/refs/heads/windows.zip" -OutFile $archive
    Expand-Archive -Path $archive -DestinationPath $extract -Force
    $source = Get-ChildItem $extract -Directory | Select-Object -First 1
    if (-not $source) { throw "Khong tim thay ma nguon trong file ZIP." }
    Move-Item -Path $source.FullName -Destination $release

    $project = Join-Path $release "windows\HumanTyper.csproj"
    [xml]$projectXml = Get-Content -Raw $project
    if ($projectXml.Project.PropertyGroup.TargetFramework -ne "net8.0-windows") {
        throw "File HumanTyper.csproj vua tai khong dung phien ban Windows .NET 8."
    }

    $dotnetCommand = Get-Command dotnet -ErrorAction SilentlyContinue
    $dotnetExe = if ($dotnetCommand) { $dotnetCommand.Source } else { $null }
    $sdk8 = $false
    if ($dotnetExe) {
        $sdk8 = [bool](@(& $dotnetExe --list-sdks) -match '^8\.')
    }
    if (-not $sdk8) {
        Write-Host "Dang cai .NET 8 SDK cho tai khoan hien tai..."
        $installer = Join-Path $temporary "dotnet-install.ps1"
        Invoke-WebRequest -UseBasicParsing -Uri "https://dot.net/v1/dotnet-install.ps1" -OutFile $installer
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer -Channel 8.0 -Architecture auto -InstallDir $dotnetHome
        if ($LASTEXITCODE -ne 0) { throw "Cai .NET 8 SDK that bai (exit code $LASTEXITCODE)." }
        $dotnetExe = Join-Path $dotnetHome "dotnet.exe"
        if (-not (Test-Path $dotnetExe)) { throw "Khong tim thay dotnet.exe sau khi cai dat." }
    }

    $env:DOTNET_ROOT = Split-Path $dotnetExe
    $env:Path = "$env:DOTNET_ROOT;$env:Path"
    Push-Location $release
    try {
        Write-Host "Dang kiem tra va build ban Windows..."
        & $dotnetExe build $project --nologo
        if ($LASTEXITCODE -ne 0) { throw "Build that bai (exit code $LASTEXITCODE)." }

        & $dotnetExe run --no-build --project $project -- $InputFile --dry-run
        if ($LASTEXITCODE -ne 0) { throw "Dry-run that bai (exit code $LASTEXITCODE)." }

        if ($Run) {
            Read-Host "Mo Google Docs, nhan Enter, roi chuyen sang tai lieu trong 5 giay dem nguoc" | Out-Null
            & $dotnetExe run --no-build --project $project -- $InputFile
            if ($LASTEXITCODE -ne 0) { throw "HumanTyper thoat voi ma loi $LASTEXITCODE." }
        }
    } finally {
        Pop-Location
    }

    Write-Host "Hoan tat. Ma nguon va ban build: $release"
    if (-not $Run) {
        Write-Host "Chay that: cd `"$release`"; .\run.cmd $InputFile"
    }
} finally {
    Remove-Item $temporary -Recurse -Force -ErrorAction SilentlyContinue
}
