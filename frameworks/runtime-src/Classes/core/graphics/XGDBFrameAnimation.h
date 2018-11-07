#ifndef __XG_DBFRAME_ANIMATION_H__
#define __XG_DBFRAME_ANIMATION_H__

#include "XGMacros.h"



class XGDBFrameAnimation: public cocos2d::Ref
{
public:
	XGDBFrameAnimation();
	~XGDBFrameAnimation();
public:
	int m_nId;
	float m_fDelay;
	Point m_sAnrPos;
	std::string m_sName;
	std::string m_sPlist;
	std::string m_sPng;
	std::vector<std::string> m_sFrames;
};

class XGDBFrameAnimationManager
{
public:
	XG_SINGLET_DECLARE(XGDBFrameAnimationManager);
	static void init();
	static void release();

	int getAnimationId(const char* sAniName);

	void parseXml();

	void addAnimationData(XGDBFrameAnimation* pData);
	XGDBFrameAnimation * getAnimationData(int nId);
	XGDBFrameAnimationManager();
	~XGDBFrameAnimationManager();
protected:
	std::unordered_map<int, XGDBFrameAnimation*> m_sAnimationDatas;
};



#endif//__XG_DBFRAME_ANIMATION_H__