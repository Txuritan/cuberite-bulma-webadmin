-- Use a table for fast concatenation of strings
local SiteContent = {}
function Output(String)
	table.insert(SiteContent, String)
end





function GetTableSize(Table)
	local Size = 0
	for key,value in pairs(Table) do
		Size = Size + 1
	end
	return Size
end





local function GetDefaultPage()
	local PM = cRoot:Get():GetPluginManager()

	local SubTitle = "Current Game"
	local Content = ""

	Content = Content .. "<h4>Plugins:</h4><ul>"
	PM:ForEachPlugin(
		function (a_CBPlugin)
			if (a_CBPlugin:IsLoaded()) then
				Content = Content ..  "<li>" .. a_CBPlugin:GetName() .. " (version " .. a_CBPlugin:GetVersion() .. ")</li>"
			end
		end
	)

	Content = Content .. "</ul>"
	Content = Content .. "<h4>Players:</h4><ul>"

	cRoot:Get():ForEachPlayer(
		function(a_CBPlayer)
			Content = Content .. "<li>" .. a_CBPlayer:GetName() .. "</li>"
		end
	)

	Content = Content .. "</ul><br>";

	return Content, SubTitle
end





function ShowPage(WebAdmin, TemplateRequest)
	SiteContent = {}
	local BaseURL = cWebAdmin:GetBaseURL(TemplateRequest.Request.Path)
	local Title = "Cuberite WebAdmin"
	local NumPlayers = cRoot:Get():GetServer():GetNumPlayers()
	local MemoryUsageKiB = cRoot:GetPhysicalRAMUsage()
	local NumChunks = cRoot:Get():GetTotalChunkCount()
	local PluginPage = cWebAdmin:GetPage(TemplateRequest.Request)
	local PageContent = PluginPage.Content
	local SubTitle = PluginPage.PluginFolder
	if (PluginPage.UrlPath ~= "") then
		SubTitle = PluginPage.PluginFolder .. " - " .. PluginPage.TabTitle
	end
	if (PageContent == "") then
		PageContent, SubTitle = GetDefaultPage()
	end

	--[[
	-- 2016-01-15 Mattes: This wasn't used anywhere in the code, no idea what it was supposed to do
	local reqParamsClass = ""
	for key, value in pairs(TemplateRequest.Request.Params) do
		reqParamsClass = reqParamsClass .. " param-" .. string.lower(string.gsub(key, "[^a-zA-Z0-9]+", "-") .. "-" .. string.gsub(value, "[^a-zA-Z0-9]+", "-"))
	end
	if (string.gsub(reqParamsClass, "%s", "") == "") then
		reqParamsClass = " no-param"
	end
	--]]

	Output([[
<!DOCTYPE html>
<!-- Copyright Justin S and Cuberite Team, licensed under CC-BY-SA 3.0 -->
<html>

<head>
	<title>]] .. Title .. [[</title>
	<meta charset="UTF-8">
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.4.1/css/bulma.min.css" />
	<link rel="icon" href="/favicon.ico">
</head>

<body>
    <div class="container is-fluid">
        <nav class="nav">
            <div class="nav-left">
                <a class="nav-item">
                    <img src="/logo_login.png" alt="Cuberite Logo" style="filter: invert(100%);">
                </a>
            </div>
        
            <div class="nav-right nav-menu" id="nav-menu">
                <a class="nav-item">
                    Players: ]] .. NumPlayers .. [[
                </a>
                <a class="nav-item">
                    Memory: ]] .. string.format("%.2f", MemoryUsageKiB / 1024) .. [[MB
                </a>
                <a class="nav-item">
                    Chunks: ]] .. NumChunks .. [[
                </a>
                <a class="nav-item">
                    Welcome back, ]] .. TemplateRequest.Request.Username .. [[
                </a>
                <div class="nav-item">
                    <div class="field is-grouped">
                        <p class="control">
                            <a class="button" href="/webadmin/">
                                <span class="icon">
                                    <i class="fa fa-sign-out" aria-hidden="true"></i>
                                </span>
                                <span>Sign Out</span>
                            </a>
                        </p>
                    </div>
                </div>
            </div>
            
            <span class="nav-toggle" id="nav-toggle">
                <span></span>
                <span></span>
                <span></span>
            </span>
        </nav>
    </div>
    
    <section class="hero is-dark">
        <div class="hero-body container">
            <div class="columns">
                <div class="column is-one-quarter">
                    <nav class="panel">
                        <p class="panel-heading">
                            Menu
                        </p>
                        
                        <a class="panel-block" href="]] .. BaseURL .. [[" style="background-color: #ffffff; color: #363636;">
                            <span class="panel-icon">
                                <i class="fa fa-home" aria-hidden="true"></i>
                            </span>
                            Home
                        </a>
                        
                        <a class="panel-block" style="background-color: #ffffff; color: #363636;">
                            <span class="panel-icon">
                                <i class="fa fa-server" aria-hidden="true"></i>
                            </span>
                            Server Management
                        </a>
                        
                        <div class="panel-block" style="background-color: #ffffff;">
                            <div class="menu">
]])

    -- Get all tabs:
	local perPluginTabs = {}
	for _, tab in ipairs(cWebAdmin:GetAllWebTabs()) do
		local pluginTabs = perPluginTabs[tab.PluginName] or {};
		perPluginTabs[tab.PluginName] = pluginTabs
		table.insert(pluginTabs, tab)
	end
	
	-- Sort by plugin:
	local pluginNames = {}
	for pluginName, pluginTabs in pairs(perPluginTabs) do
		table.insert(pluginNames, pluginName)
	end
	table.sort(pluginNames)
	
	-- Output by plugin, then alphabetically:
	for _, pluginName in ipairs(pluginNames) do
		local pluginTabs = perPluginTabs[pluginName]
		table.sort(pluginTabs,
			function(a_Tab1, a_Tab2)
				return ((a_Tab1.Title or "") < (a_Tab2.Title or ""))
			end
		)
		
		-- Translate the plugin name into the folder name (-> title)
		local pluginWebTitle = cPluginManager:Get():GetPluginFolderName(pluginName) or pluginName
		Output("<p class='menu-label'>" .. pluginWebTitle .. "</p>\n");
        
        Output("<ul class='menu-list'>\n");
		-- Output each tab:
		for _, tab in pairs(pluginTabs) do
			Output("<li><a href='" .. BaseURL .. pluginName .. "/" .. tab.UrlPath .. "'>" .. tab.Title .. "</a></li>\n")
		end
		Output("</ul>");
	end
                            
Output([[
                            </div>
                        </div>
                    </nav>
                </div>
                <div class="column">
                    <nav class="panel">
                        <p class="panel-heading">
                            ]] .. SubTitle .. [[
                        </p>
                        
                        <div class="panel-block content" style="background-color: #ffffff; display: block;">
                            ]] .. PageContent .. [[
                            </table>
                        </div>
                        
                    </nav>
                </div>
            </div>
        </div>
    </section>

    <footer class="footer" style="background-color: #ffffff;">
        <div class="container">
            <div class="columns">
                <div class="column">
                    <a href="https://cuberite.org/" target="_blank">Cuberite</a>
                </div>
                <div class="column">
                    <a href="https://forum.cuberite.org/" target="_blank">Forums</a>
                </div>
                <div class="column">
                    <a href="https://builds.cuberite.org/" target="_blank">Buildserver</a>
                </div>
                <div class="column">
                    <a href="https://api.cuberite.org/" target="_blank">API Documentation</a>
                </div>
                <div class="column">
                    <a href="https://book.cuberite.org/" target="_blank">User's Manual</a>
                </div>
            </div>
            <div class="columns">
                <div class="column">
                    Copyright © <a href="https://cuberite.org/" target="_blank">Cuberite Team</a>.
                </div>
            </div>
        </div>
    </footer>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script>
        jQuery(document).ready(function ($) {
            var $toggle = $('#nav-toggle');
            var $menu = $('#nav-menu');
            
            $toggle.click(function() {
                $(this).toggleClass('is-active');
                $menu.toggleClass('is-active');
            });
            
            $('button').each(function(index,item){
                $(item).addClass('button');
            });
            
            $('input[type=text]').each(function(index,item){
                $(item).addClass('input');
            });
            
            $('input[type=submit]').each(function(index,item){
                $(item).addClass('button');
            });
            
            $('td[width="1px"]').each(function(index,item){
                $(item).attr('width', '');
            });
            
            $('td[width="50%"]').each(function(index,item){
                $(item).remove();
            });
            
            if (window.location.pathname == '/webadmin/Core/Whitelist') {
                
            }
        });
    </script>
</body>

</html>
]])

	return table.concat(SiteContent)
end
