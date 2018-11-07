cc.exports.ShaderCache = class("ShaderCache")

local m_sGLProgramStates = {}


ShaderCache.IDS = 
{
	DEFAULT_ID = 1,
	GRAY_ID = 2,
	WATER_WAVE_ID = 3,
	WATER_ID = 4,
	SPINE_GRAY_ID = 5,
	SPRITE_LIGHT_ID = 6,
	PLAYER_LIGHT = 7,
	DES_LIGHT = 8,
	HIGH_LIGHT_ID = 9,
	HIGH_LIGHT2_ID = 10,
	MONSTER_LIGHT_ID = 11,
	CIRCLE_LIGHT_ID = 12,
	
}



function ShaderCache.getInstance()
	if not ShaderCache.s_instance then
		ShaderCache.s_instance = ShaderCache:create()
	end
	return ShaderCache.s_instance
end

function ShaderCache:ctor()

	--m_sGLProgramStates[ShaderCache.IDS.ShaderCache.DEFAULT_ID]  = GLProgramState::getOrCreateWithGLProgramName(cc.GLProgram.SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP)
	m_sGLProgramStates[ShaderCache.IDS.GRAY_ID] = self:createGLProgramStateWithFile("shader/gray.vsh","shader/gray.fsh")
	--m_sGLProgramStates[ShaderCache.RED_LIGHT_ID] = createGLProgramStateWithFile("shader/redLight.vsh","shader/redLight.fsh");
	--m_sGLProgramStates[ShaderCache.GOLD_SKIN_ID] = createGLProgramStateWithFile("shader/player.vsh","shader/playerGoldSkin.fsh");
	--m_sGLProgramStates[ShaderCache.WATER_WAVE_ID] = createGLProgramStateWithFile("shader/WaterWave.vsh","shader/WaterWave.fsh");
	--m_sGLProgramStates[ShaderCache.WATER_ID] = createGLProgramStateWithFile("shader/Water.vsh","shader/Water.fsh");
	--m_sGLProgramStates[ShaderCache.FISH_SHADOW_ID] = createGLProgramStateWithFile("shader/fishShadow3.vsh","shader/fishShadow3.fsh");
	--m_sGLProgramStates[ShaderCache.FISH_DEATH_ID] = createGLProgramStateWithFile("shader/grayDeath.vsh","shader/grayDeath.fsh");
	--m_sGLProgramStates[ShaderCache.FISH_HURT_ID] = createGLProgramStateWithFile("shader/grayDeath.vsh","shader/grayDeath.fsh");
	--m_sGLProgramStates[FL_SHADE_FISH_BLACK_ID] = createGLProgramStateWithFile("shader/fishblack.vsh","shader/fishblack.fsh");
	--m_sGLProgramStates[ShaderCache.SPINE_GRAY_ID] = createGLProgramStateWithFile("shader/spineGray.vsh", "shader/spineGray.fsh");
	m_sGLProgramStates[ShaderCache.IDS.SPRITE_LIGHT_ID] = self:createGLProgramStateWithFile("shader/spriteLight.vsh", "shader/spriteLight.fsh")
	m_sGLProgramStates[ShaderCache.IDS.PLAYER_LIGHT] = self:createGLProgramStateWithFile("shader/playerLight.vsh", "shader/playerLight.fsh")
	m_sGLProgramStates[ShaderCache.IDS.DES_LIGHT] = self:createGLProgramStateWithFile("shader/desLight.vsh", "shader/desLight.fsh")
	m_sGLProgramStates[ShaderCache.IDS.HIGH_LIGHT_ID] = self:createGLProgramStateWithFile("shader/highLight.vsh", "shader/highLight.fsh")
	m_sGLProgramStates[ShaderCache.IDS.HIGH_LIGHT2_ID] = self:createGLProgramStateWithFile("shader/highLight2.vsh", "shader/highLight2.fsh")
	m_sGLProgramStates[ShaderCache.IDS.MONSTER_LIGHT_ID] = self:createGLProgramStateWithFile("shader/monsterLight.vsh", "shader/monsterLight.fsh")
	m_sGLProgramStates[ShaderCache.IDS.CIRCLE_LIGHT_ID] = self:createGLProgramStateWithFile("shader/CircleLight.vsh", "shader/CircleLight.fsh")
	
	
end


function ShaderCache:getGLProgramState( nId)

	local it = m_sGLProgramStates[nId]

	if(it ~= nil) then
		return it
	end
	return nil
end

function  ShaderCache:createGLProgramState(sVerSrc,sFlagSrc)

	--local glprogram = cc.GLProgram:createWithFilenames("shader/gray.vsh","shader/gray.fsh")
	--local glprogramstate = cc.GLProgramState:getOrCreateWithGLProgram(glprogram)

	local glprogram = cc.GLProgram:createWithByteArrays(sVerSrc,sFlagSrc)
	local glprogramstate = cc.GLProgramState:getOrCreateWithGLProgram(glprogram)
	
	return glprogramstate;
end

function  ShaderCache:createGLProgramStateWithFile(sVerFile,sFlagFile)



	local glprogram = cc.GLProgram:createWithFilenames(sVerFile,sFlagFile)
	local glprogramstate = cc.GLProgramState:getOrCreateWithGLProgram(glprogram)

	return glprogramstate
end