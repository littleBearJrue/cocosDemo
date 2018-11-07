
#ifndef __VX_BLOCK_ALLOCATOR_H__
#define __VX_BLOCK_ALLOCATOR_H__

#include "VxDef.h"
#include "VxAllocator.h"

#define VXMEMORY_BLOCKALLOC_CHUNKSIZE					(16 * 1024)
#define VXMEMORY_BLOCKALLOC_MAXBLOCKSIZE				640
#define VXMEMORY_BLOCKALLOC_BLOCKSIZES					14
#define VXMEMORY_BLOCKALLOC_CHUNKARRAYINCRESMENT		128

struct VxBlock;
struct VxChunk;

class VxBlockAllocator : public VxAllocator
{
public:
	VxBlockAllocator();
	~VxBlockAllocator();
	void init();
	void* alloc(int size);
	void free(void** p, int size);
	void clear();
	void release();
protected:
	VxChunk* m_chunks;
	int m_chunkCount;
	int m_chunkSpace;

	VxBlock* m_freeLists[VXMEMORY_BLOCKALLOC_BLOCKSIZES];

	static int s_blockSizes[VXMEMORY_BLOCKALLOC_BLOCKSIZES];
	static int s_blockSizeLookup[VXMEMORY_BLOCKALLOC_MAXBLOCKSIZE + 1];
	static bool s_blockSizeLookupInitialized;

	
};


#endif	// __VX_BLOCK_ALLOCATOR_H__