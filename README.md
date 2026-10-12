# SolidCraft in Docker optimized for Unraid
This Docker will download and install the SolidCraft webapp and serve it via [static-web-server](https://github.com/static-web-server/static-web-server).

**Update Notice:** The container will check for a new version on each start/restart and automatically redownload the webapp if a new version is available.

**MANUAL VERSION:** You can also set a version manually by typing in the version number that you want to use for example: '0.4.0' without quotes - this does only work with release versions.

**WEBUI:** You can connect to the WebUI by opening your browser and go to HOSTIP:8080 (eg: 192.168.1.1:8080) or click on WebUI on the Docker page within Unraid.

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Folder for the webapp | /solidcraft |
| SOLIDCRAFT_V | Select if you want to download a stable or prerelease version | latest |
| START_PARAMS | Additional parameters for static-web-server | empty |
| UMASK | Umask value for new created files | 0000 |
| DATA_PERM | Data permissions for data folder | 770 |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |

## Run example
```
docker run --name SolidCraft -d \
	-p 8080:8080 \
	--env 'SOLIDCRAFT_V=latest' \
	--env 'UID=99' \
	--env 'GID=100' \
	--env 'UMASK=0000' \
	--env 'DATA_PERM=770' \
	--volume /path/to/solidcraft:/solidcraft \
	ich777/solidcraft
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/
