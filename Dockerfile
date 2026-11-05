# (A) 웹 서버 베이스 이미지 활용 방식: 공식 nginx:alpine 이미지 + 정적 콘텐츠/설정 교체
FROM nginx:alpine

# [커스텀 1] 이미지 메타데이터 - 이미지 출처/용도를 docker inspect로 확인 가능
LABEL org.opencontainers.image.title="my-custom-nginx" \
      org.opencontainers.image.description="Codyssey workstation mission - custom nginx"

# [커스텀 2] 환경 변수 기본값 - 실행 시 -e 로 덮어써서 포트/모드 변경 가능
ENV NGINX_PORT=80 \
    APP_MODE=dev

# [커스텀 3] 기본 설정 제거 후 템플릿 설정으로 교체 (/health, /info 추가)
RUN rm -f /etc/nginx/conf.d/default.conf
COPY app/nginx/default.conf.template /etc/nginx/templates/default.conf.template

# [커스텀 4] 기본 nginx 환영 페이지 대신 직접 만든 정적 사이트 배포
COPY app/site/ /usr/share/nginx/html/

# [커스텀 4-1] 호스트 파일 권한(예: 600)과 무관하게 nginx 워커가 읽을 수 있도록 보정
#   (실제로 겪은 403 Forbidden 해결 → README 트러블슈팅 8-4)
RUN chmod -R a+rX /usr/share/nginx/html /etc/nginx/templates

# [커스텀 5] 헬스체크 - docker ps 의 STATUS 에 (healthy) 표시
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:${NGINX_PORT}/health || exit 1

# 문서화 목적 (실제 공개는 docker run -p 로 결정)
EXPOSE 80
