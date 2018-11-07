
#include "VxResourceManager.h"
#include "XGCCallLuaManager.h"

#ifdef MINIZIP_FROM_SYSTEM
#include <minizip/unzip.h>
#else // from our embedded sources
#include "unzip.h"
#endif

#define BUFFER_SIZE    8192
#define MAX_FILENAME   512

USING_NS_CC;

VxResourceManager::VxResourceManager()
{
	m_downloader.reset(new network::Downloader());
	this->createDownloader();
	std::string  writeablePath = FileUtils::getInstance()->getWritablePath();
	m_downloaderPath = writeablePath + "/update/";
	m_updateZipFile = "temp_update.zip";

	if (FileUtils::getInstance()->isFileExist(m_downloaderPath + m_updateZipFile))

	{
		this->unCompress((m_downloaderPath + m_updateZipFile).c_str(), "");
	}
	
}

VxResourceManager::~VxResourceManager()
{

}

std::string VxResourceManager::getUpdatePath()
{
	return m_downloaderPath;
}

void VxResourceManager::download(std::string &sUrl,std::string &fileName, bool isUpdateZipFile)
{
	if (isUpdateZipFile)
	{
		fileName = m_updateZipFile;
	}

	this->m_downloader->createDownloadFileTask(sUrl, m_downloaderPath+ fileName, fileName);
}


void VxResourceManager::createDownloader()
{
	// define progress callback
	m_downloader->onTaskProgress = [this](const network::DownloadTask& task,
		int64_t bytesReceived,
		int64_t totalBytesReceived,
		int64_t totalBytesExpected)
	{
		/*Node* view = this->getChildByName(task.identifier);
		auto bar = (ui::LoadingBar*)view->getChildByTag(TAG_PROGRESS_BAR);
		float percent = float(totalBytesReceived * 100) / totalBytesExpected;
		bar->setPercent(percent);
		char buf[32];
		sprintf(buf, "%.1f%%[total %d KB]", percent, int(totalBytesExpected / 1024));
		auto status = (Label*)view->getChildByTag(TAG_STATUS);
		status->setString(buf);*/
		XGCCallLuaManager::getInstance()->downloaderOnTaskProgress(task.identifier, bytesReceived, totalBytesReceived, totalBytesExpected);
	};

	// define success callback
	m_downloader->onDataTaskSuccess = [this](const cocos2d::network::DownloadTask& task,
		std::vector<unsigned char>& data)
	{
		XGCCallLuaManager::getInstance()->downloaderOnDataTaskSuccess(task.identifier, data.data(), data.size());

	};

	m_downloader->onFileTaskSuccess = [this](const cocos2d::network::DownloadTask& task)
	{
		XGCCallLuaManager::getInstance()->downloaderOnFileTaskSuccess(task.identifier);
		
	};

	// define failed callback
	m_downloader->onTaskError = [this](const cocos2d::network::DownloadTask& task,
		int errorCode,
		int errorCodeInternal,
		const std::string& errorStr)
	{
		XGCCallLuaManager::getInstance()->downloaderOnTaskError(task.identifier, errorCode, errorCodeInternal, errorStr);
	};
}

bool VxResourceManager::unCompress(const char * pOutFileName, const std::string &password)
{
	if (!pOutFileName) {
		CCLOG("unCompress() - invalid arguments");
		return 0;
	}
	FileUtils *utils = FileUtils::getInstance();
	std::string outFileName = utils->fullPathForFilename(pOutFileName);
	// ��ѹ���ļ�  
	unzFile zipfile = unzOpen(outFileName.c_str());
	if (!zipfile)
	{
		CCLOG("can not open downloaded zip file %s", outFileName.c_str());
		return false;
	}
	// ��ȡzip�ļ���Ϣ  
	unz_global_info global_info;
	if (unzGetGlobalInfo(zipfile, &global_info) != UNZ_OK)
	{
		CCLOG("can not read file global info of %s", outFileName.c_str());
		unzClose(zipfile);
		return false;
	}
	// ��ʱ���棬���ڴ�zip�ж�ȡ���ݣ�Ȼ�����ݸ���ѹ����ļ�  
	char readBuffer[BUFFER_SIZE];
	//��ʼ��ѹ��  
	CCLOG("start uncompressing");
	//�����Լ�ѹ����ʽ�޸��ļ��еĴ�����ʽ  
	std::string storageDir;
	int pos = outFileName.find_last_of("/");
	storageDir = outFileName.substr(0, pos);
	//    FileUtils::getInstance()->createDirectory(storageDir);  

	// ѭ����ȡѹ�������ļ�  
	// global_info.number_entryΪѹ�������ļ�����  
	uLong i;
	for (i = 0; i < global_info.number_entry; ++i)
	{
		// ��ȡѹ�����ڵ��ļ���  
		unz_file_info fileInfo;
		char fileName[MAX_FILENAME];
		if (unzGetCurrentFileInfo(zipfile,
			&fileInfo,
			fileName,
			MAX_FILENAME,
			NULL,
			0,
			NULL,
			0) != UNZ_OK)
		{
			CCLOG("can not read file info");
			unzClose(zipfile);
			return false;
		}

		//���ļ����·��  
		std::string fullPath = storageDir + "/" + fileName;

		// ���·�����ļ��л����ļ�  
		const size_t filenameLength = strlen(fileName);
		if (fileName[filenameLength - 1] == '/')
		{
			// ���ļ���һ���ļ��У���ô�ʹ�����  
			if (!FileUtils::getInstance()->createDirectory(fullPath.c_str()))
			{
				CCLOG("can not create directory %s", fullPath.c_str());
				unzClose(zipfile);
				return false;
			}
		}
		else
		{
			// ���ļ���һ���ļ�����ô����ȡ������  
			if (password.empty())
			{
				if (unzOpenCurrentFile(zipfile) != UNZ_OK)
				{
					CCLOG("can not open file %s", fileName);
					unzClose(zipfile);
					return false;
				}
			}
			else
			{
				if (unzOpenCurrentFilePassword(zipfile, password.c_str()) != UNZ_OK)
				{
					CCLOG("can not open file %s", fileName);
					unzClose(zipfile);
					return false;
				}
			}

			// ����Ŀ���ļ�  
			FILE *out = fopen(fullPath.c_str(), "wb");
			if (!out)
			{
				CCLOG("can not open destination file %s", fullPath.c_str());
				unzCloseCurrentFile(zipfile);
				unzClose(zipfile);
				return false;
			}

			// ��ѹ���ļ�����д��Ŀ���ļ�  
			int error = UNZ_OK;
			do
			{
				error = unzReadCurrentFile(zipfile, readBuffer, BUFFER_SIZE);
				if (error < 0)
				{
					CCLOG("can not read zip file %s, error code is %d", fileName, error);
					unzCloseCurrentFile(zipfile);
					unzClose(zipfile);
					return false;
				}
				if (error > 0)
				{
					fwrite(readBuffer, error, 1, out);
				}
			} while (error > 0);

			fclose(out);
		}
		//�رյ�ǰ����ѹ�����ļ�  
		unzCloseCurrentFile(zipfile);

		// ���zip�ڻ��������ļ����򽫵�ǰ�ļ�ָ��Ϊ��һ������ѹ���ļ�  
		if ((i + 1) < global_info.number_entry)
		{
			if (unzGoToNextFile(zipfile) != UNZ_OK)
			{
				CCLOG("can not read next file");
				unzClose(zipfile);
				return false;
			}
		}
	}
	//ѹ�����  
	CCLOG("end uncompressing");

	//ѹ�����ɾ��zip�ļ���ɾ��ǰҪ�ȹر�  
	unzClose(zipfile);
	if (remove(outFileName.c_str()) != 0)
	{
		CCLOG("can not remove downloaded zip file %s", outFileName.c_str());
	}
	return true;
}