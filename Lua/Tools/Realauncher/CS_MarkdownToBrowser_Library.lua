--[[
@noindex
--]]
---------------------------------------------------------------------------------------
local htmlHead = [[
<head>
<title>Realauncher</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="..\3rdparty\github-markdown.css">
<style>
	body {
		background:#e1e2e1;
	}

	.markdown-body {
		background: white;
		box-sizing: border-box;
		min-width: 200px;
		max-width: 980px;
		margin: 0 auto;
		padding: 45px;
	}

	@media (max-width: 767px) {
		.markdown-body {
			padding: 15px;
		}
	}
</style>
</head>]]

local function fileExists(filePath)
	local f=io.open(filePath,"r")
	if f ~= nil then 
		f:close()
		return true
	else
		return false
	end
end

local function saveStringToTempFile(html)
	local attempts = 10
	
	local tempFilePath = rl.userSettingsPath.."\\tempFile_MDToBrowser.html"

	local tempFile = io.open(tempFilePath,"w")
	tempFile:write(html)
	tempFile:close()

	return  tempFilePath
end

local function deleteTempFile(filePath)
	local err, errmsg = os.remove(filePath)
	if not err then
		-- TODO handle error
	end
end

local function loadMarkdownConversor()
	package.path = package.path .. ";" .. rl.thirdPartyPath.."\\?.lua"
	md = require("md")
	return md.renderString
end

local function openHTMLFileInBrowser(htmlFile)
	-- TODO mac variant
	reaper.ExecProcess([[cmd /c "]]..htmlFile..[["]],0)
end

local function markdownToHTML(mkd)
	local conversor = loadMarkdownConversor()
	local conversorOptions = {
		-- https://github.com/bakpakin/luamd
								tag = "article",
								attributes = {class = "markdown-body"},
								prependHead = htmlHead,
							}
	local html,err = conversor(mkd,conversorOptions)
	-- TODO handle error
	return html
end
	
local function getFileContent(filePath)
	f = io.open(filePath, "r")
	if f then
		local content = f:read("a")
		f:close()
		return content
	end
end
function openMarkdownOnBrowser(mkd,isFilePath)
	if mkd then	
		if isFilePath then
			mkd = getFileContent(mkd)
		end
		
		local html = markdownToHTML(mkd)
		local filePath = saveStringToTempFile(html)
		openHTMLFileInBrowser(filePath)
		
	else
		-- TODO error. No String passed
	end
end

viewMarkdown = openMarkdownOnBrowser