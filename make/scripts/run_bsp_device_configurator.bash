#!/bin/bash
(set -o igncr) 2>/dev/null && set -o igncr
set -$-e${DEBUG+xv}
set -o errtrace

#######################################################################################################################
# Run device-configurator on the generated bsp's design.modus file to generate code and update the device.
#   Usage: run_bsp_device_configurator.bash <CY_FIND> <CY_TARGET_GEN_DIR> <DEVICE_GEN> <ADDITIONAL_DEVICES> <CY_CONFIG_MODUS_EXEC> <CY_CONFIG_LIBFILE>
#######################################################################################################################

# this function is called just before a script exits (for any reason). It's given the scripts exit code.
# E.g., if there is a failure due to "set -e" this function will still be called.
trap_exit() {
    # this is the return code the main part of the script want to return
    local result=$?

    # turn off the EXIT trap
    trap - EXIT

    # Print WARNING messages if they occur
    echo
    if [[ ${#WARNING_MESSAGES[@]} -ne 0 ]]; then
        echo ==============================================================================
        for line in "${WARNING_MESSAGES[@]}"; do
            echo "$line"
        done
        echo
    fi
    
    if [ "$result" != 0 ]; then
        echo ==============================================================================
        echo "--ABORTING--"
        echo "Script      : $0"
        echo "Bash path   : $BASH"
        echo "Bash version: $BASH_VERSION"
        echo "Exit code   : $result"
        echo "Call stack  : ${FUNCNAME[*]}"
    fi
    exit $result
}

trap "trap_exit" EXIT

CY_FIND=$1
CY_TARGET_GEN_DIR=$2
DEVICE_GEN=$3
ADDITIONAL_DEVICES=$4
CY_CONFIG_MODUS_EXEC=$5
CY_CONFIG_LIBFILE=$6

designFile=$($CY_FIND $CY_TARGET_GEN_DIR -name *.modus)
if [[ $designFile ]]; then
    echo "Running device-configurator for $DEVICE_GEN..."
    set +e
    $CY_CONFIG_MODUS_EXEC $CY_CONFIG_LIBFILE --build $designFile --set-device=$DEVICE_GEN,$ADDITIONAL_DEVICES
    cfgStatus=$?
    set -e
    if [ $cfgStatus != 0 ]; then
        echo "ERROR: Device-configuration failed for $designFile"
        exit $cfgStatus
    fi;
else
    echo "Could not detect .modus file. Skipping update..."
fi;