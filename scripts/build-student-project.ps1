$ErrorActionPreference = "Stop"

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$workshopDirectory = Join-Path $repositoryRoot "workshop"
$sourceDirectory = Join-Path $workshopDirectory "example_project"
$destinationDirectory = Join-Path $repositoryRoot "downloads"
$destinationPath = Join-Path $destinationDirectory "example_project.zip"
$temporaryPath = Join-Path $destinationDirectory ("example_project-{0}.tmp" -f [guid]::NewGuid())

if (-not (Test-Path -LiteralPath $sourceDirectory -PathType Container)) {
    throw "Student project source was not found: $sourceDirectory"
}

New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null

$excludedDirectories = @(".git", ".Rproj.user")
$excludedFiles = @(
    ".RData",
    ".Rhistory",
    ".DS_Store",
    "Thumbs.db",
    "project_demonstration.R",
    "annual_isotope_summary.csv",
    "isotope_relationship.png",
    "isotopes_through_time.png"
)

$projectFiles = @(
    Get-ChildItem -LiteralPath $sourceDirectory -Recurse -File |
        Where-Object {
            $relativePath = $_.FullName.Substring($sourceDirectory.Length).TrimStart("\", "/")
            $pathParts = $relativePath -split "[\\/]"

            -not ($excludedDirectories | Where-Object { $pathParts -contains $_ }) -and
            $excludedFiles -notcontains $_.Name
        } |
        Sort-Object FullName
)

if ($projectFiles.Count -eq 0) {
    throw "The student project contains no files to package."
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

try {
    $zipStream = [System.IO.File]::Open(
        $temporaryPath,
        [System.IO.FileMode]::CreateNew,
        [System.IO.FileAccess]::ReadWrite,
        [System.IO.FileShare]::None
    )

    try {
        $zipArchive = New-Object System.IO.Compression.ZipArchive(
            $zipStream,
            [System.IO.Compression.ZipArchiveMode]::Create,
            $false
        )

        try {
            foreach ($file in $projectFiles) {
                $relativePath = $file.FullName.Substring($sourceDirectory.Length).TrimStart("\", "/")
                $entryName = "example_project/" + ($relativePath -replace "\\", "/")

                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                    $zipArchive,
                    $file.FullName,
                    $entryName,
                    [System.IO.Compression.CompressionLevel]::Optimal
                ) | Out-Null
            }
        }
        finally {
            $zipArchive.Dispose()
        }
    }
    finally {
        $zipStream.Dispose()
    }

    Copy-Item -LiteralPath $temporaryPath -Destination $destinationPath -Force
}
finally {
    if (Test-Path -LiteralPath $temporaryPath) {
        Remove-Item -LiteralPath $temporaryPath -Force
    }
}

Write-Host "Created downloads/example_project.zip from $($projectFiles.Count) source files."
