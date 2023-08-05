<#

.SYNOPSIS

Create a new article based on the article template for AtCoder by the specified contest name.

.EXAMPLE

PS > New-AtCoderArticle -ContestName abc999
Create a new article with abc999 as the contest name.

.EXAMPLE

PS > New-AtCoderArticle -ContestName foo001 -ContensFullName "Foo Contest 001"
Create a new article with foo001 as the contest name and Foo Contest 001 as the contest full name.

#>

param (
    [Parameter(Mandatory = $true)]
    [string] $ContestName,

    [string] $ContestFullName
)

$ProjectRoot = $PSScriptRoot;
$ProjectRoot = Split-Path $ProjectRoot -Parent;

$ContestName = $ContestName.ToLower();

$DraftPath = Join-Path $ProjectRoot "input/drafts/template_atcoder.md"
$ArticleDate = Get-Date;
$ArticlePath = Join-Path $ProjectRoot "input/posts/$($ArticleDate.ToString("yyyyMMdd"))_${ContestName}.md"

if ( [string]::IsNullOrEmpty($ContestFullName) -and ($ContestName -match "^(?<Kind>a.c)(?<Number>\d+$)")) {
    if ( $Matches.Kind -eq "abc" ) { $ContestFullName = "AtCoder Beginner Contest $($Matches.Number)" }
    if ( $Matches.Kind -eq "arc" ) { $ContestFullName = "AtCoder Regular Contest $($Matches.Number)" }
    if ( $Matches.Kind -eq "agc" ) { $ContestFullName = "AtCoder Grand Contest $($Matches.Number)" }
}

if ( [string]::IsNullOrEmpty($ContestFullName)) {
    Write-Host "What is the full name of the contest?:"
    $ContestFullName = Read-Host
}

Get-Content $DraftPath |
ForEach-Object { $_ -creplace "PH__Title", $ContestName.ToUpper() } |
ForEach-Object { $_ -creplace "PH__ContestFullName", $ContestFullName } |
ForEach-Object { $_ -creplace "PH__ContestName", $ContestName } |
ForEach-Object { $_ -creplace "PH__Updated", $ArticleDate.ToString("MM/dd/yyyy") } |
ForEach-Object { $_ -creplace "PH__Published", $ArticleDate.ToString("MM/dd/yyyy") } |
Add-Content $ArticlePath
