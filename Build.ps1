#iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/StephenCleary/BuildTools/6efa9f040c0622d60dc167947b7d35b55d071f25/Build.ps1'))
Function WriteAndExecute([string]$command) {
	Write-Output $command
	Invoke-Expression $command
}

WriteAndExecute 'dotnet restore'
Push-Location
try {
    Get-ChildItem 'src' | ForEach-Object {
        $location = $_.FullName
        Write-Output "Entering $location"
        Set-Location $location
        WriteAndExecute 'dotnet pack -c Release --no-restore'
    }
} finally { Pop-Location }
