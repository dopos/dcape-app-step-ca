# dcape-app-step-ca

[![GitHub Release][1]][2] [![GitHub code size in bytes][3]]() [![GitHub license][4]][5]

[1]: https://img.shields.io/github/release/dopos/dcape-app-step-ca.svg
[2]: https://github.com/dopos/dcape-app-step-ca/releases
[3]: https://img.shields.io/github/languages/code-size/dopos/dcape-app-step-ca.svg
[4]: https://img.shields.io/github/license/dopos/dcape-app-step-ca.svg
[5]: LICENSE

[step-ca](https://github.com/smallstep/certificates/) application package for [dcape](https://github.com/dopos/dcape).

## Docker image used

* [smallstep/step-ca](https://hub.docker.com/r/smallstep/step-ca)

## Requirements

* linux 64bit (git, make, wget, gawk, openssl)
* [docker](http://docker.io)
* [dcape](https://github.com/dopos/dcape) with prepared [traefik](https://traefik.io/)
* Git service ([github](https://github.com), [gitea](https://gitea.io) or [gogs](https://gogs.io))

## Traefik config

### traefik.yml

```traefik.yml
certificatesResolvers:
  stepca:
    acme:
      email: USER@EMAIL
      storage: /etc/traefik/acme.json
      caServer: "https://APP_SITE:9000/acme/acme/directory"
      certificatesDuration: 2160 # 90 days
      tlsChallenge: true
      dnsChallenge:
        provider: pdns
      httpChallenge:
        entryPoint: web
```

### traefik.env

```traefik.env
# https://smallstep.com/docs/tutorials/acme-protocol-acme-clients/#traefik
LEGO_CA_CERTIFICATES=/etc/traefik/root_ca.crt
```

## Usage

* Fork this repo in your Git service
* Setup deploy hook
* Run "Test delivery" (config sample will be created in dcape)
* Edit and save config (enable deploy etc)
* Run "Test delivery" again (app will be installed and started on webhook host)

See also: [Deploy setup](https://github.com/dopos/dcape/blob/master/DEPLOY.md) (in Russian)

## License

The MIT License (MIT), see [LICENSE](LICENSE).

Copyright (c) 2023 Alexey Kovrizhkin <lekovr+dopos@gmail.com>
