local function run(msg, matches)
if is_momod(msg) then
  local text = matches[1]
  local b = 1

  while b ~= 0 do
    text = text:trim()
    text,b = text:gsub('^!+','')
  end
  return text
end
end

return {
  description = "Reply Your Sent Message",
  patterns = {
    "^ بگو +(.+)$"
  }, 
  run = run,
  moderated = true
}