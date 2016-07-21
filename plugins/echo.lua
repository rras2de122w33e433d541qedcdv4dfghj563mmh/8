 local function run(msg, matches)
  local text = '<code>'..matches[1]..'</code>'
  local b = 1

  while b ~= 0 do
    text = text:trim()
    text,b = text:gsub('^!+','')
  end
if is_momod(msg) then
  return text
else
return 'آقای '..msg.from.first_name..' این دستور برای شما مجاز نیست\nفقط برای مدیران'
end
end


return {
  description = "Simplest plugin ever!",
  usage = "!echo [whatever]: echoes the msg",
  patterns = {
    "^[/#!]echo +(.+)$"
  }, 
  run = run 
}
