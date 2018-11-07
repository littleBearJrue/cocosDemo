#include "VxExternal.h"
#include "VxAllocator.h"


/************************************************************************/
/* VxAlloc
/************************************************************************/
VxAllocator* VxAlloc::s_alloc;

void* VxAlloc::alloc(int size)
{
	return s_alloc->alloc(size);
}

void VxAlloc::free(void** p, int size)
{
	s_alloc->free(p, size);
}

void VxAlloc::setAlloc(VxAllocator* alloc)
{
	s_alloc = alloc;
}


/************************************************************************/
/* VxAllocator
/************************************************************************/
class VxMemInfo
{
public:
	int m_id;
	void* m_pMemPtr;
	int m_nMemSize;
};

#define VX_MEM_INFO_MAXCOUNT		1000000
static VxMemInfo s_pMemInfos[VX_MEM_INFO_MAXCOUNT];
static int s_nMemInfoId;

VxAllocator::~VxAllocator()
{
	//this->show();
	//this->release();
}

void VxAllocator::init()
{

}

void* VxAllocator::alloc(int size)
{
	void* pRet = new char[size];
	if(pRet)
	{
		for(int i = 0; i < VX_MEM_INFO_MAXCOUNT; ++i)
		{
			if(!s_pMemInfos[i].m_pMemPtr)
			{
				s_pMemInfos[i].m_pMemPtr = pRet;
				s_pMemInfos[i].m_nMemSize = size;
				s_pMemInfos[i].m_id = ++s_nMemInfoId;
				break;
			}
		}
	}
	return pRet;
}

void VxAllocator::free(void** ptr, int size)
{
	if(*ptr)
	{
		for(int i = 0; i < VX_MEM_INFO_MAXCOUNT; ++i)
		{
			if(s_pMemInfos[i].m_pMemPtr == *ptr)
			{
				s_pMemInfos[i].m_pMemPtr = NULL;
				break;
			}
		}
	}
	delete[] (char*)(*ptr);
}

void VxAllocator::clear()
{

}

void VxAllocator::release()
{

}

void VxAllocator::show()
{
	int nCount = 0;
	for(int i = 0; i < VX_MEM_INFO_MAXCOUNT; ++i)
	{
		if(s_pMemInfos[i].m_pMemPtr)
		{
			printf("id=%d, size=%d, ptr=0x%x\n", s_pMemInfos[i].m_id, s_pMemInfos[i].m_nMemSize, s_pMemInfos[i].m_pMemPtr);
			++nCount;
		}
	}

//	VXLOG("VxAllocator::show, count = %d, s_nMemInfoId = %d", nCount, s_nMemInfoId);
}
