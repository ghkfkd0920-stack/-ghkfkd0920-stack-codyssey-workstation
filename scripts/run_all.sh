#!/usr/bin/env bash
# 전체 실습을 순서대로 실행하고 logs/ 에 결과를 저장한다.
cd "$(dirname "$0")"
for s in 01_terminal 02_permissions 03_docker_basic 04_build_run 05_bind_mount 06_volume 07_git; do
  echo "================ $s ================"
  bash "./$s.sh"
done
echo
echo "보너스(Compose)는 별도로: bash scripts/08_compose.sh"
