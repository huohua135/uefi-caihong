##
#
#  Copyright (c) 2011 - 2022, ARM Limited. All rights reserved.
#  Copyright (c) 2014, Linaro Limited. All rights reserved.
#  Copyright (c) 2015 - 2020, Intel Corporation. All rights reserved.
#  Copyright (c) 2018, Bingxing Wang. All rights reserved.
#  Copyright (c) Microsoft Corporation.
#
#  SPDX-License-Identifier: BSD-2-Clause-Patent
#
##

################################################################################
#
# Defines Section - statements that will be processed to create a Makefile.
#
################################################################################
[Defines]
  PLATFORM_NAME                  = caihong
  PLATFORM_GUID                  = EA17CDFB-30F1-4CC0-8BB8-7BF51482F746
  PLATFORM_VERSION               = 0.1
  DSC_SPECIFICATION              = 0x00010005
  OUTPUT_DIRECTORY               = Build/caihongPkg
  SUPPORTED_ARCHITECTURES        = AARCH64
  BUILD_TARGETS                  = RELEASE|DEBUG
  SKUID_IDENTIFIER               = DEFAULT
  FLASH_DEFINITION               = caihongPkg/caihong.fdf
  USE_CUSTOM_DISPLAY_DRIVER      = 0

  #
  # 0 = SM8650-AA
  # 1 = SM8650-Q-AA
  # 2 = SM8650-AB
  # 3 = SM8650-Q-AB
  # 4 = SM8650-AC
  #
  SOC_TYPE                       = 2

!include LanaiPkg/LanaiPkg.dsc.inc

[PcdsFixedAtBuild]
  #
  # Console verbosity. The DEBUG default prints a memory-allocation line for
  # every driver dispatch, and on a 3000x2120 graphics console that costs the
  # whole boot: ABL's watchdog fires about sixteen seconds after the shim and
  # the payload never gets to start. Keep errors only (DEBUG_ERROR) while the
  # boot is being squeezed into that window.
  #
  gEfiMdePkgTokenSpaceGuid.PcdDebugPrintErrorLevel|0x80000000

  #
  # Boot straight into UniXNU. Without this the boot manager front page comes
  # up, waits for a key nobody presses, and the watchdog takes the board before
  # the payload is ever reached: the screen shows the white front page and then
  # 900E, which is exactly what the 2026-11-12 runs did.
  # FILE_GUID of UniXNUPkg/Application/UniXNU/UniXNU.inf in EDK II byte order.
  #
  gEfiMdeModulePkgTokenSpaceGuid.PcdBootManagerMenuFile|{ 0x04, 0x52, 0x66, 0x9B, 0x33, 0xA1, 0xA2, 0x47, 0x93, 0x96, 0x9E, 0x2B, 0x37, 0x0A, 0x4E, 0x25 }
  gEfiMdeModulePkgTokenSpaceGuid.PcdPlatformBootTimeOut|0

  #
  # DDR Memory
  #
  gArmTokenSpaceGuid.PcdSystemMemoryBase|0x80000000

  #
  # UEFI Stack
  #
  gArmPlatformTokenSpaceGuid.PcdCPUCoresStackBase|0xA760D000
  gArmPlatformTokenSpaceGuid.PcdCPUCorePrimaryStackSize|0x40000

  #
  # SMBIOS
  #
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemManufacturer|"OnePlus"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemRetailModel|"caihong"
!if $(DEVICE_MODEL) == 0
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemModel|"Pad Pro"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemRetailSku|"OPD2404"
!elseif $(DEVICE_MODEL) == 1
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemModel|"Pad Pro"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemRetailSku|"OPD2404"
!endif
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemBoardModel|"24825"

  #
  # Simple Frame Buffer
  #
  gSiliciumPkgTokenSpaceGuid.PcdFrameBufferWidth|3000
  gSiliciumPkgTokenSpaceGuid.PcdFrameBufferHeight|2120
  gSiliciumPkgTokenSpaceGuid.PcdFrameBufferColorDepth|32

  #
  # Platform PEI
  #
  gQcomPkgTokenSpaceGuid.PcdPlatformType|"LA"

[LibraryClasses]
  #
  # Memory Libraries
  #
  MemoryMapLib|caihongPkg/Library/MemoryMapLib/MemoryMapLib.inf

  #
  # QCOM Libraries
  #
  ConfigurationMapLib|caihongPkg/Library/ConfigurationMapLib/ConfigurationMapLib.inf

[Components]
  #
  # ACPI Tables
  #
  # UniXNU
  UniXNUPkg/Application/UniXNU/UniXNU.inf
  UniXNUPkg/Driver/UniXNUDxe/UniXNUDxe.inf
  # caihong: exposes the UniXNU payload (UFS partition) as a block device
  caihongPkg/Drivers/CaihongInitrdDxe/CaihongInitrdDxe.inf
  # XNU loader, packed into the firmware volume with the volume driver above
  DarwinBootPkg/Driver/DarwinBoot.inf

  [LibraryClasses]
  UniXNULib|UniXNUPkg/Library/UniXNULib/UniXNULib.inf
  FdtLib|MdePkg/Library/BaseFdtLib/BaseFdtLib.inf
