
#ifndef __VX_RESOURCE_MANAGER_H__
#define __VX_RESOURCE_MANAGER_H__

#include "VxDef.h"
#include "VxType.h"
#include "network/CCDownloader.h"
#include "VxConst.h"
#include "XGMacros.h"

class VxResourceManager
{
public:

	XG_SINGLET_WITH_INIT_DECLARE(VxResourceManager);

	bool unCompress(const char * pOutFileName, const std::string &password);

	VxResourceManager();
	~VxResourceManager();

	void download(std::string &sUrl, std::string &fileName,bool isUpdateZipFile);
	std::string getUpdatePath();
private:
	void createDownloader();

	std::unique_ptr<network::Downloader> m_downloader;
	std::string m_downloaderPath;
	std::string m_updateZipFile;
};

#endif	// __VX_RESOUCE_MANAGER_H__


