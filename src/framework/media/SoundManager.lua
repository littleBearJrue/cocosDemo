
cc.exports.SoundManager = {}

function SoundManager:playMusic(filePath,isLoop)
	 AudioEngine.playMusic(filePath, isLoop)
end

function SoundManager:stopMusic()
	AudioEngine.stopMusic()
end

function SoundManager:pauseMusic()
	AudioEngine.pauseMusic()
end

function SoundManager:resumeMusic()
	AudioEngine.resumeMusic()
end

function SoundManager:rewindMusic()
	AudioEngine.rewindMusic()
end

function SoundManager:isMusicPlaying()
	return AudioEngine.isMusicPlaying()
end

function SoundManager:playEffect(filePath,isLoop)
	return AudioEngine.playEffect(filePath,isLoop)
end

function SoundManager:stopEffect(effectId)
	AudioEngine.stopEffect(effectId)
end

function SoundManager:pauseEffect(effectId)
	AudioEngine.pauseEffect(effectId)
end

function SoundManager:resumeEffect(effectId)
	AudioEngine.resumeEffect(effectId)
end

function SoundManager:pauseAllEffects(effectId)
	AudioEngine.pauseAllEffects(effectId)
end

function SoundManager:stopAllEffects(effectId)
	AudioEngine.stopAllEffects(effectId)
end

function SoundManager:unloadEffect(filePath)
	AudioEngine.unloadEffect(filePath)
end

function SoundManager:setMusicVolume(volume)
	AudioEngine.setMusicVolume(volume)
end

function SoundManager:getMusicVolume()
	return AudioEngine.getMusicVolume()
end
        
function SoundManager:setEffectsVolume(volume)
	AudioEngine.setEffectsVolume(volume)
end

function SoundManager:getEffectsVolume()
	return AudioEngine.getEffectsVolume()
end
 
function SoundManager:preloadMusic(filePath)
	return AudioEngine.preloadMusic(filePath)
end  

function SoundManager:preloadEffect(filePath)
	return AudioEngine.preloadEffect(filePath)
end 

        