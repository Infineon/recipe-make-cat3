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

include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/defines_common.mk


################################################################################
# General
################################################################################
#
# Compactibility interface for this recipe make
#
MTB_RECIPE__INTERFACE_VERSION=1

#
# List the supported toolchains
#
CY_SUPPORTED_TOOLCHAINS:=GCC_ARM IAR

#
# Family specifics
#
ifeq (XMC1100,$(_MTB_RECIPE__DEVICE_DIE))
_MTB_RECIPE__XMC_ARCH:=XMC1
_MTB_RECIPE__OPENOCD_CHIP_NAME:=xmc1100
_MTB_RECIPE__XMC_SERIES:=XMC1100

else ifeq (XMC1200,$(_MTB_RECIPE__DEVICE_DIE))
_MTB_RECIPE__XMC_ARCH:=XMC1
_MTB_RECIPE__OPENOCD_CHIP_NAME:=xmc1200
_MTB_RECIPE__XMC_SERIES:=XMC1200

else ifeq (XMC1300,$(_MTB_RECIPE__DEVICE_DIE))
_MTB_RECIPE__XMC_ARCH:=XMC1
_MTB_RECIPE__OPENOCD_CHIP_NAME:=xmc1300
_MTB_RECIPE__XMC_SERIES:=XMC1300

else ifeq (XMC1400,$(_MTB_RECIPE__DEVICE_DIE))
_MTB_RECIPE__XMC_ARCH:=XMC1
_MTB_RECIPE__OPENOCD_CHIP_NAME:=xmc1400
_MTB_RECIPE__XMC_SERIES:=XMC1400

else ifneq (,$(findstring $(_MTB_RECIPE__DEVICE_DIE),XMC4100 XMC4104 XMC4108))
_MTB_RECIPE__XMC_ARCH:=XMC4
_MTB_RECIPE__OPENOCD_CHIP_NAME:=xmc4100
_MTB_RECIPE__XMC_SERIES:=XMC4100

else ifeq (XMC4200,$(_MTB_RECIPE__DEVICE_DIE))
_MTB_RECIPE__XMC_ARCH:=XMC4
_MTB_RECIPE__OPENOCD_CHIP_NAME:=xmc4200
_MTB_RECIPE__XMC_SERIES:=XMC4200

else ifeq (XMC4300,$(_MTB_RECIPE__DEVICE_DIE))
_MTB_RECIPE__XMC_ARCH:=XMC4
_MTB_RECIPE__OPENOCD_CHIP_NAME:=xmc4300
_MTB_RECIPE__XMC_SERIES:=XMC4300

else ifeq (XMC4400,$(_MTB_RECIPE__DEVICE_DIE))
_MTB_RECIPE__XMC_ARCH:=XMC4
_MTB_RECIPE__OPENOCD_CHIP_NAME:=xmc4400
_MTB_RECIPE__XMC_SERIES:=XMC4400

else ifneq (,$(findstring $(_MTB_RECIPE__DEVICE_DIE),XMC4500 XMC4502 XMC4504))
_MTB_RECIPE__XMC_ARCH:=XMC4
_MTB_RECIPE__OPENOCD_CHIP_NAME:=xmc4500
_MTB_RECIPE__XMC_SERIES:=XMC4500

else ifeq (XMC4700,$(_MTB_RECIPE__DEVICE_DIE))
_MTB_RECIPE__XMC_ARCH:=XMC4
_MTB_RECIPE__OPENOCD_CHIP_NAME:=xmc4700
_MTB_RECIPE__XMC_SERIES:=XMC4700

else ifeq (XMC4800,$(_MTB_RECIPE__DEVICE_DIE))
_MTB_RECIPE__XMC_ARCH:=XMC4
_MTB_RECIPE__OPENOCD_CHIP_NAME:=xmc4800
_MTB_RECIPE__XMC_SERIES:=XMC4800

else
$(call mtb__error,Incorrect part number $(DEVICE). Check DEVICE variable.)
endif

#
# Architecture specifics
#
ifeq ($(_MTB_RECIPE__XMC_ARCH),XMC1)
_MTB_RECIPE__START_FLASH:=0x10001000
_MTB_RECIPE__OPENOCD_DEVICE_CFG:=xmc1xxx.cfg
_MTB_RECIPE__JLINK_DEVICE_CFG_ATTACH:=$(DEVICE)
else ifeq ($(_MTB_RECIPE__XMC_ARCH),XMC4)
_MTB_RECIPE__START_FLASH:=0x0C000000
_MTB_RECIPE__OPENOCD_DEVICE_CFG:=xmc4xxx.cfg
_MTB_RECIPE__JLINK_DEVICE_CFG_ATTACH:=Cortex-M4
endif

# Add the series name to the standard components list
# to enable auto-discovery of CMSIS startup templates
MTB_RECIPE__COMPONENT+=$(_MTB_RECIPE__DEVICE_DIE)

################################################################################
# IDE specifics
################################################################################

MTB_RECIPE__IDE_SUPPORTED:=eclipse vscode uvision5 ewarm8

ifeq ($(filter vscode,$(MAKECMDGOALS)),vscode)
$(MTB_RECIPE__IDE_RECIPE_DATA_FILE)_vscode:
	$(MTB__NOISE)echo "s|&&DEVICE&&|$(DEVICE)|g;" > $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);\
	echo "s|&&_MTB_RECIPE__OPENOCD_CHIP&&|$(_MTB_RECIPE__OPENOCD_CHIP_NAME)|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);
ifeq ($(MTB_RECIPE__CORE),CM0)
	$(MTB__NOISE)echo "s|&&_MTB_RECIPE__APP_ENTRY_POINT&&|main|g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);
else
	$(MTB__NOISE)echo "s|&&_MTB_RECIPE__APP_ENTRY_POINT&&||g;" >> $(MTB_RECIPE__IDE_RECIPE_DATA_FILE);
endif
endif

ifeq ($(filter eclipse,$(MAKECMDGOALS)),eclipse)
eclipse_textdata_file:
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_PROGRAM&&=$(DEVICE))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_DEBUG&&=$(DEVICE))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_ATTACH&&=$(_MTB_RECIPE__JLINK_DEVICE_CFG_ATTACH))

_MTB_ECLIPSE_TEMPLATE_RECIPE_SEARCH:=$(MTB_TOOLS__RECIPE_DIR)/make/scripts/eclipse
_MTB_ECLIPSE_TEMPLATE_RECIPE_APP_SEARCH:=$(MTB_TOOLS__RECIPE_DIR)/make/scripts/eclipse/Application

eclipse_recipe_metadata_file:
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_METADATA_FILE),RECIPE_TEMPLATE=$(_MTB_ECLIPSE_TEMPLATE_RECIPE_SEARCH))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_METADATA_FILE),RECIPE_APP_TEMPLATE=$(_MTB_ECLIPSE_TEMPLATE_RECIPE_APP_SEARCH))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_METADATA_FILE),PROJECT_UUID=&&PROJECT_UUID&&)

endif

ewarm8_recipe_data_file:
	$(call mtb__file_write,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(DEVICE))

ewarm8: ewarm8_recipe_data_file

ifeq ($(_MTB_RECIPE__XMC_ARCH),XMC1)
_MTB_RECIPE__CMSIS_ARCH_NAME:=XMC1000_DFP
else ifeq ($(_MTB_RECIPE__XMC_ARCH),XMC4)
_MTB_RECIPE__CMSIS_ARCH_NAME:=XMC4000_DFP
endif
_MTB_RECIPE__CMSIS_VENDOR_NAME:=Infineon
_MTB_RECIPE__CMSIS_VENDOR_ID:=7
# pName is optional in the DFP and cprj. But they must match.
# pName is not specified in the XMC dfp, so we have to also not specify in the generated cprj file.
# If we specified the pName, the generated cprj file will not work.
_MTB_RECIPE__CMSIS_PNAME:=

_MTB_RECIPE__CMSIS_LDFLAGS:=

uvision5_recipe_data_file:
	$(call mtb__file_write,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(_MTB_RECIPE__CMSIS_ARCH_NAME))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(_MTB_RECIPE__CMSIS_VENDOR_NAME))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(_MTB_RECIPE__CMSIS_VENDOR_ID))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(_MTB_RECIPE__CMSIS_PNAME))
	$(call mtb__file_append,$(MTB_RECIPE__IDE_RECIPE_DATA_FILE),$(_MTB_RECIPE__CMSIS_LDFLAGS))

uvision5: uvision5_recipe_data_file

################################################################################
# Tools specifics
################################################################################

ifneq (,$(findstring $(_MTB_RECIPE__DEVICE_DIE),XMC1100 XMC1200 XMC1300 XMC1400))
MTB_RECIPE__SIM_URL_RAW="https://design.infineon.com/tinaui/designer.php?path=EXAMPLESROOT%7CINFINEON%7CApplications%7CIndustrial%7C&file=mcu_$(_MTB_RECIPE__XMC_SERIES)_Boot_Kit_MTB_v2.tsc"

ifeq ($(OS),Windows_NT)
# escape the & with ^&
MTB_RECIPE__SIM_URL=$(subst &,^&,$(MTB_RECIPE__SIM_URL_RAW))
else
MTB_RECIPE__SIM_URL=$(MTB_RECIPE__SIM_URL_RAW)
endif
MTB_RECIPE__SIM_GEN_SUPPORTED=1
endif
