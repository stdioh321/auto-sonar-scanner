#!/bin/bash

usage() {
  cat << EOF
Uso: $0 -n NOME -s /home/pc/MEU_PROJETO/src -b master,release [-e "-Dsonar.algo1=algo1 -Dsonar.algo2=algo2"]
Opções:
  -n [NOME]                Nome do projeto
  -s [SRC]                 Caminho do projeto "/home/pc/meu-projeto/src"
  -b [BRANCH1,BRANCH2,...] Branches para testar. Min: 1
  -e                       (Opcional) Parâmetros extras para o sonar-scanner
  -h                       Exibir esta mensagem de ajuda
EOF
}

# Check if Docker and Docker Compose are installed
if ! command -v docker >/dev/null || (! command -v docker-compose >/dev/null && ! command -v docker compose >/dev/null); then
  echo "Necessario ter instalado docker e docker-compose 😠😠😠"
  exit 1
fi

# Determine the appropriate Docker Compose command
DOCKER_COMPOSE=$(command -v docker-compose || command -v docker compose)

# Initialize variables
EXTRA_ARGS=""
SRC_FOLDER=""
BRANCHES=""
PROJECT_KEY=""

# Parse command-line arguments
while getopts ':e:s:b:n:h' opt; do
  case "$opt" in
    e)
      EXTRA_ARGS="$OPTARG"
      ;;
    s)
      SRC_FOLDER="$OPTARG"
      ;;
    b)
      BRANCHES="$OPTARG"
      ;;
    n)
      PROJECT_KEY="$OPTARG"
      ;;
    h)
      usage
      exit 0
      ;;
    :)
      echo "opção requer um argumento: -$OPTARG"
      usage
      exit 1
      ;;
    ?)
      usage
      exit 1
      ;;
  esac
done

# Check if all required parameters are provided
if [[ -z  $SRC_FOLDER || -z  $BRANCHES || -z $PROJECT_KEY ]]; then
  echo "Faltaram parâmetros 😠😠😠"
  usage
  exit 1
fi

# Use a heredoc for Docker Compose configuration
read -r -d '' tempDockerCompose << EOF
version: '3.3'
services:
  sonar:
    container_name: sonar
    image: diaslinoh/auto-sonar:0.0.2
    network_mode: host
  sonar-scanner:
    container_name: sonar-scanner
    image: diaslinoh/auto-sonar-scanner:0.0.2
    network_mode: host
    environment:
      - PROJECT_KEY=$PROJECT_KEY
      - BRANCHES=$BRANCHES
      - EXTRA_ARGS=$EXTRA_ARGS
    volumes:
      - "$SRC_FOLDER:/temp/current"
    depends_on:
      sonar:
        condition: service_healthy
EOF

# Use the function to execute Docker Compose operations
run_docker_compose() {
  $DOCKER_COMPOSE -f - "$1" <<< "$tempDockerCompose"
}

# Execute Docker Compose commands
run_docker_compose "build"
run_docker_compose "up"
run_docker_compose "down"
