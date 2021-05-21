#! /bin/bash -e

HELM_BIN="${HELM_BIN:-helm}"
HELM_CHKK_VERSION="$(cat ${HELM_PLUGIN_DIR}/plugin.yaml | grep "version" | cut -d '"' -f 2)"

helm_options=()
chkk_options=()
eoo=0

while [[ $1 ]]
do
    if ! ((eoo)); then
        case "$1" in
            --version|-v|version)
                echo "Helm Chkk Version: $HELM_CHKK_VERSION"
                exit
                ;;
            --help|-h|--list|config)
                $HELM_PLUGIN_DIR/bin/helm-chkk $1
                exit
                ;;
            --continue-on-error|--show-diff)
                chkk_options+=("$1")
                shift
                ;;
            --run-checks|-r|--skip-checks|-s|--check-type|-t)
                chkk_options+=("$1")
                chkk_options+=("$2")
                shift 2
                ;;
            *)
                helm_options+=("$1")
                shift
                ;;
        esac
    else
        helm_options+=("$1")
        shift
    fi
done

echo "Rendering template for ${helm_options[0]} ..."
render=$(${HELM_BIN} template "${helm_options[@]}")

$HELM_PLUGIN_DIR/bin/helm-chkk -- -f "$render" --name "${helm_options[0]}" "${chkk_options[@]}"
