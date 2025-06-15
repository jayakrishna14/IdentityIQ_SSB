# PowerShell script to rename all XML files in config subfolders to <ObjectType>-<ObjectName>.xml

$root = Join-Path $PSScriptRoot 'config'

Get-ChildItem -Path $root -Recurse -Filter *.xml -File | ForEach-Object {
    $folder = Split-Path $_.DirectoryName -Leaf
    $objectType = $folder
    
    # Read the file and try to extract the object name from the root element's name attribute
    $xml = [xml](Get-Content $_.FullName)
    $objectName = $null
    if ($xml.DocumentElement -and $xml.DocumentElement.HasAttribute('name')) {
        $objectName = $xml.DocumentElement.GetAttribute('name')
    } else {
        # fallback: use filename without extension
        $objectName = $_.BaseName
    }
    
    $newName = "$objectType-$objectName.xml"
    $newPath = Join-Path $_.DirectoryName $newName
    if ($_.Name -ne $newName) {
        Write-Host "Renaming $($_.FullName) to $newPath"
        Rename-Item $_.FullName $newPath -Force
    }
}
Write-Host "All config XML files have been renamed to <ObjectType>-<ObjectName>.xml format."
