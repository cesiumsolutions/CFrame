# CFrame Docker Operations

## Prerequisites

### Docker:

Install Docker and Docker compose.

Refer to: https://docs.docker.com/compose/install/

### Windows only:

To run the sample qtosgboostviewer application, an X window server emulator
must be installed.

XLaunch has been tested an known to work,
see: https://sourceforge.net/projects/xming/

Install and run it with all default options selected.

## Operations

All commands are executed from the ```CFrame/docker/cframe directory```

Start the containers:
> docker-compose up -d

Verify running containers:
> docker-compose ls

Stop the containers:
> docker-compose down

The following operations can either be done from the Host or from within the Container.

To enter into a bash shell in existing container from the Host:
> docker exec -it cframe-cppdev-1 bash

### Compile the Sample

From Within Docker Container:
> cd ~/source/Cframe/docker/cframe

> ./container-build-sample

From the Host:
> cd /path/to/CFrame/docker/cframe

> ./host-build-sample

### Run the Sample

From within the Container:
> cd ~/source/CFrame/docker/cframe

> ./container-run-sample

From the Host:
> cd /path/to/CFrame/docker/cframe

> ./host-run-sample

### Operating the Sample

Once the example qtosgboostviewer application is running (see above)

> Select menu: File->Open

> Select: models/testSphere.osg

A sphere object should appear.

Use the following mouse buttons to operate camera view:
- Left Mouse: Rotate
- Middle Mouse: Pan
- Right Mouse: Zoom

**NOTE**: On Linux the mouse controls do not function properly.
