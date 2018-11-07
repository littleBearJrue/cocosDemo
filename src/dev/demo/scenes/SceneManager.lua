require "dev.demo.scenes.Scene"
local SceneWelcome = require "dev.demo.scenes.welcome.SceneWelcome"
local SceneLogin = require "dev.demo.scenes.login.SceneLogin"
--local SceneTest = require "dev.demo.scenes.test.SceneTest"



require "dev.demo.scenes.layers.LayerManager"


cc.exports.SceneManager = class("SceneManager")

local director = cc.Director:getInstance()

function SceneManager.getInstance()
	if not SceneManager.s_instance then
		SceneManager.s_instance = SceneManager.create()
	end
	return SceneManager.s_instance
end

function SceneManager:ctor()

    self.m_firstEnter  = true
    self:init()
    LayerManager.getInstance()
    if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(true)
    end
end

function SceneManager:init()
    --NxLayerManager.init();
	LogicSys:regEventHandler(LogicEvent.EVENT_SCENE_ENTER, SceneManager.onSceneEnter, self);
	LogicSys:regEventHandler(LogicEvent.EVENT_SCENE_EXIT, SceneManager.onSceneExit, self);
	LogicSys:regEventHandler(LogicEvent.EVENT_SCENE_CHANGE, SceneManager.onSceneChange, self);
	LogicSys:regEventHandler(LogicEvent.EVENT_SCENE_RESUME, SceneManager.onSceneResume, self);
	LogicSys:regEventHandler(LogicEvent.EVENT_SCENE_PAUSE, SceneManager.onScenePause, self);
	LogicSys:regEventHandler(LogicEvent.EVENT_SCENE_TOBERUN, SceneManager.onSceneToBeRun, self);
end

function SceneManager:release()

	--removeScene(getSceneCount());

   -- NxLayerManager.releaseEx();

	LogicSys:unregEventHandler(LogicEvent.EVENT_SCENE_ENTER, SceneManager.onSceneEnter, self);
	LogicSys:unregEventHandler(LogicEvent.EVENT_SCENE_EXIT, SceneManager.onSceneExit, self);
	LogicSys:unregEventHandler(LogicEvent.EVENT_SCENE_CHANGE, SceneManager.onSceneChange, self);
	LogicSys:unregEventHandler(LogicEvent.EVENT_SCENE_RESUME, SceneManager.onSceneResume, self);
	LogicSys:unregEventHandler(LogicEvent.EVENT_SCENE_PAUSE, SceneManager.onScenePause, self);
	LogicSys:unregEventHandler(LogicEvent.EVENT_SCENE_TOBERUN, SceneManager.onSceneToBeRun, self);
end

function SceneManager:getCurrentScene()
	return director:getRunningScene()
end

function SceneManager:isCurrentScene(nSceneId)

	local pScene = self:getCurrentScene()
	if pScene == nil then
        return false
    end
	return pScene:getSceneId() == nSceneId
end

function SceneManager:getColliderManager()
    return self.m_colliderManager
end

function SceneManager:setColliderManager(colliderManager)
    self.m_colliderManager = colliderManager
end


function SceneManager:createScene( nSceneId,data)

	local pScene = nil;
	repeat

        local nSceneType = nSceneId

       
       if nSceneType == Scene.XG_SCENE_WELCOME then

			pScene = self:createTransition(Transition_Table.CCTransitionJumpZoom,2.0,SceneWelcome:create(data))

		elseif nSceneType == Scene.XG_SCENE_UPDATE then
		
		elseif nSceneType == Scene.XG_SCENE_LOGIN then
			pScene = self:createTransition(Transition_Table.CCTransitionFade,2.0,SceneLogin:create(data) )
		
        end

	 until true 

	return pScene
end


-----------------------------
-- Create Transition
-----------------------------
function SceneManager:createTransition(transitionType, t, scene)
    --cc.Director:getInstance():setDepthTest(false)
    if self.m_firstEnter == true then
        self.m_firstEnter  = false
        return scene
    end

    if transitionType == Transition_Table.CCTransitionJumpZoom then
        scene = cc.TransitionJumpZoom:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionProgressRadialCCW then
        scene = cc.TransitionProgressRadialCCW:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionProgressRadialCW then
        scene = cc.TransitionProgressRadialCW:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionProgressHorizontal then
        scene = cc.TransitionProgressHorizontal:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionProgressVertical then
        scene = cc.TransitionProgressVertical:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionProgressInOut then
        scene = cc.TransitionProgressInOut:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionProgressOutIn then
        scene = cc.TransitionProgressOutIn:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionCrossFade then
        scene = cc.TransitionCrossFade:create(t, scene)
    elseif transitionType == Transition_Table.TransitionPageForward then
        cc.Director:getInstance():setDepthTest(true)
        scene = cc.TransitionPageTurn:create(t, scene, false)
    elseif transitionType == Transition_Table.TransitionPageBackward then
        cc.Director:getInstance():setDepthTest(true)
        scene = cc.TransitionPageTurn:create(t, scene, true)
    elseif transitionType == Transition_Table.CCTransitionFadeTR then
        scene = cc.TransitionFadeTR:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionFadeBL then
        scene = cc.TransitionFadeBL:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionFadeUp then
        scene = cc.TransitionFadeUp:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionFadeDown then
        scene = cc.TransitionFadeDown:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionTurnOffTiles then
        scene = cc.TransitionTurnOffTiles:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionSplitRows then
        scene = cc.TransitionSplitRows:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionSplitCols then
        scene = cc.TransitionSplitCols:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionFade then
        scene = cc.TransitionFade:create(t, scene)
    elseif transitionType == Transition_Table.FadeWhiteTransition then
        scene = cc.TransitionFade:create(t, scene, cc.c3b(255, 255, 255))
    elseif transitionType == Transition_Table.FlipXLeftOver then
        scene = cc.TransitionFlipX:create(t, scene, cc.TRANSITION_ORIENTATION_LEFT_OVER )
    elseif transitionType == Transition_Table.FlipXRightOver then
        scene = cc.TransitionFlipX:create(t, scene, cc.TRANSITION_ORIENTATION_RIGHT_OVER )
    elseif transitionType == Transition_Table.FlipYUpOver then
        scene = cc.TransitionFlipY:create(t, scene, cc.TRANSITION_ORIENTATION_UP_OVER)
    elseif transitionType == Transition_Table.FlipYDownOver then
        scene = cc.TransitionFlipY:create(t, scene, cc.TRANSITION_ORIENTATION_DOWN_OVER )
    elseif transitionType == Transition_Table.FlipAngularLeftOver then
        scene = cc.TransitionFlipAngular:create(t, scene, cc.TRANSITION_ORIENTATION_LEFT_OVER )
    elseif transitionType == Transition_Table.FlipAngularRightOver then
        scene = cc.TransitionFlipAngular:create(t, scene, cc.TRANSITION_ORIENTATION_RIGHT_OVER )
    elseif transitionType == Transition_Table.ZoomFlipXLeftOver then
        scene = cc.TransitionZoomFlipX:create(t, scene, cc.TRANSITION_ORIENTATION_LEFT_OVER )
    elseif transitionType == Transition_Table.ZoomFlipXRightOver then
        scene = cc.TransitionZoomFlipX:create(t, scene, cc.TRANSITION_ORIENTATION_RIGHT_OVER )
    elseif transitionType == Transition_Table.ZoomFlipYUpOver then
        scene = cc.TransitionZoomFlipY:create(t, scene, cc.TRANSITION_ORIENTATION_UP_OVER)
    elseif transitionType == Transition_Table.ZoomFlipYDownOver then
        scene = cc.TransitionZoomFlipY:create(t, scene, cc.TRANSITION_ORIENTATION_DOWN_OVER )
    elseif transitionType == Transition_Table.ZoomFlipAngularLeftOver then
        scene = cc.TransitionZoomFlipAngular:create(t, scene, cc.TRANSITION_ORIENTATION_LEFT_OVER )
    elseif transitionType == Transition_Table.ZoomFlipAngularRightOver then
        scene = cc.TransitionZoomFlipAngular:create(t, scene, cc.TRANSITION_ORIENTATION_RIGHT_OVER )
    elseif transitionType == Transition_Table.CCTransitionShrinkGrow then
        scene = cc.TransitionShrinkGrow:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionRotoZoom then
        scene = cc.TransitionRotoZoom:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionMoveInL then
        scene = cc.TransitionMoveInL:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionMoveInR then
        scene = cc.TransitionMoveInR:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionMoveInT then
        scene = cc.TransitionMoveInT:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionMoveInB then
        scene = cc.TransitionMoveInB:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionSlideInL then
        scene = cc.TransitionSlideInL:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionSlideInR then
        scene = cc.TransitionSlideInR:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionSlideInT then
        scene = cc.TransitionSlideInT:create(t, scene)
    elseif transitionType == Transition_Table.CCTransitionSlideInB then
        scene = cc.TransitionSlideInB:create(t, scene)
    end

    return scene
end


function  SceneManager:destroyScene( pScene)

	if (pScene) then
		--pScene->onDestroy()
	end
end

function SceneManager:runScene( pScene)

	local pOldScene = director:getRunningScene()

	if( pOldScene == nil ) then
		director:runWithScene(pScene)
    elseif ( pScene ~= pOldScene) then
        deleteWithChildren(pOldScene)
		director:replaceScene(pScene)
	end
	
end


function SceneManager:onSceneEnter(nSceneId,data)
    local scene = self:createScene(nSceneId,data)
    self:runScene(scene)
end

return SceneManager 