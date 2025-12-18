#!/bin/bash

# Drop into the running step-ca container with bash + step completions loaded

set -euo pipefail

CONTAINER_NAME="step-ca-kub"

if ! docker ps --format '{{.Names}}' | grep -Fxq "$CONTAINER_NAME"; then
    echo "Container $CONTAINER_NAME is not running. Start it with ./install.sh first." >&2
    exit 1
fi

docker exec -it "$CONTAINER_NAME" bash -c "
TMP=\$(mktemp)
cleanup() { rm -f \"\$TMP\"; }
trap cleanup EXIT
cat > \"\$TMP\" <<'EOS'
if [ -f /etc/profile ]; then
    source /etc/profile
fi
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
source <(step completion bash)
printf $'\nUse the \e[97m\'step ca\'\e[0m command for CA operations. \e[97m\'step\'\e[0m supports tab completions in this shell.\n\n'
PS1=\"\\[\\e[34m\\][\\[\\e[97m\\]step-ca\\[\\e[34m\\]]\\[\\e[32m\\][\\[\\e[0m\\]\\w\\[\\e[32m\\]]\\[\\e[0m\\] > \"
EOS
bash --rcfile \"\$TMP\" -i
"