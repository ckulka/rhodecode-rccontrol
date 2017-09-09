# RhodeCode Control

[![](https://images.microbadger.com/badges/version/ckulka/rhodecode-rccontrol.svg)](https://github.com/ckulka/rhodecode-rccontrol "Get your own version badge on microbadger.com")

Dockerfile for [RhodeCode Control](https://docs.rhodecode.com/RhodeCode-Control/), ready-to-go for VCS Server, [RhodeCode Community Edition](https://rhodecode.com/open-source) and [RhodeCode Enterprise Edition](https://docs.rhodecode.com/RhodeCode-Enterprise/).

For more details, see <https://github.com/ckulka/rhodecode-rccontrol>.

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
    volumes:
      - repos:/data

  db:
    image: postgres:alpine
    environment:
      POSTGRES_PASSWORD: cookiemonster
    volumes:
      - db:/var/lib/postgresql/data

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
    volumes:
      - repos:/data

volumes:
  repos:
  db:
```

You can now open <http://localhost:5000> and sign in using the `admin` username and the password `ilovecookies`.

## Environment Variables

### RC_APP

The `RC_APP` variable controls which application to install. Must be one of `VCSServer`, `Community` and `Enterprise`.

### RC_VERSION

The `RC_VERSION` variable controls the desired version of the application. If the correct version is not installed, then RhodeCode Control is used to either upgrade the existing version.

For a list of available version, see RhodeCode's [Release Notes](https://docs.rhodecode.com/RhodeCode-Enterprise/release-notes/release-notes.html).

## RC_USER

The `RC_USER` variable specifies the admin username used during the installation, i.e. when a new container is started.

This variable is only required for the RhodeCode CE and EE.

## RC_PASSWORD

The `RC_PASSWORD` variable specifies the admin username password during the installation, i.e. when a new container is started.

This variable is only required for the RhodeCode CE and EE.

## RC_EMAIL

The `RC_EMAIL` variable specifies the admin email address during the installation, i.e. when a new container is started.

This variable is only required for the RhodeCode CE and EE.

## RC_DB

The `RC_DB` variable specifies the admin email address during the installation, i.e. when a new container is started.

For more details on supported databases, see [Supported Databases](https://docs.rhodecode.com/RhodeCode-Enterprise/install/install-database.html).

This variable is only required for the RhodeCode CE and EE.

## RC_CONFIG

The `RC_CONFIG` variable updates the VCS Server or Rhodecode CE/EE configuration before it is being started. It can override variables that were intially set during installation, e.g. the database.

The example below spins up a complete RhodeCode stack and then sets up the email configuration.

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
        [DEFAULT]
        email_to = adalovelace@example.com
        error_email_from = rhodecode_error@localhost
        app_email_from = noreply@example.com
        smtp_server = mail.example.com
        smtp_use_ssl = true

        [app:main]
        vcs.server = vcsserver:9900
    ports:
      - "5000:5000"
```

For more details, see [Post Installation Tasks](https://docs.rhodecode.com/RhodeCode-Enterprise/install/install-steps.html).

## Persistence

RhodeCode is configured to use `/data` as the location for the respositories.

For more details on how to back up the repositories, see [Repository Backup](https://docs.rhodecode.com/RhodeCode-Enterprise/admin/backup-restore.html#repository-backup).

## Migrating existing installations

Migrating an existing installation of RhodeCode to Docker is essentially described in [Backup and Restore: Restoration Steps](https://docs.rhodecode.com/RhodeCode-Enterprise/admin/backup-restore.html#restoration-steps)

1. Spin up a new instance
    - Mount your existing repositories
    - Use `RC_DB=sqlite`
    - Use `RC_CONFIG` to import your existing configuration
1. [Remap and rescan](https://docs.rhodecode.com/RhodeCode-Enterprise/admin/admin-tricks.html#remap-rescan) your repositories
1. Perform any necessary [Post Restoration Steps](https://docs.rhodecode.com/RhodeCode-Enterprise/admin/backup-restore.html#post-restoration-steps)

```yaml
version: "3"

services:
  vcsserver:
    image: ckulka/rhodecode-vcsserver
    volumes:
      - /mnt/repositories:/data

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
        sqlalchemy.db1.url = postgresql://rhodecode:secret@mydbserver/rhodecode
    ports:
      - "5000:5000"
    volumes:
      - /mnt/repositories:/data
```