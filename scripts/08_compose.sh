#!/usr/bin/env bash
# 보너스: Docker Compose 운영 명령 (up / ps / logs / 네트워크 통신 / down)
source "$(dirname "$0")/lib.sh"
start_log 08_compose
cd "$ROOT"

section "실행"
run 'docker compose version'
run 'docker compose up -d --build'
sleep 3

section "상태 / 로그"
run 'docker compose ps'
run 'docker compose logs --tail 5'

section "호스트 → web 접속 (포트 매핑)"
run 'curl -s http://localhost:${HOST_PORT:-8090}/info'

section "컨테이너 간 통신: web 컨테이너에서 서비스명 whoami 로 접근"
run 'docker compose exec web wget -qO- http://whoami | head -5'
run 'docker network ls --filter name=_default'

section "환경 변수로 포트/모드 변경 후 재기동"
run 'HOST_PORT=8091 APP_MODE=staging docker compose up -d'
sleep 3
run 'curl -s http://localhost:8091/info'

section "종료"
run 'docker compose down'
run 'docker compose ps'

echo "로그 저장: $LOG_FILE"
