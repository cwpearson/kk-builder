set -eu -o pipefail
set -x

date

# copied this from the login environment
export NIX_PATH=nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels

export PATH="$HOME/.nix-profile/bin:$PATH"

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

export KK_YEAR=`date +%Y`
export KK_MONTH=`date +%m`
export KK_DAY=`date +%d`
export CORE_DIR="$SCRIPTPATH/kokkos"
export KERN_DIR="$SCRIPTPATH/kokkos-kernels"
export BUILD_ROOT="$SCRIPTPATH/$KK_YEAR/$KK_MONTH/$KK_DAY"
export LOG_DIR="$SCRIPTPATH/logs"

if [[ -d "$CORE_DIR" ]]; then
  cd "$CORE_DIR"
  git checkout develop
  git pull
  cd -
else
  git clone https://github.com/kokkos/kokkos.git "$CORE_DIR"
  cd "$CORE_DIR"
  git checkout develop
  cd -
fi

echo updated core

if [[ -d "$KERN_DIR" ]]; then
  cd "$KERN_DIR"
  git checkout develop
  git pull
  cd -
else
  git clone https://github.com/kokkos/kokkos-kernels.git "$KERN_DIR"
  cd "$KERN_DIR"
  git checkout develop
  cd -
fi

echo updated kernels

mkdir -p "$BUILD_ROOT"
mkdir -p "$LOG_DIR"

set +e # don't exit on error
BUILD_NAME=gcc8 nix-shell --run $SCRIPTPATH/build-gcc.sh $SCRIPTPATH/gcc8.nix
gcc8_code="$?"

BUILD_NAME=gcc8-openmp nix-shell --run $SCRIPTPATH/build-gcc-openmp.sh $SCRIPTPATH/gcc8.nix
gcc8_openmp_code="$?"

BUILD_NAME=gcc9 nix-shell --run $SCRIPTPATH/build-gcc.sh $SCRIPTPATH/gcc9.nix 
gcc9_code="$?"

BUILD_NAME=gcc9-openmp nix-shell --run $SCRIPTPATH/build-gcc-openmp.sh $SCRIPTPATH/gcc9.nix
gcc9_openmp_code="$?"

BUILD_NAME=gcc10 nix-shell --run $SCRIPTPATH/build-gcc.sh $SCRIPTPATH/gcc10.nix 
gcc10_code="$?"

BUILD_NAME=gcc10-openmp nix-shell --run $SCRIPTPATH/build-gcc-openmp.sh $SCRIPTPATH/gcc10.nix
gcc10_openmp_code="$?"

BUILD_NAME=gcc11 nix-shell --run $SCRIPTPATH/build-gcc.sh $SCRIPTPATH/gcc11.nix 
gcc11_code="$?"

BUILD_NAME=gcc11-openmp nix-shell --run $SCRIPTPATH/build-gcc-openmp.sh $SCRIPTPATH/gcc11.nix
gcc11_openmp_code="$?"

BUILD_NAME=gcc12 nix-shell --run $SCRIPTPATH/build-gcc.sh $SCRIPTPATH/gcc12.nix 
gcc12_code="$?"

BUILD_NAME=gcc12-openmp nix-shell --run $SCRIPTPATH/build-gcc-openmp.sh $SCRIPTPATH/gcc12.nix
gcc12_openmp_code="$?"

BUILD_NAME=clang8 nix-shell --run $SCRIPTPATH/build-clang.sh $SCRIPTPATH/clang8.nix 
clang8_code="$?"

BUILD_NAME=clang8-openmp nix-shell --run $SCRIPTPATH/build-clang-openmp.sh $SCRIPTPATH/clang8.nix 
clang8_openmp_code="$?"

BUILD_NAME=clang9 nix-shell --run $SCRIPTPATH/build-clang.sh $SCRIPTPATH/clang9.nix 
clang9_code="$?"

BUILD_NAME=clang9-openmp nix-shell --run $SCRIPTPATH/build-clang-openmp.sh $SCRIPTPATH/clang9.nix 
clang9_openmp_code="$?"

BUILD_NAME=clang10 nix-shell --run $SCRIPTPATH/build-clang.sh $SCRIPTPATH/clang10.nix 
clang10_code="$?"

BUILD_NAME=clang10-openmp nix-shell --run $SCRIPTPATH/build-clang-openmp.sh $SCRIPTPATH/clang10.nix 
clang10_openmp_code="$?"

BUILD_NAME=clang11 nix-shell --run $SCRIPTPATH/build-clang.sh $SCRIPTPATH/clang11.nix 
clang11_code="$?"

BUILD_NAME=clang11-openmp nix-shell --run $SCRIPTPATH/build-clang-openmp.sh $SCRIPTPATH/clang11.nix 
clang11_openmp_code="$?"

BUILD_NAME=clang12 nix-shell --run $SCRIPTPATH/build-clang.sh $SCRIPTPATH/clang12.nix 
clang12_code="$?"

BUILD_NAME=clang12-openmp nix-shell --run $SCRIPTPATH/build-clang-openmp.sh $SCRIPTPATH/clang12.nix 
clang12_openmp_code="$?"

BUILD_NAME=clang13 nix-shell --run $SCRIPTPATH/build-clang.sh $SCRIPTPATH/clang13.nix 
clang13_code="$?"

BUILD_NAME=clang13-openmp nix-shell --run $SCRIPTPATH/build-clang-openmp.sh $SCRIPTPATH/clang13.nix 
clang13_openmp_code="$?"

BUILD_NAME=clang14 nix-shell --run $SCRIPTPATH/build-clang.sh $SCRIPTPATH/clang14.nix
clang14_code="$?"

BUILD_NAME=clang14-openmp nix-shell --run $SCRIPTPATH/build-clang-openmp.sh $SCRIPTPATH/clang14.nix 
clang14_openmp_code="$?"

# cd in to keep that structure from being added to zip file
cd ${LOG_DIR}
zip -r "/tmp/${KK_YEAR}_${KK_MONTH}_${KK_DAY}.zip"  *${KK_YEAR}_${KK_MONTH}_${KK_DAY}*.log
cd -

echo "Subject: kk-builder summary" > /tmp/kk-builder.txt
echo "g++8          : $gcc8_code" >> /tmp/kk-builder.txt
echo "g++8-openmp   : $gcc8_openmp_code" >> /tmp/kk-builder.txt
echo "g++9          : $gcc9_code" >> /tmp/kk-builder.txt
echo "g++9-openmp   : $gcc9_openmp_code" >> /tmp/kk-builder.txt
echo "g++10         : $gcc10_code" >> /tmp/kk-builder.txt
echo "g++10-openmp  : $gcc10_openmp_code" >> /tmp/kk-builder.txt
echo "g++11         : $gcc11_code" >> /tmp/kk-builder.txt
echo "g++11-openmp  : $gcc11_openmp_code" >> /tmp/kk-builder.txt
echo "g++12         : $gcc12_code" >> /tmp/kk-builder.txt
echo "g++12-openmp  : $gcc12_openmp_code" >> /tmp/kk-builder.txt
echo "clang8        : $clang8_code" >> /tmp/kk-builder.txt
echo "clang8-openmp : $clang8_openmp_code" >> /tmp/kk-builder.txt
echo "clang 9       : $clang9_code" >> /tmp/kk-builder.txt
echo "clang8-openmp : $clang8_openmp_code" >> /tmp/kk-builder.txt
echo "clang10       : $clang10_code" >> /tmp/kk-builder.txt
echo "clang10-openmp: $clang10_openmp_code" >> /tmp/kk-builder.txt
echo "clang11       : $clang11_code" >> /tmp/kk-builder.txt
echo "clang11-openmp: $clang11_openmp_code" >> /tmp/kk-builder.txt
echo "clang12       : $clang12_code" >> /tmp/kk-builder.txt
echo "clang12-openmp: $clang12_openmp_code" >> /tmp/kk-builder.txt
echo "clang13       : $clang13_code" >> /tmp/kk-builder.txt
echo "clang13-openmp: $clang13_openmp_code" >> /tmp/kk-builder.txt
echo "clang14       : $clang14_code" >> /tmp/kk-builder.txt
echo "clang14-openmp: $clang14_openmp_code" >> /tmp/kk-builder.txt

cat /tmp/kk-builder.txt | mutt -s "kk-builder summary" me@carlpearson.net -a /tmp/${KK_YEAR}_${KK_MONTH}_${KK_DAY}.zip
rm -f /tmp/kk-builder.txt

