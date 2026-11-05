#!/usr/bin/env bash
# Git 설정 확인 (사용자 정보/기본 브랜치는 미리 설정되어 있어야 함)
#   git config --global user.name  "내이름"
#   git config --global user.email "내이메일"
#   git config --global init.defaultBranch main
source "$(dirname "$0")/lib.sh"
start_log 07_git
cd "$ROOT"

section "버전"
run 'git --version'

section "설정 목록 (credential/토큰 관련 줄은 제외, 이메일 일부 마스킹)"
run 'git config --list --show-origin | grep -viE "credential|token|password" | sed -E "s/(user\.email=)[^@]*@/\1***@/"'

section "기본 브랜치 / 원격 저장소"
run 'git config --global init.defaultBranch'
run 'git branch --show-current'
run 'git remote -v'
run 'git log --oneline -5'

echo "로그 저장: $LOG_FILE"
