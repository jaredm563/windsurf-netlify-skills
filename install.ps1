# Windsurf Netlify Skills Installer for Windows PowerShell

Write-Host "🌊 Windsurf Netlify Skills Installer" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Determine skills directory
$SkillsDir = Join-Path $env:USERPROFILE ".windsurf\skills"

Write-Host "Detected platform: Windows (PowerShell)"
Write-Host ""

# Create skills directory if it doesn't exist
if (-not (Test-Path $SkillsDir)) {
    Write-Host "Creating Windsurf skills directory..."
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
}

# Check if we're in the repo directory
if (-not (Test-Path "netlify-creating-sites")) {
    Write-Host "❌ Error: Please run this script from the windsurf-netlify-skills directory" -ForegroundColor Red
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  git clone https://github.com/jaredm563/windsurf-netlify-skills.git"
    Write-Host "  cd windsurf-netlify-skills"
    Write-Host "  .\install.ps1"
    exit 1
}

# Count existing skills
$ExistingSkills = Get-ChildItem -Path $SkillsDir -Directory -Filter "netlify-*" -ErrorAction SilentlyContinue
$ExistingCount = ($ExistingSkills | Measure-Object).Count

if ($ExistingCount -gt 0) {
    Write-Host "⚠️  Found $ExistingCount existing Netlify skill(s) in $SkillsDir" -ForegroundColor Yellow
    Write-Host ""
    $Response = Read-Host "Overwrite existing skills? (y/N)"
    if ($Response -notmatch "^[Yy]$") {
        Write-Host "Installation cancelled."
        exit 0
    }
}

# Copy skills
Write-Host ""
Write-Host "Installing skills to $SkillsDir..."
Write-Host ""

$Skills = Get-ChildItem -Path . -Directory -Filter "netlify-*"
$Installed = 0

foreach ($Skill in $Skills) {
    Write-Host "  ✓ $($Skill.Name)" -ForegroundColor Green
    Copy-Item -Path $Skill.FullName -Destination $SkillsDir -Recurse -Force
    $Installed++
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "✅ Successfully installed $Installed skills!" -ForegroundColor Green
Write-Host ""
Write-Host "Skills installed in: $SkillsDir"
Write-Host ""
Write-Host "Windsurf will automatically reference these skills"
Write-Host "when working on Netlify projects."
Write-Host ""
Write-Host "Happy coding! 🚀" -ForegroundColor Cyan
