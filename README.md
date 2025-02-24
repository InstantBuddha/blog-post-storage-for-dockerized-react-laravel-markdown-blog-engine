# blog-post-storage-for-dockerized-react-laravel-markdown-blog-engine

This is the repository to organize and inspect .md blog posts automatically using CI/CD for the project [dockerized-react-laravel-markdown-blog-engine](https://github.com/InstantBuddha/dockerized-react-laravel-markdown-blog-engine)

- [blog-post-storage-for-dockerized-react-laravel-markdown-blog-engine](#blog-post-storage-for-dockerized-react-laravel-markdown-blog-engine)
  - [Structure](#structure)
  - [Blog Post file structure](#blog-post-file-structure)
  - [Adding Execute permission to the script](#adding-execute-permission-to-the-script)
  - [Running test-workflows locally in Docker](#running-test-workflows-locally-in-docker)


## Structure

Each individual blog post is stored in a separate .md file. These files are stored in the blog folder. The images are stored in the images folder.

## Blog Post file structure

Each file needs to have front matter in JSON format with blog post metadata such as creation date or title. CI/CD checks front matter validity.

## Adding Execute permission to the script

The following command might be needed to add executable permission to the script:

```bash
chmod +x validate-md-file-front-matter.sh
```

## Running test-workflows locally in Docker

The file validate-md-file-front-matter.sh in ./local-test-workflows/ is a duplicate of the github workflow, so tests can be run locally with Docker by:

```bash
docker compose up --build
```