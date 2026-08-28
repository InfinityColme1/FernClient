# Deja listo el entorno de pruebas de FeRN en un solo comando.
#
#   .\tool\test_env\prepare.ps1
#   .\tool\test_env\prepare.ps1 -Out D:\pruebas-fern -SkipSeed
#
# Hace tres cosas, y las tres se pueden repetir sin estropear nada:
#   1. Genera el material etiquetado (imagenes y videos cortos).
#   2. Deja unos pesos de fuera con los que probar la importacion.
#   3. Siembra la base de datos de FeRN con todo ello y un modelo listo.
#
# El paso 3 escribe en la base de datos de la aplicacion, asi que **FeRN tiene
# que estar cerrado**. Con -SkipSeed se queda en los dos primeros, que es lo que
# se quiere para probar el camino largo: importar a mano desde la aplicacion y
# marcar las regiones uno mismo.

param(
    # Donde dejar el material. Por defecto, al lado de la biblioteca de FeRN.
    [string]$Out = "$env:USERPROFILE\Documents\Fern\pruebas",

    # Cuantas imagenes generar. Con menos, todo va mas rapido y el modelo sale
    # peor, que tambien es algo que merece la pena ver.
    [int]$Images = 96,

    # No tocar la base de datos: solo generar ficheros.
    [switch]$SkipSeed
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$python = "$env:USERPROFILE\Documents\Fern\recognition\runtime\venv\Scripts\python.exe"

if (-not (Test-Path $python)) {
    Write-Error @"
No esta el entorno de reconocimiento en:
  $python

Abre FeRN, ve a Ajustes e instala el motor de reconocimiento. Este script usa su
Python porque ya trae numpy, PIL y OpenCV: asi no hace falta instalar nada mas.
"@
}

Write-Host "1/3  Generando material en $Out ..." -ForegroundColor Cyan
& $python "$root\tool\test_env\generate_media.py" --out $Out --images $Images

Write-Host ""
Write-Host "2/3  Preparando unos pesos de fuera ..." -ForegroundColor Cyan
& $python "$root\tool\test_env\make_external_weights.py" --out "$Out\pesos-externos"

if ($SkipSeed) {
    Write-Host ""
    Write-Host "Listo. La base de datos no se ha tocado: importa el material desde FeRN." -ForegroundColor Green
    return
}

Write-Host ""
Write-Host "3/3  Sembrando la base de datos (FeRN tiene que estar cerrado) ..." -ForegroundColor Cyan

Push-Location $root
try {
    dart run tool/test_env/seed.dart --media $Out
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "Listo. Abre FeRN y entra en Modelos." -ForegroundColor Green
