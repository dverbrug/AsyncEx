param([String]$oldVersion="", [String]$newVersion="")
#iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/StephenCleary/BuildTools/6efa9f040c0622d60dc167947b7d35b55d071f25/Version.ps1'))

if (($oldVersion -eq "") -or ($newVersion -eq ""))
{
    throw [InvalidOperationException] "Pass the current version and the new version numbers to this script."
}

$oldVersionPreIndex = $oldVersion.IndexOf("-");
if ($oldVersionPreIndex -eq -1)
{
    $shortOldVersion = $oldVersion;
    $oldVersionSuffix = "";
}
else
{
    $shortOldVersion = $oldVersion.Substring(0, $oldVersionPreIndex);
    $oldVersionSuffix = $oldVersion.Substring($oldVersionPreIndex + 1);
}

$newVersionPreIndex = $newVersion.IndexOf("-");
if ($newVersionPreIndex -eq -1)
{
    $shortNewVersion = $newVersion;
    $newVersionSuffix = "";
}
else
{
    $shortNewVersion = $newVersion.Substring(0, $newVersionPreIndex);
    $newVersionSuffix = $newVersion.Substring($newVersionPreIndex + 1);
}

$files = @(dir SharedAssemblyInfo.cs -recurse) + @(dir src/*/*.csproj) + @(dir *.nuspec -recurse)
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False

ForEach($file in $files)
{
    $content = $originalContent = Get-Content $file
    if ($file.FullName.EndsWith(".cs"))
    {
        $content = $content -replace "AssemblyVersion\(`"$shortOldVersion`"\)", "AssemblyVersion(`"$shortNewVersion`")"
        $content = $content -replace "AssemblyFileVersion\(`"$shortOldVersion`"\)", "AssemblyFileVersion(`"$shortNewVersion`")"
        $content = $content -replace "AssemblyInformationalVersion\(`"$oldVersion`"\)", "AssemblyInformationalVersion(`"$newVersion`")"
		$encoding = "ASCII"
    }
	elseif ($file.FullName.EndsWith(".csproj"))
    {
        $content = $content -replace "<VersionPrefix>$shortOldVersion</VersionPrefix>", "<VersionPrefix>$shortNewVersion</VersionPrefix>"
		$content = $content -replace "<VersionSuffix>$oldVersionSuffix</VersionSuffix>", "<VersionSuffix>$newVersionSuffix</VersionSuffix>"
		$encoding = "UTF8"
    }
	else
	{
		$content = $content -replace "$oldVersion", "$newVersion"
		$encoding = "ASCII"
	}
    if ([String]::Join("`r`n", $originalContent) -ne [String]::Join("`r`n", $content))
    {
		Set-Content -Value $content -Path $file -Encoding $encoding
        Write-Output "Updated $file"
    }
}

Set-Clipboard ("v" + $newVersion)
Write-Output "Remember to tag!"
