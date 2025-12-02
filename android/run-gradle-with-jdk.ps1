<#
Runs Gradle with an embedded (auto-downloaded) JDK 17 so users don't need
to change their system `JAVA_HOME`.

Usage:
  .\run-gradle-with-jdk.ps1 signingReport
  .\run-gradle-with-jdk.ps1 "assembleRelease"

The script will download a Temurin JDK 17 for Windows x64 (if not present),
extract it into `android\.gradle-jdks\jdk-17`, and invoke `gradlew.bat` with
`--java-home` pointed to that directory. This does not change the system
environment permanently.
#>

param(
    [string]$GradleArgs = 'signingReport'
)

Set-StrictMode -Version Latest

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Push-Location $scriptDir
try {
    $jdksDir = Join-Path $scriptDir '.gradle-jdks'
    $jdkTarget = Join-Path $jdksDir 'jdk-17'

    if (-not (Test-Path $jdkTarget)) {
        Write-Host "JDK 17 not found locally. Preparing to download Temurin JDK 17..."
        if (-not (Test-Path $jdksDir)) { New-Item -Path $jdksDir -ItemType Directory | Out-Null }

        $apiUrl = 'https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/adoptium'
        $zipPath = Join-Path $scriptDir 'jdk17.zip'

        Write-Host "Downloading JDK 17 from Adoptium..."
        try {
            Invoke-WebRequest -Uri $apiUrl -OutFile $zipPath -UseBasicParsing -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to download JDK. Please download a JDK 17 manually and set --java-home when running gradle or set JAVA_HOME for this session. Error: $_"
            exit 1
        }

        Write-Host "Extracting JDK..."
        Expand-Archive -Path $zipPath -DestinationPath $jdksDir -Force
        Remove-Item $zipPath -Force

        # Move/rename the extracted folder (it can contain versioned name) to `jdk-17`
        $extracted = Get-ChildItem -Path $jdksDir -Directory | Where-Object { $_.Name -match 'jdk' } | Select-Object -First 1
        if ($null -eq $extracted) {
            Write-Error "Could not locate extracted JDK folder under $jdksDir"
            exit 1
        }

        if ($extracted.FullName -ne $jdkTarget) {
            # Remove any previous target if exists
            if (Test-Path $jdkTarget) { Remove-Item -Recurse -Force $jdkTarget }
            Move-Item -Path $extracted.FullName -Destination $jdkTarget
        }
        Write-Host "JDK 17 ready at: $jdkTarget"
    }

    # Ensure gradlew.bat exists in this directory
    $gradlew = Join-Path $scriptDir 'gradlew.bat'
    if (-not (Test-Path $gradlew)) {
        Write-Error "Could not find gradlew.bat in $scriptDir. Run this script from the `android` directory."
        exit 1
    }

    Write-Host "Running Gradle with embedded JDK (temporary JAVA_HOME)..."
    $prevJavaHome = $env:JAVA_HOME
    $env:JAVA_HOME = $jdkTarget
    try {
        & $gradlew --no-daemon --console=plain --warning-mode=all $GradleArgs
        $exitCode = $LASTEXITCODE
        if ($exitCode -ne 0) { exit $exitCode }
    }
    finally {
        if ($null -ne $prevJavaHome -and $prevJavaHome -ne '') { $env:JAVA_HOME = $prevJavaHome } else { Remove-Item Env:JAVA_HOME -ErrorAction SilentlyContinue }
    }
}
finally {
    Pop-Location
}
