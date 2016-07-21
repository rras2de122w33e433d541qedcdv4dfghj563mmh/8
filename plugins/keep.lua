	do	
	    function run(msg, matches)
	    local text1 = matches[2]
        local text2 = matches[3]
	  	local text3 = matches[4]
local color = {

"e31f17&tc",
"1b037d&tc",
"0cc0fd&tc",
"926FE3&tc",
"CCD4A1&tc",
"D4AF37&tc",
"7249E3&tc",
"e3068d&tc", 
}
local color1 = {
"000000&cc",
"ffffff&cc",
"d4af37&cc",
"fffdd0&cc",
"fffdd0&cc",
"D44215&cc",
}
local color2 = {
"000000&uc",
"d4af37&uc",
"fffdd0&uc",
"D44215&uc",
}
local c = color[math.random(#color)]
local cc =color1[math.random(#color1)]
local ccc =color2[math.random(#color2)]

local url ="http://www.keepcalmstudio.com/-/p.php?t=%EE%BB%BD%0D%0AKEEP%0D%0ACALM%0D%0A"..text1.."%0D%0A"..text2.."%0D%0A"..text3.."&bc="..c.."="..cc.."="..ccc.."=true&ts=true&ff=PNG&w=500&ps=sq"
		 local  file = download_to_file(url,'keep.webp')
			send_document(get_receiver(msg), file, ok_cb, false)

        
end
return {
  description = "تبدیل متن به لوگو",
  usage = {
    "/keep calm font text: ساخت لوگو",
  },
  patterns = {
   "^[#!/]([Kk][Ee][Ee][Pp] [Cc][Aa][Ll][Mm]) (.+) (.+) (.+)$",
  },
  run = run
}

end
