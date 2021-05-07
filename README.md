# Check your Helm Chart for Reliability Risks

A Helm plugin for using Chkk to catch reliability risks in your Helm charts.

## Installation

Install the Chkk plugin using the built in `helm plugin install` command provided by the Helm plugin manager.

```bash
$ cd <path_to_helm-chkk_directory>/helm-chkk
$ helm plugin install .
```

The plugin connects to the Chkk service to lookup reliability risks information. If you don't already have your personal access token, go to [https://www.chkk.dev](https://www.chkk.dev) to sign up for free and get the access token.

You should set the `CHKK_ACCESS_TOKEN` environment variable as shown below:

```bash
export CHKK_ACCESS_TOKEN=<your-chkk-access-token>
```

## Usage

Run `helm chkk` command and point it to the Helm chart you want to run checks on. For example:

```console
$ helm chkk coredns coredns/coredns
[FAILED] [CHKK-K8S-36] [High Severity] Image pull policy should not be set to Always
   Impact: imagePullPolicy=Always means you're exercising your dependencies on every container launch.
   If there's network disruption or the registry is down, your application launch will fail.

   Recommendations:
      (1) Set ImagePullPolicy to IfNotPresent for each container.

   Knowledge base:  https://docs.chkk.dev/docs/chkk-k8s-36
...

Target manifest:  coredns.yaml
Found  5 issues with High severity
Found  1 issues with Medium severity
Found  3 issues with Low severity
Summary:
	Total Passed: 11
	Total Failed: 9
	Total Skipped: 0
...
```

The Chkk plugin supports various arguments for modifying the chart, including `--set` and `--values`. For example, you can run checks on a chart while overriding the image as following:

```bash
helm chkk coredns coredns/coredns --set image.tag=1.8.3
```

Chkk has properties that allow a user to run or skip specific checks. These options are automatically passed to Chkk, with any other options being passed to Helm in the same manner as `helm template`.

| Flag | Default | Description |
| :---: |:---: | :---: |
| --file, -f | | The name of the Kubernetes manifest file you want to test.|
| --skip-checks, -s | | Skip specified list of comma separated checks in the run.|
| --run-checks, -r | | Run specified list of comma separated checks in the run.|
| --hide-diff         | false   | Hide code-diff in result output               |
| --continue-on-error | false | Do not raise error in case a check fails |


For further options and features, please refer to the help instructions with the `helm chkk --help` flag.
