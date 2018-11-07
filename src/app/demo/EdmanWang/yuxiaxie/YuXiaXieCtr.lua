-- @Author: EdmanWang
-- @Date:   2018-10-23 18:12:30
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-24 16:26:31
local YuXiaXieCtr = class("YuXiaXieCtr",cc.load("boyaa").mvc.BoyaaCtr);
local YuXiaXieView =  import("app.EdmanWang.yuxiaxie.YuXiaXieView");

function YuXiaXieCtr:ctor()
    self.YuXiaXieView = nil;
    self:initView();
    -- self:getChip_node()
end

function YuXiaXieCtr:initView()
	self.YuXiaXieView = YuXiaXieView.new();
	self:setView(self.YuXiaXieView);
end

function YuXiaXieCtr:getChip_node()
	-- local node  = self.YuXiaXieView.chipView:getChip_Node();
	-- local a = node:getChildByTag(1);
	-- local size  =a:getLocation();
	-- print("xxx",size.width,size.height);
    -- node:setContentSize(294,5);
    -- node:setColor(cc.c3b(255, 0, 0));
    -- print("mmmmm",node:getContentSize().width,node:getContentSize().height);

    -- local node = cc.Node:create();
    -- node:setContentSize(294,5);

end

return YuXiaXieCtr;