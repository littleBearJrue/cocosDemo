-- @Author: RonanLuo
-- @Date:   2018-01-02 09:52:28
-- @Last Modified by:   RonanLuo
-- @Last Modified time: 2018-01-02 09:55:32

local LibBase = import("..base.LibBase")
local M = class(LibBase);

function M:main(data)
	return CardUtils.getCardSize(data);
end

return M;