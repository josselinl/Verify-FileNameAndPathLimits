<#
.SYNOPSIS
    Scanne un répertoire et ses sous-répertoires pour lister les fichiers dont le nom ou chemin complet dépassent les limites strictes.

.DESCRIPTION
    Ce script analyse la longueur en caractères Unicode et en octets UTF-8 du nom (brut) et du chemin complet (nettoyé),
    et affiche les fichiers dépassant un des seuils suivants :
    - nom > 255 caractères ou 255 octets,
    - chemin complet > $limitPath caractères ou $limitPath octets.
#>

# Chemin racine à scanner
$rootPath = "H:\"  # Modifiez ici

# Limite personnalisée pour le chemin complet (caractères et octets)
$limitPath = 249

# Nettoie la chaîne : supprime retours à la ligne et tabulations (pour chemins uniquement)
function Clean-Name($string) {
    return ($string -replace "\r|\n|\t", '').Trim()
}

# Longueur en caractères Unicode
function Get-CharLength($string) {
    return $string.Length
}

# Taille en octets UTF-8
function Get-ByteLengthUtf8($string) {
    return [System.Text.Encoding]::UTF8.GetByteCount($string)
}

$result = @()

Write-Host "Début du scan. Cela peut prendre un certain temps..."

try {
    $files = Get-ChildItem -Path $rootPath -File -Recurse -ErrorAction SilentlyContinue
} catch {
    Write-Warning "Erreur d'accès à certains dossiers : $_"
    $files = @()
}

foreach ($file in $files) {
    # Ici on mesure le nom brut sans nettoyage
    $nameRaw = $file.Name
    # On nettoie uniquement le chemin complet
    $cleanPath = Clean-Name $file.FullName

    $nameCharLen = Get-CharLength $nameRaw
    $pathCharLen = Get-CharLength $cleanPath
    $nameByteLen = Get-ByteLengthUtf8 $nameRaw
    $pathByteLen = Get-ByteLengthUtf8 $cleanPath

    if ($nameCharLen -gt 255 -or $pathCharLen -gt $limitPath -or $nameByteLen -gt 255 -or $pathByteLen -gt $limitPath) {
        $result += [PSCustomObject]@{
            FullName        = $file.FullName
            NameRaw         = $nameRaw
            NameCharLength  = $nameCharLen
            PathCharLength  = $pathCharLen
            NameByteLength  = $nameByteLen
            PathByteLength  = $pathByteLen
        }
    }
}

if ($result.Count -gt 0) {
    Write-Host "Fichiers dépassant les limites détectés :"
    $result | Format-Table -Wrap -AutoSize
} else {
    Write-Host "Aucun fichier ne dépasse les limites en caractères ou en octets."
}

Write-Host "Scan terminé."

Read-Host "Appuyez sur une touche pour fermer"
