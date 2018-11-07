#ifndef __XG_FRAME_ANIMATION_H__
#define __XG_FRAME_ANIMATION_H__

#include "XGMacros.h"

class XGDBFrameAnimation;

class XGFrameAnimation : public cocos2d::Animate
{
public:
	static XGFrameAnimation* create(int nAnimationId,bool bLoop=false);

	XGFrameAnimation();
	~XGFrameAnimation();

	bool init(int nAnimationId, bool bLoop=false);
	int getAnimationId() { return m_nAnimationId; }

	static CCSprite* playFrameAnimation(Node* pParent, const Point &sPoint, int nId, bool bLoop = false, CallFunc* pCallBack = NULL);
protected:
	int m_nAnimationId;
	XGDBFrameAnimation *m_pData;
};

#endif // __XG_FRAME_ANIMATION_H__