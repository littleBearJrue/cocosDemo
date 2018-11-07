
#include "VxTime.h"
#include <chrono>
/************************************************************************/
/* VxHourTime
/************************************************************************/

VxHourTime::VxHourTime(int nTotalSecs)
{
	setTotalSeconds(nTotalSecs);
}

void VxHourTime::setTotalSeconds(int nTotalSecs)
{
	m_nSec = nTotalSecs % 60;
	nTotalSecs /= 60;
	m_nMin = nTotalSecs % 60;
	m_nHour = nTotalSecs / 60;
}

int VxHourTime::getTotalSeconds() const
{
	return (m_nHour * 60 + m_nMin) * 60 + m_nSec;
}

bool VxHourTime::operator < (const VxHourTime& other) const
{
	return getTotalSeconds() < other.getTotalSeconds();
}

bool VxHourTime::operator == (const VxHourTime& other) const
{
	return getTotalSeconds() == other.getTotalSeconds();
}

VxHourTime VxHourTime::operator + (const VxHourTime& other) const
{
	return VxHourTime(getTotalSeconds() + other.getTotalSeconds());
}

VxHourTime VxHourTime::operator - (const VxHourTime& other) const
{
	return VxHourTime(getTotalSeconds() - other.getTotalSeconds());
}

VxHourTime VxHourTime::operator * (float nNumber) const
{
	return VxHourTime(getTotalSeconds() * nNumber);
}



/************************************************************************/
/* VxTime
/************************************************************************/

VxDateTime VxTime::getCurrDateTime()
{
	VxDateTime ret;
	return ret;
}

std::string VxTime::getDateTimeString(
	VxDateTime dateTime,
	VxTimeFormat eFormat,
	char dateSeperator,
	char timeSeperator,
	char sectionSeperator)
{
	char buffer[128] = { 0 };
	switch(eFormat)
	{
	case VxTime::VXTIME_FORMAT_YYYY_MM_DD_HH_MM_SS_MMM:
	case VxTime::VXTIME_FORMAT_YYYY_MM_DD_HH_MM_SS:
		sprintf(buffer, "%04d%c%02d%c%02d%c%02d%c%02d%c%02d",
			dateTime.year(),
			dateSeperator,
			dateTime.month(),
			dateSeperator,
			dateTime.mday(),
			sectionSeperator,
			dateTime.hour(),
			timeSeperator,
			dateTime.minute(),
			timeSeperator,
			dateTime.sec()
			);
		break;
	case VxTime::VXTIME_FORMAT_YYYY_MM_DD_HH_MM:
		sprintf(buffer, "%04d%c%02d%c%02d%c%02d%c%02d",
			dateTime.year(),
			dateSeperator,
			dateTime.month(),
			dateSeperator,
			dateTime.mday(),
			sectionSeperator,
			dateTime.hour(),
			timeSeperator,
			dateTime.minute()
			);
		break;
	case VxTime::VXTIME_FORMAT_YYYY_MM_DD:
		sprintf(buffer, "%04d%c%02d%c%02d",
			dateTime.year(),
			dateSeperator,
			dateTime.month(),
			dateSeperator,
			dateTime.mday()
			);
		break;
	case VxTime::VXTIME_FORMAT_HH_MM_SS:
		sprintf(buffer, "%02d%c%02d%c%02d",
			dateTime.hour(),
			timeSeperator,
			dateTime.minute(),
			timeSeperator,
			dateTime.sec()
			);
		break;
	default:
		break;
	}

	return buffer;
}

std::string VxTime::getCurrentDateTimeString(VxTimeFormat eFormat,
	char dateSeperator,
	char timeSeperator,
	char sectionSeperator)
{
	switch(eFormat)
	{
	case VxTime::VXTIME_FORMAT_YYYY_MM_DD_HH_MM_SS_MMM:
		{
			VxDateTime dateTime = VxTime::getCurrDateTime();
			char buffer[128] = { 0 };
			int64 ms = VxTime::getCurrMilliSecs();
			VxDateTime dateTimeMS = VxTime::getDateTimeFromMillisecs(ms);
			ms %= VXTIME_MILLISECONDS_IN_SECOND;
			sprintf(buffer, "%04d%c%02d%c%02d%c%02d%c%02d%c%02d%c%03d",
				dateTime.year(),
				dateSeperator,
				dateTime.month(),
				dateSeperator,
				dateTime.mday(),
				sectionSeperator,
				dateTimeMS.hour(),
				timeSeperator,
				dateTimeMS.minute(),
				timeSeperator,
				dateTimeMS.sec(),
				sectionSeperator,
				(int)ms
				);
			return buffer;
		}
	default:
		return getDateTimeString(VxTime::getCurrDateTime(), eFormat);
	}
	
}

int64 VxTime::getCurrSecs()
{
	VxDateTime cur;
	return cur.time();
}

VxDateTime VxTime::getDateTimeFromSecs(int64 secs)
{
	return VxDateTime((time_t)secs);
}




int64 VxTime::getCurrMilliSecs()
{
	std::chrono::time_point<std::chrono::system_clock, std::chrono::milliseconds> tp = std::chrono::time_point_cast<std::chrono::milliseconds>(std::chrono::system_clock::now());
	auto tmp = std::chrono::duration_cast<std::chrono::milliseconds>(tp.time_since_epoch());
	std::time_t timestamp = tmp.count();
	//std::time_t timestamp = std::chrono::system_clock::to_time_t(tp);  
	return timestamp;


	
	//return milliSecs;//(((int64)val.tv_sec) * 1000 + val.tv_usec / 1000);
}

VxDateTime VxTime::getDateTimeFromMillisecs(int64 millisecs)
{
	VxDateTime ret(millisecs / VXTIME_MILLISECONDS_IN_SECOND);
	return ret;
}

// timespec VxTime::getTimespec(int64 millisecs)
// {
// 	struct timespec outtime;
// 	int64 ms = millisecs + VxTime::getCurrMilliSecs();
// 	outtime.tv_sec = ms / VXTIME_MILLISECONDS_IN_SECOND;
// 	outtime.tv_nsec = ms % VXTIME_MILLISECONDS_IN_SECOND * VXTIME_MICROSECOND_IN_MILLISECOND * VXTIME_NANOSECOND_IN_MICROSECOND;
// 	return outtime;
// 
// 	/*
// 	struct timeval now;
// 	struct timespec outtime;
// 	gettimeofday(&now, NULL);
// 	time_t curr = time(NULL);
// 	//outtime.tv_sec = now.tv_sec + millisecs / VXTIME_MILLISECONDS_IN_SECOND;
// 	outtime.tv_sec = curr + millisecs / VXTIME_MILLISECONDS_IN_SECOND;
// 	millisecs %= VXTIME_MILLISECONDS_IN_SECOND;
// 	outtime.tv_nsec = now.tv_usec * VXTIME_NANOSECOND_IN_MICROSECOND + millisecs * VXTIME_MICROSECOND_IN_MILLISECOND * VXTIME_NANOSECOND_IN_MICROSECOND;
// 	if(VXTIME_NANOSECOND_IN_SECOND <= outtime.tv_nsec)
// 	{
// 		outtime.tv_nsec -= VXTIME_NANOSECOND_IN_SECOND;
// 		++outtime.tv_sec;
// 	}
// 	return outtime;
// 	*/
// }



std::string VxTime::getGMTDataTime(int64 nTimeIsMS)
{
	static const char *weekdaymsg[]={ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };
	static const char *monthmsg[]={ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };

	time_t sTimeT = nTimeIsMS;
	const struct tm *t = gmtime(&sTimeT);
	char dst[64] = { 0 };
	sprintf(dst,
		"%s, %02d %s %04d %02d:%02d:%02d GMT",weekdaymsg[t->tm_wday], t->tm_mday, monthmsg[t->tm_mon],
		(t->tm_year<1900)? t->tm_year+1900: t->tm_year, t->tm_hour, t->tm_min, t->tm_sec );
	return dst;
}




/************************************************************************/
/* VxServerTime
/************************************************************************/
static int64 s_nServerTimeDistance;
static int64 s_nServerTimeDistance2;

void VxServerTime::adjustServerTime(int64 nMillisecs)
{
	s_nServerTimeDistance = VxTime::getCurrMilliSecs() - nMillisecs;
	s_nServerTimeDistance2 = VxTime::getCurrSecs() - nMillisecs/1000;
}

int64 VxServerTime::getServerTimeInMillisec()
{
	return VxTime::getCurrMilliSecs() - s_nServerTimeDistance;
}

int64 VxServerTime::getServerTimeInSec()
{
	return VxTime::getCurrSecs() - s_nServerTimeDistance / 1000;
}

int64 VxServerTime::getServerTimeInMillisec2()
{
	return VxTime::getCurrMilliSecs() - s_nServerTimeDistance*1000;
}

int64 VxServerTime::getServerTimeInSec2()
{
	return VxTime::getCurrSecs() - s_nServerTimeDistance2;
}

int64 VxServerTime::getRemainServerTimeInSec(int64 nLastTime, int64 nDuration)
{
	int64 nCurrentTime = getServerTimeInSec();
	if(nLastTime + nDuration < nCurrentTime)
	{
		return 0;
	}
	else
	{
		return nLastTime + nDuration - nCurrentTime;
	}
}

VxHourTime VxServerTime::getRemainServerTimeInHourTime(int64 nLastTime, int64 nDuration)
{
	return VxHourTime(getRemainServerTimeInSec(nLastTime, nDuration));
}

std::string VxServerTime::getHourTimeString(int64 nTotalSeconds)
{
	VxHourTime sHourTime(nTotalSeconds);
	char pStringBuffer[64] = { 0 };
	sprintf(pStringBuffer, "%02d:%02d:%02d", sHourTime.m_nHour, sHourTime.m_nMin, sHourTime.m_nSec);
	return pStringBuffer;
}
