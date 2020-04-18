# Photius Docker

Photius Docker is unpretentious workhorse that maintains fitness of your personal photo and video home archive.

## What it does?

Photius constantly monitors an input directory `/opt/src` for media files (images and video), performs various optimizations on them and then moves them into an output directory `/opt/dest` sorting your media into YYYY/MM/DD subfolders.

Here're list of actions that Photius currently performs on media files:

- Optimize JPEG quality.
- Convert PNG to JPEG and optimize its quality.
- Convert video to mp4 with libx265 (HEVC) codec.
- Set EXIF DateTimeOriginal from filename and file attributes (if DateTimeOriginal is absent).
- Sanitize EXIF.
- Convert file extension to lower-case.
- Make filename of photoboost photo (which were taken with Google Camera) look better.

## Usage

```
docker run -it --restart unless-stopped \
    --name photius \
    -v /opt/webdav:/opt/src \
    -v /opt/temp:/opt/temp \
    -v /opt/photos:/opt/dest \
    llamaq/photius
```

## Parameters

- **/opt/src:** incoming directory
- **/opt/temp:** temporary directory
- **/opt/dest:** final destination

When using volumes (-v flags) permissions issues can arise between the host OS and the container. You can avoid this issue by specifying the user `PUID` and group `PGID` value. For example, `-e PUID=1000 -e PGID=1000`. Default values for `PUID` and `PGID` are `1000`, if no environment variables are provided.

## Real World Usage Example

- Home / Cloud server
  - Point `/opt/src` to *webdav/ftp/samba/...* directory where you upload your photos. You may use our [llamaq/webdav](https://hub.docker.com/llamaq/webdav) docker container for your photo uploads.
  - If you want to upload your photo & video collection at multiple locations (home server, cloud server, laptop) and have all them in sync, you can give a try to an outstanding opensource solution [Syncthing](https://syncthing.net/). In this manner, when at home you upload your photos to home server, on vacation upload them to your laptop and being on the move, use your cloud server. It doesn't matter where you're, your media will be in sync. Just install `photius`, `webdav` and `syncthing` containers at each server location.
- Android or iOS device
  - If you're looking for a wireless transfer solution for photo & video backups between iOS and Android devices, computer (PC & Mac), cloud / photo services and NAS devices, you can give a try to [PhotoSync](https://www.photosync-app.com). When using PhotoSync to upload your media with WebDAV, we recommend `Date Taken + Folder Name` (`YR%mR%dR_%HR%MR%SR_%FP`) as Custom Format for filenames as WebDAV doesn't allow preserve dates and this setting will allow you to preserve creation dates for media that do not have EXIF metadata (i.e. photos downloaded from Facebook or WhatsApp) or does not support it (i.e. GIF format).

## License

Please note that the software is in early alpha stage. Please do regular backups of your data.

This container and its code is licensed under the MIT License and provided "AS IS", without warranty of any kind.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
