FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y jq bash && \
    apt-get clean

WORKDIR /app

COPY ./scripts/validate-md-file-front-matter.sh ./scripts/validate-md-file-front-matter.sh

RUN chmod +x ./scripts/validate-md-file-front-matter.sh

CMD ["./scripts/validate-md-file-front-matter.sh"]
