{ stdenv
, fetchFromGitHub
, cmake
, openssl
, liboqs
, nix-update-script
}:
stdenv.mkDerivation (finalAttrs: {
  name = "oqs-provider";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "open-quantum-safe";
    repo  = "oqs-provider";
    rev = finalAttrs.version;
    hash = "sha256-AW0rOszXm9Hy55b2fQ2mpZulhXjYwvztwL6DIFgIzjA=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    openssl
    liboqs
  ];

  nativeCheckInputs = [ openssl.bin ];

  configureFlags = [ "--with-modulesdir=$$out/lib/ossl-modules" ];

  postPatch = ''
    echo ${finalAttrs.version} > VERSION
  '';

  preInstall = ''
    mkdir -p "$out"
    for dir in "$out" "${openssl.out}"; do
      mkdir -p .install/"$(dirname -- "$dir")"
      ln -s "$out" ".install/$dir"
    done
    export DESTDIR="$(realpath .install)"
  '';

  enableParallelBuilding = true;

  enableParallelInstalling = false;

  doCheck = true;

  passthru.updateScript = nix-update-script { };
})
