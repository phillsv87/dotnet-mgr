#!/usr/bin/env pwsh

param(
    [switch]$list,
    [switch]$help,
    [string]$install,
    [string]$installCurrent,
    [string]$init,
    [switch]$noCache,
    [switch]$initProfile,
    [string]$setVersion,
    [switch]$clean
)

$ErrorActionPreference="Stop"

if($init){
    $install=$init
    $setVersion=$init
    $initProfile=$True
}

if($installCurrent){
    $install=$installCurrent
    $setVersion=$installCurrent

}

Push-Location $PSScriptRoot

try{

    $autoHelp=$True

    $versionsDir="$PSScriptRoot/versions"
    $downlaodsDir="$PSScriptRoot/downloads"

    if($clean){
        $autoHelp=$False
        rm -rf $versionsDir
        rm -rf $downlaodsDir
        rm "$PSScriptRoot/tools/dnv-*"
        Write-Host "dotnet versions cleaned. $versionsDir, $downlaodsDir" -ForegroundColor DarkYellow
    }

    mkdir -p $versionsDir
    mkdir -p $downlaodsDir

    $versions=Get-Content -Path "./dotnet-versions.json" | ConvertFrom-Json

    $current="$versionsDir/current"

    if($list){
        $autoHelp=$False

        $versions
    }

    if($install){
        $autoHelp=$False

        $version=$versions | Where-Object { $_.name -eq $install  } | Select-Object -First 1
        if(!$version){
            $versions | Out-Host
            throw "Specified version not found - $install. See versions above"
        }

        $download=$version.download

        if(!$download){
            throw "Found version does not define a download url"
        }

        $installLocation="$versionsDir/$install"

        $filename=[System.IO.Path]::GetFileName($download)

        $downloadFile="$downlaodsDir/$filename"

        if($noCache -and (Test-Path $downloadFile)){
            rm $downloadFile
        }

        if(!(Test-Path $downloadFile)){
            Write-Host "downloading $download" -ForegroundColor DarkYellow
            Invoke-WebRequest -Uri $download -OutFile $downloadFile
        }

        rm -rf $installLocation
        mkdir -p $installLocation
        tar -xvf $downloadFile -C $installLocation
        if(!$?){throw "extract $downloadFile to $installLocation"}

        $envFileName="$PSScriptRoot/tools/dnv-$install"
        "# source this file to set dotnet version to $install" > $envFileName
        "export PATH=$($installLocation):`$PATH" >> $envFileName
        "export DOTNET_ROOT=$installLocation" >> $envFileName
        chmod +x $envFileName

        Write-Host "Installed $install at $installLocation" -ForegroundColor DarkGreen

    }

    if($setVersion){
        $autoHelp=$False

        $installLocation="$versionsDir/$setVersion"

        if(!(Test-Path $installLocation)){
            $versions | Out-Host
            throw "Version not installed - $setVersion. Install one of the version above"
        }

        rm -rf $current
        ln -s $installLocation $current
        if(!$?){throw "link $installLocation -> $current failed"}

        Write-Host "Current version set to $setVersion - $installLocation -> $current" -ForegroundColor DarkGreen
        
    }

    function AddToProfile{
        param(
            $path
        )

        if(!(Test-Path $path)){
            return
        }

        $header='###_dotnet_config_###'

        $content=Get-Content -Path $path -Raw
        if($content.Contains($header)){
            Write-Host "Profile already configured - $path" -ForegroundColor DarkGray
            return;
        }

        "`n" >> $path
        $header >> $path
        "export PATH=`$PATH:$($current):$PSScriptRoot/tools" >> $path
        "export DOTNET_ROOT=$current" >> $path
        "export DOTNET_MGR_ROOT=$PSScriptRoot" >> $path
        '###_end_dotnet_config_###' >> $path
        "`n" >> $path

        Write-Host "Profile configured - $path" -ForegroundColor DarkGreen


    }

    if($initProfile){
        $autoHelp=$False

        AddToProfile -path "${env:HOME}/.bash_profile"

        AddToProfile -path "${env:HOME}/.zprofile"

    }


    if($autoHelp -or $help){
        Write-Host 'Usage: [-list] [-init {version-name}] [-install {version-name}] [-installCurrent {version-name}] [-noCache] [-initProfile] [-setVersion {version-name}] [-clean] [-help]'
    }

}finally{
    Pop-Location
}