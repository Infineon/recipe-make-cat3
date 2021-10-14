#!/bin/bash
(set -o igncr) 2>/dev/null && set -o igncr
set -$-e${DEBUG+xv}
set -o errtrace

#######################################################################################################################
# Create a copy of an original linker script and startup file. If a linker script or a startup file exists and differs
# from an original one then create a .bak copy of an existing linker script or a startup file in custom BSP. 
# The script is executed when creating a new custom BSP, updating the existing custom BSP, and changing the device.
#   Usage: copy_bsp_template.bash <CY_FIND> <CY_BSP_TEMPLATES_DIR> <CY_BSP_DESTINATION_ABSOLUTE> <CY_BSP_SEARCH_FILES_CMD> <CY_BSP_LINKER_SCRIPT> <CY_BSP_STARTUP> <CY_INTERNAL_BSP_TARGET_CREATE_BACK_UP>
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
CY_BSP_TEMPLATES_DIR=$2
CY_BSP_DESTINATION_ABSOLUTE=$3
CY_BSP_SEARCH_FILES_CMD=( $4 )
CY_BSP_LINKER_SCRIPT=$5
CY_BSP_STARTUP=$6
CY_INTERNAL_BSP_TARGET_CREATE_BACK_UP=$7

if [ -d "$CY_BSP_TEMPLATES_DIR" ]; then
    echo "Populating $CY_BSP_LINKER_SCRIPT linker scripts and $CY_BSP_STARTUP startup files..."
    pushd  $CY_BSP_TEMPLATES_DIR 1> /dev/null
    
    CY_FIND_BSP_DIRECTORY_RESULT=$($CY_FIND . -type d)
    for bsp_dir in $CY_FIND_BSP_DIRECTORY_RESULT
    do
        mkdir -p $CY_BSP_DESTINATION_ABSOLUTE/$bsp_dir
    done

    CY_FIND_BSP_FILES_RESULT=$($CY_FIND . -type f "${CY_BSP_SEARCH_FILES_CMD[@]}")
    for bsp_file in $CY_FIND_BSP_FILES_RESULT
    do
        if [[ $bsp_file == *"_ac"?".sct" ]]; then
            bsp_file_name_wo_suffix=$(echo $bsp_file | sed s/_ac[0-9]\.sct/\.sct/g)
        else
            bsp_file_name_wo_suffix=$bsp_file
        fi

        if ! cmp -s $bsp_file $CY_BSP_DESTINATION_ABSOLUTE/$bsp_file_name_wo_suffix; then
            # Process all linker scripts but the one ending with "_ac5.sct"
            if [[ $bsp_file != *"_ac5.sct" ]]; then 
                if [[ -f $CY_BSP_DESTINATION_ABSOLUTE/$bsp_file_name_wo_suffix && $CY_INTERNAL_BSP_TARGET_CREATE_BACK_UP == true ]]; then
                    echo "Creating backup file $CY_BSP_DESTINATION_ABSOLUTE/$bsp_file_name_wo_suffix.bak"
                    cp -p $CY_BSP_DESTINATION_ABSOLUTE/$bsp_file_name_wo_suffix $CY_BSP_DESTINATION_ABSOLUTE/$bsp_file_name_wo_suffix.bak
                fi          
            
                cp -p $bsp_file $CY_BSP_DESTINATION_ABSOLUTE/$bsp_file_name_wo_suffix
            fi
        fi
    done

    popd 1> /dev/null
else
    echo "Could not locate template linker scripts and startup files. Skipping update..."
fi
