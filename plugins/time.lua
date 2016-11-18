

function run(msg, matches)
local url , res = http.request('http://api.gpmod.ir/time/')
if res ~= 200 then return "No connection" end
local jdat = json:decode(url)
local text = '<b>Ir Time:</b><code>'..jdat.FAtime..'</code> \n<b> Ir Data:</b><code>'..jdat.FAdate..'</code>\n    ------------\n<b>En Time:</b><i>'..jdat.ENtime..'</i>\n<b>En Data:</b><i>'..jdat.ENdate.. '</i>'
return text
end
return {
  patterns = {"^[/!]([Tt][iI][Mm][Ee])$"}, 
run = run 
}


