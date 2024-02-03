FROM viktortassi/alpine-multi-base:3.19

ARG JVER

RUN echo "https://apk.bell-sw.com/main" | tee -a /etc/apk/repositories
RUN wget -P /etc/apk/keys/ https://apk.bell-sw.com/info@bell-sw.com-5fea454e.rsa.pub
RUN apk add --no-cache bellsoft-java${JVER}-runtime

RUN java -version
