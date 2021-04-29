FROM alpine:latest

RUN apk -U --no-cache add \
  python3 \
  py3-pip \
  py3-psycopg2 \
  su-exec && \
  rm -rf /var/cache/*

ADD requirements.txt /opt/requirements.txt
RUN pip3 install -r /opt/requirements.txt

COPY ./src /opt/app

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["python3", "-u", "main.py"]
