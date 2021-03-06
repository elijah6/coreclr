#!/bin/bash

#Parse command line arguments
__buildConfig=
for arg in "$@"
do
    case $arg in
    --buildConfig=*)
        __buildConfig="$(echo ${arg#*=} | awk '{print tolower($0)}')"
        if [[ "$__buildConfig" != "debug" && "$__buildConfig" != "release" && "$__buildConfig" != "checked" ]]; then
            exit_with_error "--buildConfig can be only Debug or Release" true
        fi
        ;;
    *)
        ;;
    esac
done

#Check if there are any uncommited changes in the source directory as git adds and removes patches
if [[ $(git status -s) != "" ]]; then
   echo 'ERROR: There are some uncommited changes. To avoid losing these changes commit them and try again.'
   echo ''
   git status
   exit 1
fi

#Change build configuration to the capitalized form to create build product paths correctly
if [[ "$__buildConfig" == "release" ]]; then
    __buildConfig="Release"
elif [[ "$__buildConfig" == "checked" ]]; then
    __buildConfig="Checked"
else
    __buildConfig="Debug"
fi
__buildDirName="$__buildOS.$__buildArch.$__buildConfig"

set -x
set -e

__dockerImage="hseok82/dotnet-buildtools-prereqs:ubuntu1604_cross_prereqs_v3_x86"

# Begin cross build
# We cannot build nuget package yet
__dockerEnvironmentSet="-e ROOTFS_DIR=/crossrootfs/x86"
__currentWorkingDir=`pwd`
__dockerCmd="docker run -i --rm ${__dockerEnvironmentVariable} -v $__currentWorkingDir:/opt/code -w /opt/code $__dockerImage"
__buildCmd="./build.sh x86 cross skipnuget $__buildConfig"
$__dockerCmd $__buildCmd

# Begin PAL test
__dockerImage="hseok82/dotnet-buildtools-prereqs:ubuntu1604_x86_test"
__dockerCmd="docker run -i --rm -v $__currentWorkingDir:/opt/code -w /opt/code $__dockerImage"
__palTestCmd="./src/pal/tests/palsuite/runpaltests.sh /opt/code/bin/obj/Linux.x86.${__buildConfig} /opt/code/bin/paltestout"
$__dockerCmd $__palTestCmd

sudo chown -R $(id -u -n) bin/

(set +x; echo 'Build complete')
