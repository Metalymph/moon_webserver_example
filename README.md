## Overview

This project demonstrates how to create and deploy with Docker a basic webserver using MoonBit and [Mocket](https://mooncakes.io/docs/oboard/mocket) webserver, and more generally how to wrap a Moonbit app in a Docker container via NodeJS 24.

## Getting Started

1. Make sure you have MoonBit installed on your system
2. Clone this repository
3. Compile/Run commands with `make`:
    - `make docker-build` (build image)
    - `make docker-clean` (clean Unix IP/socket)
    - `make docker-run` (run container in detatched and remove mode)
    - `make native-dev`
    - `make native-watch` (`watchexec` **required**)
    - `make native-prod`
4. Just commands are the same using `just` instead of `make` CLI util.