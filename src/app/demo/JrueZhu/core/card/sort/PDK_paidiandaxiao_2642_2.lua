-- @Author: JamesYang
-- @Date:   2018-07-24 09:52:28
-- @Last Modified by   JamesYang
-- @Last Modified time 2018-07-25 10:08:37

local LibBase = import("..base.LibBase")
local M = class(LibBase);

function M:main(data)
	return CardUtils.getCardSizeByColorAndValue(data);
end

return M;