################################################################################
# \file defines_common.mk
#
# \brief
# Common variables and targets for defines.mk
#
################################################################################
# \copyright
# Copyright 2018-2021 Cypress Semiconductor Corporation
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

ifeq ($(WHICHFILE),true)
$(info Processing $(lastword $(MAKEFILE_LIST)))
endif

################################################################################
# BSP Generation
################################################################################

# Move old templates files from the old bsp to a file with .bak extension
CY_BACK_OLD_BSP_TEMPLATES_CMD=$(CY_BASH) $(CY_INTERNAL_BASELIB_PATH)/make/scripts/backup_bsp_template.bash "$(CY_FIND)" "$(CY_TEMPLATES_DIR)" "$(CY_BSP_DESTINATION_ABSOLUTE)" "$(CY_SEARCH_FILES_CMD)";

# Command for copying linker scripts and starups (Note: this doesn't get expanded and used until "bsp" target)

# The find commands cannot be condensed into a single find.
# The find's exec command has a very small character limit, such that if they finds were condensed it would crash.
CY_BSP_TEMPLATES_CMD=$(CY_BASH) $(CY_INTERNAL_BASELIB_PATH)/make/scripts/copy_bsp_template.bash "$(CY_FIND)" "$(CY_BSP_TEMPLATES_DIR)" "$(CY_BSP_DESTINATION_ABSOLUTE)" "$(CY_BSP_SEARCH_FILES_CMD)" "$(CY_BSP_LINKER_SCRIPT)" "$(CY_BSP_STARTUP)" "$(CY_INTERNAL_BSP_TARGET_CREATE_BACK_UP)";

# Command for updating the device(s) (Note: this doesn't get expanded and used until "bsp" target)
CY_BSP_DEVICES_CMD=$(CY_BASH) $(CY_INTERNAL_BASELIB_PATH)/make/scripts/run_bsp_device_configurator.bash "$(CY_FIND)" "$(CY_TARGET_GEN_DIR)" "$(DEVICE_GEN)" "$(ADDITIONAL_DEVICES)" "$(CY_CONFIG_MODUS_EXEC)" "$(CY_CONFIG_LIBFILE)";

ifneq ($(CY_QSPI_FLM_DIR),)
CY_BSP_UPDATE_FLASH_LOADER_CMD=$(if $(wildcard $(CY_OPEN_qspi_configurator_OUTPUT_DIR)/*.$(CY_OPEN_qspi_configurator_EXT)),\
	$(CY_INTERNAL_TOOLS)/$(CY_TOOL_qspi-configurator-cli_EXE) --config $(wildcard $(CY_OPEN_qspi_configurator_OUTPUT_DIR)/*.$(CY_OPEN_qspi_configurator_EXT)) --flashloader-dir $(CY_QSPI_FLM_DIR),);
else
CY_BSP_UPDATE_FLASH_LOADER_CMD=
endif

################################################################################
# Paths
################################################################################

# Set the output file paths
ifneq ($(CY_BUILD_LOCATION),)
CY_SYM_FILE?=$(CY_INTERNAL_BUILD_LOC)/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_PROG_FILE?=$(CY_INTERNAL_BUILD_LOC)/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_PROGRAM)
else
CY_SYM_FILE?=\$$\{cy_prj_path\}/$(notdir $(CY_INTERNAL_BUILD_LOC))/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_PROG_FILE?=\$$\{cy_prj_path\}/$(notdir $(CY_INTERNAL_BUILD_LOC))/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_PROGRAM)
endif

# Search for device support path only when CY_DEVICESUPPORT_PATH is not defined otherwise use CY_INTERNAL_DEVICESUPPORT_PATH
ifeq ($(CY_DEVICESUPPORT_PATH),)
CY_CONDITIONAL_DEVICESUPPORT_PATH:=$(call CY_MACRO_DIR,$(firstword $(CY_DEVICESUPPORT_SEARCH_PATH)))
else
CY_CONDITIONAL_DEVICESUPPORT_PATH:=$(firstword $(CY_INTERNAL_DEVICESUPPORT_PATH))
endif


################################################################################
# IDE specifics
################################################################################

# Eclipse
ifeq ($(filter eclipse,$(MAKECMDGOALS)),eclipse)
CY_ECLIPSE_ARGS+="s|&&CY_OPENOCD_CFG&&|$(CY_OPENOCD_DEVICE_CFG)|g;"\
				"s|&&CY_OPENOCD_CHIP&&|$(CY_OPENOCD_CHIP_NAME)|g;"\
				"s|&&CY_APPNAME&&|$(CY_IDE_PRJNAME)|;"\
				"s|&&CY_CONFIG&&|$(CONFIG)|;"\
				"s|&&CY_SVD_PATH&&|$(CY_ECLIPSE_OPENOCD_SVD_PATH)|g;"\
				"s|&&CY_SYM_FILE&&|$(CY_SYM_FILE)|;"\
				"s|&&CY_PROG_FILE&&|$(CY_PROG_FILE)|;"\
				"s|&&CY_ECLIPSE_GDB&&|$(CY_ECLIPSE_GDB)|g;"
endif

# VSCode
ifeq ($(filter vscode,$(MAKECMDGOALS)),vscode)
CY_GCC_BASE_DIR=$(subst $(CY_INTERNAL_TOOLS)/,,$(CY_INTERNAL_TOOL_gcc_BASE))
CY_GCC_VERSION=$(shell $(CY_INTERNAL_TOOL_arm-none-eabi-gcc_EXE) -dumpversion)
CY_OPENOCD_EXE_DIR=$(patsubst $(CY_INTERNAL_TOOLS)/%,%,$(CY_INTERNAL_TOOL_openocd_EXE))
CY_OPENOCD_SCRIPTS_DIR=$(patsubst $(CY_INTERNAL_TOOLS)/%,%,$(CY_INTERNAL_TOOL_openocd_scripts_SCRIPT))

ifneq ($(CY_BUILD_LOCATION),)
CY_ELF_FILE?=$(CY_INTERNAL_BUILD_LOC)/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_HEX_FILE?=$(CY_INTERNAL_BUILD_LOC)/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_PROGRAM)
else
CY_ELF_FILE?=./$(notdir $(CY_INTERNAL_BUILD_LOC))/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_HEX_FILE?=./$(notdir $(CY_INTERNAL_BUILD_LOC))/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_PROGRAM)
endif

CY_C_FLAGS=$(subst $(CY_SPACE),\"$(CY_COMMA)$(CY_NEWLINE_MARKER)\",$(strip $(CY_RECIPE_CFLAGS)))

ifeq ($(CY_ATTACH_SERVER_TYPE),)
CY_ATTACH_SERVER_TYPE=openocd
endif

CY_VSCODE_ARGS+="s|&&CY_ELF_FILE&&|$(CY_ELF_FILE)|g;"\
				"s|&&CY_HEX_FILE&&|$(CY_HEX_FILE)|g;"\
				"s|&&CY_OPEN_OCD_FILE&&|$(CY_OPENOCD_DEVICE_CFG)|g;"\
				"s|&&CY_SVD_FILE_NAME&&|$(CY_VSCODE_OPENOCD_SVD_PATH)|g;"\
				"s|&&CY_MTB_PATH&&|$(CY_TOOLS_DIR)|g;"\
				"s|&&CY_TOOL_CHAIN_DIRECTORY&&|$(subst ",,$(CY_CROSSPATH))|g;"\
				"s|&&CY_C_FLAGS&&|$(CY_C_FLAGS)|g;"\
				"s|&&CY_GCC_VERSION&&|$(CY_GCC_VERSION)|g;"\
				"s|&&CY_OPENOCD_EXE_DIR&&|$(CY_OPENOCD_EXE_DIR)|g;"\
				"s|&&CY_OPENOCD_SCRIPTS_DIR&&|$(CY_OPENOCD_SCRIPTS_DIR)|g;"\
				"s|&&CY_CDB_FILE&&|$(CY_CDB_FILE)|g;"\
				"s|&&CY_CONFIG&&|$(CONFIG)|g;"\
				"s|&&CY_DEVICE_ATTACH&&|$(CY_JLINK_DEVICE_CFG_ATTACH)|g;"\
				"s|&&CY_MODUS_SHELL_BASE&&|$(CY_TOOL_modus-shell_BASE)|g;"\
				"s|&&CY_ATTACH_SERVER_TYPE&&|$(CY_ATTACH_SERVER_TYPE)|g;"

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_VSCODE_ARGS+="s|&&CY_GCC_BIN_DIR&&|$(CY_INTERNAL_TOOL_gcc_BASE)/bin|g;"\
				"s|&&CY_GCC_DIRECTORY&&|$(CY_INTERNAL_TOOL_gcc_BASE)|g;"
else
CY_VSCODE_ARGS+="s|&&CY_GCC_BIN_DIR&&|$$\{config:modustoolbox.toolsPath\}/$(CY_GCC_BASE_DIR)/bin|g;"\
				"s|&&CY_GCC_DIRECTORY&&|$$\{config:modustoolbox.toolsPath\}/$(CY_GCC_BASE_DIR)|g;"
endif
endif

################################################################################
# Tools specifics
################################################################################

ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_CAPSENSE)))
CY_SUPPORTED_TOOL_TYPES+=capsense-configurator capsense-tuner
endif

CY_BT_ENABLED_DEVICE_COMPONENTS=43012 4343W 43438
ifneq ($(filter $(CY_BT_ENABLED_DEVICE_COMPONENTS),$(COMPONENTS)),)
CY_SUPPORTED_TOOL_TYPES+=bt-configurator
CY_OPEN_bt_configurator_DEVICE=--device 43xxx
endif

ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FS_USB)))
CY_SUPPORTED_TOOL_TYPES+=usbdev-configurator
endif

ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_SECURE)))
CY_SUPPORTED_TOOL_TYPES+=secure-policy-configurator
endif
