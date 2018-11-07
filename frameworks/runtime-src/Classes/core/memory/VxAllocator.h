
#ifndef __VX_ALLOCATOR_H__
#define __VX_ALLOCATOR_H__

/************************************************************************/
/* VxAllocator
/************************************************************************/
class VxAllocator
{
public:
	virtual ~VxAllocator();
public:
	virtual void init();
	virtual void* alloc(int size);
	virtual void free(void** ptr, int size);
	virtual void clear();
	virtual void release();
	virtual void show();
};


/************************************************************************/
/* VxAlloc
/************************************************************************/
class VxAlloc
{
public:
	static void* alloc(int size);
	static void free(void** p, int size);
	static void setAlloc(VxAllocator* alloc);
protected:
	static VxAllocator* s_alloc;
};



#endif	// __VX_ALLOCATOR_H__