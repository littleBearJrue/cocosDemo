LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := pbc

LOCAL_MODULE_FILENAME := libpbc

LOCAL_ARM_MODE := arm

LOCAL_SRC_FILES := \
src/alloc.c \
src/array.c \
src/bootstrap.c \
src/context.c \
src/decode.c \
src/map.c \
src/pattern.c \
src/proto.c \
src/register.c \
src/rmessage.c \
src/stringpool.c \
src/varint.c \
src/wmessage.c \
pbc/pbc-lua.c \



LOCAL_C_INCLUDES+= src \
pbc \
$(LOCAL_PATH)/../lua/luajit/include

#LOCAL_WHOLE_STATIC_LIBRARIES := cocos2d_lua_android_static



#LUA_IMPORT_PATH := lua/luajit/prebuilt/android
#LUA_INCLUDE_PATH := $(LOCAL_PATH)/../lua/luajit/include

include $(BUILD_STATIC_LIBRARY)
#$(call import-module,$(LUA_IMPORT_PATH))