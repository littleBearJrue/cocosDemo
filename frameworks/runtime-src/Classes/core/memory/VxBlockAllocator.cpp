
#include "VxBlockAllocator.h"
#include "VxLocalObject.h"
#include <mutex>
#include <thread>

/************************************************************************/
/* VxBlockAllocator
/************************************************************************/
int VxBlockAllocator::s_blockSizes[VXMEMORY_BLOCKALLOC_BLOCKSIZES] = 
{
	16,		// 0
	32,		// 1
	64,		// 2
	96,		// 3
	128,	// 4
	160,	// 5
	192,	// 6
	224,	// 7
	256,	// 8
	320,	// 9
	384,	// 10
	448,	// 11
	512,	// 12
	640,	// 13
};

int VxBlockAllocator::s_blockSizeLookup[VXMEMORY_BLOCKALLOC_MAXBLOCKSIZE + 1];
bool VxBlockAllocator::s_blockSizeLookupInitialized;

static std::mutex s_mutex;

struct VxChunk
{
	int blockSize;
	VxBlock* blocks;
};

struct VxBlock
{
	VxBlock* next;
};


VxBlockAllocator::VxBlockAllocator()
{
}

void VxBlockAllocator::init()
{
	//CCASSERT(VXMEMORY_BLOCKALLOC_BLOCKSIZES < 0xFF, "VXMEMORY_BLOCKALLOC_BLOCKSIZES = %d", VXMEMORY_BLOCKALLOC_BLOCKSIZES);

	m_chunkSpace = VXMEMORY_BLOCKALLOC_CHUNKARRAYINCRESMENT;
	m_chunkCount = 0;
	m_chunks = (VxChunk*)new char[(m_chunkSpace * sizeof(VxChunk))];
	if(!m_chunks)
	{
		return;
	}

	memset(m_chunks, 0, m_chunkSpace * sizeof(VxChunk));
	memset(m_freeLists, 0, sizeof(m_freeLists));

	if (s_blockSizeLookupInitialized == false)
	{
		int j = 0;
		for (int i = 1; i <= VXMEMORY_BLOCKALLOC_MAXBLOCKSIZE; ++i)
		{
			//CCASSERT(j < VXMEMORY_BLOCKALLOC_BLOCKSIZES, "j = %d, VXMEMORY_BLOCKALLOC_BLOCKSIZES = %d", j, VXMEMORY_BLOCKALLOC_BLOCKSIZES);
			if (i <= s_blockSizes[j])
			{
				s_blockSizeLookup[i] = j;
			}
			else
			{
				++j;
				s_blockSizeLookup[i] = j;
			}
		}

		s_blockSizeLookupInitialized = true;
	}

	//VxMutexManager::create(&s_mutex);
}

void VxBlockAllocator::release()
{
	//VxMutexManager::destroy(&s_mutex);
	this->clear();
	for (int i = 0; i < m_chunkCount; ++i)
	{
		VX_SAFE_DELETE_ARRAY(m_chunks[i].blocks);
	}

	VX_SAFE_DELETE_ARRAY(m_chunks);
}


VxBlockAllocator::~VxBlockAllocator()
{
	this->release();
}

void* VxBlockAllocator::alloc(int size)
{
	if (size == 0)
		return NULL;

	//CCASSERT(0 < size, "size = %d", size);

	if (size > VXMEMORY_BLOCKALLOC_MAXBLOCKSIZE)
	{
		return new char[size];
	}

	int index = s_blockSizeLookup[size];
	//CCASSERT(0 <= index && index < VXMEMORY_BLOCKALLOC_BLOCKSIZES, "index = %d, VXMEMORY_BLOCKALLOC_BLOCKSIZES = %d", index, VXMEMORY_BLOCKALLOC_BLOCKSIZES);

	//VxLocalMutex sLocalMutex(&s_mutex);
	std::lock_guard<std::mutex> lk(s_mutex);
	if (m_freeLists[index])
	{
		VxBlock* block = m_freeLists[index];
		m_freeLists[index] = block->next;
		return block;
	}
	else
	{
		if (m_chunkCount == m_chunkSpace)
		{
			VxChunk* oldChunks = m_chunks;
			m_chunkSpace += VXMEMORY_BLOCKALLOC_CHUNKARRAYINCRESMENT;
			m_chunks = (VxChunk*)new char[m_chunkSpace * sizeof(VxChunk)];
			if(NULL == m_chunks)
			{
				m_chunks = oldChunks;
				return NULL;
			}
			memcpy(m_chunks, oldChunks, m_chunkCount * sizeof(VxChunk));
			memset(m_chunks + m_chunkCount, 0, VXMEMORY_BLOCKALLOC_CHUNKARRAYINCRESMENT * sizeof(VxChunk));
			VX_SAFE_DELETE_ARRAY(oldChunks);
		}

		VxChunk* chunk = m_chunks + m_chunkCount;
		chunk->blocks = (VxBlock*)new char[VXMEMORY_BLOCKALLOC_CHUNKSIZE];
		if(!chunk->blocks)
		{
			return NULL;
		}
		int blockSize = s_blockSizes[index];
		chunk->blockSize = blockSize;
		int blockCount = VXMEMORY_BLOCKALLOC_CHUNKSIZE / blockSize;
		//CCASSERT(blockCount * blockSize <= VXMEMORY_BLOCKALLOC_CHUNKSIZE, "blockCount = %d, blockSize = %d, Vx_chunkSize = %d", blockCount, blockSize, VXMEMORY_BLOCKALLOC_CHUNKSIZE);
		for (int i = 0; i < blockCount - 1; ++i)
		{
			VxBlock* block = (VxBlock*)(((char*)chunk->blocks) + blockSize * i);
			VxBlock* next = (VxBlock*)(((char*)chunk->blocks) + blockSize * (i + 1));
			block->next = next;
		}
		VxBlock* last = (VxBlock*)(((char*)chunk->blocks) + blockSize * (blockCount - 1));
		last->next = NULL;

		m_freeLists[index] = chunk->blocks->next;
		++m_chunkCount;
		return chunk->blocks;
	}
}

void VxBlockAllocator::free(void** p, int size)
{
	if (size == 0
		|| NULL == *p)
	{
		return;
	}

	//CCASSERT(0 < size, "size = %d", size);

	if (size > VXMEMORY_BLOCKALLOC_MAXBLOCKSIZE)
	{
		delete[] (char*)(*p);
		return;
	}


	std::lock_guard<std::mutex> lk(s_mutex);

	int index = s_blockSizeLookup[size];
	//CCASSERT(0 <= index && index < VXMEMORY_BLOCKALLOC_BLOCKSIZES, "index = %d, VXMEMORY_BLOCKALLOC_BLOCKSIZES = %d", index, VXMEMORY_BLOCKALLOC_BLOCKSIZES);

	VxBlock* block = (VxBlock*)(*p);
	block->next = m_freeLists[index];
	m_freeLists[index] = block;
	*p = NULL;
}

void VxBlockAllocator::clear()
{
	for (int i = 0; i < m_chunkCount; ++i)
	{
		VX_SAFE_DELETE_ARRAY(m_chunks[i].blocks);
	}

	m_chunkCount = 0;
	memset(m_chunks, 0, m_chunkSpace * sizeof(VxChunk));

	memset(m_freeLists, 0, sizeof(m_freeLists));
}
