<#
.SYNOPSIS
    Scanne un répertoire et ses sous-répertoires pour lister les fichiers dont le nom dépasse 255 caractères ou dont le chemin complet dépasse 260 caractères.

.DESCRIPTION
    Ce script parcourt récursivement tous les fichiers d'un répertoire spécifié,
    mesurant la longueur en caractères Unicode du nom de fichier et du chemin complet.
    Il affiche ensuite la liste des fichiers dépassant la limite stricte de 255 caractères pour le nom,
    ou 260 caractères pour le chemin complet, qui correspondent aux limites les plus basses utilisées par exFAT et Windows classiques.
#>

# Chemin du répertoire à scanner (à modifier selon besoin)
$rootPath = "C:\tmp\"


# Fonction pour calculer la longueur en caractères Unicode d'une chaîne
function Get-CharLength($string) {
    return $string.Length
}

# Récupère tous les fichiers dans le répertoire et ses sous-répertoires
$files = Get-ChildItem -Path $rootPath -File -Recurse

# Liste des fichiers dépassant la limite
$result = @()

Write-Host "Début du scan, cela peut prendre un certain temps..."

foreach ($file in $files) {
    $nameLength = Get-CharLength $file.Name
    $pathLength = Get-CharLength $file.FullName

    if ($nameLength -gt 255 -or $pathLength -gt 260) {
        $result += [PSCustomObject]@{
            FullName       = $file.FullName
            NameLength     = $nameLength
            PathLength     = $pathLength
        }
    }
}

if ($result.Count -gt 0) {
    Write-Host "Fichiers problématiques détectés :"
    $result | Format-Table
} else {
    Write-Host "Aucun fichier avec un nom > 255 caractères ou un chemin complet > 260 caractères trouvé."
}

Write-Host "Scan terminé."

Read-Host "Appuyez sur une touche pour fermer"
