#!/bin/bash
usage(){
  echo "Uso: $0 -n NOME -s /home/pc/MEU_PROJETO/src -b master,release"
  echo ""
  echo "-n [NOME] (Nome do projeto)"
  echo "-s [SRC] Caminho do projeto \"/home/pc/meu-projeto/src\""
  echo "-b [BRANCH1,BRANCH2,...] Branches para testar. Min: 1"
}

while getopts ':s:b:n:h' opt; do
  case "$opt" in
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
      echo -e "opção requer um argumento: -$OPTARG"
      usage
      exit 1
      ;;

    ?)
      usage
      exit 1
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [[ -z  $SRC_FOLDER || -z  $BRANCHES || -z $PROJECT_KEY ]]; then
  echo Faltaram parâmetros 😠😠😠
  usage
  exit 1
fi

echo $SRC_FOLDER
echo $BRANCHES
echo $PROJECT_KEY