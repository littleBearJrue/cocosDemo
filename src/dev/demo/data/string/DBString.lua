
--DBString = {}

xg.loadString = function (ty)
	if ty == xg.LanguageType.Zh then
		cc.exports.DBString = require("dev.demo.data.string.zh.DBStringZh")
		
	else
		cc.exports.DBString = require("dev.demo.data.string.en.DBStringEn")
	end
end

xg.loadString(xg.LanguageType.Zh)

--return DBString