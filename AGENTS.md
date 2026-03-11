# Repository Guidelines

## Project Structure & Module Organization
This repository is intentionally small and flat. `Dockerfile` builds the Alpine-based image and compiles `pidproxy` in a multi-stage build. `start_vsftpd.sh` is the runtime entrypoint: it parses `USERS`, creates local accounts, prepares home directories, and starts `vsftpd`. `vsftpd.conf` contains the base FTP server configuration, while runtime values such as passive ports, address, and TLS paths are injected from environment variables. `README.md` is the public usage guide and must stay aligned with any config or behavior changes.

## Build, Test, and Development Commands
Use Docker directly from the repository root:

```sh
docker build -t alpine-ftp-server .
docker run --rm -p "21:21" -p 21000-21010:21000-21010 \
  -e USERS="one|1234" -e ADDRESS=127.0.0.1 alpine-ftp-server
docker run --rm alpine-ftp-server /bin/sh
```

The first command builds the image. The second runs a local smoke-test instance. The third opens a shell inside the container for debugging startup logic, user creation, or generated permissions.

## Coding Style & Naming Conventions
Keep shell code compatible with POSIX `sh`; do not introduce Bash-only syntax. Follow the existing script style: short comments, simple conditionals, and two-space indentation in shell blocks. Keep Dockerfile instructions uppercase (`FROM`, `RUN`, `COPY`) and prefer one responsibility per layer. Use uppercase names for environment variables such as `USERS`, `ADDRESS`, `MIN_PORT`, and `TLS_CERT`.

## Testing Guidelines
There is no automated test suite in this repository today. Validate changes by rebuilding the image and running a manual FTP smoke test: login, upload a file, create a directory, and confirm ownership and modes inside `/ftp/<user>`. When changing defaults or parsing logic, also test at least one custom `uid|gid` case.

## Commit & Pull Request Guidelines
Recent history favors short, imperative commit subjects such as `remove TLSv1 support` or `Removed docker volume (#74)`. Keep subjects concise, describe one logical change, and avoid bundling config, docs, and behavior changes unless they are tightly related. PRs should include the user-visible impact, any changed environment variables or ports, and the exact manual verification steps you ran.

## Security & Configuration Notes
Be careful with defaults that affect exposure or filesystem access. Changes to TLS flags, passive port ranges, chroot behavior, or upload permissions must be documented in `README.md` and called out explicitly in the PR.
