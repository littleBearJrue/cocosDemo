
#ifndef __VX_DEF_H__
#define __VX_DEF_H__

#include "VxExternal.h"
#include "VxAllocator.h"
/************************************************************************/
/* Platform
/************************************************************************/
#define VX_PLATFORM_UNKNOWN				CC_PLATFORM_UNKNOWN
#define VX_PLATFORM_IOS					CC_PLATFORM_IOS
#define VX_PLATFORM_ANDROID				CC_PLATFORM_ANDROID
#define VX_PLATFORM_WIN32				CC_PLATFORM_WIN32
#define VX_PLATFORM_MARMALADE			CC_PLATFORM_MARMALADE
#define VX_PLATFORM_LINUX				CC_PLATFORM_LINUX
#define VX_PLATFORM_BADA				CC_PLATFORM_BADA
#define VX_PLATFORM_BLACKBERRY			CC_PLATFORM_BLACKBERRY
#define VX_PLATFORM_MAC					CC_PLATFORM_MAC

#define VX_TARGET_PLATFORM				CC_TARGET_PLATFORM

/************************************************************************/
/* Pay Platform
 /************************************************************************/
//do not define here,just show you which name is used
//VX_PAY_PLATFORM_91
//#define VX_TARGET_PAY_PLATFORM
#define VX_PAY_PLATFORM_UNKNOWN            0
#define VX_PAY_PLATFORM_91                 1
#define VX_PAY_PLATFORM_UC                 2
#define VX_PAY_PLATFORM_DL                 3
#define VX_PAY_PLATFORM_PP				   4

// Determine target platform by compile environment macro.
#define VX_TARGET_PAY_PLATFORM             VX_PAY_PLATFORM_UNKNOWN

// 91
#if ! VX_TARGET_PAY_PLATFORM && defined(TARGET_91)
#undef  VX_TARGET_PAY_PLATFORM
#define VX_TARGET_PAY_PLATFORM         VX_PAY_PLATFORM_91
#endif

// UC
#if ! VX_TARGET_PAY_PLATFORM && defined(TARGET_UC)
#undef  VX_TARGET_PAY_PLATFORM
#define VX_TARGET_PAY_PLATFORM         VX_PAY_PLATFORM_UC
#endif

// DL
#if ! VX_TARGET_PAY_PLATFORM && defined(TARGET_DL)
#undef  VX_TARGET_PAY_PLATFORM
#define VX_TARGET_PAY_PLATFORM         VX_PAY_PLATFORM_DL
#endif

// PP
#if ! VX_TARGET_PAY_PLATFORM && defined(TARGET_PP)
#undef  VX_TARGET_PAY_PLATFORM
#define VX_TARGET_PAY_PLATFORM         VX_PAY_PLATFORM_PP
#endif

//UNKNOWN
#if ! VX_TARGET_PAY_PLATFORM && defined(TARGET_PAY_UNKNOWN)
#undef  VX_TARGET_PAY_PLATFORM
#define VX_TARGET_PAY_PLATFORM         VX_PAY_PLATFORM_UNKNOWN
#endif


/************************************************************************/
/* Log
/************************************************************************/
void _VxLog(const char* pszFormat, ...);
void _VxLogData(const void* pvData, int iDataLen, const char* pszFormat, ...);
#define VXLOG(format, ...)			CCLOG(format, ##__VA_ARGS__)		//_VxLog(format, ##__VA_ARGS__)
#define VXLOGDATA(data, len, format, ...)	_VxLogData(data, len, format, ##__VA_ARGS__)


/************************************************************************/
/* Assert
/************************************************************************/
void _VxAssertLog(const char* pMsg);
#define VXASSERT(cond, ...)				CCAssert(cond, ...)//do { if(!(cond)) { char msg[1024]; sprintf(msg, ##__VA_ARGS__); _VxAssertLog(msg); CCAssert((cond), msg); } } while(0)


/************************************************************************/
/* SAFE OPERATION
/************************************************************************/
#define VX_SAFE_DELETE(p)				CC_SAFE_DELETE(p)
#define VX_SAFE_DELETE_ARRAY(p)			CC_SAFE_DELETE_ARRAY(p)
#define VX_SAFE_FREE(p)					CC_SAFE_FREE(p)
#define VX_SAFE_RELEASE(p)				CC_SAFE_RELEASE(p)
#define VX_SAFE_RELEASE_NULL(p)			CC_SAFE_RELEASE_NULL(p)
#define VX_SAFE_RETAIN(p)				CC_SAFE_RETAIN(p)
#define VX_SAFE_CLOSE_FILE(f)			do { if((f)) { fclose((f)); (f) = NULL; } } while(0)
#define VX_SAFE_DELETE_MSG(p, T)		do { p->~T(); VxAlloc::free((void**)(&(p)), sizeof(T)); } while(0)
#define VX_NEW_MSG(T)					new (VxAlloc::alloc(sizeof(T))) T
#define VX_SAFE_STOP_TIMER(t)			do { if(t) { VxTimerManager::stop(t); t = VXTIMER_INVALID_HANDLE; } } while(0)


/************************************************************************/
/* Condition Statement
/************************************************************************/
#define VX_BREAK_IF(cond)				CC_BREAK_IF(cond)
#define VX_RETURN_IF(cond)				do { if(cond) return; } while(0)
#define VX_RETURN_NULL_IF(cond)			do { if(cond) return NULL; } while(0)
#define VX_RETURN_VALUE_IF(cond, value)	do { if(cond) return value; } while(0)
#define VX_CONTINUE_IF(cond)			if(cond) continue


/************************************************************************/
/* Semaphore
/************************************************************************/
#if (VX_TARGET_PLATFORM == VX_PLATFORM_IOS)
#define VX_SEMAPHORE_USE_NAMED_SEMAPHORE
#endif


/************************************************************************/
/* Math
/************************************************************************/
#define VXMATH_PERCENTAGE(a, b)				((int)((a) * 100.0 / (b)))
#define VXMATH_ALIGMENT(p, align)			((((int)(p)) + (align) - 1) / (align) * (align))
#define VXMATH_ALIGMENT4(p)					VXMATH_ALIGMENT(p, 4)

/************************************************************************/
/* Spin lock
/************************************************************************/
#define VXSPINLOCK(a)						while(a)

/************************************************************************/
/* Utils
/************************************************************************/
#define VXMEMBEROFFSET(field, type)			((int)(&(((type*)(0))->field)))
#define VXMAKEMAPPAIR(key, val)				{ key, val }
#define VXGETBIT(n, flag)					(0 != ((n) & (flag)))
#define VXSETBIT(n, flag, b)				do { if(b) { ((n) |= (flag)); } else { ((n) &= (~(flag))); } } while(0)

/************************************************************************/
/* Traverse
/************************************************************************/
#define VX_FOR_EACH_ITERATOR(type, map, i)			for(type::iterator i = (map).begin(); i != (map).end(); ++i)
#define VX_FOR_EACH_ITERATOR_EX(_key_type, _value_type, _map, i)			for(std::map<_key_type, _value_type>::iterator i = (_map).begin(); i != (_map).end(); ++i)
#define VX_STDMAP_FIND(type, map, i, key)			for(type::iterator i = (map).find(key); i != (map).end(); i = (map).end())
#define VX_STDMAP_FIND_EX(_key_type, _value_type, _map, i, key)			for(std::map<_key_type, _value_type>::iterator i = (_map).find(key); i != (_map).end(); i = (_map).end())
#define VX_STDMAP_REMOVE(type, map, key)			do { type::iterator __i = (map).find(key); if(__i != (map).end()) { (map).erase(__i); } } while (0)
#define VX_STDMAP_REMOVE_EX(_key_type, _value_type, _map, key)			do { std::map<_key_type, _value_type>::iterator __i = (_map).find(key); if(__i != (_map).end()) { (_map).erase(__i); } } while (0)
#define VX_STDVECTOR_REMOVE(type, vec, val)			do { for(type::iterator __i = (vec).begin(); __i != (vec).end(); ++__i) if((*__i) == (val)) { (vec).erase(__i); break; } } while (0)
#define VX_FOR_RCARRAY_INDEX(row, col, k)			for(int __i = 0, k = 0; __i < row; ++__i) for(int __j = 0; __j < col; ++__j, ++k)
#define VX_FOR_I(i, s, e)							for(int i = s; i < e; ++i)
#define VX_RFOR_I(i, s, e)							for(int i = e - 1; s <= i; --i)
#define VX_FOR_U(i, s, e)							for(unsigned int i = s; i < e; ++i)
#define VX_SAFE_RELEASE_VECTOR(container)			do {VX_FOR_I(i, 0, (int)container.size()){VX_SAFE_RELEASE(container[i]);} container.clear();}while(false);

/************************************************************************/
/* Singlet
/************************************************************************/
#define VX_SINGLET_DECLARE(T) \
	public: \
	static T** getSingletInstancePtr() \
	{ \
		static T* m_pInst = NULL; \
		return &m_pInst; \
	} \
	static T* getInstance() \
	{ \
		T** m_pInst = getSingletInstancePtr(); \
		if(!(*m_pInst)) \
		{ \
			*m_pInst = new T(); \
		} \
		return *m_pInst; \
	} \
	static void pureInstance() \
	{ \
		T** m_pInst = getSingletInstancePtr(); \
		if(*m_pInst) delete(*m_pInst); \
		*m_pInst = NULL; \
	} \

#define VX_SINGLET_WITH_INIT_DECLARE(T) \
	public: \
	static T** getSingletInstancePtr() \
	{ \
	static T* m_pInst = NULL; \
	return &m_pInst; \
	} \
	static T* getInstance() \
	{ \
	T** m_pInst = getSingletInstancePtr(); \
	if(!(*m_pInst)) \
		{ \
		*m_pInst = new T(); \
		} \
		return *m_pInst; \
	} \
	static void pureInstance() \
	{ \
	T** m_pInst = getSingletInstancePtr(); \
	if(*m_pInst) delete(*m_pInst); \
	*m_pInst = NULL; \
	} \
	static void init()\
	{\
		getInstance();\
	}\
	static void release()\
	{\
		pureInstance();\
	}


/************************************************************************/
/* Cocos node loader
/************************************************************************/

#define VX_CCB_REGISTER_LOADER(Name, Func) \
	static void registerLoader(CCNodeLoaderLibrary* pLoader) \
	{ \
		pLoader->registerCCNodeLoader(Name, Func()); \
	} \


#define VX_CCB_LOADER_DECLARE_CONTENT(T, Name) \
	public: \
	CCB_STATIC_NEW_AUTORELEASE_OBJECT_METHOD(Loader, Load); \
	VX_CCB_REGISTER_LOADER(Name, Load); \
	protected: \
	CCB_VIRTUAL_NEW_AUTORELEASE_CREATECCNODE_METHOD(T); \


#define VX_CCB_LOADER_DECLARE(T, Name) \
	class Loader : public CCNodeLoader \
	{ \
	public: \
		CCB_STATIC_NEW_AUTORELEASE_OBJECT_METHOD(Loader, Load); \
		VX_CCB_REGISTER_LOADER(Name, Load); \
	protected: \
		CCB_VIRTUAL_NEW_AUTORELEASE_CREATECCNODE_METHOD(T); \
	}; \


#define VX_CCB_MEMBERVARIABLEASSIGNER_GLUE_ADDTO_VECTOR(TARGET, MEMBERVARIABLENAME, MEMBERVARIABLETYPE, VECTOR) \
	if (pTarget == TARGET && pMemberVariableName->compare(MEMBERVARIABLENAME) == 0) { \
	MEMBERVARIABLETYPE __myVal = dynamic_cast<MEMBERVARIABLETYPE>(pNode); \
	CC_ASSERT(__myVal); \
	__myVal->retain(); \
	VECTOR.push_back(__myVal); \
	return true; \
	}

/************************************************************************/
/* String Parser
/************************************************************************/
#define VX_STRING_PARSER_FUNCTION_BEGIN(func)			static int func(std::string value) {
#define VX_STRING_PARSER_FUNCTION_END					return 0; }
#define VX_STRING_PARSER_GETVALUE(Name, Type)			do { if(Name == value) return Type; } while (0)


/************************************************************************/
/* Class Member
/************************************************************************/
#define VX_PROPERTY_READONLY				CC_PROPERTY_READONLY
#define VX_PROPERTY_READONLY_PASS_BY_REF	CC_PROPERTY_READONLY_PASS_BY_REF
#define VX_PROPERTY							CC_PROPERTY
#define VX_PROPERTY_PASS_BY_REF				CC_PROPERTY_PASS_BY_REF
#define VX_SYNTHESIZE_READONLY				CC_SYNTHESIZE_READONLY
#define VX_SYNTHESIZE_READONLY_PASS_BY_REF	CC_SYNTHESIZE_READONLY_PASS_BY_REF
#define VX_SYNTHESIZE_PASS_BY_REF			CC_SYNTHESIZE_PASS_BY_REF
#define VX_SYNTHESIZE						CC_SYNTHESIZE
#define VX_SYNTHESIZE_RETAIN				CC_SYNTHESIZE_RETAIN


#define VX_SYNTHESIZE_STATIC_PASS_BY_REF(varType, varName)\
public: static varType& varName(void) { static varType varName; return varName; }

/************************************************************************/
/* Class Convert
/************************************************************************/
#define VX_CLASS_CONVERT_DECLARE(__SRC, __DST) \
protected: \
	void init(const __DST& sOther); \
public: \
	static __SRC* create(const __DST& sOther) { __SRC* p = new __SRC(); p->init(sOther); return p; } \
	__SRC& operator = (const __DST& sOther) { init(sOther); return *this; }

#define VX_CLASS_CONVERT_DECLARE_WITH_CONSTRUCTOR(__SRC, __DST) \
	VX_CLASS_CONVERT_DECLARE(__SRC, __DST) \
public: \
	__SRC(const __DST& sOther) { init(sOther); }

#endif	// __VX_DEF_H__
