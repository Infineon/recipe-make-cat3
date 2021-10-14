################################################################################
# \file defines.mk
#
# \brief
# Defines, needed for the XMC build recipe.
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

include $(CY_INTERNAL_BASELIB_PATH)/make/recipe/defines_common.mk


################################################################################
# General
################################################################################

#
# List the supported toolchains
#
CY_SUPPORTED_TOOLCHAINS=GCC_ARM IAR

#
# Core specifics
#
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_M0)))
CORE=CM0
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_M4)))
CORE=CM4
else
$(call CY_MACRO_ERROR,Incorrect part number $(DEVICE). Check DEVICE variable.)
endif


CY_XMC_ARCH_CAL=$(strip \
	$(if $(findstring $(1),$(CY_DEVICES_WITH_M0)),\
	XMC1,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_M4)),\
	XMC4,\
	$(call CY_MACRO_ERROR,Incorrect part number $(1). Check DEVICE variable.)\
	)))

CY_XMC_ARCH=$(call CY_XMC_ARCH_CAL,$(DEVICE))

#
# Architecture specifics
#
ifeq ($(CY_XMC_ARCH),XMC1)
CY_START_FLASH=0x10001000
CY_START_SRAM=0x20000000
CY_OPENOCD_DEVICE_CFG=xmc1xxx.cfg
CY_JLINK_DEVICE_CFG_ATTACH=$(DEVICE)
else ifeq ($(CY_XMC_ARCH),XMC4)
CY_START_FLASH=0x0C000000
CY_OPENOCD_DEVICE_CFG=xmc4xxx.cfg
CY_JLINK_DEVICE_CFG_ATTACH=Cortex-M4
endif

CY_XMC_SUBSERIES_CALC=$(strip \
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC1100)),\
	XMC1100,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC1200)),\
	XMC1200,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC1300)),\
	XMC1300,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC1400)),\
	XMC1400,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC4100)),\
	XMC4100,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC4104)),\
	XMC4104,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC4108)),\
	XMC4108,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC4200)),\
	XMC4200,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC4300)),\
	XMC4300,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC4400)),\
	XMC4400,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC4402)),\
	XMC4402,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC4500)),\
	XMC4500,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC4502)),\
	XMC4502,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC4504)),\
	XMC4504,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC4700)),\
	XMC4700,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC4800)),\
	XMC4800,\
	$(call CY_MACRO_ERROR,Incorrect part number $(1). Check DEVICE_GEN variable.)\
	)))))))))))))))))

CY_XMC_SUBSERIES=$(call CY_XMC_SUBSERIES_CALC,$(DEVICE))

#
# Family specifics
#
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC1100)))
CY_OPENOCD_CHIP_NAME=xmc1100
CY_XMC_SERIES=XMC1100

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC1200)))
CY_OPENOCD_CHIP_NAME=xmc1200
CY_XMC_SERIES=XMC1200

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC1300)))
CY_OPENOCD_CHIP_NAME=xmc1300
CY_XMC_SERIES=XMC1300

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC1400)))
CY_OPENOCD_CHIP_NAME=xmc1400
CY_XMC_SERIES=XMC1400

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC4100) $(CY_DEVICES_WITH_DIE_XMC4104) $(CY_DEVICES_WITH_DIE_XMC4108)))
CY_START_SRAM=0x1FFFE000
CY_OPENOCD_CHIP_NAME=xmc4100
CY_XMC_SERIES=XMC4100

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC4200)))
CY_START_SRAM=0x1FFFC000
CY_OPENOCD_CHIP_NAME=xmc4200
CY_XMC_SERIES=XMC4200

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC4300)))
CY_START_SRAM=0x1FFF0000
CY_OPENOCD_CHIP_NAME=xmc4300
CY_XMC_SERIES=XMC4300

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC4400) $(CY_DEVICES_WITH_DIE_XMC4402)))
CY_START_SRAM=0x1FFFC000
CY_OPENOCD_CHIP_NAME=xmc4400
CY_XMC_SERIES=XMC4400

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC4500) $(CY_DEVICES_WITH_DIE_XMC4502) $(CY_DEVICES_WITH_DIE_XMC4504)))
CY_START_SRAM=0x20000000
CY_OPENOCD_CHIP_NAME=xmc4500
CY_XMC_SERIES=XMC4500

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC4700)))
CY_START_SRAM=0x1FFE8000
CY_OPENOCD_CHIP_NAME=xmc4700
CY_XMC_SERIES=XMC4700

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC4800)))
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_200)))
CY_START_SRAM=0x1FFEE000
else
CY_START_SRAM=0x1FFE8000
endif
CY_OPENOCD_CHIP_NAME=xmc4800
CY_XMC_SERIES=XMC4800

else
$(call CY_MACRO_ERROR,Incorrect part number $(DEVICE). Check DEVICE variable.)
endif

# Add the series name to the standard components list
# to enable auto-discovery of CMSIS startup templates
COMPONENTS+=$(CY_XMC_SUBSERIES)

#
# Flash memory specifics
#
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_8)))
CY_MEMORY_FLASH=8192
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_16)))
CY_MEMORY_FLASH=16384
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_32)))
CY_MEMORY_FLASH=32768
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_64)))
CY_MEMORY_FLASH=65536
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_128)))
CY_MEMORY_FLASH=131072
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_200)))
CY_MEMORY_FLASH=204800
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_256)))
CY_MEMORY_FLASH=262144
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_512)))
CY_MEMORY_FLASH=524288
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_768)))
CY_MEMORY_FLASH=786432
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_1024)))
CY_MEMORY_FLASH=1048576
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_1536)))
CY_MEMORY_FLASH=1572864
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_2048)))
CY_MEMORY_FLASH=2097152
else
$(call CY_MACRO_ERROR,No Flash memory size defined for $(DEVICE))
endif

#
# SRAM memory specifics
#
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_16)))
CY_MEMORY_SRAM=16384
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_20)))
CY_MEMORY_SRAM=20480
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_40)))
CY_MEMORY_SRAM=40960
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_80)))
CY_MEMORY_SRAM=81920
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_128)))
CY_MEMORY_SRAM=131072
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_160)))
CY_MEMORY_SRAM=163840
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_200)))
CY_MEMORY_SRAM=204800
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_276)))
CY_MEMORY_SRAM=282624
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_352)))
CY_MEMORY_SRAM=360448
else
$(call CY_MACRO_ERROR,No SRAM memory size defined for $(DEVICE))
endif

#
# linker scripts
#

# The IAR linker scripts shipped as part of the IAR install rather than BSP.
# These linker have "xxxxx" rather than just a single "x" in their name.
# These linker script also don't have '0' after the 'x'.
# In GCC the linker script name may a '0' after the 'x' if its a XMC1 device
# I.E XMC1404xxxxx200.icf instead XMC1404x0200.ld


CY_MACRO_GCC_XMC1_LINKER_CALC_INTERNAL=$(strip \
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_8)),\
	$(2)x0008,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_16)),\
	$(2)x0016,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_32)),\
	$(2)x0032,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_64)),\
	$(2)x0064,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_128)),\
	$(2)x0128,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_200)),\
	$(2)x0200,\
	)))))))

CY_MACRO_GCC_XMC4_LINKER_CALC_INTERNAL=$(strip \
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_64)),\
	$(2)x64,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_128)),\
	$(2)x128,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_256)),\
	$(2)x256,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_512)),\
	$(2)x512,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_768)),\
	$(2)x768,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_1024)),\
	$(2)x1024,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_1536)),\
	$(2)x1536,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_2048)),\
	$(2)x2048,\
	)))))))))

# first part of the linker script (XMC4104xxxx)
# remove the part name after the dash and add x.
# the 4100 and 4200 has 4x while everything else has 5x
CY_MACRO_IAR_LINKER_PREFIX_CALC_INTERNAL=$(strip $(word 1,$(subst -, ,$(1)))$(strip \
	$(if $(findstring $(1),$(CY_DEVICES_WITH_DIE_XMC4100) $(CY_DEVICES_WITH_DIE_XMC4104) $(CY_DEVICES_WITH_DIE_XMC4108) $(CY_DEVICES_WITH_DIE_XMC4200)),xxxx,xxxxx)))

CY_MACRO_IAR_LINKER_MEM_CALC_INTERNAL=$(strip \
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_8)),\
	8,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_16)),\
	16,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_32)),\
	32,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_64)),\
	64,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_128)),\
	128,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_200)),\
	200,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_256)),\
	256,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_512)),\
	512,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_768)),\
	768,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_1024)),\
	1024,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_1536)),\
	1536,\
	$(if $(findstring $(1),$(CY_DEVICES_WITH_FLASH_KB_2048)),\
	2048,\
	)))))))))))))

# ARCH, DEVICE, SUBSERIES, TOOLCHAIN
CY_MACRO_LINKER_CALC=$(strip \
	$(if $(findstring IAR,$(4)),\
	$(call CY_MACRO_IAR_LINKER_PREFIX_CALC_INTERNAL,$(2))$(call CY_MACRO_IAR_LINKER_MEM_CALC_INTERNAL,$(2)),\
	$(if $(findstring $(1),XMC1),\
	$(call CY_MACRO_GCC_XMC1_LINKER_CALC_INTERNAL,$(2),$(3)),\
	$(if $(findstring $(1),XMC4),\
	$(call CY_MACRO_GCC_XMC4_LINKER_CALC_INTERNAL,$(2),$(3)),\
	$(call CY_MACRO_ERROR,Could not resolve device series for linker script.)\
	))))

CY_LINKER_SCRIPT_NAME=$(call CY_MACRO_LINKER_CALC,$(CY_XMC_ARCH),$(DEVICE),$(CY_XMC_SUBSERIES),$(TOOLCHAIN))


################################################################################
# BSP generation
################################################################################

DEVICE_GEN?=$(DEVICE)

# Core specifics
CY_BSP_ARCH=$(call CY_XMC_ARCH_CAL,$(DEVICE_GEN))

# Architecture specifics
CY_BSP_SUBSERIES=$(call CY_XMC_SUBSERIES_CALC,$(DEVICE_GEN))

# Linker script
# It's OK to hardcode GCC_ARM here.
# This variable is used to copy the linker script into new custom BSP.
# GCC, and GCC_ARM use the same linker script naming convention.
# For IAR, there are no linker script to copy since they are shipper with IAR workbench.
CY_BSP_LINKER_SCRIPT=$(call CY_MACRO_LINKER_CALC,$(CY_BSP_ARCH),$(DEVICE_GEN),$(CY_BSP_SUBSERIES),GCC_ARM)

# Paths
CY_INFINEON_TEMPLATE_DIR=$(CY_CONDITIONAL_DEVICESUPPORT_PATH)/CMSIS/Infineon
CY_TEMPLATES_DIR=$(CY_INFINEON_TEMPLATE_DIR)/COMPONENT_$(CY_XMC_SUBSERIES)/Source
CY_BSP_TEMPLATES_DIR=$(CY_INFINEON_TEMPLATE_DIR)/COMPONENT_$(CY_BSP_SUBSERIES)/Source
CY_BSP_DESTINATION_ABSOLUTE=$(abspath $(CY_TARGET_GEN_DIR))

ifeq ($(strip $(CY_BSP_LINKER_SCRIPT)),)
CY_BSP_TEMPLATES_CMD=echo "Could not locate template linker scripts and startup files for DEVICE $(DEVICE_GEN). Skipping update...";
endif

# Command for searching files in the template directory
CY_BSP_SEARCH_FILES_CMD=-name "*$(CY_BSP_LINKER_SCRIPT)*.*"

ifneq ($(CY_BSP_LINKER_SCRIPT),$(CY_LINKER_SCRIPT_NAME))
CY_SEARCH_FILES_CMD=-name "*$(CY_LINKER_SCRIPT_NAME)*.*"
else
CY_SEARCH_FILES_CMD=
endif

# Paths used in program/debug
ifeq ($(CY_DEVICESUPPORT_PATH),)
CY_ECLIPSE_OPENOCD_SVD_PATH?=$$\{cy_prj_path\}/$(dir $(firstword $(CY_DEVICESUPPORT_SEARCH_PATH)))CMSIS/Infineon/SVD/$(CY_XMC_SERIES).svd
CY_VSCODE_OPENOCD_SVD_PATH?=$(dir $(firstword $(CY_DEVICESUPPORT_SEARCH_PATH)))CMSIS/Infineon/SVD/$(CY_XMC_SERIES).svd
else
CY_ECLIPSE_OPENOCD_SVD_PATH?=$$\{cy_prj_path\}/$(CY_DEVICESUPPORT_PATH)/CMSIS/Infineon/SVD/$(CY_XMC_SERIES).svd
CY_VSCODE_OPENOCD_SVD_PATH?=$(CY_DEVICESUPPORT_PATH)/CMSIS/Infineon/SVD/$(CY_XMC_SERIES).svd
endif


################################################################################
# IDE specifics
################################################################################

ifeq ($(filter vscode,$(MAKECMDGOALS)),vscode)
CY_VSCODE_ARGS+="s|&&DEVICE&&|$(DEVICE)|g;"\
				"s|&&CY_OPENOCD_CHIP&&|$(CY_OPENOCD_CHIP_NAME)|g;"
endif

ifeq ($(filter eclipse,$(MAKECMDGOALS)),eclipse)
CY_ECLIPSE_ARGS+="s|&&CY_JLINK_CFG_PROGRAM&&|$(DEVICE)|g;"\
				"s|&&CY_JLINK_CFG_DEBUG&&|$(DEVICE)|g;"\
				"s|&&CY_JLINK_CFG_ATTACH&&|$(CY_JLINK_DEVICE_CFG_ATTACH)|g;"
endif

CY_IAR_DEVICE_NAME=$(DEVICE)

ifeq ($(CY_XMC_ARCH),XMC1)
CY_CMSIS_ARCH_NAME=XMC1000_DFP
else ifeq ($(CY_XMC_ARCH),XMC4)
CY_CMSIS_ARCH_NAME=XMC4000_DFP
endif
CY_CMSIS_VENDOR_NAME?=Infineon
CY_CMSIS_VENDOR_ID?=7
# pName is optional in the DFP and cprj. But they must match.
# pName is not specified in the XMC dfp, so we have to also not specify in the generated cprj file.
# If we specified the pName, the generated cprj file will not work.
CY_CMSIS_SPECIFY_CORE=0

################################################################################
# Tools specifics
################################################################################

CY_SUPPORTED_TOOL_TYPES+=device-configurator

ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC1100) $(CY_DEVICES_WITH_DIE_XMC1200) $(CY_DEVICES_WITH_DIE_XMC1300) $(CY_DEVICES_WITH_DIE_XMC1400)))
CY_SUPPORTED_TOOL_TYPES+=online-simulator
CY_OPEN_TYPE_LIST+=online-simulator

CY_OPEN_online_simulator_FILE_RAW="https://design.infineon.com/tinaui/designer.php?path=EXAMPLESROOT%7CINFINEON%7CApplications%7CIndustrial%7C&file=mcu_$(CY_XMC_SERIES)_Boot_Kit_MTB_v2.tsc"

ifeq ($(OS),Windows_NT)
# escape the & with ^&
CY_OPEN_online_simulator_FILE=$(subst &,^&,$(CY_OPEN_online_simulator_FILE_RAW))
else
CY_OPEN_online_simulator_FILE=$(CY_OPEN_online_simulator_FILE_RAW)
endif
CY_SIMULATOR_GEN_SUPPORTED=1
endif
