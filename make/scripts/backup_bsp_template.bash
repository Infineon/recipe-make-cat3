#!/bin/bash
(set -o igncr) 2>/dev/null && set -o igncr
set -$-e${DEBUG+xv}
set -o errtrace

#######################################################################################################################
# Create a .bak copy of linker script and startup file in custom bsp when calling update bsp and changing device
#   Usage: backup_bsp_template.bash <CY_FIND> <CY_TEMPLATES_DIR> <CY_BSP_DESTINATION_ABSOLUTE> <CY_SEARCH_FILES_CMD>
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
CY_TEMPLATES_DIR=$2
CY_BSP_DESTINATION_ABSOLUTE=$3
CY_SEARCH_FILES_CMD=( $4 )

if [ "$CY_SEARCH_FILES_CMD" != "" ]; then
    if [ -d "$CY_TEMPLATES_DIR" ]; then
        echo "Creating backup of old bsp linker scripts and startup files..."
        pushd  $CY_TEMPLATES_DIR 1> /dev/null

        CY_FIND_BSP_FILES_RESULT=$($CY_FIND . -type f "${CY_SEARCH_FILES_CMD[@]}")
        for old_file in $CY_FIND_BSP_FILES_RESULT
        do
            if [[ $old_file == *"_ac"?".sct" ]]; then
                old_file_name_wo_suffix=$(echo $old_file | sed s/_ac[0-9]\.sct/\.sct/g)
            else
                old_file_name_wo_suffix=$old_file
            fi

            if [[ -f $CY_BSP_DESTINATION_ABSOLUTE/$old_file_name_wo_suffix ]]; then
                echo "Creating backup file $CY_BSP_DESTINATION_ABSOLUTE/$old_file_name_wo_suffix.bak"
                mv $CY_BSP_DESTINATION_ABSOLUTE/$old_file_name_wo_suffix $CY_BSP_DESTINATION_ABSOLUTE/$old_file_name_wo_suffix.bak
            fi
        done

        popd 1> /dev/null;\
    fi;\
fi;
