# Check your Helm Chart for Reliability Risks

A Helm plugin for using Chkk to catch reliability risks in your Helm charts.

## Installation

Install the Chkk plugin using the built in `helm plugin install` command provided by the Helm plugin manager.

```bash
helm plugin install https://github.com/chkk-io/helm-chkk
```

The plugin connects to the Chkk service to lookup reliability risks information. If you don't already have your personal access token, go to [https://www.chkk.dev](https://www.chkk.dev) to sign up for free and get the access token.

You should set the `CHKK_ACCESS_TOKEN` environment variable as shown below:

```bash
export CHKK_ACCESS_TOKEN=<your-chkk-access-token>
```

## Usage

Run `helm chkk` command and point it to the Helm chart you want to run checks on. For example:

```console
$ helm repo add coredns https://coredns.github.io/helm
$ helm chkk coredns coredns/coredns

❌ Image pull policy should not be set to Always [2 occurences]
🛠️ Set ImagePullPolicy to IfNotPresent for each container.
📚 https://docs.chkk.dev/docs/chkk-k8s-36
🦅 [CHKK-K8S-36] [High Severity] [Type: Reliability]
...

+-------------------------------------+-------------------------------------------+
| Total checks passed                 | 1                                         |
| Total checks failed                 | 2                                         |
| Total checks skipped                | 0                                         |
| Integrate Chkk into your CI systems | https://docs.chkk.dev/docs/ci-integration |
+-------------------------------------+-------------------------------------------+
...
```

The Chkk plugin supports various arguments for modifying the chart, including `--set` and `--values`. For example, you can run checks on a chart while overriding the image as following:

```bash
helm chkk coredns coredns/coredns --set image.tag=1.8.3
```

Chkk has properties that allow a user to run or skip specific checks. These options are automatically passed to Chkk, with any other options being passed to Helm in the same manner as `helm template`.

| Flag | Default | Description |
| :---: |:---: | :---: |
| --skip-checks, -s | | Skip specified list of comma separated checks in the run.|
| --run-checks, -r | | Run specified list of comma separated checks in the run.|
| --show-diff         | false   | Show code-diff in result output               |
| --continue-on-error | false | Do not raise error in case a check fails |
| --check-type | all | Run specific type of checks. Available options: [all, reliability, security, apideprecation, operatingsystem, livenessreadinessprobe, resourcelimit] |


For further options and features, please refer to the help instructions with the `helm chkk --help` flag.
