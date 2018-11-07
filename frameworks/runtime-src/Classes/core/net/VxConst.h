
#ifndef __VX_CONST_H__
#define __VX_CONST_H__

#ifndef NULL
#define NULL 0
#endif

#define NX_APP_NAME								"GodWisher"

#define VX_VALUE_STRING_EMPTY					""
#define VX_VALUE_STRING_UTF8					"utf-8"
#define VX_VALUE_STRING_TRUE					"true"
#define VX_VALUE_STRING_FALSE					"false"
#define VX_VALUE_STRING_LINEENDING				"\n"
#define VX_VALUE_WSTRING_LINEENDING				"\r\n"
#define VX_VALUE_STRING_SPACE					" "
#define VX_VALUE_STRING_SLASH					"\\"
#define VX_VALUE_STRING_BACKSLASH				"/"
#define VX_VALUE_STRING_DOT						"."

#define VX_VALUE_CHAR_SPACE						' '
#define VX_VALUE_CHAR_BACKSLASH					'/'
#define VX_VALUE_CHAR_COLON						':'

/************************************************************************/
/* Module
/************************************************************************/
enum
{
	VXMODULE_ID_MAIN = 100,
	VXMODULE_ID_DATA = VXMODULE_ID_MAIN,
	VXMODULE_ID_BG,

	// none-module id
	VXMODULE_ID_TIMER = 200,

	// dynamic-module id
	VXMODULE_ID_DYNAMIC = 300
};

enum
{
	VXMODULE_STATE_NOT_START,
	VXMODULE_STATE_STARTING,
	VXMODULE_STATE_RUNNING,
	VXMODULE_STATE_EXITING
};

/************************************************************************/
/* Path
/************************************************************************/
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
#define VXPATH_SEPERATOR								VX_VALUE_STRING_SLASH
#else
#define VXPATH_SEPERATOR								VX_VALUE_STRING_BACKSLASH
#endif

#define VXPATH_CACHE_DIR								"Cache"
#define VXPATH_ENGINE_DIR								"Engine"

#define VXPATH_DATA_DIR									"Data"
#define VXPATH_RANDOM_DIR								VXPATH_CACHE_DIR
#define VXPATH_RANDOM_FILENAME_PREFFIX					"rf_"
#define VXPATH_PATH_CONFIG_FILE							"PathConfig.cfg"

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#define VXPATH_SDCARD_ROOT								"/mnt/sdcard"
#elif CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
#define VXPATH_SDCARD_ROOT								"..\\SDCard"
#else
#define VXPATH_SDCARD_ROOT								""
#endif

#define VX_PATH_UPDATE_DIR								"Update"


/************************************************************************/
/* Log
/************************************************************************/
#define VXLOG_FILENAME								"log.txt"
#define VXLOG_LINEENDING							VX_VALUE_WSTRING_LINEENDING
#define VXLOG_DATA_SEPERATOR						VX_VALUE_STRING_SPACE
#define VXLOG_BUFFER_LEN							1024

// do change it
#define VXLOG_DATALEN_PER_COLUMN					8

// should be multi-times of VXLOG_DATALEN_PER_COLUMN
#define VXLOG_DATALEN_PER_LINE						(VXLOG_DATALEN_PER_COLUMN << 1)

/************************************************************************/
/* Time
/************************************************************************/
#define VXTIME_NANOSECOND_IN_MICROSECOND			1000
#define VXTIME_MICROSECOND_IN_MILLISECOND			1000
#define VXTIME_MILLISECONDS_IN_SECOND				1000
#define VXTIME_MICROSECOND_IN_SECOND				(VXTIME_MILLISECONDS_IN_SECOND * VXTIME_MICROSECOND_IN_MILLISECOND)
#define VXTIME_NANOSECOND_IN_SECOND					(VXTIME_MICROSECOND_IN_SECOND * VXTIME_NANOSECOND_IN_MICROSECOND)
#define VXTIME_SECONDS_IN_MINUTE					60
#define VXTIME_MINUTES_IN_HOUR						60
#define VXTIME_HOURS_IN_DAY							24

/************************************************************************/
/* Timer
/************************************************************************/
#define VXTIMER_INVALID_INTERVAL					(-1)
#define VXTIMER_INVALID_DURATION					(-1)
#define VXTIMER_INVALID_HANDLE						(0)
#define VXTIMER_TIMER_MAX_COUNT						80
#define VXTIMER_TIMER_DEFAULT_PRECISION				100

/************************************************************************/
/* Thread
/************************************************************************/
#define VXSEM_NAME_PREFFIX							"vxsem"
#define VXSEM_NAME_LEN								16
#define VXTHREAD_STACK_DEFAULT_SIZE					(16 * 1024)


/************************************************************************/
/* Error code
/************************************************************************/
enum
{
	VXERR_SUCCESS,
	VXERR_FAILED = -1,
	VXERR_NULL_ARGS = -2,
	VXERR_NOT_IMPLEMENT = -3,
	VXERR_BUSY = -4,

	VXERR_STREAM = -1000,
	VXERR_STREAM_WRITE,
	VXERR_STREAM_READ,
	VXERR_STREAM_SEEK,
	VXERR_STREAM_PARAM_ERROR,
	VXERR_STREAM_OPERATION_NOT_ALLOW,

	VXERR_MEMORY = -2000,
	VXERR_MEMORY_NOT_ENOUGH,

	VXERR_SOCKECLIENT = -3000,
	VXERR_SOCKECLIENT_SEND_ERROR,
	VXERR_SOCKECLIENT_SEND_MUTEX_ERROR,

	VXERR_JVM = -4000,
	VXERR_JVM_METHOD_NOT_FOUND,

	VXERR_FILE = -5000,
	VXERR_FILE_OPEN_FAILED,
	VXERR_FILE_WRITE_FAILED,
	VXERR_FILE_READ_FAILED,
};

/************************************************************************/
/* Stream
/************************************************************************/
enum
{
	VX_SEEK_BEGIN,
	VX_SEEK_CURRENT,
	VX_SEEK_END
};

#define VXSTREAM_CAPACITY_MAX						0x60000000

#define VXSTREAM_FILE_BUFFER_DEFAULT_SIZE			(1024 * 10)

#define VXSTREAM_MEMORY_BUFFER_DEFAULT_SIZE			(1024 * 10)

#define VXSTREAM_COPY_BUFFER_SIZE					(50 * 1024)

/************************************************************************/
/* File
/************************************************************************/
#define VXFILE_OPEN_FLAG_CREATE							(1 << 1)
#define VXFILE_OPEN_FLAG_CREATE_ALWAYS					(1 << 2)
#define VXFILE_OPEN_FLAG_APPEND							(1 << 3)

#define VXFILE_OPEN_MODE_CREATE_ALWAYS					"wb+"
#define VXFILE_OPEN_MODE_CREATE							"rb+"
#define VXFILE_OPEN_MODE_APPEND							"ab+"

#define VXFILE_FILL_ZERO_BUFFER_SIZE_MIN				(1024)
#define VXFILE_FILL_ZERO_BUFFER_SIZE_MAX				(1024 * 50)


/************************************************************************/
/* Net
/************************************************************************/
#define VXSOCKETCLIENT_INTERNAL_BUFFER_SIZE				(10 * 1024)
#define VXSOCKETCLIENT_IP_STRING_SIZE					64

enum
{
	VXSOCKET_EVENT_CONNECT_BEGIN,
	VXSOCKET_EVENT_CONNECT_COMPLETE,
	VXSOCKET_EVENT_CONNECT_FAILED,
	VXSOCKET_EVENT_CLOSED,
	VXSOCKET_EVENT_RECV,
	VXSOCKET_EVENT_SEND,
	VXSOCKET_EVENT_MAX
};

enum
{
	VXSOCKET_STATE_NOT_OPEN,
	VXSOCKET_STATE_CONNECTING,
	VXSOCKET_STATE_RUNNING,
	VXSOCKET_STATE_CLOSING
};

#define VXPROTOCOL_HEARTBEATDURATION					30000
#define VXSOCK_EVENT_SEND_CB_DURATION					1000

/************************************************************************/
/* Framework
/************************************************************************/
#define VXMSGMANAGER_MSGCB_IMMEDIATELY					1





/************************************************************************/
/* Sound
/************************************************************************/
#define VXSOUND_RECORD_TIME_UNLIMIT						0
#define VXSOUND_RECORD_TIME_LIMIT_DEFAULT				(10 * 1000)



/************************************************************************/
/* Priority
/************************************************************************/
enum
{
	VXPRIORITY_0,
	VXPRIORITY_HIGHEST = VXPRIORITY_0,
	VXPRIORITY_1,
	VXPRIORITY_HIGHER = VXPRIORITY_1,
	VXPRIORITY_2,
	VXPRIORITY_HIGH = VXPRIORITY_2,
	VXPRIORITY_3,
	VXPRIORITY_NORMAL_HIGH = VXPRIORITY_3,
	VXPRIORITY_4,
	VXPRIORITY_NORMAL = VXPRIORITY_4,
	VXPRIORITY_5,
	VXPRIORITY_NORMAL_LOW = VXPRIORITY_5,
	VXPRIORITY_6,
	VXPRIORITY_LOW = VXPRIORITY_6,
	VXPRIORITY_7,
	VXPRIORITY_LOWER = VXPRIORITY_7,
	VXPRIORITY_8,
	VXPRIORITY_LOWEST = VXPRIORITY_8,
};

/************************************************************************/
/* Compress
/************************************************************************/
enum
{
	VXCOMPRESS_ENCODE_ADD_ALL,
	VXCOMPRESS_ENCODE_MUL_ALL,
	VXCOMPRESS_ENCODE_MUL_AND_ADD,
	VXCOMPRESS_ENCODE_ADD_AND_MUL,
	VXCOMPRESS_ENCODE_TYPE_COUNT
};


/************************************************************************/
/* Alignment Format
/************************************************************************/
#define VX_STRING_EMPTY_SEPERATOR_SIZE					4
#define VX_ALIGNMENT_SIZE								4

/************************************************************************/
/* Direction
/************************************************************************/
enum 
{
	VX_DIRECTION_RIGHT,
	VX_DIRECTION_UP,
	VX_DIRECTION_LEFT,
	VX_DIRECTION_DOWN,
	VX_DIRECTION_COUNT
};

#endif	// __VX_CONST_H__
