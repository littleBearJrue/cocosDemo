--[[--ldoc desc
@module Bit
@author JrueZhu

Date   2018-10-22 17:32:13
Last Modified by   JrueZhu
Last Modified time 2018-10-24 10:26:25
]]
local Bit = {};

function Bit:brShift(data, num)
    return math.modf(data / 2^num);
end

local function b2d(arg)  --bit:b2d 
    local   nr=0  
    for i=1,32 do  
        if arg[i] ==1 then  
        nr=nr+2^(32-i)  
        end  
    end  
    return  nr  
end

local function d2b(arg)  --bit:d2b  
    local bit = {
        data32 = {}
    }; 

    for i = 1, 32 do  
        bit.data32[i] = 2^(32 - i);  
    end  
  
    local tr = {};  
    for i = 1, 32 do  
        if arg >= bit.data32[i] then  
            tr[i] = 1; 
            arg = arg - bit.data32[i];
        else  
            tr[i] = 0;
        end  
    end  
    return tr;  
end   

function Bit:band(a, b)
    local op1 = d2b(a);
    local op2 = d2b(b); 
    local r = {};  
      
    for i = 1, 32 do  
        if op1[i] == 1 and op2[i] == 1 then  
            r[i] = 1;  
        else  
            r[i] = 0;  
        end  
    end  
    return b2d(r)     
end

function Bit:byteToValue(byte, type)
    return byte - type * 0x10;
end

function Bit:toByte(type, value)
    return type * 0x10 + value;
end

return Bit;