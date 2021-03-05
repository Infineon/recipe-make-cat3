################################################################################
# \file defines.mk
#
# \brief
# Defines, needed for the XMC build recipe.
#
################################################################################
# \copyright
# Copyright 2018-2020 Cypress Semiconductor Corporation
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
CY_SUPPORTED_TOOLCHAINS=GCC_ARM

#
# Core specifics
#
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_M0)))
CORE=CM0
CY_XMC_ARCH=XMC1
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_M4)))
CORE=CM4
CY_XMC_ARCH=XMC4
else
$(call CY_MACRO_ERROR,Incorrect part number $(DEVICE). Check DEVICE variable.)
endif

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

#
# Family specifics
#
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC1100)))
CY_OPENOCD_CHIP_NAME=xmc1100
CY_XMC_SERIES=XMC1100
CY_XMC_SUBSERIES=XMC1100

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC1200)))
CY_OPENOCD_CHIP_NAME=xmc1200
CY_XMC_SERIES=XMC1200
CY_XMC_SUBSERIES=XMC1200

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC1300)))
CY_OPENOCD_CHIP_NAME=xmc1300
CY_XMC_SERIES=XMC1300
CY_XMC_SUBSERIES=XMC1300

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC1400)))
CY_OPENOCD_CHIP_NAME=xmc1400
CY_XMC_SERIES=XMC1400
CY_XMC_SUBSERIES=XMC1400

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC4100)))
CY_START_SRAM=0x1FFFE000
CY_OPENOCD_CHIP_NAME=xmc4100
CY_XMC_SERIES=XMC4100
ifneq (,$(findstring XMC4104,$(DEVICE)))
CY_XMC_SUBSERIES=XMC4104
else ifneq (,$(findstring XMC4108,$(DEVICE)))
CY_XMC_SUBSERIES=XMC4108
else
CY_XMC_SUBSERIES=XMC4100
endif

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC4200)))
CY_START_SRAM=0x1FFFC000
CY_OPENOCD_CHIP_NAME=xmc4200
CY_XMC_SERIES=XMC4200
CY_XMC_SUBSERIES=XMC4200

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC4300)))
CY_START_SRAM=0x1FFF0000
CY_OPENOCD_CHIP_NAME=xmc4300
CY_XMC_SERIES=XMC4300
CY_XMC_SUBSERIES=XMC4300

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC4400)))
CY_START_SRAM=0x1FFFC000
CY_OPENOCD_CHIP_NAME=xmc4400
CY_XMC_SERIES=XMC4400
ifneq (,$(findstring XMC4402,$(DEVICE)))
CY_XMC_SUBSERIES=XMC4402
else
CY_XMC_SUBSERIES=XMC4400
endif

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC4500)))
CY_START_SRAM=0x20000000
CY_OPENOCD_CHIP_NAME=xmc4500
CY_XMC_SERIES=XMC4500
ifneq (,$(findstring XMC4502,$(DEVICE)))
CY_XMC_SUBSERIES=XMC4502
else ifneq (,$(findstring XMC4504,$(DEVICE)))
CY_XMC_SUBSERIES=XMC4504
else
CY_XMC_SUBSERIES=XMC4500
endif

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC4700)))
CY_START_SRAM=0x1FFE8000
CY_OPENOCD_CHIP_NAME=xmc4700
CY_XMC_SERIES=XMC4700
CY_XMC_SUBSERIES=XMC4700

else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_DIE_XMC4800)))
ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_SRAM_KB_200)))
CY_START_SRAM=0x1FFEE000
else
CY_START_SRAM=0x1FFE8000
endif
CY_OPENOCD_CHIP_NAME=xmc4800
CY_XMC_SERIES=XMC4800
CY_XMC_SUBSERIES=XMC4800

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
ifeq ($(CY_XMC_ARCH),XMC1)

ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_8)))
CY_LINKER_SCRIPT_NAME=$(CY_XMC_SUBSERIES)x0008
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_16)))
CY_LINKER_SCRIPT_NAME=$(CY_XMC_SUBSERIES)x0016
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_32)))
CY_LINKER_SCRIPT_NAME=$(CY_XMC_SUBSERIES)x0032
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_64)))
CY_LINKER_SCRIPT_NAME=$(CY_XMC_SUBSERIES)x0064
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_128)))
CY_LINKER_SCRIPT_NAME=$(CY_XMC_SUBSERIES)x0128
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_200)))
CY_LINKER_SCRIPT_NAME=$(CY_XMC_SUBSERIES)x0200
endif

else ifeq ($(CY_XMC_ARCH),XMC4)

ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_64)))
CY_LINKER_SCRIPT_NAME=$(CY_XMC_SUBSERIES)x64
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_128)))
CY_LINKER_SCRIPT_NAME=$(CY_XMC_SUBSERIES)x128
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_256)))
CY_LINKER_SCRIPT_NAME=$(CY_XMC_SUBSERIES)x256
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_512)))
CY_LINKER_SCRIPT_NAME=$(CY_XMC_SUBSERIES)x512
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_768)))
CY_LINKER_SCRIPT_NAME=$(CY_XMC_SUBSERIES)x768
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_1024)))
CY_LINKER_SCRIPT_NAME=$(CY_XMC_SUBSERIES)x1024
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_1536)))
CY_LINKER_SCRIPT_NAME=$(CY_XMC_SUBSERIES)x1536
else ifneq (,$(findstring $(DEVICE),$(CY_DEVICES_WITH_FLASH_KB_2048)))
CY_LINKER_SCRIPT_NAME=$(CY_XMC_SUBSERIES)x2048
endif

endif

ifeq ($(CY_LINKER_SCRIPT_NAME),)
$(call CY_MACRO_ERROR,Could not resolve device series for linker script)
endif

# Command for searching files in the template directory
CY_SEARCH_FILES_CMD=\
	-name "*$(CY_LINKER_SCRIPT_NAME).*"

################################################################################
# BSP generation
################################################################################

DEVICE_GEN?=$(DEVICE)

# Core specifics
ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_M0)))
CY_BSP_ARCH=XMC1
else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_M4)))
CY_BSP_ARCH=XMC4
else
$(call CY_MACRO_ERROR,Incorrect part number $(DEVICE_GEN). Check DEVICE_GEN variable.)
endif

# Architecture specifics
ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_DIE_XMC1100)))
CY_BSP_SERIES=XMC1100
CY_BSP_SUBSERIES=XMC1100

else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_DIE_XMC1200)))
CY_BSP_SERIES=XMC1200
CY_BSP_SUBSERIES=XMC1200

else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_DIE_XMC1300)))
CY_BSP_SERIES=XMC1300
CY_BSP_SUBSERIES=XMC1300

else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_DIE_XMC1400)))
CY_BSP_SERIES=XMC1400
CY_BSP_SUBSERIES=XMC1400

else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_DIE_XMC4100)))
CY_BSP_SERIES=XMC4100
ifneq (,$(findstring XMC4104,$(DEVICE_GEN)))
CY_BSP_SUBSERIES=XMC4104
else ifneq (,$(findstring XMC4108,$(DEVICE_GEN)))
CY_BSP_SUBSERIES=XMC4108
else
CY_BSP_SUBSERIES=XMC4100
endif

else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_DIE_XMC4200)))
CY_BSP_SERIES=XMC4200
CY_BSP_SUBSERIES=XMC4200

else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_DIE_XMC4300)))
CY_BSP_SERIES=XMC4300
CY_BSP_SUBSERIES=XMC4300

else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_DIE_XMC4400)))
CY_BSP_SERIES=XMC4400
ifneq (,$(findstring XMC4402,$(DEVICE_GEN)))
CY_BSP_SUBSERIES=XMC4402
else
CY_BSP_SUBSERIES=XMC4400
endif

else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_DIE_XMC4500)))
CY_BSP_SERIES=XMC4500
ifneq (,$(findstring XMC4502,$(DEVICE_GEN)))
CY_BSP_SUBSERIES=XMC4502
else ifneq (,$(findstring XMC4504,$(DEVICE_GEN)))
CY_BSP_SUBSERIES=XMC4504
else
CY_BSP_SUBSERIES=XMC4500
endif

else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_DIE_XMC4700)))
CY_BSP_SERIES=XMC4700
CY_BSP_SUBSERIES=XMC4700

else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_DIE_XMC4800)))
CY_BSP_SERIES=XMC4800
CY_BSP_SUBSERIES=XMC4800

else
$(call CY_MACRO_ERROR,Incorrect part number $(DEVICE_GEN). Check DEVICE_GEN variable.)
endif

# Linker script
ifeq ($(CY_BSP_ARCH),XMC1)

ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_8)))
CY_BSP_LINKER_SCRIPT=$(CY_BSP_SUBSERIES)x0008
else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_16)))
CY_BSP_LINKER_SCRIPT=$(CY_BSP_SUBSERIES)x0016
else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_32)))
CY_BSP_LINKER_SCRIPT=$(CY_BSP_SUBSERIES)x0032
else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_64)))
CY_BSP_LINKER_SCRIPT=$(CY_BSP_SUBSERIES)x0064
else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_128)))
CY_BSP_LINKER_SCRIPT=$(CY_BSP_SUBSERIES)x0128
else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_200)))
CY_BSP_LINKER_SCRIPT=$(CY_BSP_SUBSERIES)x0200
endif

else ifeq ($(CY_BSP_ARCH),XMC4)

ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_64)))
CY_BSP_LINKER_SCRIPT=$(CY_BSP_SUBSERIES)x64
else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_128)))
CY_BSP_LINKER_SCRIPT=$(CY_BSP_SUBSERIES)x128
else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_256)))
CY_BSP_LINKER_SCRIPT=$(CY_BSP_SUBSERIES)x256
else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_512)))
CY_BSP_LINKER_SCRIPT=$(CY_BSP_SUBSERIES)x512
else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_768)))
CY_BSP_LINKER_SCRIPT=$(CY_BSP_SUBSERIES)x768
else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_1024)))
CY_BSP_LINKER_SCRIPT=$(CY_BSP_SUBSERIES)x1024
else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_1536)))
CY_BSP_LINKER_SCRIPT=$(CY_BSP_SUBSERIES)x1536
else ifneq (,$(findstring $(DEVICE_GEN),$(CY_DEVICES_WITH_FLASH_KB_2048)))
CY_BSP_LINKER_SCRIPT=$(CY_BSP_SUBSERIES)x2048
endif

endif

# Paths
CY_INFINEON_TEMPLATE_DIR=$(call CY_MACRO_DIR,$(firstword $(CY_DEVICESUPPORT_SEARCH_PATH)))/CMSIS/Infineon
CY_TEMPLATES_DIR=$(CY_INFINEON_TEMPLATE_DIR)/COMPONENT_$(CY_XMC_SUBSERIES)/Source
CY_BSP_TEMPLATES_DIR=$(CY_INFINEON_TEMPLATE_DIR)/COMPONENT_$(CY_BSP_SUBSERIES)/Source
CY_BSP_DESTINATION_ABSOLUTE=$(abspath $(CY_TARGET_GEN_DIR))

ifeq ($(strip $(CY_BSP_LINKER_SCRIPT)),)
CY_BSP_TEMPLATES_CMD=echo "Could not locate template linker scripts and startup files for DEVICE $(DEVICE_GEN). Skipping update...";
endif

# Command for searching files in the template directory
CY_BSP_SEARCH_FILES_CMD=-name "*$(CY_BSP_LINKER_SCRIPT).*"

ifneq ($(CY_BSP_LINKER_SCRIPT),$(CY_LINKER_SCRIPT_NAME))
CY_SEARCH_FILES_CMD=-name "*$(CY_LINKER_SCRIPT_NAME).*"
else
CY_SEARCH_FILES_CMD=
endif

# Paths used in program/debug
ifeq ($(CY_DEVICESUPPORT_PATH),)
CY_OPENOCD_SVD_PATH?=$(dir $(firstword $(CY_DEVICESUPPORT_SEARCH_PATH)))CMSIS/Infineon/SVD/$(CY_XMC_SERIES).svd
else
CY_OPENOCD_SVD_PATH?=$(CY_INTERNAL_DEVICESUPPORT_PATH)/CMSIS/Infineon/SVD/$(CY_XMC_SERIES).svd
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

################################################################################
# Tools specifics
################################################################################

CY_SUPPORTED_TOOL_TYPES=device-configurator