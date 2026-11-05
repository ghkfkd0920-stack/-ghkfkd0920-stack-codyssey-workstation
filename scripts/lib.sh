#!/usr/bin/env bash
# 공통 헬퍼: "명령어 입력"과 "출력 결과"를 함께 화면 + 로그 파일에 남긴다.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT/logs"
mkdir -p "$LOG_DIR"

# 사용법: start_log 01_terminal
start_log() {
  LOG_FILE="$LOG_DIR/$1.log"
  : > "$LOG_FILE"
  echo "# $1  ($(date '+%Y-%m-%d %H:%M:%S'))" | tee -a "$LOG_FILE"
  echo | tee -a "$LOG_FILE"
}

# 사용법: run 'ls -la'   (실패해도 멈추지 않고 출력을 기록)
run() {
  echo "\$ $*" | tee -a "$LOG_FILE"
  eval "$@" 2>&1 | mask | tee -a "$LOG_FILE"
  echo | tee -a "$LOG_FILE"
}

# 섹션 제목
section() {
  echo "## $*" | tee -a "$LOG_FILE"
  echo | tee -a "$LOG_FILE"
}

# 민감정보 마스킹: 토큰/비밀번호류 패턴을 가린다
mask() {
  sed -E \
    -e 's/(gh[pousr]_)[A-Za-z0-9]{10,}/\1****MASKED****/g' \
    -e 's/(github_pat_)[A-Za-z0-9_]{10,}/\1****MASKED****/g' \
    -e 's/(([Pp]assword|PASSWORD|passwd|[Tt]oken|TOKEN|[Ss]ecret|SECRET)[[:space:]]*[=:][[:space:]]*)[^[:space:]]+/\1****MASKED****/g' \
    -e 's#(https?://)[^/@[:space:]]+@#\1****MASKED****@#g'
}
