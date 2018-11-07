
#include "VxFile.h"
#include "VxLocalObject.h"
#include "VxStream.h"
//#include "VxFileDataManager.h"
//#include "VxPath.h"
//#include "VxFileDB.h"

#define __VX_FILE_ENCRYPTION__

#define VXFILE_COPY_FILE_BUFFER_SIZE			(100 * 1024)

/************************************************************************/
/* VxFile
/************************************************************************/
FILE* VxFile::open(const char* pFileName, int nMode)
{
	FILE* pRet = NULL;
	if(VXFILE_OPEN_FLAG_CREATE_ALWAYS & nMode)
	{
		pRet = fopen(pFileName, VXFILE_OPEN_MODE_CREATE_ALWAYS);
	}
	else if(VXFILE_OPEN_FLAG_CREATE & nMode)
	{
		pRet = fopen(pFileName, VXFILE_OPEN_MODE_CREATE);
		if(NULL == pRet)
		{
			pRet = fopen(pFileName, VXFILE_OPEN_MODE_CREATE_ALWAYS);
		}
	}
	else if(VXFILE_OPEN_FLAG_APPEND & nMode)
	{
		pRet = fopen(pFileName, VXFILE_OPEN_MODE_APPEND);
	}
	return pRet;
}

void VxFile::close(FILE* pFileHandle)
{
	fclose(pFileHandle);
}

bool VxFile::createDirEx(const char* pDir)
{
	char* t;
	VxLocalString sLocalT(&t, pDir);

	while (t = strchr(++t, '\\'))
	{
		*t = 0;
		if (VxFile::isDirExist(pDir))
		{
			*t = '\\';
			continue;
		}
		if(!VxFile::createDir(pDir))
		{
			return false;
		}
		*t = '\\';
	}
	return true;
}

bool VxFile::createDir(const char* pDir)
{
#if VX_TARGET_PLATFORM == VX_PLATFORM_WIN32
	return 0 == _mkdir(pDir);
#else
	return 0 == mkdir(pDir, 0777);
#endif
}

bool VxFile::isDirExist(const char* pDir)
{
#if VX_TARGET_PLATFORM == VX_PLATFORM_WIN32
	return 0 == _access(pDir, 0);
#else
	return 0 == access(pDir, 0);
#endif
}

bool VxFile::isFileExist(const char* pFile)
{
#if VX_TARGET_PLATFORM == VX_PLATFORM_WIN32
	return 0 == _access(pFile, 0);
#else
	return 0 == access(pFile, 0);
#endif
}

bool VxFile::fillZeroData(FILE* pFile, int zeroDataSize)
{
	VxFileStream sFile(pFile);
	return sFile.fillZero(zeroDataSize);
}

bool VxFile::write(FILE* pFile, const char* pBuffer, int nSize)
{
	return nSize == fwrite(pBuffer, 1, nSize, pFile);
}

bool VxFile::write(FILE* pFile, int nFilePos, const char* pBuffer, int nSize)
{
	if(0 > fseek(pFile, nFilePos, SEEK_SET))
	{
		return false;
	}
	return write(pFile, pBuffer, nSize);
}

bool VxFile::read(FILE* pFile, char* pBuffer, int nSize)
{
	return nSize == fread(pBuffer, 1, nSize, pFile);
}

bool VxFile::read(FILE* pFile, int nFilePos, char* pBuffer, int nSize)
{
	if(0 > fseek(pFile, nFilePos, SEEK_SET))
	{
		return false;
	}
	return read(pFile, pBuffer, nSize);
}

int VxFile::getFileSize(const char* pFileName)
{
	struct stat file_info;

	if(stat(pFileName, &file_info) == 0) 
	{
		return file_info.st_size;
	}

	return -1;
}

bool VxFile::removeFile(const char* pFileName)
{
#if VX_PLATFORM_WIN32 == VX_TARGET_PLATFORM
	return 0 == _unlink(pFileName);
#else
	return 0 == unlink(pFileName);
#endif
}

bool VxFile::rename(const char* pSrcName, const char* pDstName)
{
	return 0 == std::rename(pSrcName, pDstName);
}

bool VxFile::copy(const char* pSrcFile, const char* pDstFile)
{
	VX_RETURN_VALUE_IF(!VxFile::isFileExist(pSrcFile), false);

	std::string sSrcFile = pSrcFile;
	std::string sDstFile = pDstFile;

	VX_RETURN_VALUE_IF(sSrcFile == sDstFile, true);

	VxFile::removeFile(pDstFile);

	bool bRet = false;

	FILE* pSrcHandle = NULL;
	FILE* pDstHandle = NULL;
	char* pBuffer = NULL;

	do 
	{
		pSrcHandle = VxFile::open(pSrcFile);
		VX_BREAK_IF(!pSrcHandle);

		pDstHandle = VxFile::open(pDstFile);
		VX_BREAK_IF(!pDstHandle);

		pBuffer = new char[VXFILE_COPY_FILE_BUFFER_SIZE];
		VX_BREAK_IF(!pBuffer);

		bRet = true;

		int nReadSize, nWriteSize;
		while(0 < (nReadSize = fread(pBuffer, 1, VXFILE_COPY_FILE_BUFFER_SIZE, pSrcHandle)))
		{
			nWriteSize = fwrite(pBuffer, 1, nReadSize, pDstHandle);
			if(nReadSize != nWriteSize)
			{
				VXLOG("VxFile::copy, error, read size = %d, write size = %d", nReadSize, nWriteSize);
				bRet = false;
				break;
			}
		}

	} while (0);

	if(!bRet)
	{
		VXLOG("VxFile::copy, error, src = %s", pSrcFile);
		VXLOG("VxFile::copy, error, dst = %s", pDstFile);
	}

	VX_SAFE_CLOSE_FILE(pSrcHandle);
	VX_SAFE_CLOSE_FILE(pDstHandle);
	VX_SAFE_DELETE_ARRAY(pBuffer);

	return bRet;
}

bool VxFile::move(const char* pSrcFile, const char* pDstFile)
{
	VX_RETURN_VALUE_IF(!VxFile::isFileExist(pSrcFile), false);

	std::string sSrcFile = pSrcFile;
	std::string sDstFile = pDstFile;
	
	VX_RETURN_VALUE_IF(sSrcFile == sDstFile, true);

	VxFile::removeFile(pDstFile);

	sSrcFile = sSrcFile.substr(0, sSrcFile.find(VXPATH_SEPERATOR));
	sDstFile = sDstFile.substr(0, sDstFile.find(VXPATH_SEPERATOR));
	if(sSrcFile == sDstFile)
	{
		return VxFile::rename(pSrcFile, pDstFile);
	}
	else
	{
		bool bRet = VxFile::copy(pSrcFile, pDstFile);
		if(bRet)
		{
			VxFile::removeFile(pSrcFile);
		}
		return bRet;
	}
}


