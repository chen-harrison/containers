# Container Registry

This repo is used to configure and run GitHub Actions to maintain the containers
in the registry:

- `tools`: contains installations for a bunch of files, packages, and
  tools that I use in my normal workflow. Nerd Fonts, fd, fzf, nnn, Lazygit, and
  clangd
- `ros`: ROS 2 images from the official Dockerhub registry, but with additional
  quality of life improvements. Non-root user, color terminal, bash completion,
  and all installations from the `tools` image are included, making it a much
  more pleasant experience to develop with
