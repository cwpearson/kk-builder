set -eu -o pipefail

echo BUILD_ROOT "$BUILD_ROOT"
echo BUILD_NAME "$BUILD_NAME"
echo CORE_DIR "$CORE_DIR"
echo KERN_DIR "$KERN_DIR"
echo LOG_DIR "$LOG_DIR"

workdir="$BUILD_ROOT/$BUILD_NAME"
core_build="$workdir/core-build"
core_install="$workdir/core-install"
kern_build="$workdir/kern-build"

core_config_log="$LOG_DIR/${BUILD_NAME}_${KK_YEAR}_${KK_MONTH}_${KK_DAY}_config_core.log"
core_build_log="$LOG_DIR/${BUILD_NAME}_${KK_YEAR}_${KK_MONTH}_${KK_DAY}_build_core.log"
kern_config_log="$LOG_DIR/${BUILD_NAME}_${KK_YEAR}_${KK_MONTH}_${KK_DAY}_config_kern.log"
kern_build_log="$LOG_DIR/${BUILD_NAME}_${KK_YEAR}_${KK_MONTH}_${KK_DAY}_build_kern.log"

mkdir -p "$core_build"
mkdir -p "$core_install"
mkdir -p "$kern_build"

cd $workdir

cmake -S "$CORE_DIR" -B "$core_build" \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_INSTALL_PREFIX="$core_install" \
-DKokkos_ENABLE_SERIAL=ON \
-DCMAKE_BUILD_TYPE=Debug \
| tee "$core_config_log" 2>&1


cd $core_build
make -j`nproc` install | tee "$core_build_log" 2>&1
cd -

cmake -S "$KERN_DIR" -B "$kern_build" \
-DCMAKE_BUILD_TYPE=Release \
-DKokkos_DIR="$core_install/lib64/cmake/Kokkos" \
-DCMAKE_CXX_FLAGS="-Wall -Wshadow -pedantic -Wsign-compare -Wtype-limits -Wignored-qualifiers -Wempty-body -Wuninitialized" \
-DKokkosKernels_ENABLE_TESTS=ON \
-DKokkosKernels_ENABLE_EXAMPLES:BOOL=ON \
-DKokkosKernels_INST_COMPLEX_DOUBLE=ON \
-DKokkosKernels_INST_DOUBLE=ON \
-DKokkosKernels_INST_COMPLEX_FLOAT=ON \
-DKokkosKernels_INST_FLOAT=ON \
-DKokkosKernels_INST_LAYOUTLEFT:BOOL=ON \
-DKokkosKernels_INST_LAYOUTRIGHT:BOOL=ON \
-DKokkosKernels_INST_OFFSET_INT=ON \
-DKokkosKernels_INST_OFFSET_SIZE_T=ON \
| tee "$kern_config_log" 2>&1

cd "$kern_build"
startDate=`date`
echo "====START==== $startDate" > "$kern_build_log"
make -j`nproc` | tee -a "$kern_build_log" 2>&1
endDate=`date`
echo "====END==== $endDate" >> "$kern_build_log"
cd -

rm -rf "$core_build"
rm -rf "$core_install"
rm -rf "$kern_build"
