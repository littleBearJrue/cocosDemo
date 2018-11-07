cc.exports.index_begin = 1
cc.exports.getIndex = function()
    cc.exports.index_begin = cc.exports.index_begin + 1
    return cc.exports.index_begin
end

 cc.exports.isTableNilOrEmpty  = function(tab)
    if (tab and type(tab) == "table" and next(tab) ~= nil) then
        return false;
    else
        return true;
    end
end



 cc.exports.Transition_Table =
{
    CCTransitionJumpZoom = 0,
    CCTransitionProgressRadialCCW = 1,
    CCTransitionProgressRadialCW = 2,
    CCTransitionProgressHorizontal = 3,
    CCTransitionProgressVertical = 4,
    CCTransitionProgressInOut = 5,
    CCTransitionProgressOutIn = 6,
    CCTransitionCrossFade = 7,
    TransitionPageForward = 8,
    TransitionPageBackward = 9,
    CCTransitionFadeTR = 10,
    CCTransitionFadeBL = 11,
    CCTransitionFadeUp = 12,
    CCTransitionFadeDown = 13,
    CCTransitionTurnOffTiles = 14,
    CCTransitionSplitRows = 15,
    CCTransitionSplitCols = 16,
    CCTransitionFade = 17,
    FadeWhiteTransition =  18,
    FlipXLeftOver = 19,
    FlipXRightOver = 20,
    FlipYUpOver = 21,
    FlipYDownOver = 22,
    FlipAngularLeftOver = 23,
    FlipAngularRightOver = 24,
    ZoomFlipXLeftOver = 25,
    ZoomFlipXRightOver = 26,
    ZoomFlipYUpOver = 27,
    ZoomFlipYDownOver = 28,
    ZoomFlipAngularLeftOver = 29,
    ZoomFlipAngularRightOver = 30,
    CCTransitionShrinkGrow = 31,
    CCTransitionRotoZoom = 32,
    CCTransitionMoveInL = 33,
    CCTransitionMoveInR = 34,
    CCTransitionMoveInT = 35,
    CCTransitionMoveInB = 36,
    CCTransitionSlideInL = 37,
    CCTransitionSlideInR = 38,
    CCTransitionSlideInT = 39,
    CCTransitionSlideInB = 40,

}

require "framework.base.Functions"
require "framework.sys.NativeCall"
require "framework.base.Delegate"
-- cc.exports.LogicSys = (require "framework.event.LogicSys"):create()
-- cc.exports.ViewSys = (require "framework.event.ViewSys"):create()
-- cc.exports.NetSys = (require "framework.event.NetSys"):create()
-- cc.exports.NodeUtils = require("framework.utils.NodeUtils")
require("framework.graphics.ShaderCache")
require("framework.media.SoundManager")

