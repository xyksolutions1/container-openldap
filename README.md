# nfrastack/container-openldap

## About

This repository will build a container for [OpenLDAP](https://www.openldap.org) server for maintaining a directory.

Upon starting this image it will give you a ready to run server with many configurable options.

* Tracks latest release
* Compiles from source
* Multiple backends (bdb, hdb, mdb, sql)
* All overlays compiled
* Supports TLS encryption
* Supports Replication
* Scheduled Backups of Data
* Ability to choose NIS or rfc2307bis Schema
* Additional Password Modules (Argon, SHA2, PBKDF2)
* Two Password Checking Modules - check_password.so and ppm.so
* Zabbix Monitoring templates included

## Maintainer

- [Nfrastack](https://www.nfrastack.com)

## Table of Contents

- [About](#about)
- [Maintainer](#maintainer)
- [Table of Contents](#table-of-contents)
- [Installation](#installation)
  - [Prebuilt Images](#prebuilt-images)
  - [Quick Start](#quick-start)
  - [Persistent Storage](#persistent-storage)
- [Environment Variables](#environment-variables)
  - [Base Images used](#base-images-used)
  - [Core Configuration](#core-configuration)
- [Users and Groups](#users-and-groups)
  - [Networking](#networking)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)
- [Support & Maintenance](#support--maintenance)
- [License](#license)

## Installation

### Prebuilt Images

Feature limited builds of the image are available on the [Github Container Registry](https://github.com/nfrastack/container-openldap/pkgs/container/container-openldap) and [Docker Hub](https://hub.docker.com/r/nfrastack/openldap).

To unlock advanced features, one must provide a code to be able to change specific environment variables from defaults. Support the development to gain access to a code.

To get access to the image use your container orchestrator to pull from the following locations:

```
ghcr.io/nfrastack/container-openldap:(image_tag)
docker.io/nfrastack/openldap:(image_tag)
```


Image tag syntax is:

`<image>:<branch>-<optional tag>-<optional_distribution>_<optional_distribution_variant>`

Example:
`ghcr.io/nfrastack/container-openldap:2.6` or optionally

`ghcr.io/nfrastack/container-openldap:2.6-1.0` or optionally

`ghcr.io/nfrastack/container-openldap:2.6-1.0-alpine` or optinally


- The `branch` will relate to the MAJOR eg `2` and MINOR `.6` release.
- An optional `tag` may exist that matches the [CHANGELOG](CHANGELOG.md) - These are the safest
- If it is built for multiple distributions there may exist a value of `alpine` or `debian`
- If there are multiple distribution variations it may include a version - see the registry for availability

Have a look at the container registries and see what tags are available.

#### Multi-Architecture Support

Images are built for `amd64` by default, with optional support for `arm64` and other architectures.

### Quick Start

- The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [compose.yml](examples/compose.yml) that can be modified for your use.

- Map [persistent storage](#persistent-storage) for access to configuration and data files for backup.
- Set various [environment variables](#environment-variables) to understand the capabilities of this image.

### Persistent Storage

The following directories are used for configuration and can be mapped for persistent storage.

| Directory                                                  | Description                                                             |
| ---------------------------------------------------------- | ----------------------------------------------------------------------- |
| `/data/db`                                                 | OpenLDAP frontend database                                              |
| `/data/config`                                             | OpenLDAP backend (config) files                                         |
| `/override/container/data/openldap/custom-scripts/`        | If you'd like to execute a script during the initialization             |
|                                                            | process drop it here (Useful for using this image as a base)            |
| `/override/container/data/openldap/custom-backup-scripts/` | If you'd like to execute a script after the backup process drop it here |
| `/certs/`                                                  | Drop TLS Certificates here (or use your own path)                       |
| `/data/backup`                                             | Backup Directory                                                        |

### Environment Variables

#### Base Images used

This image relies on a customized base image in order to work.
Be sure to view the following repositories to understand all the customizable options:

| Image                                                   | Description |
| ------------------------------------------------------- | ----------- |
| [OS Base](https://github.com/nfrastack/container-base/) | Base Image  |

Below is the complete list of available options that can be used to customize your installation.

- Variables showing an 'x' under the `Advanced` column can only be set if the containers advanced functionality is enabled.

#### Core Configuration

| Parameter              | Description                                                   | Default                | `_FILE` | Advanced |
| ---------------------- | ------------------------------------------------------------- | ---------------------- | ------- | -------- |
| `DATA_PATH`            | Base Data Folder                                              | `/data/`               ||
| `CONFIG_PATH`          | Configuration files path                                      | `${DATA_PATH}/config/` | |
| `DB_PATH`              | Data Files path                                               | `${DATA_PATH}/db/`     ||
| `DOMAIN`               | LDAP domain.                                                  | `example.org`          |         |          |
| `BASE_DN`              | LDAP base DN. If empty automatically set from `DOMAIN` value. | (empty)                |         |          |
| `ADMIN_PASS`           | Ldap Admin password.                                          | `admin`                | x       |          |
| `CONFIG_PASS`          | Ldap Config password.                                         | `config`               | x       |          |
| `ORGANIZATION`         | Organization Name                                             | `Example Organization` |         |          |
| `ENABLE_READONLY_USER` | Add a read only/Simple Security Object/DSA                    | `false`                |         |          |
| `READONLY_USER_USER`   | Read only user username.                                      | `readonly`             | x       |          |
| `READONLY_USER_PASS`   | Read only user password.                                      | `readonly`             | x       |          |
| `SCHEMA_TYPE`          | Use `nis` or `rfc2307bis` core schema.                        | `nis`                  |         |          |

#### Logging Options

| Variable     | Description                   | Default        | Advanced |
| ------------ | ----------------------------- | -------------- | -------- |
| `LOG_FILE`   | Filename for logging          | `openldap.log` |          |
| `LOG_LEVEL`  | Set LDAP Log Level            | `256`          |          |
| `LOG_PATH`   | Path for Logs                 | `/logs/`       |          |
| `LOG_TYPE`   | Output to `CONSOLE` or `FILE` | `CONSOLE`      |          |
| `LOG_PREFIX` | Prefix for log lines          |                |          |

#### Backup Options

| Parameter                      | Description                                                                                | Default                   |
| ------------------------------ | ------------------------------------------------------------------------------------------ | ------------------------- |
| `ENABLE_BACKUP`                | Enable Backup System                                                                       | `TRUE`                    |
| `BACKUP_BEGIN`                 | What time to do the first dump. Defaults to immediate. Must be in one of two formats       | `0400`                    |
|                                | Absolute HHMM, e.g. `2330` or `0415`                                                       |                           |
|                                | Relative +MM, i.e. how many minutes after starting the container,                          |                           |
|                                | e.g. `+0` (immediate), `+10` (in 10 minutes), or `+90` in an hour and a half               |                           |
| `BACKUP_ARCHIVE_TIME`          | Value in minutes to move all files older than (x) from `BACKUP_PATH`                       |                           |
|                                | to `BACKUP_PATH_ARCHIVE` - which is useful when pairing against an external backup system. |                           |
| `BACKUP_CHECKSUM`              | `md5` or `sha1`                                                                            | `md5`                     |
| `BACKUP_COMPRESSION_LEVEL`     | Numberical value of what level of compression to use,                                      |                           |
|                                | most allow `1` to `9` except for `ZSTD` which allows for `1` to `19`                       | `8`                       |
| `BACKUP_COMPRESSION`           | Use either Gzip `GZ`, Bzip2 `BZ`, XZip `XZ`, ZSTD `ZSTD` or `none`      `                  | `zstd`                    |
| `BACKUP_CREATE_LATEST_SYMLINK` | Create a symbolic link pointing to last backup in this format                              | `TRUE`                    |
| `BACKUP_ENABLE_CHECKSUM`       | Enable checksum after backup `TRUE` or `FALSE`                                             | `TRUE`                    |
| `BACKUP_INTERVAL`              | How often to do a dump, in minutes. Defaults to 1440 minutes,                              | `1440`                    |
|                                | or once per day.                                                                           |                           |
| `BACKUP_PARALLEL_COMPRESSION`  | Use multiple cores when compressing backups `TRUE` or `FALSE`                              | `TRUE`                    |
| `BACKUP_PATH`                  | Filesystem path on where to place backups                                                  | `/data/backup`            |
| `BACKUP_PATH_ARCHIVE`          | Optional Directory where the database dumps archives are kept.                             | `${BACKUP_PATH}/archive/` |
| `BACKUP_RETENTION`             | Value in minutes to delete old backups (only fired when dump                               |                           |
|                                | freqency fires). 1440 would delete anything above 1 day old.                               |                           |
|                                | You don't need to set this variable if you want to hold onto everything.                   |                           |
| `BACKUP_TEMP_LOCATION`         | If you wish to specify a different location, enter it here                                 | `/tmp/backups/`           |


#### Password Policy Options

If you already have a check_password.conf or ppm.conf in /etc/openldap/ the following environment variables will not be applied

| Variable                       | Description                               | Default |
| ------------------------------ | ----------------------------------------- | ------- |
| `ENABLE_PPOLICY`               | Enable PPolicy Module utilization         | `TRUE`  |
| `PPOLICY_CHECK_RDN`            | Check RDN Parameter (ppm.so)              | `0`     |
| `PPOLICY_FORBIDDEN_CHARACTERS` | Forbidden Characters (ppm.so)             | ``      |
| `PPOLICY_MAX_CONSEC`           | Maximum Consective Character Pattern      | `0`     |
| `PPOLICY_MIN_DIGIT`            | Minimum Digit Characters                  | `0`     |
| `PPOLICY_MIN_LOWER`            | Minimum Lowercase Characters              | `0`     |
| `PPOLICY_MIN_POINTS`           | Minimum Points required to pass checker   | `3`     |
| `PPOLICY_MIN_PUNCT`            | Minimum Punctuation Characters            | `0`     |
| `PPOLICY_MIN_UPPER`            | Minimum Uppercase Characters              | `0`     |
| `PPOLICY_USE_CRACKLIB`         | Use Cracklib for verifying words (ppm.so) | `1`     |

#### TLS options

| Variable                | Description                                                        | Default                                   |
| ----------------------- | ------------------------------------------------------------------ | ----------------------------------------- |
| `ENABLE_TLS`            | Add TLS capabilities. Can't be removed once set to `TRUE`.         | `true`                                    |
| `TLS_CA_NAME`           | Selfsigned CA Name                                                 | `ldap-selfsigned-ca`                      |
| `TLS_CA_SUBJECT`        | Selfsigned CA Subject                                              | `/C=XX/ST=LDAP/L=LDAP/O=LDAP/CN=`         |
| `TLS_CA_CRT_SUBJECT`    | SelfSigned CA Cert Sujbject                                        | `${TLS_CA_SUBJECT}${TLS_CA_NAME}`         |
| `TLS_CA_CRT_FILENAME`   | CA Cert filename                                                   | `${TLS_CA_AME}.crt`                       |
| `TLS_CA_KEY_FILENAME`   | CA Key filename                                                    | `${TLS_CA_NAME}.key`                      |
| `TLS_CA_CRT_PATH`       | CA Certificates path                                               | `/certs/${TLS_CA_NAME}/`                  |
| `TLS_CIPHER_SUITE`      | Cipher Suite to use                                                | `HIGH:!aNULL:!MD5:!3DES:!RC4:!DES:!eNULL` |
| `TLS_CREATE_CA`         | Automatically create CA when generating certificates               | `TRUE`                                    |
| `TLS_CRT_FILENAME`      | TLS cert filename                                                  | `cert.pem`                                |
| `TLS_CRT_PATH`          | TLS cert path                                                      | `/certs/`                                 |
| `TLS_ENABLE_DH_PARAM`   | Enable DH Param Functionality                                      | `TRUE`                                    |
| `TLS_DH_PARAM_FILENAME` | DH Param filename                                                  | `dhparam.pem`                             |
| `TLS_DH_PARAM_KEYSIZE`  | Keysize for DH Param                                               | `2048`                                    |
| `TLS_DH_PARAM_PATH`     | DH Param path                                                      | `/certs/`                                 |
| `TLS_ENFORCE`           | Enforce TLS Usage                                                  | `FALSE`                                   |
| `TLS_KEY_FILENAME`      | TLS Key filename                                                   | `key.pem`                                 |
| `TLS_KEY_PATH`          | TLS Key path                                                       | `/certs/`                                 |
| `TLS_RESET_PERMISSIONS` | Change permissions on certificate directories for OpenLDAP to read | `TRUE`                                    |
| `TLS_VERIFY_CLIENT`     | TLS verify client.                                                 | `try`                                     |

    Help: http://www.openldap.org/doc/admin26/tls.html

#### Replication options

| Variable                      | Description                                                              | Default                                           | `_FILE` |
| ----------------------------- | ------------------------------------------------------------------------ | ------------------------------------------------- | ------- |
| `ENABLE_REPLICATION`          | Add replication capabilities. Multimaster only at present.               | `false`                                           |         |
| `REPLICATION_CONFIG_SYNCPROV` | olcSyncRepl options used for the config database.                        | `binddn="cn=config" bindmethod=simple`            | x       |
|                               | Without rid and provider which are automatically                         | `credentials=$CONFIG_PASS searchbase="cn=config"` |         |
|                               | added based on `REPLICATION_HOSTS`.                                      | `type=refreshAndPersist retry="5 5 60 +"`         |         |
|                               |                                                                          | `timeout=1 filter="(!(objectclass=olcGlobal))"`   |         |
|                               |                                                                          |                                                   |         |
| `REPLICATION_DB_SYNCPROV`     | olcSyncRepl options used for the database. Without rid                   | `binddn="cn=admin,$BASE_DN"`                      | x       |
|                               | and provider which are automatically added based                         | `bindmethod=simple credentials=$ADMIN_PASS`       |         |
|                               | on `REPLICATION_HOSTS`.                                                  | `searchbase="$BASE_DN"` `type=refreshAndPersist`  |         |
|                               |                                                                          | `interval=00:00:00:10 retry="5 5 60 +" timeout=1` |         |
|                               |                                                                          |                                                   |         |
|                               |                                                                          |                                                   |         |
|                               |                                                                          |                                                   |         |
| `REPLICATION_HOSTS`           | List of replication hosts seperated by a space, must contain the current |                                                   | x       |
|                               | container hostname set by --hostname on docker run command.              |                                                   |         |
|                               | If replicating all hosts must be set in the same order. Example:         |                                                   |         |
| `REPLICATION_SAFETY_CHECK`    | Check to see if all hosts resolve before starting replication            |                                                   |         |
|                               | Introduced as a safety measure to avoid slapd not starting.              | `TRUE`                                            |         |
| `WAIT_FOR_REPLICAS`           | Should we wait for configured replicas to come online                    | `false`                                           |         |
|                               | (respond to ping) before startup?                                        |                                                   |         |

#### Other environment variables

| Variable                    | Description                                                                 | Default                                        |
| --------------------------- | --------------------------------------------------------------------------- | ---------------------------------------------- |
| `REMOVE_CONFIG_AFTER_SETUP` | Delete config folder after setup.                                           | `true`                                         |
| `SLAPD_ARGS`                | If you want to override slapd runtime arguments place here . Default (null) |                                                |
| `SLAPD_HOSTS`               | Allow overriding the default listen parameters                              | `ldap://$HOSTNAME ldaps://$HOSTNAME ldapi:///` |
| `ULIMIT_N`                  | Set Open File Descriptor Limit                                              | `1024`                                         |

## Users and Groups

| Type  | Name   | ID  |
| ----- | ------ | --- |
| User  | `ldap` | 389 |
| Group | `ldap` | 389 |

### Networking

| Port  | Protocol | Description      |
| ----- | -------- | ---------------- |
| `389` | tcp      | slapd daemon     |
| `636` | tcp      | TLS slapd daemon |

* * *

## Maintenance

### Shell Access

For debugging and maintenance, `bash` and `sh` are available in the container.

## Support & Maintenance

- For community help, tips, and community discussions, visit the [Discussions board](/discussions).
- For personalized support or a support agreement, see [Nfrastack Support](https://nfrastack.com/).
- To report bugs, submit a [Bug Report](issues/new). Usage questions will be closed as not-a-bug.
- Feature requests are welcome, but not guaranteed. For prioritized development, consider a support agreement.
- Updates are best-effort, with priority given to active production use and support agreements.

### References

* <https://openldap.org>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
