
<#

.SYNOPSIS
SonarQubeAnalysis.ps1 helps making SonarQube analysis on windows machines

.DESCRIPTION
SonarQube is a static analysis tool. This script is a helper that will download all necessary executables for making such an analysis.
Latest version can be found on https://github.com/jairbubbles/sonar-powershell.

.PARAMETER hostUrl
    MANDATORY: Server URL (see http://docs.sonarqube.org/display/SONAR/Analysis+Parameters).
	
.PARAMETER login
    MANDATORY: The authentication token of a SonarQube user with Execute Analysis permission.

.PARAMETER projectName
    MANDATORY: Name of the project that will be displayed on the web interface.
	
.PARAMETER projectKey
    MANDATORY: The project key that is unique for each project.\nAllowed characters are: letters, numbers, '-', '_', '.' and ':', with at least one non-digit.
	
.PARAMETER projectVersion
    MANDATORY: The project version.
	
.PARAMETER sources
    MANDATORY: Comma-separated paths to directories containing source files.
	
.PARAMETER buildWrapperCommand
    OPTIONAL: Build wrapper command (for C/C++/Objective-C builds) (see http://docs.sonarqube.org/pages/viewpage.action?pageId=3080359).
	
.PARAMETER gitHubPullRequest
    OPTIONAL: Pull request number (see http://docs.sonarqube.org/display/PLUG/GitHub+Plugin).
	
.PARAMETER gitHubOauth
    OPTIONAL: Personal access token generated in GitHub for the technical user.
	
.PARAMETER gitHubRepository
    OPTIONAL: Identification of the repository. Format is: <organisation/repo>. Exemple: SonarSource/sonarqube.
#>

Param(
	# Analysis parameters 
	[parameter(Mandatory=$true)]
	[alias("h")]
	[string]$hostUrl,
	[parameter(Mandatory=$true)]
	[alias("l")]
	[string]$login,
	[parameter(Mandatory=$true)]
	[alias("n")]
	[string]$projectName, 
	[parameter(Mandatory=$true)]
	[alias("k")]
	[string]$projectKey,
	[parameter(Mandatory=$true)]
	[alias("v")]
	[string]$projectVersion,
	[parameter(Mandatory=$true)]
	[alias("s")]
	[string]$sources,
	[string]$buildWrapperCommand,
	# GitHub
	[int]$gitHubPullRequest,
	[string]$gitHubOauth,	
	[string]$gitHubRepository
)

Add-Type -assembly system.io.compression.filesystem

# Download and unzip sonnar scanner
if(![System.IO.Directory]::Exists($PSScriptRoot + '\SonarScanner'))
{
	(new-object net.webclient).DownloadFile('http://repo1.maven.org/maven2/org/sonarsource/scanner/cli/sonar-scanner-cli/2.8/sonar-scanner-cli-2.8.zip', $PSScriptRoot +  '\SonarScanner.zip')
	[io.compression.zipfile]::ExtractToDirectory($PSScriptRoot + '\SonarScanner.zip', $PSScriptRoot + '\SonarScanner')
}

$scannerCmdLine = ".\SonarScanner\sonar-scanner-2.8\bin\sonar-scanner.bat -D sonar.host.url='$hostUrl' -D sonar.login='$login' -D sonar.projectKey='$projectKey' -D sonar.projectName='$projectName' -D sonar.projectVersion='$projectVersion' -D sonar.sources='$sources'"

#Download build wrapper (if needed)
if($buildWrapperCommand)
{
	if(![System.IO.Directory]::Exists($PSScriptRoot +  '\BuildWrapper'))
	{
		[System.Net.ServicePointManager]::SecurityProtocol = @('Tls12','Tls11','Tls','Ssl3')
		(new-object net.webclient).DownloadFile('http://sonarqube.com/static/cpp/build-wrapper-win-x86.zip', $PSScriptRoot + '\BuildWrapper.zip')
		[io.compression.zipfile]::ExtractToDirectory($PSScriptRoot + '\BuildWrapper.zip', $PSScriptRoot + '\BuildWrapper')
	}
	
	# Compile with BuildWrapper
	
    $builderCmdLine = ".\BuildWrapper\build-wrapper-win-x86\build-wrapper-win-x86-64.exe --out-dir 'Build' $buildWrapperCommand"

	Invoke-Expression $builderCmdLine
	
	$scannerCmdLine += ' -D sonar.cfamily.build-wrapper-output=Build'
}

# Pull request ?
if($gitHubPullRequest)
{
	$scannerCmdLine += " -D sonar.analysis.mode=preview -D sonar.github.oauth='$gitHubOauth' -D sonar.github.repository='$gitHubRepository' -D sonar.github.pullRequest='$gitHubPullRequest'"
}

Invoke-Expression $scannerCmdLine
