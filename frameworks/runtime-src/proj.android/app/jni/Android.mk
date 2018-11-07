LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := \
../../../Classes/AppDelegate.cpp \
../../../Classes/core/graphics/XGDBFrameAnimation.cpp \
../../../Classes/core/graphics/XGFrameAnimation.cpp \
../../../Classes/core/event/XGBaseSys.cpp \
../../../Classes/core/event/XGDelegate.cpp \
../../../Classes/core/event/XGEvent.cpp \
../../../Classes/core/event/XGLogicEvent.cpp \
../../../Classes/core/event/XGLogicSys.cpp \
../../../Classes/core/io/VxFile.cpp \
../../../Classes/core/io/VxIOStream.cpp \
../../../Classes/core/io/VxResourceManager.cpp \
../../../Classes/core/io/VxStream.cpp \
../../../Classes/core/memory/VxAllocator.cpp \
../../../Classes/core/memory/VxBlockAllocator.cpp \
../../../Classes/core/net/NxProtocol.cpp \
../../../Classes/core/net/VxMsg.cpp \
../../../Classes/core/net/VxNetClient.cpp \
../../../Classes/core/net/VxNetManager.cpp \
../../../Classes/core/net/VxProtocol.cpp \
../../../Classes/core/net/VxSocket.cpp \
../../../Classes/core/net/VxSocketClient.cpp \
../../../Classes/core/net/VxObject.cpp \
../../../Classes/core/utils/VxConvert.cpp \
../../../Classes/core/utils/VxLocalObject.cpp \
../../../Classes/core/utils/VxTime.cpp \
../../../Classes/core/utils/XGXml.cpp \
../../../Classes/core/utils/VxNativeUtils.cpp \
../../../Classes/core/lua/XGCCallLuaManager.cpp \
../../../Classes/core/lua/XGLuaBindings.cpp \
../../../Classes/reader/animation/AnimateClip.cpp \
../../../Classes/reader/animation/AnimationClip.cpp \
../../../Classes/reader/animation/AnimationManager.cpp \
../../../Classes/reader/animation/Bezier.cpp \
../../../Classes/reader/animation/Easing.cpp \
../../../Classes/reader/collider/Collider.cpp \
../../../Classes/reader/collider/ColliderManager.cpp \
../../../Classes/reader/collider/Contract.cpp \
../../../Classes/reader/collider/Intersection.cpp \
../../../Classes/reader/CreatorReader.cpp \
../../../Classes/reader/dragonBones/animation/Animation.cpp \
../../../Classes/reader/dragonBones/animation/AnimationState.cpp \
../../../Classes/reader/dragonBones/animation/BaseTimelineState.cpp \
../../../Classes/reader/dragonBones/animation/TimelineState.cpp \
../../../Classes/reader/dragonBones/animation/WorldClock.cpp \
../../../Classes/reader/dragonBones/armature/Armature.cpp \
../../../Classes/reader/dragonBones/armature/Bone.cpp \
../../../Classes/reader/dragonBones/armature/Constraint.cpp \
../../../Classes/reader/dragonBones/armature/DeformVertices.cpp \
../../../Classes/reader/dragonBones/armature/Slot.cpp \
../../../Classes/reader/dragonBones/armature/TransformObject.cpp \
../../../Classes/reader/dragonBones/cocos2dx/CCArmatureDisplay.cpp \
../../../Classes/reader/dragonBones/cocos2dx/CCFactory.cpp \
../../../Classes/reader/dragonBones/cocos2dx/CCSlot.cpp \
../../../Classes/reader/dragonBones/cocos2dx/CCTextureAtlasData.cpp \
../../../Classes/reader/dragonBones/core/BaseObject.cpp \
../../../Classes/reader/dragonBones/core/DragonBones.cpp \
../../../Classes/reader/dragonBones/event/EventObject.cpp \
../../../Classes/reader/dragonBones/factory/BaseFactory.cpp \
../../../Classes/reader/dragonBones/geom/Point.cpp \
../../../Classes/reader/dragonBones/geom/Transform.cpp \
../../../Classes/reader/dragonBones/model/AnimationConfig.cpp \
../../../Classes/reader/dragonBones/model/AnimationData.cpp \
../../../Classes/reader/dragonBones/model/ArmatureData.cpp \
../../../Classes/reader/dragonBones/model/BoundingBoxData.cpp \
../../../Classes/reader/dragonBones/model/CanvasData.cpp \
../../../Classes/reader/dragonBones/model/ConstraintData.cpp \
../../../Classes/reader/dragonBones/model/DisplayData.cpp \
../../../Classes/reader/dragonBones/model/DragonBonesData.cpp \
../../../Classes/reader/dragonBones/model/SkinData.cpp \
../../../Classes/reader/dragonBones/model/TextureAtlasData.cpp \
../../../Classes/reader/dragonBones/model/UserData.cpp \
../../../Classes/reader/dragonBones/parser/BinaryDataParser.cpp \
../../../Classes/reader/dragonBones/parser/DataParser.cpp \
../../../Classes/reader/dragonBones/parser/JSONDataParser.cpp \
../../../Classes/reader/lua-bindings/creator_reader_bindings.cpp \
../../../Classes/reader/lua-bindings/dragonbones/lua_dragonbones_auto.cpp \
../../../Classes/reader/lua-bindings/dragonbones/lua_dragonbones_manual.cpp \
../../../Classes/reader/lua-bindings/reader/lua_creator_reader_auto.cpp \
../../../Classes/reader/lua-bindings/reader/lua_creator_reader_manual.cpp \
../../../Classes/reader/ui/PageView.cpp \
../../../Classes/reader/ui/RichtextStringVisitor.cpp \
../../../Classes/reader/ui/WidgetExport.cpp \
../../../Classes/sqlite3/lsqlite3.c \
../../../Classes/sqlite3/sqlite3.c \
hellolua/main.cpp

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../../Classes \
$(LOCAL_PATH)/../../../Classes/core \
$(LOCAL_PATH)/../../../Classes/core/event \
$(LOCAL_PATH)/../../../Classes/core/io \
$(LOCAL_PATH)/../../../Classes/core/graphics \
$(LOCAL_PATH)/../../../Classes/core/memory \
$(LOCAL_PATH)/../../../Classes/core/net \
$(LOCAL_PATH)/../../../Classes/core/utils \
$(LOCAL_PATH)/../../../Classes/core/lua \
$(LOCAL_PATH)/../../../Classes/reader \
$(LOCAL_PATH)/../../../Classes/reader/collider \
$(LOCAL_PATH)/../../../Classes/reader/animation \
$(LOCAL_PATH)/../../../Classes/reader/dragonbones/cocos2dx \
$(LOCAL_PATH)/../../../Classes/reader/dragonbones/armature \
$(LOCAL_PATH)/../../../Classes/reader/dragonbones/animation \
$(LOCAL_PATH)/../../../Classes/reader/dragonbones/events \
$(LOCAL_PATH)/../../../Classes/reader/dragonbones/factories \
$(LOCAL_PATH)/../../../Classes/reader/dragonbones/core \
$(LOCAL_PATH)/../../../Classes/reader/dragonbones/geom \
$(LOCAL_PATH)/../../../Classes/sqlite3 \
$(LOCAL_PATH)/../../../../cocos2d-x/external/curl/include/android \
$(LOCAL_PATH)/../../../../cocos2d-x/external/pbc \
$(LOCAL_PATH)/../../../../cocos2d-x/external/json \
$(LOCAL_PATH)/../../../../cocos2d-x/tools/simulator/libsimulator/lib/protobuf-lite \
$(LOCAL_PATH)/../../../../cocos2d-x/external/lua/luajit/include \

# _COCOS_HEADER_ANDROID_BEGIN
# _COCOS_HEADER_ANDROID_END

LOCAL_STATIC_LIBRARIES := cocos2d_lua_static
LOCAL_STATIC_LIBRARIES += pbc
LOCAL_STATIC_LIBRARIES += cocos2d_simulator_static

# _COCOS_LIB_ANDROID_BEGIN
# _COCOS_LIB_ANDROID_END

include $(BUILD_SHARED_LIBRARY)

$(call import-add-path, $(LOCAL_PATH)/../../../../cocos2d-x)
$(call import-module, cocos/scripting/lua-bindings/proj.android)
$(call import-module, external/pbc)
$(call import-module, tools/simulator/libsimulator/proj.android)

# _COCOS_LIB_IMPORT_ANDROID_BEGIN
# _COCOS_LIB_IMPORT_ANDROID_END
