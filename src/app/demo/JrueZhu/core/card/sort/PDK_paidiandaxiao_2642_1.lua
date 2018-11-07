-- @Author: JamesYang
-- @Date:   2018-07-24 09:52:28
-- @Last Modified by   JamesYang
-- @Last Modified time 2018-07-30 10:43:16

local LibBase = import("..base.LibBase")
local M = class(LibBase);

function M:main(data)
	return CardUtils.getCardSizeByValueAndColor(data);
end

return M;