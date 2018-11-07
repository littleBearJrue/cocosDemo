-- @Author: EdmanWang
-- @Date:   2018-10-17 10:01:38
-- @Last Modified by:   EdmanWang
-- @Last Modified time: 2018-10-17 18:45:43

--[[-
    特别注意：button 控件在cocos/ui文件夹下。调用ui文件夹下面的类的时候，使用的方式是ccui.xxx:create(参数)
    具体的方法的实现需要看官方的api
    button:的点击事件 addClickEventListener
-]]
local function create_button(  )
	local scene = display.newScene("button");
 	--加载资源图片
	local images = {
          normal = "button/Button01.png"; --正常显示
          pressed = "button/Button01Disabled.png"; --按下时显示
          disabled = "button/Button01Pressed.png";  -- 禁止操作时候显示
    }
    local btn = ccui.Button:create(images.normal, images.pressed, images.disabled);
    btn:addClickEventListener(function ( event )  --addClickEventListener
    	print("我点击了",event.name);
    end)
    btn:setTitleText("wgx")
    btn:setPosition(100,10);
    btn:addTo(scene);
	return scene;
end

function main( ... )
  local scene = create_button();
  scene:addChild(CreateBackMenuItem());
	return scene;
end

return main;