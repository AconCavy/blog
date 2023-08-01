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

$DraftPath = Join-Path $ProjectRoot "input/drafts/template_yyyymmdd_abc000.md"
$ArticleDate = Get-Date;
$ArticlePath = Join-Path $ProjectRoot "input\posts\$($ArticleDate.ToString("yyyyMMdd"))_${ContestName}.md"

if ( [string]::IsNullOrEmpty($ContestFullName)) {
    if ( $ContestName -match "abc*" ) { $ContestFullName = "AtCoder Beginner Contest" }
    elseif ( $ContestName -match "arc*" ) { $ContestFullName = "AtCoder Regular Contest" }
    elseif ( $ContestName -match "agc*" ) { $ContestFullName = "AtCoder Grand Contest" }
    else {
        Write-Host What is the full name of the contest?:
        $ContestFullName = Read-Host
    }
}

Get-Content $DraftPath |
ForEach-Object { $_ -creplace "AtCoder Beginner Contest 000", $ContestFullName } |
ForEach-Object { $_ -creplace "abc000", $ContestName } |
ForEach-Object { $_ -creplace "ABC000", $ContestName.ToUpper() } |
ForEach-Object { $_ -creplace "MM/dd/yyyy", $ArticleDate.ToString("MM/dd/yyyy") } |
Add-Content $ArticlePath
