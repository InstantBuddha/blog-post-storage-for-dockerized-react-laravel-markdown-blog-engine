# blog-post-storage-for-dockerized-react-laravel-markdown-blog-engine

This is the repository to organize and inspect .md blog posts automatically using CI/CD for the project [dockerized-react-laravel-markdown-blog-engine](https://github.com/InstantBuddha/dockerized-react-laravel-markdown-blog-engine)

- [blog-post-storage-for-dockerized-react-laravel-markdown-blog-engine](#blog-post-storage-for-dockerized-react-laravel-markdown-blog-engine)
  - [Structure](#structure)
  - [Blog Post file structure](#blog-post-file-structure)


## Structure

Each individual blog post is stored in a separate .md file. These files are stored in the blog folder. The images are stored in the images folder.

## Blog Post file structure

Each file needs to have front matter in JSON format with blog post metadata such as creation date or title. CI/CD checks front matter validity.