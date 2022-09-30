################################################################################
# \file recipe_common.mk
#
# \brief
# Common variables and targets for recipe.mk
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
# QSPI programming flags
################################################################################

ifneq ($(CY_SECONDSTAGE),)

_MTB_RECIPE__QUERY_EVAL_CONFIG_FILE=$(MTB_TOOLS__OUTPUT_BASE_DIR)/mtbquery-eval-config.mk
# get the path of design.modus file
_MTB_RECIPE__CONFIG_MODUS_FILE:=$(filter %.modus,$(CY_SEARCH_ALL_FILES))

ifneq ($(words $(_MTB_RECIPE__CONFIG_MODUS_FILE)),1)
ifneq ($(words $(_MTB_RECIPE__CONFIG_MODUS_FILE)),0)
$(warning Multiple .modus files found: $(_MTB_RECIPE__CONFIG_MODUS_FILE) -- using the first.)
 _MTB_RECIPE__CONFIG_MODUS_FILE:=$(word 1,$(_MTB_RECIPE__CONFIG_MODUS_FILE))
endif
endif

_MTB_RECIPE__PROJECT_DIR_NAME=$(notdir $(realpath $(MTB_TOOLS__PRJ_DIR)))

ifeq ($(_MTB_RECIPE__CONFIG_MODUS_FILE),)
_MTB_RECIPE__CONFIG_MODUS_OUTPUT=
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_WITH_FLAG=
else
_MTB_RECIPE__CONFIG_MODUS_OUTPUT=$(call mtb__get_dir,$(_MTB_RECIPE__CONFIG_MODUS_FILE))/GeneratedSource
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_WITH_FLAG=-s &quot;$(_MTB_RECIPE__CONFIG_MODUS_OUTPUT)&quot;&\#13;&\#10;
endif
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH=$(_MTB_RECIPE__CONFIG_MODUS_OUTPUT)
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_APPLICATION=$(patsubst $(call mtb_path_normalize,$(MTB_TOOLS__PRJ_DIR)/..)/%,%,$(call mtb_path_normalize,$(_MTB_RECIPE__CONFIG_MODUS_OUTPUT)))
endif

################################################################################
# Compiler and linker arguments
################################################################################

#
# Defines construction
#
ifneq ($(DEFINES),)
_MTB_RECIPE__USER_DEFINES=$(addprefix -D,$(DEFINES))
endif
ifneq ($(LIBNAME),)
_MTB_RECIPE__USER_NAME=-DCY_LIBNAME_$(subst -,_,$(LIBNAME))
else
_MTB_RECIPE__USER_NAME=-DCY_APPNAME_$(subst -,_,$(APPNAME))
endif

ifneq (,$(MTB_RECIPE__CORE_NAME))
_MTB_RECIPE__CORE_NAME_DEFINES=-DCORE_NAME_$(MTB_RECIPE__CORE_NAME)=1
endif

# Note: _MTB_RECIPE__DEFAULT_COMPONENT is needed as DISABLE_COMPONENTS cannot be empty
_MTB_RECIPE__COMPONENT_LIST=$(filter-out $(DISABLE_COMPONENTS) _MTB_RECIPE__DEFAULT_COMPONENT,$(MTB_CORE__FULL_COMPONENT_LIST))

MTB_RECIPE__DEFINES=$(sort \
	$(_MTB_RECIPE__USER_DEFINES)\
	$(_MTB_RECIPE__USER_NAME)\
	-DTARGET_$(subst -,_,$(TARGET))\
	-DCY_TARGET_BOARD=$(subst -,_,$(TARGET))\
	$(addprefix -DCOMPONENT_,$(subst -,_,$(_MTB_RECIPE__COMPONENT_LIST)))\
	$(MTB_RECIPE__TOOLCHAIN_DEFINES)\
	-DCY_SUPPORTS_DEVICE_VALIDATION\
	$(_MTB_RECIPE__CORE_NAME_DEFINES)\
	$(addprefix -D, $(subst -,_,$(DEVICE)) $(BSP_DEFINES) $(DEVICE_DEFINES)))

#
# Includes construction
#
MTB_RECIPE__INCLUDES=\
	$(addprefix -I,$(INCLUDES))\
	$(addprefix -I,$(MTB_CORE__SEARCH_APP_INCLUDES))\
	$(addprefix -I,$(MTB_RECIPE__TOOLCHAIN_INCLUDES))

#
# Sources construction
#
MTB_RECIPE__SOURCE=$(MTB_CORE__SEARCH_APP_SOURCE)

#
# Libraries construction
#
MTB_RECIPE__LIBS=$(LDLIBS) $(MTB_CORE__SEARCH_APP_LIBS)

#
# Generate source step
#
ifneq ($(CY_SEARCH_RESOURCE_FILES),)
_MTB_RECIPE__RESOURCE_FILES=$(CY_SEARCH_RESOURCE_FILES)
CY_RECIPE_GENERATED_FLAG=TRUE

# Define the generated source file. Use := for better performance
CY_RECIPE_GENERATED:=$(addprefix $(MTB_TOOLS__OUTPUT_GENERATED_DIR)/,$(addsuffix .$(MTB_RECIPE__SUFFIX_C),\
					$(basename $(notdir $(subst .,_,$(CY_SEARCH_RESOURCE_FILES))))))

_MTB_RECIPE__GENSRC=\
	bash --norc --noprofile\
	$(MTB_TOOLS__CORE_DIR)/make/scripts/genresources.bash\
	$(MTB_TOOLS__CORE_DIR)/make/scripts\
	$(MTB_TOOLS__OUTPUT_GENERATED_DIR)/resources.cyrsc\
	$(MTB_TOOLS__OUTPUT_GENERATED_DIR)\
	"MEM"
endif

#
# Prebuild step
#
recipe_prebuild:

#
# Postbuild step
#
ifeq ($(LIBNAME),)

recipe_postbuild: $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_PROGRAM)

$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_PROGRAM): $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_TARGET)
ifeq ($(TOOLCHAIN),A_Clang)
	$(_MTB_RECIPE__ACLANG_POSTBUILD)
endif
ifeq ($(TOOLCHAIN),ARM)
	$(MTB_TOOLCHAIN_ARM__BASE_DIR)/bin/fromelf --output $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_PROGRAM) --i32combined $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_TARGET)
endif
ifeq ($(TOOLCHAIN),IAR)
	$(MTB_TOOLCHAIN_GCC_ARM__OBJCOPY) -O ihex $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_TARGET) $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_PROGRAM)
endif
ifeq ($(TOOLCHAIN),GCC_ARM)
	$(MTB_TOOLCHAIN_GCC_ARM__OBJCOPY) -O ihex $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_TARGET) $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_PROGRAM)
endif

ifeq ($(MTB_TYPE),PROJECT)
ifeq ($(MTB_APPLICATION_PROMOTE),true)
recipe_postbuild: $(_MTB_RECIPE__PRJ_HEX_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_PROGRAM)
endif

# Copy project-specific program image to the application directory
$(_MTB_RECIPE__PRJ_HEX_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_PROGRAM): $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_PROGRAM)
	$(MTB__NOISE)mkdir -p $(_MTB_RECIPE__PRJ_HEX_DIR)
	cp $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_PROGRAM) $(_MTB_RECIPE__PRJ_HEX_DIR)/$(_MTB_RECIPE__PROJECT_DIR_NAME).$(MTB_RECIPE__SUFFIX_PROGRAM)

# always regenerate the hex file in case the build dir or config changes
.PHONY: $(_MTB_RECIPE__PRJ_HEX_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_PROGRAM)

ifneq ($(MTB_APPLICATION_SUBPROJECTS),)
# Multi-core application build/qbuild targets run application_postbuild
# for the first project in the MTB_PROJECTS list
application_postbuild: $(_MTB_RECIPE__APP_HEX_FILE)

$(_MTB_RECIPE__APP_HEX_FILE): $(foreach project,$(MTB_APPLICATION_SUBPROJECTS),$(_MTB_RECIPE__PRJ_HEX_DIR)/$(project).$(MTB_RECIPE__SUFFIX_PROGRAM))
ifeq ($(CY_TOOL_srec_cat_EXE_ABS),)
	$(call mtb__error,Unable to proceed. srec_cat executable not found)
endif
	$(CY_TOOL_srec_cat_EXE_ABS) $(foreach project,$(MTB_APPLICATION_SUBPROJECTS),$(_MTB_RECIPE__PRJ_HEX_DIR)/$(project).$(MTB_RECIPE__SUFFIX_PROGRAM) -intel) -o $(_MTB_RECIPE__APP_HEX_FILE) -intel --Output_Block_Size 16

# always regenerate the hex file in case the build dir or config changes
.PHONY: $(_MTB_RECIPE__APP_HEX_FILE)

endif #($(MTB_APPLICATION_SUBPROJECTS),)
endif #($(MTB_TYPE),PROJECT)
endif #($(LIBNAME),)

################################################################################
# Memory Consumption
################################################################################

ifeq ($(TOOLCHAIN),A_Clang)
_MTB_RECIPE__GEN_READELF=
_MTB_RECIPE__MEMORY_CAL=
else
_MTB_RECIPE__GEN_READELF=$(MTB_TOOLCHAIN_GCC_ARM__READELF) -Sl $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_TARGET) > $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).readelf
_MTB_RECIPE__MEM_CALC=\
	bash --norc --noprofile\
	$(MTB_TOOLS__CORE_DIR)/make/scripts/memcalc.bash\
	$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).readelf\
	$(_MTB_RECIPE__DEVICE_FLASH_KB)\
	$(_MTB_RECIPE__START_FLASH)
endif

memcalc:
ifeq ($(LIBNAME),)
	$(MTB__NOISE)echo Calculating memory consumption: $(DEVICE) $(TOOLCHAIN) $(MTB_TOOLCHAIN_OPTIMIZATION)
	$(MTB__NOISE)echo
	$(MTB__NOISE)$(_MTB_RECIPE__GEN_READELF)
	$(MTB__NOISE)$(_MTB_RECIPE__MEM_CALC)
	$(MTB__NOISE)echo
endif

#
# Identify the phony targets
#
.PHONY: recipe_postbuild application_postbuild memcalc
