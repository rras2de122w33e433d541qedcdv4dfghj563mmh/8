do

function run(msg, matches)
if is_sudo(msg) then
  return "I am online ͡° ͜ʖ ͡°"
else
return "انلاینم اصلا به تو چه من انلاینم یا افلاین😐"
end
end
return {
  description = "", 
  usage = "",
  patterns = {
    "^[Pp][Ii][Nn][Gg]",
    "^[!@/#][Pp][Ii][Nn][Gg]",
  },
  run = run
}
end
