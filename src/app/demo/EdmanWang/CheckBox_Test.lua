-- @Author: EdmanWang
-- @Date:   2018-10-17 18:50:51
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-19 09:28:22


--[[-
       /**
     * Create an checkbox with various images.
     *
     * @param backGround    backGround texture.
     * @param backGroundSelected    backGround selected state texture.
     * @param cross    cross texture.
     * @param backGroundDisabled    backGround disabled state texture.
     * @param frontCrossDisabled    cross dark state texture.
     * @param texType    @see `Widget::TextureResType`
     *
     * @return A CheckBox instance pointer.
     */
    static CheckBox* create(const std::string& backGround,    -- 场景加载checkBox的时候，默认显示的图片
                            const std::string& backGroundSelected, -- 点击时候，显示的图片
                            const std::string& cross,  -- 松开点击（即为选中的时候的图片）
                            const std::string& backGroundDisabled,  -- 不可点击的时候的图片
                            const std::string& frontCrossDisabled,   -- 渐变色 
                            TextureResType texType = TextureResType::LOCAL);  -- 纹理
-]]

--[[-上面是checkbox 在c++中的源码，create方法-]]
local function checkBox_create()
	local images = {
        off = "button/CheckBoxButtonOff.png";
        off_pressed = "button/CheckBoxButtonOffPressed.png";
        off_disabled = "button/CheckBoxButtonOffDisabled.png";
        on = "button/CheckBoxButtonOn.png";
        on_pressed = "button/CheckBoxButtonOnPressed.png";
        on_disabled = "button/CheckBoxButtonOnDisabled.png";
    }

    local checkBox = ccui.CheckBox:create(images.off,
    	                                  -- images.on_pressed,
                                          images.on)
    	-- );
    checkBox:move(display.cx,display.cy);

    checkBox:addEventListener(function (target,selector)
		--selector 0:选中 CHECKBOX_STATE_EVENT_SELECTED； 1:没选 CHECKBOX_STATE_EVENT_UNSELECTED 
		dump(target,"checkbox target =")
		dump(selector,"checkbox selector =")
		dump(CHECKBOX_STATE_EVENT_SELECTED,"checkbox 000 =")
	end)

	return checkBox;
end

local function createBtn()
	local btn = ccui.Button:create(s_PlayNormal, s_PlaySelect, s_PlayNormal, 0)
    :move(display.cx, display.cy+50)
    btn:setAnchorPoint(cc.p(0.5, 0.5))
    return btn
end 

function main()
	local scene = cc.Scene:create()
    
    local box = checkBox_create()
    local btn = createBtn()
    btn:addClickEventListener(function ()
    	box:setEnabled(false) --禁用
    end)

    scene:addChild(box)
    scene:addChild(btn)
    scene:addChild(CreateBackMenuItem())
    return scene
end

return main;