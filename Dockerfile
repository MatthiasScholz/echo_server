FROM alpine:3.12

ARG app_name=echo
ENV app_name=${app_name}

RUN apk --no-cache -U upgrade
RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY ${app_name} .

ENTRYPOINT ./${app_name}
