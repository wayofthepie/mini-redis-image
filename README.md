# Mini Redis Image
WIP to create a docker image for redis < 1MB in size, uncompressed.

So far the image is 1.01MB...

```
$ docker images|grep redis
redis    latest     ba6b64638b73     48 years ago     1.01MB
```

Dont mind the age...

Requirements:

  * Non-root user called `redis`
  * Fully working redis

Right now redis is statically linked against glibc. Linking against
musl should bring the size of the exe down to less than 1MB, it
doesn't seem straightforward to do this with nix though, see
https://github.com/NixOS/nixpkgs/issues/25178.

## Building
You'll need [nix](https://nixos.org/nix/) installed. Once installed run:

```
$ nix-build
```

If everything was successful:

```
$ docker load < result
```
The image should be loaded with the name `redis`.
