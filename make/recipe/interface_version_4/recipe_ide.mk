################################################################################
# \file recipe_ide.mk
#
# \brief
# This make file defines the IDE export variables and target.
#
################################################################################
# \copyright
# (c) 2022-2025, Cypress Semiconductor Corporation (an Infineon company)
# or an affiliate of Cypress Semiconductor Corporation. All rights reserved.
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

##############################################
# General
##############################################
MTB_RECIPE__IDE_SUPPORTED:=eclipse vscode uvision5 ewarm8

_MTB_RECIPE__IDE_EXPORT_INTERFACE_VERSION=interface_version_4
_MTB_RECIPE__IDE_RECIPE_DIR:=$(MTB_TOOLS__RECIPE_DIR)/make/recipe/$(_MTB_RECIPE__IDE_EXPORT_INTERFACE_VERSION)
include $(_MTB_RECIPE__IDE_RECIPE_DIR)/recipe_ide_common.mk

##############################################
# Eclipse VSCode
##############################################
_MTB_RECIPE__IDE_TEXT_DATA_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/recipe_ide_text_data.txt
_MTB_RECIPE__IDE_TEMPLATE_META_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/recipe_ide_template_meta_data.txt
eclipse_generate vscode_generate: MTB_CORE__EXPORT_CMDLINE += -textdata $(_MTB_RECIPE__IDE_TEXT_DATA_FILE)

##############################################
# Eclipse 
##############################################
eclipse_generate:recipe_eclipse_text_replacement_data_file recipe_eclipse_meta_replacement_data_file
eclipse_generate: MTB_CORE__EXPORT_CMDLINE += -metadata $(_MTB_RECIPE__IDE_TEMPLATE_META_DATA_FILE)

recipe_eclipse_text_replacement_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_PROGRAM&&=$(DEVICE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_DEBUG&&=$(DEVICE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__JLINK_CFG_ATTACH&&=$(_MTB_RECIPE__JLINK_DEVICE_CFG_ATTACH))

recipe_eclipse_meta_replacement_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__IDE_TEMPLATE_META_DATA_FILE),UUID=&&PROJECT_UUID&&)
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/eclipse/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)/default=.mtbLaunchConfigs)

.PHONY: recipe_eclipse_text_replacement_data_file recipe_eclipse_meta_replacement_data_file

##############################################
#  VSCode
##############################################
_MTB_RECIPE__VSCODE_SINGLE_CORE_APP_TASKS_JSON:=$(_MTB_RECIPE__IDE_CORE_SCRIPT_DIR)/vscode/tasks_legacy.json
_MTB_RECIPE__VSCODE_SINGLE_CORE_APP_LAUNCH_JSON:=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/vscode/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)/launch.json

vscode_generate: recipe_vscode_text_replacement_data_file
recipe_vscode_text_replacement_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&DEVICE&&=$(DEVICE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__OPENOCD_CHIP&&=$(_MTB_RECIPE__OPENOCD_CHIP_NAME))
ifeq ($(MTB_RECIPE__CORE),CM0)
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__APP_ENTRY_POINT&&=main)
else
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_TEXT_DATA_FILE),&&_MTB_RECIPE__APP_ENTRY_POINT&&=)
endif

.PHONY:recipe_vscode_text_replacement_data_file 

##############################################
#  UV
##############################################
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

_MTB_RECIPE__IDE_DFP_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/recipe_ide_dfp_data.txt
_MTB_RECIPE__IDE_BUILD_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/recipe_ide_build_data.txt

uvision5: MTB_CORE__EXPORT_CMDLINE += -dfp_data $(_MTB_RECIPE__IDE_DFP_DATA_FILE) -build_data $(_MTB_RECIPE__IDE_BUILD_DATA_FILE)
uvision5:recipe_uvision5_dfp_data_file recipe_uvision5_build_data_file

recipe_uvision5_dfp_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__IDE_DFP_DATA_FILE),DEVICE=$(DEVICE))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_DFP_DATA_FILE),DFP_NAME=$(_MTB_RECIPE__CMSIS_ARCH_NAME))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_DFP_DATA_FILE),VENDOR_NAME=$(_MTB_RECIPE__CMSIS_VENDOR_NAME))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_DFP_DATA_FILE),VENDOR_ID=$(_MTB_RECIPE__CMSIS_VENDOR_ID))
	$(call mtb__file_append,$(_MTB_RECIPE__IDE_DFP_DATA_FILE),PNAME=$(_MTB_RECIPE__CMSIS_PNAME))

recipe_uvision5_build_data_file:
	$(call mtb__file_write,$(_MTB_RECIPE__IDE_BUILD_DATA_FILE),LINKER_SCRIPT=$(MTB_RECIPE__LINKER_SCRIPT))

.PHONY:recipe_uvision5_dfp_data_file recipe_uvision5_build_data_file

##############################################
#  EW
##############################################
# We intentionally don't generate linker script for EW export.
#For XMC, the IAR linker scripts are shipped with EW.
# We will just use the EW IAR defaut linker scripts.

##############################################
# Combiner/Signer Integration
##############################################
ifneq ($(MTB_COMBINE_SIGN_$(_MTB_RECIPE__IDE_PRJ_DIR_NAME)_HEX_FILES),)
_MTB_RECIPE__VSCODE_CS_TASKS_JSON:=$(_MTB_RECIPE__IDE_CORE_SCRIPT_DIR)/vscode/tasks_program_sign_combine.json
_MTB_RECIPE__VSCODE_CS_LAUNCH_JSON:=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/vscode/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)/launch_combine_sign.json

_MTB_RECIPE__ECLIPSE_COMBINE_SIGN_MEATA_DATA_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/eclipse_combine_sign_meta_data.txt
_MTB_RECIPE__ECLIPSE_CS_DST_BASE_NAME:=.mtbLaunchConfigs/$(_MTB_RECIPE__ECLIPSE_APPLICATION_NAME) &&MTB_COMBINE_SIGN_&&IDX&&_CONFIG_NAME&&

eclipse_generate: MTB_CORE__EXPORT_CMDLINE += -metadata $(_MTB_RECIPE__ECLIPSE_COMBINE_SIGN_MEATA_DATA_FILE)
eclipse_generate: recipe_eclipse_combine_sign_meta

recipe_eclipse_combine_sign_meta:
	$(call mtb__file_write,$(_MTB_RECIPE__ECLIPSE_COMBINE_SIGN_MEATA_DATA_FILE))
ifneq ($(wildcard $(_MTB_RECIPE__IDE_TEMPLATE_DIR)/eclipse/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)/combine_sign/Debug.launch),)
	$(call mtb__file_append,$(_MTB_RECIPE__ECLIPSE_COMBINE_SIGN_MEATA_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_RECIPE__IDE_TEMPLATE_DIR)/eclipse/$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)/combine_sign/Debug.launch=$(_MTB_RECIPE__ECLIPSE_CS_DST_BASE_NAME) Debug $(_MTB_RECIPE__PROGRAM_INTERFACE_LAUNCH_SUFFIX).launch)
	$(call mtb__file_append,$(_MTB_RECIPE__ECLIPSE_COMBINE_SIGN_MEATA_DATA_FILE),TEMPLATE_REPEAT=$(_MTB_RECIPE__ECLIPSE_CS_DST_BASE_NAME) Debug $(_MTB_RECIPE__PROGRAM_INTERFACE_LAUNCH_SUFFIX).launch=$(MTB_COMBINE_SIGN_$(_MTB_RECIPE__IDE_PRJ_DIR_NAME)_HEX_FILES))
endif

endif