set -eu -o pipefail

date

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



set -x
mkdir -p "$BUILD_ROOT"
mkdir -p "$LOG_DIR"
set +x

set +e # don't exit on error
BUILD_NAME=gcc8 nix-shell --run $SCRIPTPATH/build-gcc.sh $SCRIPTPATH/gcc8.nix
gcc8_code="$?"

BUILD_NAME=gcc9 nix-shell --run $SCRIPTPATH/build-gcc.sh $SCRIPTPATH/gcc9.nix 
gcc9_code="$?"

BUILD_NAME=gcc10 nix-shell --run $SCRIPTPATH/build-gcc.sh $SCRIPTPATH/gcc10.nix 
gcc10_code="$?"

BUILD_NAME=gcc11 nix-shell --run $SCRIPTPATH/build-gcc.sh $SCRIPTPATH/gcc11.nix 
gcc11_code="$?"

BUILD_NAME=gcc12 nix-shell --run $SCRIPTPATH/build-gcc.sh $SCRIPTPATH/gcc12.nix 
gcc12_code="$?"

BUILD_NAME=clang8 nix-shell --run $SCRIPTPATH/build-clang.sh $SCRIPTPATH/clang8.nix 
clang8_code="$?"

BUILD_NAME=clang9 nix-shell --run $SCRIPTPATH/build-clang.sh $SCRIPTPATH/clang9.nix 
clang9_code="$?"

BUILD_NAME=clang10 nix-shell --run $SCRIPTPATH/build-clang.sh $SCRIPTPATH/clang10.nix 
clang10_code="$?"

BUILD_NAME=clang11 nix-shell --run $SCRIPTPATH/build-clang.sh $SCRIPTPATH/clang11.nix 
clang11_code="$?"

BUILD_NAME=clang12 nix-shell --run $SCRIPTPATH/build-clang.sh $SCRIPTPATH/clang12.nix 
clang12_code="$?"

BUILD_NAME=clang13 nix-shell --run $SCRIPTPATH/build-clang.sh $SCRIPTPATH/clang13.nix 
clang13_code="$?"

BUILD_NAME=clang14 nix-shell --run $SCRIPTPATH/build-clang.sh $SCRIPTPATH/clang14.nix
clang14_code="$?"

# cd in to keep that structure from being added to zip file
cd ${LOG_DIR}
zip -r "/tmp/${KK_YEAR}_${KK_MONTH}_${KK_DAY}.zip"  *${KK_YEAR}_${KK_MONTH}_${KK_DAY}*.log
cd -

echo "Subject: kk-builder summary" > /tmp/kk-builder.txt
echo "g++  8: $gcc8_code" >> /tmp/kk-builder.txt
echo "g++  9: $gcc9_code" >> /tmp/kk-builder.txt
echo "g++ 10: $gcc10_code" >> /tmp/kk-builder.txt
echo "g++ 11: $gcc11_code" >> /tmp/kk-builder.txt
echo "g++ 12: $gcc12_code" >> /tmp/kk-builder.txt
echo "clang  8: $clang8_code" >> /tmp/kk-builder.txt
echo "clang  9: $clang9_code" >> /tmp/kk-builder.txt
echo "clang 10: $clang10_code" >> /tmp/kk-builder.txt
echo "clang 11: $clang11_code" >> /tmp/kk-builder.txt
echo "clang 12: $clang12_code" >> /tmp/kk-builder.txt
echo "clang 13: $clang13_code" >> /tmp/kk-builder.txt
echo "clang 14: $clang14_code" >> /tmp/kk-builder.txt

cat /tmp/kk-builder.txt | msmtp me@carlpearson.net
cat /tmp/kk-builder.txt | mutt -s "kk-builder summary" me@carlpearson.net -a /tmp/${KK_YEAR}_${KK_MONTH}_${KK_DAY}.zip
rm -f /tmp/kk-builder.txt

