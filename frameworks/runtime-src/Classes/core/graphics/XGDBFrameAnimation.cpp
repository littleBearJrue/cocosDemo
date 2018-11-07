#include "XGDBFrameAnimation.h"
#include "XGXml.h"
#include "VxConvert.h"
/************************************************************************/
/* XGDBFrameAnimation
************************************************************************/
XGDBFrameAnimation::XGDBFrameAnimation()
{

}

XGDBFrameAnimation::~XGDBFrameAnimation()
{
}

/************************************************************************/
/* XGDBPetManager
************************************************************************/

void XGDBFrameAnimationManager::init()
{
	getInstance()->parseXml();
}

void XGDBFrameAnimationManager::release()
{
	pureInstance();
}

XGDBFrameAnimationManager::XGDBFrameAnimationManager()
{

}

XGDBFrameAnimationManager::~XGDBFrameAnimationManager()
{
	for(auto it = m_sAnimationDatas.begin(); it != m_sAnimationDatas.end(); it++)
	{
		CC_SAFE_DELETE(it->second);
	}
	m_sAnimationDatas.clear();
}

void XGDBFrameAnimationManager::addAnimationData(XGDBFrameAnimation* pData)
{
	CCASSERT(pData,"");
	m_sAnimationDatas[pData->m_nId] = pData;
}

XGDBFrameAnimation * XGDBFrameAnimationManager::getAnimationData(int nId)
{
	XGDBFrameAnimation * pRet = NULL;
	auto it = m_sAnimationDatas.find(nId);
	if(it != m_sAnimationDatas.end())
	{
		pRet = it->second;
	}
	return pRet;
}

int XGDBFrameAnimationManager::getAnimationId(const char* sAniName)
{
	for(auto it = m_sAnimationDatas.begin(); it != m_sAnimationDatas.end(); it++)
	{
		if(0 == it->second->m_sName.compare(sAniName))
		{
			return it->first;
		}
	}

	return 0;
}

void XGDBFrameAnimationManager::parseXml()
{

	Data pFileData = FileUtils::getInstance()->getDataFromFile("data/frameAnimation.xml");
    tinyxml2::XMLDocument sXmlDoc;
    sXmlDoc.Parse((char *)pFileData.getBytes());


	//tinyxml2::XMLDocument *pDoc = new tinyxml2::XMLDocument();
	//pDoc->LoadFile(filePath.c_str());

	tinyxml2::XMLElement *pRoot = sXmlDoc.RootElement();


	CCASSERT(pRoot, "frameAnimation xml file is missing");

	TP_FOR_EACH_XML_NAMED_CHILDREN(pAni,pRoot,"animation")
	{
		XGDBFrameAnimation* pData = new XGDBFrameAnimation();
		pData->m_nId = XGXml::getAttrInteger(pAni, "id");
		pData->m_sName = XGXml::getAttrString(pAni, "name");
		pData->m_fDelay = XGXml::getAttrFloat(pAni, "delay");
		pData->m_sAnrPos.x = XGXml::getAttrFloat(pAni, "anrx");
		pData->m_sAnrPos.y = XGXml::getAttrFloat(pAni, "anry");
		pData->m_sPlist = XGXml::getValueString(pAni, "plist");
		pData->m_sPng = XGXml::getValueString(pAni, "png");
		
		xmlNodePtr pFrames = XGXml::getXMLNodeForKey(pAni,"frames");

		TP_FOR_EACH_XML_NAMED_CHILDREN(pFrame,pFrames,"frame")
		{
			pData->m_sFrames.push_back(XGXml::getValueString(pFrame));
		}
		if(m_sAnimationDatas.find(pData->m_nId) != m_sAnimationDatas.end())
		{
			CCASSERT(0,("the same id "+VxConvert::integerToString(pData->m_nId)).c_str());
		}
		m_sAnimationDatas[pData->m_nId] = pData;
	}

}