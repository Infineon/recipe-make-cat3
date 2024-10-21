################################################################################
# \file program.mk
#
# \brief
# This make file is called recursively and is used to build the
# resoures file system. It is expected to be run from the example directory.
#
################################################################################
# \copyright
# Copyright 2018-2024 Cypress Semiconductor Corporation
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

_MTB_RECIPE__GDB_ARGS=$(MTB_TOOLS__RECIPE_DIR)/make/scripts/gdbinit
_MTB_RECIPE__SYMBOL_IMG=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_TARGET)

ifneq ($(MTB_PROBE_SERIAL),)
_MTB_RECIPE__JLINK_PROBE_SERIAL:=-USB $(MTB_PROBE_SERIAL)
endif

_MTB_RECIPE__PROBE_INTERFACE:=swd
ifneq ($(MTB_PROBE_INTERFACE),)
_MTB_RECIPE__PROBE_INTERFACE:=$(MTB_PROBE_INTERFACE)
endif

#
# jlink gdb server command line launch
#
_MTB_RECIPE__JLINK_GDB_SERVER_ARGS=-if $(_MTB_RECIPE__PROBE_INTERFACE) $(_MTB_RECIPE__JLINK_PROBE_SERIAL) -device $(DEVICE) -endian little -speed auto -port 2331 -vd -ir -localhostonly 1 -singlerun -strict -timeout 0 -nogui
_MTB_RECIPE__GDB_SERVER_COMMAND:="$(MTB_CORE__JLINK_GDB_EXE)" $(_MTB_RECIPE__JLINK_GDB_SERVER_ARGS)
_MTB_RECIPE__JLink_COMMANDER_ARGS:=-AutoConnect 1 -ExitOnError 1 -NoGui 1 $(_MTB_RECIPE__JLINK_PROBE_SERIAL) -Device $(DEVICE) -If $(_MTB_RECIPE__PROBE_INTERFACE) -Speed 4000
_MTB_RECIPE__JLink_PROGRAM_COMMAND:="$(MTB_CORE__JLINK_EXE)" $(_MTB_RECIPE__JLink_COMMANDER_ARGS) -CommandFile $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/program.jlink
_MTB_RECIPE__JLink_ERASE_COMMAND:="$(MTB_CORE__JLINK_EXE)" $(_MTB_RECIPE__JLink_COMMANDER_ARGS) -CommandFile $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/erase.jlink

# Generate command files required by JLink tool for programming/erasing
jlink_generate:
	sed "s|&&PROG_FILE&&|$(_MTB_RECIPE__PROG_FILE_USER)|g;" $(MTB_TOOLS__RECIPE_DIR)/make/scripts/program.jlink > $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/program.jlink
	cp $(MTB_TOOLS__RECIPE_DIR)/make/scripts/erase.jlink $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/erase.jlink

erase: erase_JLink

program: program_JLink

program_JLink: build

program_JLink qprogram_JLink: jlink_generate
erase_JLink: jlink_generate

qprogram: qprogram_JLink

#
# only program if it is not a lib project, and if not DIRECT_LOAD
#
program_JLink qprogram_JLink:
ifeq ($(LIBNAME),)
	$(MTB__NOISE)echo;\
	echo "Programming target device ... "
	$(_MTB_RECIPE__JLink_PROGRAM_COMMAND)
	echo "Programming complete"
else
	$(MTB__NOISE)echo "Library application detected. Skip programming... ";\
	echo
endif

debug: program qdebug

qdebug:
ifeq ($(LIBNAME),)
	$(MTB__NOISE)echo;\
	echo ==============================================================================;\
	echo "Instruction:";\
	echo "Open a separate shell and run the attach target (make attach)";\
	echo "to start the GDB client. Then use the GDB commands to debug.";\
	echo ==============================================================================;\
	echo;\
	echo "Opening GDB port ... ";\
	$(_MTB_RECIPE__GDB_SERVER_COMMAND)
else
	$(MTB__NOISE)echo "Library application detected. Skip debug... ";\
	echo
endif

attach:
	$(MTB__NOISE)echo;\
	echo "Starting GDB Client... ";\
	echo "DBG: $(MTB_TOOLCHAIN_GCC_ARM__GDB) $(_MTB_RECIPE__SYMBOL_IMG) -x $(_MTB_RECIPE__GDB_ARGS)";\
	$(MTB_TOOLCHAIN_GCC_ARM__GDB) $(_MTB_RECIPE__SYMBOL_IMG) -x $(_MTB_RECIPE__GDB_ARGS)

erase_JLink:
	$(MTB__NOISE)echo;\
	echo "Erasing target device ... ";\
	$(_MTB_RECIPE__JLink_ERASE_COMMAND)

.PHONY: erase erase_JLink attach qdebug debug qprogram qprogram_JLink program program_JLink