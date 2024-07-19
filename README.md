# Checkmarx CxFlow++ GitHub Action

This action uses the same underlying CxFlow scan orchestrator as the [checkmarx-cxflow-github-action](https://github.com/checkmarx-ts/checkmarx-cxflow-github-action).

This action has some significant differences:

* It can be configured to execute dependency resolution for SCA in the following locations:
  * The GitHub hosted runner.
  * A self-hosted GitHub runner.
  * A docker image with a supplied tag, executed in either the GitHub hosted or self-hosted runner.
* It will post scan summaries in pull-request comments with no additional configuration.
* It will upload Sarif results to GitHub security with no additional configuration.


# Quick Start

There are several example workflows that can be found on the [Wiki](https://github.com/checkmarx-ts/checkmarx-cxflow-plusplus-github-action/wiki).

This example uses the CxFlow++ action to do the following:

* Performs a SAST and SCA scan on push to a protected branch or a pull-request
targetting a protected branch.
* When scanning on pull-request, posts a scan summary to the pull-request discussion.
* Block merges for pull-requests targeting the defined default branch until the scan is complete.
* When scanning on push, uploads Sarif results to the GitHub code scanning vulnerability alerts.
* Closes code scanning vulnerability alerts when the vulnerability is fixed or
marked Not Exploitable.


```
name: SDLC Workflow with CxFlow++
on:
    push:
        branches: master
    pull_request:
        branches: master
    
jobs:
    checkmarx-scan:
        permissions:
            security-events: write
            pull-requests: write
        runs-on: ubuntu-latest
        steps:
          - name: Fetch Code
            uses: actions/checkout@v4
        
          - name: Execute Scan
            uses: checkmarx-ts/checkmarx-cxflow-plusplus-github-action@v2
            with:
                sast-url: ${{ vars.CX_SAST_URL }}
                sast-username: ${{ secrets.CX_SAST_USERNAME }}
                sast-password: ${{ secrets.CX_SAST_PASSWORD }}
                sca-tenant: ${{ secrets.CX_SCA_TENANT }}
                sca-username: ${{ secrets.CX_SCA_USERNAME }}
                sca-password: ${{ secrets.CX_SCA_PASSWORD }}
```

---

# Configuration Parameters

## Scan Parameters

* `app-name`: The name of the application used when making issue tracker tags. Default: `$GITHUB_REPOSITORY`
* `project-name`: The name of the scan project.  This should include the branch being scanned using your organization's established system naming convention. The string `{branch}` will be replaced by the event's branch name if found in the project name. Default: `$GITHUB_REPOSITORY-{branch}`


**Required unless `disable-sast-scan` is set to `true`**
* `sast-url`: The base URL to the Checkmarx SAST server (do not include `CxWebClient`).
* `sast-team`: The full path of the SAST team that owns the project to scan. Default: `/CxServer`
* `sast-username`: The username of the SAST account to use for scanning.
* `sast-password`: The password for the selected SAST account.


**Required unless `disable-sca-scan` is set to `true`**

* `sca-tenant`: The name of the SCA tenant.
* `sca-username`: The username of the SCA account to use for scanning.
* `sca-password`: The password for the selected SCA account.


## Optional Parameters

### CxFlow Parameters
* `cxflow-jar-path`: (default: blank) The local path to the CxFlow jar.  If blank, CxFlow will be downloaded.
* `cxflow-version`: (default: latest) The CxFlow version to use for execution.  Ignored if `cxflow-jar-path` is set.
* `cxflow-params`: Command line parameters to pass to CxFlow at every execution.
* `pull-request-cxflow-params`: Command line parameters passed to CxFlow only when executing during a pull-request event.
* `push-cxflow-params`: Command line parameters passed to CxFlow only when executing during a push event.

### Docker Registry Parameters

* `docker-login-registry`: (default: docker.io) The name of the container registry to use for login.
* `docker-login-username`: (default: blank) The username for the container registry login.
* `docker-login-password`: (default: blank) The password for the container registry login.

### Execution Parameters

* `upload-sarif-file`: (default: true) Uploads the Sarif file to create entries on the GitHub security tab during push events. 
* `delete-sarif-file`: (default: true) Set to "false" when using the Sarif feedback channel to keep the Sarif file at the path returned in the `sarif-path` output parameter.
* `default-branch`: (default: `${{github.event.repository.default_branch}}`) The default branch of the repository used as the root parent project in SAST from which branch projects are derived.  This defaults to the repo's defined default branch.
* `disable-sast-scan`: (default: false) Set to true to disable SAST scanning.
* `disable-sca-scan`: (default: false) Set to true to disable SCA scanning.
* `enable-wire-trace`: (default: false) Set to true to emit web API I/O wire tracing to the action logs.
* `sast-log-level`: (default: INFO) The logging level for CxFlow output emitted as the action executes. (TRACE, DEBUG, ERROR, INFO)
* `push-feedback-channel`: (default: Sarif) The feedback channel to use when scanning for a push.
* `pull-request-feedback-channel`: (default: GITHUBPULL) The feedback channel to use when scanning for a pull request.
* `application-yaml-path`: (default: `$GITHUB_ACTION_PATH/cxflow-defaults.yml`) A path to a CxFlow yaml configuration file.
* `build-container-tag`: The container image where SCA Resolver is executed.  If not supplied, SCA Resolver is executed on the current GitHub runner.

### Java Parameters
* `java-opts`: (default: -Xms512m -Xmx2048m) Options to pass to the JVM.
* `java-props`: (default: -Djava.security.egd=file:/dev/./urandom) Properties to pass to the JVM.
* `spring-props`: (default: blank) Spring boot properties to pass to the JVM.
* `custom-ca-path`: (default: blank) Path to a file or directory containing a custom CA cert chain that is imported into the Java runtime cacerts store. 


## Advanced Parameters

Please consult with Checkmarx Professional Services for guidance in using these parameters.

### Execution Parameters

* `scaresolver-tag`: (default: blank) The tag for the containerized SCAResolver build environment where the action will execute dependency scanning.  The image must not be built with a `*-bare` target. If both `build-container-tag` and `scaresolver-tag` are supplied, the
`scaresolver-tag` container will be the default container used to execute dependency
resolution for an SCA scan.
