
#ifndef __VX_TIME_H__
#define __VX_TIME_H__

#include "VxDef.h"
#include "VxConst.h"

#define localtime_r( _clock, _result ) \
        ( *(_result) = *localtime( (_clock) ), \
          (_result) )

/************************************************************************/
/* VxDateTime
/************************************************************************/

class VxDateTime
{
public:
    VxDateTime()
    {
		time_ = ::time(NULL); 
		localtime_r(&time_, &tm_); 
    }
	
    VxDateTime(const VxDateTime &dt)
    {
		time_ = dt.time_; 
		tm_ = dt.tm_;
    }
	
    VxDateTime(const struct tm &tm_val)
    {
		tm_ = tm_val; 
		time_ = mktime(&tm_); 
    }
	
    explicit VxDateTime(const time_t tt)
    {
		time_ = tt; 
		localtime_r(&time_, &tm_); 
    }
	
    // Override operator
    inline VxDateTime& operator = (const VxDateTime &dt)
    {
		if (this != &dt)
		{
			this->time_ = dt.time_;
			this->tm_   = dt.tm_;
		}
		return *this;
    }
    inline VxDateTime operator - (const VxDateTime &dt) const
    {
		return VxDateTime(this->time_ - dt.time_);
    }
    inline VxDateTime operator - (const VxDateTime &dt)
    {
		return VxDateTime(this->time_ - dt.time_);
    }
    inline VxDateTime operator + (const VxDateTime &dt) const
    {
		return VxDateTime(this->time_ + dt.time_);
    }
    inline VxDateTime operator + (const VxDateTime &dt)
    {
		return VxDateTime(this->time_ + dt.time_);
    }
	
    inline bool operator < (const VxDateTime &dt) const
    {
		return this->time_ < dt.time_;
    }
    inline bool operator < (const VxDateTime &dt)
    {
		return this->time_ < dt.time_;
    }
    inline bool operator <=(const VxDateTime &dt) const
    {
		return *this < dt || *this == dt;
    }
    inline bool operator <=(const VxDateTime &dt)
    {
		return *this < dt || *this == dt;
    }
    inline bool operator ==(const VxDateTime &dt) const
    {
		return this->time_ == dt.time_;
    }
    inline bool operator ==(const VxDateTime &dt)
    {
		return this->time_ == dt.time_;
    }
    inline bool operator !=(const VxDateTime &dt) const
    {
		return this->time_ != dt.time_;
    }
    inline bool operator !=(const VxDateTime &dt)
    {
		return this->time_ != dt.time_;
    }
	
    inline int year  () const { return this->tm_.tm_year + 1900; }
    inline int month () const { return this->tm_.tm_mon  + 1; }
    inline int wday  () const { return this->tm_.tm_wday ; }
    inline int mday  () const { return this->tm_.tm_mday ; }
    inline int hour  () const { return this->tm_.tm_hour ; }
    inline int minute() const { return this->tm_.tm_min ;  }
    inline int sec   () const { return this->tm_.tm_sec ;  }
	
    inline void year(const int nyear)
    {
		this->tm_.tm_year = nyear - 1900;
		this->time_ = mktime(&this->tm_);
    }
    inline void month(const int nmon)
    {
		this->tm_.tm_mon = nmon - 1;
		this->time_ = mktime(&this->tm_); 
    }
    inline void mday(const int nday)
    {
		this->tm_.tm_mday = nday; 
		this->time_ = mktime(&this->tm_); 
    }
    inline void hour(const int nhou)
    {
		this->tm_.tm_hour = nhou;
		this->time_ = mktime(&this->tm_); 
    }
    inline void minute(const int nmin)
    {
		this->tm_.tm_min  = nmin;
		this->time_ = mktime(&this->tm_); 
    }
    inline void sec(const int nsec)
    {
		this->tm_.tm_sec  = nsec; 
		this->time_ = mktime(&this->tm_); 
    }
	
    // get time
    inline time_t time(void) const
    {
		return this->time_;
    }
    // get date value. convert string will be "2008-12-12 00:00:00"
    time_t date(void) const
    {
		struct tm stm;
		localtime_r(&this->time_, &stm);
		stm.tm_hour = stm.tm_min = stm.tm_sec = 0;
		return mktime(&stm);
    }

    // get current date and time
    inline time_t update(void)
    {
		this->time_ = ::time(NULL); 
		localtime_r(&this->time_, &this->tm_); 
		return this->time_;
    }
	
    // set date and time
    inline time_t update(time_t dtime)
    {
		this->time_ = dtime;
		localtime_r(&this->time_, &this->tm_); 
		return this->time_;
    }
protected:
    time_t    time_;
    struct tm tm_;
};

/************************************************************************/
/* VxHourTime
/************************************************************************/

class VxHourTime
{
public:
	VxHourTime(int nTotalSecs = 0);
	void setTotalSeconds(int nTotalSecs = 0);
	int getTotalSeconds() const;
	bool operator < (const VxHourTime& other) const;
	bool operator == (const VxHourTime& other) const;
	VxHourTime operator + (const VxHourTime& other) const;
	VxHourTime operator - (const VxHourTime& other) const;
	VxHourTime operator * (float nNumber) const;

public:
	int m_nHour;
	int m_nMin;
	int m_nSec;
};



/************************************************************************/
/* VxTime
/************************************************************************/
class VxTime
{
public:
	enum VxTimeFormat
	{
		VXTIME_FORMAT_YYYY_MM_DD_HH_MM_SS,
		VXTIME_FORMAT_YYYY_MM_DD_HH_MM,
		VXTIME_FORMAT_YYYY_MM_DD,
		VXTIME_FORMAT_HH_MM_SS,
		VXTIME_FORMAT_YYYY_MM_DD_HH_MM_SS_MMM,
	};

public:
	// precision: second
	static VxDateTime getCurrDateTime();

	static std::string getCurrentDateTimeString(
		VxTimeFormat eFormat = VXTIME_FORMAT_YYYY_MM_DD_HH_MM_SS,
		char dateSeperator = VX_VALUE_CHAR_BACKSLASH,
		char timeSeperator = VX_VALUE_CHAR_COLON,
		char sectionSeperator = VX_VALUE_CHAR_SPACE);

	static std::string getDateTimeString(VxDateTime dateTime,
		VxTimeFormat eFormat = VXTIME_FORMAT_YYYY_MM_DD_HH_MM_SS,
		char dateSeperator = VX_VALUE_CHAR_BACKSLASH,
		char timeSeperator = VX_VALUE_CHAR_COLON,
		char sectionSeperator = VX_VALUE_CHAR_SPACE);

	// precision: second
	static int64 getCurrSecs();

	static VxDateTime getDateTimeFromSecs(int64 secs);


	// precision: millisecond
	static int64 getCurrMilliSecs();

	static VxDateTime getDateTimeFromMillisecs(int64 millisecs);			// only get the hour, min and secs

	// get the timespec = now + millisecs.
//	static timespec getTimespec(int64 miilisecs);

	static std::string getGMTDataTime(int64 nTimeIsMS);
};



/************************************************************************/
/* VxServerTime
/************************************************************************/
class VxServerTime
{
public:
	static void adjustServerTime(int64 nMillisecs);
	static int64 getServerTimeInMillisec();
	static int64 getServerTimeInSec();
	static int64 getServerTimeInMillisec2();
	static int64 getServerTimeInSec2();
	static int64 getRemainServerTimeInSec(int64 nLastTime, int64 nDuration);
	static VxHourTime getRemainServerTimeInHourTime(int64 nLastTime, int64 nDuration);
	static std::string getHourTimeString(int64 nTotalSeconds);
	static std::string getLastHourTimeString(int64 nLastTime);
};

#endif	// __VX_TIME_H__


