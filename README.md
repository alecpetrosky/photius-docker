# Photius Docker

Photius Docker is open source unpretentious workhorse that maintains fitness of your personal photo and video home archive.

## What it does?

Photius constantly monitors an input directory `/opt/src` for media files (images and video), performs various optimizations on them and then moves them into an output directory `/opt/dest` sorting your media into YYYY/MM/DD subfolders.

Here're list of actions that Photius currently performs on media files:

- JPEG quality optimization with `jpegoptim`.
- Automatic (using exif orientation tag) lossless rotation with `exiftran`.
- PNG files optimization with OptiPNG that reduces their size to a minimum, without losing semantic information. In addition, this program shall perform error recovery. This option has no effect on valid input files. The  program will spend a reasonable amount of effort to recover as much data as possible.
- MP4 video convertion with `ffmpeg` (libx265 hvc1).
- Setting EXIF DateTimeOriginal from filename and file attributes (if DateTimeOriginal is absent) with `exiftool`.
- EXIF sanitizing with `exiftool`.
- Lower-case file extension convertion.
- Making filename of photoboost photo (which were taken with Google Camera) look better.
- Setting original file's md5sum as “Image Unique ID” EXIF field that could be used in photo management software.

## Usage

```
docker run -it --restart unless-stopped \
    --name photius \
    -v /srv/webdav:/opt \
    llamaq/photius

```

## Parameters & variables

- **/opt:** Volume "base" directory
- /opt/src: incoming directory (if needed outside of base directory)
- /opt/temp: temporary directory (if needed outside of base directory)
- /opt/fail: directory where files with processing errors will be placed (if needed outside of base directory)
- /opt/dest: final destination (if needed outside of base directory)

When using volumes (-v flags) permissions issues can arise between the host OS and the container. You can avoid this issue by specifying the user `PUID` and group `PGID` value. For example, `-e PUID=1000 -e PGID=1000`. Default values for `PUID` and `PGID` are `1000`, if no environment variables are provided.

- `PHOTIUS_SKIP_PICTURES` exclude pictures from scanning and processing (default 0).
- `PHOTIUS_SKIP_VIDEOS` exclude videos from scanning and processing (default 0).
- `PHOTIUS_FAILURE_THRESHOLD` interval in seconds for the container to be considered unhealthy (default 300).
- `PHOTIUS_ALLDATES_FROM_PROCESSINGDATE` replace all exif dates with file processing datetime (default 0).
- `PHOTIUS_RENAME_PROCESSINGDATE` apply file processing datetime for all exif dates and use it as new filename with the following format `%Y%m%d_%H%M%S_FOLDERNAME` (default 0).
- `PHOTIUS_RENAME_DATETIMEORIGINAL` use exif datetime (DateTimeOriginal > CreateDate > ModifyDate > FileModifyDate, the first one found is applied) as new filename with the following format `%Y%m%d_%H%M%S_FOLDERNAME` (default 0).

## Real World Usage Example

- Home / Cloud server
  - Point `/opt` to any directory within *webdav/ftp/samba/...* server. Upload/copy your media into `src` directory. You may use our [llamaq/nginx-extras](https://hub.docker.com/r/llamaq/nginx-extras) docker container as the base for your webdav server.
  - If you want to upload your photo & video collection at multiple locations (home server, cloud server, laptop) and have all them in sync, you can give a try to an outstanding opensource solution [Syncthing](https://syncthing.net/). In this manner, when at home you upload your photos to home server, on vacation upload them to your laptop and being on the move, use your cloud server. It doesn't matter where you're, your media will be in sync. Just install `photius`, `nginx-extras` and `syncthing` containers at each server location.
- Android or iOS device
  - If you're looking for a wireless transfer solution for photo & video backups between iOS and Android devices, computer (PC & Mac), cloud / photo services and NAS devices, you can give a try to [PhotoSync](https://www.photosync-app.com). When using PhotoSync to upload your media with WebDAV, we recommend `Date Taken` as Format for filenames as WebDAV doesn't allow preserve dates and this setting will allow you to preserve creation dates for media that do not have EXIF metadata (i.e. photos downloaded from Facebook or WhatsApp) or does not support it (i.e. GIF format). If you'd like to preserve parent directory name (which is often corresponds to app name) then check FolderSync's `Create Subdirectories` with format `Folder Name` and enable `PHOTIUS_RENAME_DATETIMEORIGINAL` for you container. You can get the same effect setting `Date Taken + Folder Name` (YR%mR%dR_%HR%MR%SR_%FP) as Custom Format for uploaded files in FolderSync. In this case, you don't have to enable `PHOTIUS_RENAME_DATETIMEORIGINAL` for your container.

## Advanced Usage Example

Using `PHOTIUS_SKIP_PICTURES` and `PHOTIUS_SKIP_VIDEOS` you may run simultaneously
two instances of Photius with different `PHOTIUS_FAILURE_THRESHOLD` values:
one for images and another for videos.

This way you can avoid jamming incoming processing queue (remember that video
processing usually takes much longer than image processing).

docker run -it --restart unless-stopped \
    --name photius_pictures \
    -v /srv/webdav:/opt \
    -e PHOTIUS_FAILURE_THRESHOLD=300 \
    -e PHOTIUS_SKIP_VIDEOS=1 \
    llamaq/photius

docker run -it --restart unless-stopped \
    --name photius_videos \
    -v /srv/webdav:/opt \
    -e PHOTIUS_FAILURE_THRESHOLD=3600 \
    -e PHOTIUS_SKIP_PICTURES=1 \
    llamaq/photius

## Contribute

Source: https://github.com/alecpetrosky/photius-docker

Bug reports: https://github.com/alecpetrosky/photius-docker/issues

## License

Please note that the software is in early beta stage. Please do regular backups of your data.

This container and its code is licensed under the MIT License and provided "AS IS", without warranty of any kind.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
