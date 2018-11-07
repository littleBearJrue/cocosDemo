-- -- @Author: YiangYang
-- -- @Date:   2018-10-24 10:01:26
-- -- @Last Modified by:   YiangYang
-- -- @Last Modified time: 2018-10-29 17:13:07
-- local OutCardViewCtr = class("OutCardViewCtr",cc.load("boyaa").mvc.BoyaaCtr)


-- function OutCardViewCtr:ctor()
-- 	self:bindEvent()
-- end

-- function OutCardViewCtr:bindEvent()
-- 	self:bindEventListener("outCard",handler(self, self.updateViewWithOutCard))
-- 	self:bindEventListener("grabCard",handler(self, self.updateViewWithGrabCard))
-- end

-- ----获取底牌上面的cardview对象
-- function OutCardViewCtr:getDiPai()
-- 	return self.view:getDiPai()
-- end

-- --获取出牌上面的cardview对象
-- function OutCardViewCtr:getChuPai()
-- 	return self.view:getChuPai()
-- end

-- --根据出牌更新界面
-- function OutCardViewCtr:updateViewWithOutCard( data )
-- 	dump(data._usedata, "updateViewWithOutCard data -->")
-- 	self.view:updateViewWithOutCard(data)
-- end

-- ----根据抓牌更新界面
-- function OutCardViewCtr:updateViewWithGrabCard( data )
-- 	dump(data._usedata, "updateViewWithGrabCard data -->")
-- 	self.view:updateViewWithGrabCard(data)
-- end

-- return OutCardViewCtr