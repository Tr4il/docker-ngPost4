# Docker container for ngPost
This is a Docker container for [ngPost](https://github.com/mbruel/ngPost).

The GUI of the application is accessed through a modern web browser (no installation or configuration needed on client side) or via any VNC client.

BIG thanks to Jocelyn Le Sage (https://github.com/jlesage) for the base of this image.
I'm only the script-kiddie who modified it for his own needs :).

---

<img align="left" width="80" height="80" src="https://raw.githubusercontent.com/mbruel/ngPost/master/src/resources/icons/ngPost.png" alt="ngPost">

# ngPost v4.16

ngPost is a convenient unified client to post files to usenet.

---

## Quick Start

**NOTE**: The Docker command provided in this quick start is given as an example
and parameters should be adjusted to your need.

Launch the ngPost docker container with the following command:
```
docker run -d \
    --name=ngpost \
    -p 5800:5800 \
    -v /docker/appdata/ngpost:/config:rw \
    -v $HOME:/storage:ro \
    tr4il/ngpost
```

Where:
  - `/docker/appdata/ngpost`: This is where the application stores its configuration, log and any files needing persistency.
  - `$HOME`: This location contains files from your host that need to be accessible by the application.

Browse to `http://your-host-ip:5800` to access the ngPost GUI.
Files from the host appear under the `/storage` folder in the container.

## Documentation

Full documentation is available at https://github.com/tr4il/docker-ngpost.

## Support or Contact

Having troubles with the container or have questions?  Please
[create a new issue].

For other great Dockerized applications from the guy who built the base for this container, see https://jlesage.github.io/docker-apps.

[create a new issue]: https://github.com/tr4il/docker-ngpost/issues
