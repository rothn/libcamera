# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2021, GlobalLogic Ukraine
# Copyright (C) 2021, Roman Stratiienko (r.stratiienko@gmail.com)
#
# Android.mk - Android makefile
#

ifneq ($(filter true, $(BOARD_LIBCAMERA_USES_MESON_BUILD)),)

LOCAL_PATH := $(call my-dir)
LIBCAMERA_TOP := $(dir $(LOCAL_PATH))
LIBCAMERA_MESON_VERSION := .0.0.1

include $(CLEAR_VARS)

LOCAL_SHARED_LIBRARIES := libc libexif libjpeg libyuv_chromium libdl libyaml
MESON_GEN_PKGCONFIGS := libexif libjpeg yaml-0.1 libyuv dl

ifeq ($(TARGET_IS_64_BIT),true)
LOCAL_MULTILIB := 64
else
LOCAL_MULTILIB := 32
endif
include $(LOCAL_PATH)/meson_cross.mk

ifdef TARGET_2ND_ARCH
LOCAL_MULTILIB := 32
include $(LOCAL_PATH)/meson_cross.mk
endif

#-------------------------------------------------------------------------------

define libcamera-lib
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE := $1
LOCAL_VENDOR_MODULE := true
LOCAL_MODULE_RELATIVE_PATH := $2
ifdef TARGET_2ND_ARCH
LOCAL_SRC_FILES_$(TARGET_ARCH) := $(call relative_top_path,$(LOCAL_PATH))$($3)
LOCAL_SRC_FILES_$(TARGET_2ND_ARCH) := $(call relative_top_path,$(LOCAL_PATH))$(2ND_$3)
LOCAL_MULTILIB := both
else
LOCAL_SRC_FILES := $(call relative_top_path,$(LOCAL_PATH))$($3)
endif
LOCAL_CHECK_ELF_FILES := false
LOCAL_MODULE_SUFFIX := .so$(${4})
include $(BUILD_PREBUILT)
include $(CLEAR_VARS)
endef

__MY_SHARED_LIBRARIES := $(LOCAL_SHARED_LIBRARIES)
include $(CLEAR_VARS)
LOCAL_SHARED_LIBRARIES := $(__MY_SHARED_LIBRARIES)

# Modules 'libcamera', produces '/vendor/lib{64}/libcamera.so'
$(eval $(call libcamera-lib,libcamera,,LIBCAMERA_BIN,LIBCAMERA_MESON_VERSION))
# Modules 'libcamera-base', produces '/vendor/lib{64}/libcamera-base.so'
$(eval $(call libcamera-lib,libcamera-base,,LIBCAMERA_BASE_BIN,LIBCAMERA_MESON_VERSION))
# Modules 'ipa_rkisp1', produces '/vendor/lib{64}/ipa_rkisp1.so'
$(eval $(call libcamera-lib,ipa_rkisp1,,LIBCAMERA_IPA_RKISP1_BIN,))
# Modules 'ipa_rkisp1', produces '/vendor/lib{64}/ipa_rpi.so'
$(eval $(call libcamera-lib,ipa_rpi,,LIBCAMERA_IPA_RASPBERRYPI_BIN,))
# Modules 'ipa_rkisp1', produces '/vendor/lib{64}/ipa_ipu3.so'
$(eval $(call libcamera-lib,ipa_ipu3,,LIBCAMERA_IPA_IPU3_BIN,))
# Modules 'ipa_rkisp1', produces '/vendor/lib{64}/ipa_vimc.so'
$(eval $(call libcamera-lib,ipa_vimc,,LIBCAMERA_IPA_VIMC_BIN,))

LOCAL_SHARED_LIBRARIES += libcamera libcamera-base ipa_rkisp1 ipa_rpi ipa_ipu3 ipa_vimc
LOCAL_REQUIRED_MODULES := libcamera libcamera-base ipa_rkisp1 ipa_rpi ipa_ipu3 ipa_vimc
# ipa_raspberrypi tends to corrupt the build-- only enable once done

# Modules 'camera.libcamera', produces '/vendor/lib{64}/hw/camera.libcamera.so' HAL
$(eval $(call libcamera-lib,camera.libcamera,hw,LIBCAMERA_HAL_BIN,))

$(shell mkdir -p $(TARGET_OUT_VENDOR_ETC)/rkisp1/)
$(shell mkdir -p $(TARGET_OUT_VENDOR_ETC)/rpi/)
$(shell mkdir -p $(TARGET_OUT_VENDOR_ETC)/ipu3/)
$(shell mkdir -p $(TARGET_OUT_VENDOR_ETC)/vimc/)
$(shell cp $(LIBCAMERA_IPA_RKISP1_CONFIGS)/* $(TARGET_OUT_VENDOR_ETC)/rkisp1/)
$(shell cp $(LIBCAMERA_IPA_RASPBERRYPI_CONFIGS)/* $(TARGET_OUT_VENDOR_ETC)/raspberrypi/)
$(shell cp $(LIBCAMERA_IPA_IPU3_CONFIGS)/* $(TARGET_OUT_VENDOR_ETC)/ipu3/)
$(shell cp $(LIBCAMERA_IPA_VIMC_CONFIGS)/* $(TARGET_OUT_VENDOR_ETC)/vimc/)

#-------------------------------------------------------------------------------

endif
