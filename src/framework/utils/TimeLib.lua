local NumberLib = require(".NumberLib");
local TableLib = require(".TableLib");

local TimeLib = {};

TimeLib.TIME_DAY       = 24 * 60 * 60;
TimeLib.TIME_HOUR      = 60 * 60;
TimeLib.TIME_MIN       = 60;

--@brief 获取当天0时0分0秒的时间戳
function TimeLib.getDayStartTime(timestamp)
    local timeTable = os.date("*t", timestamp);
    timeTable.hour = 0;
    timeTable.sec = 0;
    timeTable.min = 0; 
    return os.time(timeTable) or 0;
end

--@brief 获取二个时间戳相隔多少天
function TimeLib.getDayInterval(timestampA, timestampB)
    local timeA = TimeLib.getDayStartTime(timestampA);
    local timeB = TimeLib.getDayStartTime(timestampB);
    local secondADay = 24 * 3600;
    local day = math.floor((timeB - timeA) / secondADay);
    return day;
end

--@brief 判断timestampB是否在timestampA的2天内
function TimeLib.isInTwoDay(timestampA, timestampB)
    local diffDay = TimeLib.getDayInterval(timestampA, timestampB);

    if diffDay == 2 then
        return true, "后天";
    elseif diffDay == 1 then 
        return true, "明天";
    elseif diffDay == 0 then 
        return true, "今天";
    elseif diffDay == -1 then 
        return true, "昨天";
    elseif diffDay == -2 then 
        return true, "前天";
    else
        return false, "";
    end
end

--@brief 判断timestampA和timestampB是否为同一天
function TimeLib.isSameDay(timestampA, timestampB)
    local timeTableA = os.date("*t", timestampA);
    local timeTableB = os.date("*t", timestampB);
    if timeTableA.year == timeTableB.year and 
        timeTableA.month == timeTableB.month and 
        timeTableA.day == timeTableB.day then
        return true;
    end
    return false;
end

--@brief 判断timestampA和timestampB是否为同一月
function TimeLib.isSameTimeLibonth(timestampA, timestampB)
    local timeTableA = os.date("*t", timestampA);
    local timeTableB = os.date("*t", timestampB);
    if timeTableA.year == timeTableB.year and 
        timeTableA.month == timeTableB.month then
        return true;
    end
    return false;    
end

--@brief 将时间戳转化成 xx年xx月xx日xx时xx分xx秒格式
function TimeLib.getTimeYTimeLibDHTimeLibS(timestamp)
    local format = "%Y年%m月%d日%H时%M分%S秒";
    return os.date(format, NumberLib.valueOf(timestamp) );
end

--@brief 将时间戳转换成 xx月xx日xx:xx:xx格式
function TimeLib.getTimeTimeLibDHTimeLibS(timestamp)
    local format = "%m月%d日%H:%M:%S";
    return os.date(format, NumberLib.valueOf(timestamp) );
end

--@brief 将时间戳转换成 xx月xx日xx:xx格式
function TimeLib.getTimeTimeLibDHTimeLib(timestamp)
    local format = "%m月%d日%H:%M";
    return os.date(format, NumberLib.valueOf(timestamp) );
end

--@brief 将时间戳转换成 xx年xx月xx日
function TimeLib.getTimeYTimeLibD(timestamp)
    local format = "%Y年%m月%d日";
    return os.date(format, NumberLib.valueOf(timestamp) );
end

--@brief 将时间戳转换成 xx年xx月
function TimeLib.getTimeYTimeLib(timestamp)
    local format = "%Y年%m月";
    return os.date(format, NumberLib.valueOf(timestamp) );
end

--@brief 将时间戳转换成 xx月xx日
function TimeLib.getTimeTimeLibD(timestamp)
    local format = "%m月%d日";
    return os.date(format, NumberLib.valueOf(timestamp) );   
end

--@brief 拆分时间 00时:00分:00秒
function TimeLib.skipTime(timestamp)
    timestamp = NumberLib.valueOf(timestamp);
    local timeTable = os.date("*t",timeNum);
    return string.format("%02d:%02d:%02d", timeTable.hour, timeTable.min, timeTable.sec);
end

--@brief 拆分时间 00时:00分
function TimeLib.skipTimeHTimeLib(timestamp)
    timestamp = NumberLib.valueOf(timestamp);
    local timeTable = os.date("*t",timestamp);
    if TableLib.isEmpty(timeTable) then
        return "00:00"
    else
        return string.format("%02d:%02d", timeTable.hour, timeTable.min);
    end
end

--@brief 拆分时间 00分:00秒
-- >1小时 展示 00时:00分:00秒
function TimeLib.skipTimeMSTimeLib(timestamp)
    local h, _ = math.floor(timestamp/3600);
    local m, _ = math.floor(timestamp % 3600 / 60);
    local s = timestamp % 3600 % 60;
    local str;
    if h > 0 then
        str = string.format("%.2d:%.2d:%.2d", h, m, s);
    else
        str = string.format("%.2d:%.2d", m, s);
    end
    return str 
end

--@brief 拆分时间 00分:00秒
function TimeLib.skipTimeMSTimeLib2(timestamp)
    timestamp = NumberLib.valueOf(timestamp);
    local timeTable = os.date("*t",timeNum);
    if TableLib.isEmpty(timeTable) then
        return "00:00"
    else
        return string.format("%02d:%02d", timeTable.min, timeTable.sec);
    end 
end

--@brief 将时间戳转换成xx-xx-xx
function TimeLib.getTimeYTimeLibD2(timestamp)
    timestamp = NumberLib.valueOf(timestamp);
    local format = "%Y-%m-%d";
    return os.date(format, timestamp);
end

--@brief 将时间戳转换成 年月日20171116
function TimeLib.getTimeYTimeLibD3(timestamp)
    local format = "%Y%m%d";
    return os.date(format, NumberLib.valueOf(timestamp) );
end

--[[
    获取二个时间戳相隔的时间
    >1天：xx天xx小时
    (1天，60分钟)：xx小时xx分
    <60分钟：xx分钟
    timeTable.hour = 0;
    timeTable.sec = 0;
    timeTable.min = 0; 

]]
function TimeLib.getShowTime(timestampB)
    local timestampA = os.time();
    timestampB = tonumber(timestampB);
    if (not timestampB) or timestampB <= 0 then
        return "";
    end
    if timestampA > timestampB then
        return "";
    end
    local secondDay = 24*3600;
    local secondHour = 3600;
    local secondMin = 60;
    local day = math.floor((timestampB - timestampA) / secondDay);
    local hour = math.floor((timestampB - timestampA) / secondHour);
    local min = math.floor((timestampB - timestampA) / secondMin);
    if day >= 1 then
        local str = "%s天%s小时";
        hour = hour - day*24;
        return string.format(str,day,hour);
    else
        if hour > 1 then
            min = min - hour*60;
            local str = "%s小时%s分钟";
            return string.format(str,hour,min);
        else
            local str = "%s分钟";
            return string.format(str,min);
        end
    end
end

--转换时间戳
--当天显示 %H:%M
--昨天显示 昨天%H:%M
--明天显示 明天%H:%M
--其余显示 %Y年%m月%d日 %H:%M
function TimeLib.formatTime(timestamp)
    timestamp = tonumber(timestamp) or os.time();
    local cur = TimeLib.getDayStartTime(os.time());
    local diff = 24 * 3600;
    local format = "%Y年%m月%d日 %H:%M"
    if timestamp >= cur and (timestamp < (cur + diff)) then 
        format = "%H:%M";
    elseif (timestamp < cur ) and (timestamp >= (cur - diff)) then 
        format = "昨天 %H:%M";
    elseif (timestamp >= (cur + diff)) and (timestamp < (cur + 2 * diff)) then 
        format = "明天 %H:%M";
    end 
        
    return os.date(format, timestamp);
end

-- 获取当前日期格式
-- return {
--  hour  时
--  min   分
--  wday  星期几(1 - 7)
--  day   日
--  month  月
--  year  年
--  sec   秒
--  yday  年内天数
--  isdst  是否夏令时    
--}
function TimeLib.getToday()
    local times = os.date("*t",os.time());
    local week = times.wday;
    week = week -1;
    if week == 0 then
        week = 7;
    end
    times.wday = week;

    return times;
end

-- 把秒转换为时间格式
-- return {
--  hour  时
--  min   分
--  wday  星期几(1 - 7)
--  day   日
--  month  月
--  year  年
--  sec   秒
--  yday  年内天数
--  isdst  是否夏令时    
--}
function TimeLib.getTimerBySecond(second)
    local times = os.date("*t",second);
    local week = times.wday;
    week = week -1;
    if week == 0 then
        week = 7;
    end
    times.wday = week;

    return times;
end

-- 将long转换成日期格式
-- @param regex 日期格式
--   %Y 年
--   %m 月
--   %d 日
--   %H 时
--   %M 分
--   %S 秒
-- 例：getTimeYMDHMS("%Y年%m月%d日 - %H:%M:%S"), 输出："2018年12月1日 - 12:30:20"
function TimeLib.getTimeYMDHMS(regex,time)
    local days = "";
    if time and tonumber(time) then
        local timeNum = tonumber(time);
        timeNum = math.abs(timeNum);
        days = os.date(regex,timeNum);
    end
    return days;
end

-- 拆分时间
function TimeLib.skipTimeHMS(time)
    local times = nil;
    local hour = nil;
    local min  = nil;
    local sec  = nil;
    if time then
        local timeNum = tonumber(time);
        if timeNum and timeNum > 0 then
            hour = os.date("*t",timeNum).hour - 8;
            min  = os.date("*t",timeNum).min;
            sec  = os.date("*t",timeNum).sec;

            hour = string.format("%02d",hour);
            min = string.format("%02d",min);
            sec = string.format("%02d",sec);
        end
    end
    return hour,min,sec;
end

--输入两个时间的秒数，获取两个时间差
--输出格式time = {sec=0, min=0, hour= 0, day=1}
function TimeLib.timeDiff(long_time,short_time)
    local diff = {sec=0, min=0, hour= 0, day=0};  
    if not long_time or not short_time then
        return diff
    end
    local diff_time  = long_time - short_time
    if diff_time <= 0 then
        return diff
    end
    local n_diff_time  = os.date('*t',diff_time)
    for i,v in ipairs({'sec','min','hour','yday'}) do  
       if v == "yday" then
           diff.day = n_diff_time[v]
       else
           diff[v] = n_diff_time[v]
       end 
    end

    return diff  
end 

-- 获取x天后剩余秒数
function TimeLib.getRemainSecondsByDays(days)
    local curTime = TimeLib.getToday();
    local hour = curTime.hour;
    local minutes = curTime.min;
    local curCostSeconds = hour * TimeLib.TIME_HOUR + minutes * TimeLib.TIME_MIN + curTime.sec;
    local totalDays = days or 1;
    local remainSeconds = TimeLib.TIME_DAY * totalDays - curCostSeconds;
    return remainSeconds;
end

function TimeLib.seconds2hhmmss(seconds)
    local  strTime = "";
    if seconds >= 60*60 then
        local hour = math.floor(seconds / (60*60));
        local min = math.floor((seconds - hour * 60*60) / 60);
        local second = seconds%60;
        strTime = string.format("%02d:%02d:%02d", hour, min, second);
    else
        local min = math.floor(seconds / 60);
        local second = seconds%60;
        strTime = string.format("%02d:%02d", min, second);
    end
    return strTime;
end

--[[
返回当前的系统时区（单位：秒）
--]]
function TimeLib.getTimeZone()
    local now = os.time()
    return os.difftime(now, os.time(os.date("!*t", now)))
end

return TimeLib;