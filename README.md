# RhodeCode Control

[![](https://images.microbadger.com/badges/version/ckulka/rhodecode-rccontrol.svg)](https://github.com/ckulka/rhodecode-rccontrol "Get your own version badge on microbadger.com")

Dockerfile for [RhodeCode Control](https://docs.rhodecode.com/RhodeCode-Control/), ready-to-go for VCS Server, [RhodeCode Community Edition](https://rhodecode.com/open-source) and [RhodeCode Enterprise Edition](https://docs.rhodecode.com/RhodeCode-Enterprise/).

## Supported Tags

I follow the same naming scheme for the images as [RhodeCode](https://docs.rhodecode.com/RhodeCode-Control/release-notes/release-notes.html) themselves

- [latest](https://github.com/ckulka/rhodecode-rccontrol/tree/master) (corresponds to 1.14.0)
- [1.14.0](https://github.com/ckulka/rhodecode-rccontrol/tree/1.14.0)


## Complete Stack

The following `docker-compose.yaml` file spins up a complete RhodeCode stack

```yaml
version: "3"

services:
  vcsserver:
    image: ckulka/rhodecode-vcsserver

  db:
    image: postgres:alpine
    environment:
      POSTGRES_PASSWORD: cookiemonster

  rhodecode:
    image: ckulka/rhodecode-ce
    environment:
      RC_USER: admin
      RC_PASSWORD: ilovecookies
      RC_EMAIL: adalovelace@example.com
      RC_DB: postgresql://postgres:cookiemonster@db
      RC_CONFIG: |
        [app:main]
        vcs.server = vcsserver:9900
    ports:
      - "5000:5000"
```