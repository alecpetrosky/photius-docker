# CHANGELOG

## 0.11.18 / 2020-11-18

- Enhancement: `PHOTIUS_SF_DATETIMEORIGINAL` flag added. See `README`.

## 0.10.20 / 2020-10-20

- Enhancement: Dynamic pause between queued files ([#11](https://github.com/alecpetrosky/photius-docker/issues/11)).

## 0.9.29b / 2020-09-29

- Optimization & refactoring.

## 0.9.29 / 2020-09-29

- Added: Move files into a special directory if processing errors. ([#9](https://github.com/alecpetrosky/photius-docker/issues/9)).
- Added: Expose "base" directory (/opt) as external volume. ([#10](https://github.com/alecpetrosky/photius-docker/issues/10)).

## 0.9.26 / 2020-09-26

- Added: Enforce FIFO for the main loop queue ([#7](https://github.com/alecpetrosky/photius-docker/issues/7)).

## 0.9.25 / 2020-09-25

- Added: exclude hidden directories ([#3](https://github.com/alecpetrosky/photius-docker/issues/3)).
- Fixed: race condition with active `PHOTIUS_RENAME_PROCESSINGDATE` flag ([#4](https://github.com/alecpetrosky/photius-docker/issues/4)).
- Fixed: specify global options before other arguments ([#5](https://github.com/alecpetrosky/photius-docker/issues/5)).
- Added: sort main queue before processing ([#6](https://github.com/alecpetrosky/photius-docker/issues/6)).

## 0.9.24 / 2020-09-24

- Added `PHOTIUS_RENAME_PROCESSINGDATE` and `PHOTIUS_RENAME_DATETIMEORIGINAL` flags.

## 0.9.18 / 2020-09-18

- Display PHOTIUS_VERSION on start.

## 0.9.17 / 2020-09-17

- Added flags `PHOTIUS_SKIP_PICTURES`, `PHOTIUS_SKIP_VIDEOS` and `PHOTIUS_FAILURE_THRESHOLD` ([#1](https://github.com/alecpetrosky/photius-docker/issues/1)).
