################################################################################
# \file recipe.mk
#
# \brief
# Set up a set of defines, includes, software components, linker script, 
# Pre and Post build steps and call a macro to create a specific ELF file.
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

include $(CY_INTERNAL_BASELIB_PATH)/make/recipe/recipe_common.mk

#
# linker script construction
#
ifeq ($(LINKER_SCRIPT),)
ifeq (IAR,$(TOOLCHAIN))
# IAR linker script are shipped with IAR embedded workbench
# Remove quotes from path and escape spaces. Spaces can already be escaped.
LINKER_SCRIPT=$(call CY_MACRO_GET_PATH_W_ESCAPED_SPACES,$(CY_COMPILER_IAR_DIR)/config/linker/Infineon/$(CY_LINKER_SCRIPT_NAME).$(CY_TOOLCHAIN_SUFFIX_LS))
# IAR default install contains spaces with doesn't work well with make. Skip the wildcard check.
else
# Remove quotes from path and escape spaces. Spaces can already be escaped.
LINKER_SCRIPT=$(call CY_MACRO_GET_PATH_W_ESCAPED_SPACES,$(CY_TARGET_DIR)/TOOLCHAIN_$(TOOLCHAIN)/$(CY_LINKER_SCRIPT_NAME).$(CY_TOOLCHAIN_SUFFIX_LS))
endif
endif

ifeq ($(wildcard $(LINKER_SCRIPT)),)
$(call CY_MACRO_ERROR,The specified linker script could not be found at "$(LINKER_SCRIPT)")
endif

ifeq ($(TOOLCHAIN),A_Clang)
include $(LINKER_SCRIPT)
else
# Quote linker script path and remove escape from spaces
CY_RECIPE_LSFLAG=$(CY_TOOLCHAIN_LSFLAGS)"$(call CY_MACRO_GET_RAW_PATH,$(LINKER_SCRIPT))"
endif

# Aclang arguments must match the symbols in the PDL makefile
CY_RECIPE_ACLANG_POSTBUILD=\
	$(CY_TOOLCHAIN_M2BIN)\
	--verbose --vect $(VECT_BASE_CM0P) --text $(TEXT_BASE_CM0P) --data $(RAM_BASE_CM0P) --size $(TEXT_SIZE_CM0P)\
	$(CY_CONFIG_DIR)/$(APPNAME).mach_o\
	$(CY_CONFIG_DIR)/$(APPNAME).bin

progtool:
	$(call CY_MACRO_ERROR,make progtool is not supported for the current device.)

.PHONY: progtool
