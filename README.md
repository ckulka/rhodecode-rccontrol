# RhodeCode Control

[![](https://images.microbadger.com/badges/version/ckulka/rhodecode-rccontrol.svg)](https://github.com/ckulka/rhodecode-rccontrol "Get your own version badge on microbadger.com")

Dockerfile for [RhodeCode Control](https://docs.rhodecode.com/RhodeCode-Control/), ready-to-go for VCS Server, [RhodeCode Community Edition](https://rhodecode.com/open-source) and [RhodeCode Enterprise Edition](https://docs.rhodecode.com/RhodeCode-Enterprise/).

For more details, see <https://github.com/ckulka/rhodecode-rccontrol>.

## Supported Tags

I follow the same naming scheme for the images as [RhodeCode](https://docs.rhodecode.com/RhodeCode-Control/release-notes/release-notes.html) themselves

- [latest](https://github.com/ckulka/rhodecode-rccontrol/tree/master) (corresponds to 1.14.0)
- [1.14.0](https://github.com/ckulka/rhodecode-rccontrol/tree/1.14.0)

## Usage

The following steps are required to spin up a complete RhodeCode stack

1. Initialise the database
1. Spin up the VCS Server and RhodeCode CE/EE

```yaml
version: "3"

services:
  db:
    image: postgres:alpine
    environment:
      POSTGRES_PASSWORD: cookiemonster

  vcsserver:
    image: ckulka/rhodecode-vcsserver

  rhodecode:
    image: ckulka/rhodecode-ce
    environment:
      RC_DB: postgresql://postgres:cookiemonster@db
    ports:
      - "5000:5000"
    links:
      - db
      - vcsserver
```

See [example/docker-compose.yaml](https://github.com/ckulka/rhodecode-rccontrol/blob/master/example/docker-compose.yaml) for a complete example including volumes for persistence.

```bash
# Launch the database (see docker-compose.yaml below)
docker-compose up -d db

# Run the installer for RhodeCode
docker-compose run --rm rhodecode ./install.sh

# Alternatively, if you haven't defined RC_DB
docker-compose run --rm rhodecode ./install <database>

# Spin up the VCS Server and RhodeCode after the installation
docker-compose up -d
```

You can now open <http://localhost:5000> and sign in using the `admin` username and the password `ilovecookies`.

## Environment Variables

### RC_DB

The `RC_DB` variable specifies the database RhodeCode connects to.
It's only there for convenience over `RC_CONFIG` and takes precendence over `sqlalchemy.db1.url` in `RC_CONFIG`.

For more details on supported databases, see [Supported Databases](https://docs.rhodecode.com/RhodeCode-Enterprise/install/install-database.html).

This variable is only used in the RhodeCode CE and EE.

### RC_CONFIG

The `RC_CONFIG` variable updates the VCS Server or Rhodecode CE/EE configuration, adding/updating settings that were set or not available during installation.

If `RC_CONF` is not set, the contents of [files/rhodecode.override.ini](https://github.com/ckulka/rhodecode-rccontrol/blob/master/files/rhodecode.override.ini) is used by default.

The example below additionally sets up the email configuration.

```yaml
  rhodecode:
    image: ckulka/rhodecode-ce
    environment:
      RC_DB: postgresql://postgres:cookiemonster@db
      RC_CONFIG: |
        [DEFAULT]
        email_to = adalovelace@example.com
        error_email_from = rhodecode_error@localhost
        app_email_from = noreply@example.com
        smtp_server = mail.example.com
        smtp_use_ssl = true

        [app:main]
        vcs.server.enable = true
        vcs.server = vcsserver:9900
```

For more details on the configuration, see [Post Installation Tasks](https://docs.rhodecode.com/RhodeCode-Enterprise/install/install-steps.html).

## Persistence

RhodeCode is configured to use `/data` as the location for the respositories.

Only the VCS Server needs to have access to the repository files, as depicted in the [System Overview](https://docs.rhodecode.com/RhodeCode-Enterprise/admin/system-overview.html).

For more details on how to back up the repositories, see [Repository Backup](https://docs.rhodecode.com/RhodeCode-Enterprise/admin/backup-restore.html#repository-backup).

## Migrating existing installations

**WIP:** While it sounds like it makes sense, I still have to test it.

Migrating an existing installation of RhodeCode to Docker is essentially described in [Backup and Restore: Restoration Steps](https://docs.rhodecode.com/RhodeCode-Enterprise/admin/backup-restore.html#restoration-steps)

1. Spin up a new instance
    - Mount your existing repositories
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
      RC_CONFIG: |
        [app:main]
        vcs.server.enable = true
        vcs.server = vcsserver:9900
        sqlalchemy.db1.url = postgresql://rhodecode:secret@mydbserver/rhodecode
        # ...
    ports:
      - "5000:5000"
```