{ pkgs ? import <nixpkgs> {} }:

with pkgs;
let
  passwd = pkgs.stdenv.mkDerivation {
    name = "passwd";
    src = ./.;
    installPhase = ''
      mkdir -p $out/etc
      echo "redis:x:1000:1000:,,,:/home/redis:/bin/bash" > $out/etc/passwd
    '';
  };

  redis_3_0_7 = pkgs.stdenv.mkDerivation {
    name = "redis-test";
    src = fetchurl {
      url = "http://download.redis.io/releases/redis-3.0.7.tar.gz";
      sha256 = "08vzfdr67gp3lvk770qpax2c5g2sx8hn6p64jn3jddrvxb2939xj";
    };
    preBuild = ''
      makeFlagsArray=(CC="gcc -static"
                      MALLOC="libc"
                      CFLAGS="-static"
                      LDFLAGS="-L${glibc.static}/lib"
                      EXEEXT="-static")
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp src/redis-server $out/bin
      strip -s $out/bin/redis-server
      ${upx}/bin/upx $out/bin/redis-server
    '';
    postInstall = ''
      rm -f $out/bin/redis-{benchmark,check-aof,check-dump,cli}
    '';
  };

  redisImage = redis: baseImage: dockerTools.buildImage {
    name = "redis";
    contents = [ passwd ];
    config = {
      Cmd = [ "${redis_3_0_7}/bin/redis-server" ];
      User = "redis";
      ExposedPorts = {
        "6379/tcp" = {};
      };
      WorkingDir = "/data";
      Volumes = {
        "/data" = {};
      };
    };
  };

in {
  redisMini = redisImage redis_3_0_7 null;
}
