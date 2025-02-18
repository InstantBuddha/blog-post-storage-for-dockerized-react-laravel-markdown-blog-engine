FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y jq bash && \
    apt-get clean

WORKDIR /app

COPY ./local-test-workflows/validate-md-file-front-matter.sh ./local-test-workflows/validate-md-file-front-matter.sh
RUN mkdir /local-test-workflows
RUN chmod +x ./local-test-workflows/validate-md-file-front-matter.sh

CMD ["./local-test-workflows/validate-md-file-front-matter.sh"]
