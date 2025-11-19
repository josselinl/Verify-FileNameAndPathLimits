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


$limitName = 249
$limitPath = 249

Write-Host "Début du scan : $rootPath`n"

# Scan
try {
    $files = Get-ChildItem -LiteralPath $rootPath -File -Recurse -ErrorAction SilentlyContinue
} catch {
    Write-Warning "Erreur d'accès à certains dossiers : $_"
    $files = @()
}

$result = @()

foreach ($file in $files) {
    $path = $file.FullName
    # Enlever le préfixe \\?\ si présent
    if ($path.StartsWith("\\?\")) { $path = $path.Substring(4) }

    $lenWin32 = [Win32PathHelper.PathWin32]::GetPathLengthWin32($path)
    $nameLength = $file.Name.Length

    if ($nameLength -gt $limitName -or $lenWin32 -ge $limitPath) {
        $result += [PSCustomObject]@{
            FullName    = $path
            NameLength  = $nameLength
            PathLength  = $lenWin32
        }
    }
}

if ($result.Count -gt 0) {
    Write-Host "`nFichiers dépassant les limites :" -ForegroundColor Yellow
    $result | Sort-Object PathLength -Descending | Format-Table -Wrap -AutoSize
} else {
    Write-Host "`nAucun fichier ne dépasse les limites exFAT." -ForegroundColor Green
}

Write-Host "`nScan terminé."
Read-Host "Appuyez sur Entrée pour fermer"
