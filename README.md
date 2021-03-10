# sonar-powershell

It's a test

Simple PowerShell scripts to help making SonarQube analysis on windows machines.

It's based on the [shell script](https://github.com/bellingard/multi-language-project/blob/master/runSonarQubeAnalysis.sh) provided by SonarQube.

There are for now 2 scripts:
- SonarQubeAnalysis.ps1 is the more generic script that exposes all parameters.
- SonarQubeAnalysisForAppVeyor.ps1 which is meant to be used on http://AppVeyor.com. Most of the parameters are already filled with environment variables.

## Command line details

```
SonarQubeAnalysis.ps1 
[-hostUrl] <string>
[-login] <string>
[-projectName] <string>
[-projectKey] <string>
[-projectVersion] <string>
[-sources] <string>
[[-buildWrapperCommand] <string>]
[[-gitHubPullRequest] <int>]
[[-gitHubOauth] <string>]
[[-gitHubRepository] <string>]
```

Analysis parameters (more infos [here](http://docs.sonarqube.org/display/SONAR/Analysis+Parameters)):
- `hostUrl`: https://sonarqube.com/ in most cases
- `login`: The authentication token of a SonarQube user with Execute Analysis permission. For SonarQube.com you just need to log in with your GitHub account and generate a user token from the “My Account” > “Security” page.
- `projectName`: Name of the project that will be displayed on the web interface.
- `projectKey`: The project key that is unique for each project. Allowed characters are: letters, numbers, -, _, . and :, with at least one non-digit.
- `projectVersion`: Project version number.
- `source`: Comma-separated paths to directories containing source files.

C/C++/Objective-C specicifc arguments (more infos [here](http://docs.sonarqube.org/pages/viewpage.action?pageId=3080359)):
- `buildWrapperCommand`: Command for building your project (e.g. : msbuild 'src/masolution.com')

GitHub specific arguments (more infos [here](http://docs.sonarqube.org/display/PLUG/GitHub+Plugin)):
- `gitHubPullRequest`: Pull request number
- `gitHubOauth`: Personal access token generated in GitHub for the technical user
- `gitHubRepository`: Identification of the repository. Format is: <organisation/repo>. Exemple: SonarSource/sonarqube

## AppVeyor integration

With the appveyor script you only have to fill `sources` and `buildWrapperCommand`.

It assumes that the 3 following variables are defined:
- `SONAR_HOST_URL` => should point to the public URL of the SQ server (e.g. : https://sonarqube.com)
- `SONAR_TOKEN` => token of a user who has the "Execute Analysis" permission on the SQ server
- `GITHUB_TOKEN` => token for commenting pull requests in GitHub

Just go in settings / Environment to set up these variables:

![settings](doc/AppVeyor_settings.png)

Full analysis are only done on the master branch.

For pull requests a fast analysis is done and comments will be added to the pull request. You're encouraged to create a technical user for that purpose and generate a token for that user with the "public_repo" scope. You can see that on the SonarQube sample project https://github.com/bellingard/multi-language-project/pull/5

