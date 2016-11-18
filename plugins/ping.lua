do

function run(msg, matches)
if is_owner(msg) then
  return "<b>I am online ͡° ͜ʖ ͡°</b>"
end
end
return {
  description = "", 
  usage = "",
  patterns = {
    "^[Pp][Ii][Nn][Gg]$",
  },
  run = run
}
end