<# CIFAR-10 Model Run Script
.SYNOPSIS
    One-click setup and run for CIFAR-10 image classification project.
.DESCRIPTION
    Step-by-step guided execution: setup > training > evaluation > inference.
    Detects GPU automatically and installs the correct PyTorch version.
.EXAMPLE
    .\modelrun.cmd
    Runs the full pipeline interactively.
#>
param(
    [switch]$SetupOnly,
    [switch]$TrainOnly,
    [switch]$EvaluateOnly,
    [switch]$InferenceOnly
)

$ErrorActionPreference = "Stop"
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CIFAR-10 Image Classification Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Python
Write-Host "[1/6] Checking Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "  Found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Python not found. Install Python 3.9+ from https://python.org" -ForegroundColor Red
    exit 1
}

# Step 2: Create virtual environment if needed
if (-not (Test-Path "venv\Scripts\python.exe")) {
    Write-Host "[2/6] Creating virtual environment..." -ForegroundColor Yellow
    python -m venv venv
    Write-Host "  Virtual environment created." -ForegroundColor Green
} else {
    Write-Host "[2/6] Virtual environment already exists. Skipping." -ForegroundColor Green
}

# Step 3: Install dependencies
Write-Host "[3/6] Installing dependencies + GPU detection..." -ForegroundColor Yellow
.\venv\Scripts\python.exe setup.py
Write-Host "  Dependencies installed." -ForegroundColor Green

if ($SetupOnly) { Write-Host "Setup complete! Exiting." -ForegroundColor Green; exit 0 }

# Step 4: Generate data plots
Write-Host "[4/6] Generating data visualization plots..." -ForegroundColor Yellow
.\venv\Scripts\python.exe utils.py
Write-Host "  Data plots generated in results/plots/" -ForegroundColor Green

# Step 5: Train model
if (-not $EvaluateOnly -and -not $InferenceOnly) {
    Write-Host "[5/6] Training model (this may take ~30 min)..." -ForegroundColor Yellow
    .\venv\Scripts\python.exe train.py
    Write-Host "  Training complete!" -ForegroundColor Green
} else {
    Write-Host "[5/6] Skipping training (--EvaluateOnly or --InferenceOnly set)" -ForegroundColor Yellow
}

if ($TrainOnly) { Write-Host "Training complete! Exiting." -ForegroundColor Green; exit 0 }

# Step 6: Evaluate model
if (-not $InferenceOnly) {
    Write-Host "[6/6] Evaluating model on test set..." -ForegroundColor Yellow
    .\venv\Scripts\python.exe evaluate.py
    Write-Host "  Evaluation complete!" -ForegroundColor Green
} else {
    Write-Host "[6/6] Skipping evaluation (--InferenceOnly set)" -ForegroundColor Yellow
}

if ($EvaluateOnly) { Write-Host "Evaluation complete! Exiting." -ForegroundColor Green; exit 0 }

# Step 7: Launch inference app
if (-not $TrainOnly -and -not $EvaluateOnly) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  All done! Launching inference app..." -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    .\venv\Scripts\python.exe inference.py
}
