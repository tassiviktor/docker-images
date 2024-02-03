FROM viktortassi/alpine-multi-base:3.19

RUN apk add redis; \
	redis-cli --version; \
	redis-server --version; 

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 6379
CMD ["redis-server"]