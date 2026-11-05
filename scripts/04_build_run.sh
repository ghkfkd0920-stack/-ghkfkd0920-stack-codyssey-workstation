#!/usr/bin/env bash
# Dockerfile 커스텀 이미지 빌드 + 포트 매핑 2회 + 환경 변수 주입
source "$(dirname "$0")/lib.sh"
start_log 04_build_run
cd "$ROOT"
docker rm -f my-web-8080 my-web-8081 my-web-conflict my-web-prod >/dev/null 2>&1

section "빌드"
run 'docker build -t my-web:1.0 .'
run 'docker images my-web'
run 'docker inspect my-web:1.0 --format "Labels={{json .Config.Labels}} Env={{json .Config.Env}}"'

section "포트 매핑 실행 #1 (호스트 8080 → 컨테이너 80)"
run 'docker run -d -p 8080:80 --name my-web-8080 my-web:1.0'
sleep 2
run 'curl -s http://localhost:8080 | grep -o "<h1>.*</h1>"'
run 'curl -s http://localhost:8080/health'

section "포트 매핑 실행 #2 (호스트 8081 → 컨테이너 80, 같은 이미지)"
run 'docker run -d -p 8081:80 --name my-web-8081 my-web:1.0'
sleep 2
run 'curl -s http://localhost:8081 | grep -o "<h1>.*</h1>"'

section "포트 충돌 재현 (이미 사용 중인 8080 재사용) → 트러블슈팅 2"
run 'docker run -d -p 8080:80 --name my-web-conflict my-web:1.0'
run 'docker rm -f my-web-conflict'

section "환경 변수 주입: 컨테이너 내부 포트 8000, 모드 prod"
run 'docker run -d -p 8082:8000 -e NGINX_PORT=8000 -e APP_MODE=prod --name my-web-prod my-web:1.0'
sleep 2
run 'curl -s http://localhost:8082/info'
run 'curl -s http://localhost:8080/info'

section "상태 / 로그 / 리소스"
sleep 8
run 'docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"'
run 'docker logs --tail 5 my-web-8080'
run 'docker stats --no-stream my-web-8080 my-web-8081 my-web-prod'

echo "로그 저장: $LOG_FILE"
echo ">>> 지금 브라우저에서 http://localhost:8080 , http://localhost:8081 을 열고"
echo "    주소창이 보이게 캡처 → docs/screenshots/port-8080.png, port-8081.png"
echo ">>> 캡처 후 정리: docker rm -f my-web-8080 my-web-8081 my-web-prod"
