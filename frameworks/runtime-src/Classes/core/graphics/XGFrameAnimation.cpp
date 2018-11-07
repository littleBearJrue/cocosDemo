#include "XGFrameAnimation.h"
#include "XGDBFrameAnimation.h"


XGFrameAnimation* XGFrameAnimation::create(int nAnimationId,bool bLoop)
{
	XGFrameAnimation* pRet = new XGFrameAnimation();
	if(pRet && pRet->init(nAnimationId, bLoop))
	{
		pRet->autorelease();
	}
	else
	{
		CC_SAFE_DELETE(pRet);
	}
	return pRet;
}

XGFrameAnimation::XGFrameAnimation()
	: m_nAnimationId(0)
	, m_pData(nullptr)
{

}

XGFrameAnimation::~XGFrameAnimation()
{

}


bool XGFrameAnimation::init(int nAnimationId, bool bLoop)
{
	m_nAnimationId = nAnimationId;

	m_pData = XGDBFrameAnimationManager::getInstance()->getAnimationData(m_nAnimationId);

	int count = m_pData->m_sFrames.size();
	Vector<SpriteFrame *> frames(count);

	if(!SpriteFrameCache::getInstance()->spriteFrameByName(m_pData->m_sFrames[0].c_str()))
	{
		SpriteFrameCache::getInstance()->addSpriteFramesWithFile(m_pData->m_sPlist.c_str());

		Director::getInstance()->getTextureCache()->addImage(m_pData->m_sPng.c_str());
	}

	for (int i = 0; i < count; i++)
	{
		SpriteFrame *frame = SpriteFrameCache::getInstance()->spriteFrameByName(m_pData->m_sFrames[i].c_str());
		frames.pushBack(frame);
	}

	return initWithAnimation(Animation::createWithSpriteFrames(frames, m_pData->m_fDelay));
}


CCSprite* XGFrameAnimation::playFrameAnimation(Node* pParent, const Point &sPoint, int nId, bool bLoop,CallFunc* pCallBack)
{
	CCSprite *pSprite = CCSprite::create();
	XGFrameAnimation* pFrameAni = XGFrameAnimation::create(nId);
	SpriteFrame* pSpriteFrame = (pFrameAni->getAnimation()->getFrames().at(0))->getSpriteFrame();
	pSprite->setSpriteFrame(pSpriteFrame);

	ActionInterval *pSequence;//
	if (bLoop)
	{
		pSequence = RepeatForever::create(pFrameAni);
	}
	else
	{
		if (pCallBack)
		{
			pSequence = CCSequence::create(pFrameAni, pCallBack, NULL);
		}
		else
		{
			pSequence = CCSequence::create(pFrameAni, CallFunc::create(pSprite, callfunc_selector(CCSprite::removeFromParent)), NULL);
		}
		
	}
	pSprite->setAnchorPoint(pFrameAni->m_pData->m_sAnrPos);
	pSprite->runAction(pSequence);
	pSprite->setPosition(sPoint);
	pParent->addChild(pSprite);
	return pSprite;
}