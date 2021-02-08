###############################################
# Shared Build Time Arguments
###############################################
ARG app_name=echo
ARG work_dir=/go

###############################################
# Builder
###############################################
FROM golang:1.15.5-alpine as builder
ARG app_name
ARG work_dir

RUN apk --no-cache add make git

WORKDIR ${work_dir}

COPY . .

RUN make dependencies
RUN make build app_name=${app_name}

###############################################
# Final
###############################################
FROM alpine:3.12
ARG app_name
ARG work_dir
ENV app_name=${app_name}

RUN apk --no-cache -U upgrade
RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder ${work_dir}/${app_name} .

ENTRYPOINT ./${app_name}
