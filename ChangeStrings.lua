
--ChangeStrings_1.4 
--last updated on 18.07.2020 by Noah Hähnel
--created by Noah Hähnel


--To Do: 
--			 1. Add bigger QuickSelect feature
--			 2. Update the notes so others can more easily understand what's happening





local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 650,400

--finds current mouse position 
MouseX = fu:GetMousePos()[1]
MouseY = fu:GetMousePos()[2]

	print('_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _')
	print(' ')
	print('Change Strings Opened.')
	print('_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _')
	print(' ')

	--checks to see if Fusion or Resolve is used

host = fusion:MapPath('Fusion:/')

if string.lower(host):match('resolve') then
		Fusion_S = false
		print('Working in DaVinci Resolve mode')
		print('Remembering Inputs in Global Fusion Preferences')
		resolve = Resolve()
	  pm = resolve:GetProjectManager()
		comp = fusion --VERY IMPORTANT TO USE composition: for everything that is not able to write in the Fusion preferences
    
else
		Fusion_S = true
		print('Working in Fusion Standalone mode')
   
end

Global = fusion:GetPrefs('Comp.ChangeStrings.OldDoResolve')

if Fusion_S == true then
if Global == 'Checked' then
comp = fusion
else
comp = composition
end
end

if comp == fusion then
print('Global mode')
elseif comp == composition then
print('Local mode')
end
 
if comp:GetPrefs('Comp.ChangeStrings') then
OldData = comp:GetPrefs('Comp.ChangeStrings')
end

pattern_breaker = 'ïèëï'
limit = 30
debugging = true

if OldData then
if OldData.OldDoDebugging == 'Checked' then
debugging = true
else
debugging = false
end

if OldData.OldPatternBreakerInput ~= '' then
pattern_breaker = OldData.OldPatternBreakerInput
end
if OldData.OldPatternBreakerInput == nil then
pattern_breaker = 'ïèëï'
end

if OldData.OldMaxLimit ~= '' then
limit = tonumber(OldData.OldMaxLimit)
end
if OldData.OldMaxLimit == nil then
limit = 30
end

end


if debugging == true then
print('Prints actions to the console')
else
print('')
end


if pattern_breaker == 'ïèëï' then
print('Pattern Breaker is the default: ', pattern_breaker)
else
print('Pattern Breaker is the custom: ', pattern_breaker)
end

if limit == 30 then
print('Limit is the default: ', limit)
else
print('Limit is the custom: ', limit)
end

if OldData == nil then
	print('No previous Settings found in this Composition file')

end




--The following two functions are from the bmd.scriptlib:

-- trim(strTrim)
--
-- returns strTrim with leading and trailing spaces
-- removed.
--
-- introduced bmd.dfscriptlib v1.0
-- last updated in v1.3
-----------------------------------------------------
function trim(strTrim)
	strTrim = string.gsub(strTrim, "^(%s+)", "") -- remove leading spaces
	strTrim = string.gsub(strTrim, "(%s+)$", "") -- remove trailing spaces
	return strTrim
end
-- split(strInput, delimit)
--
-- converts string strInput into a table, separating
-- records using the provided delimiter string
--
-----------------------------------------------------
function split(strInput, delimit)
	local strLength
	local strTemp
	local strCollect
	local tblSplit
	local intCount

	tblSplit = {}
	intCount = 0
	strCollect = ""
	if delimit == nil then
		delimit = ","
	end

	strLength = string.len(strInput)
	for i = 1, strLength do
		strTemp = string.sub(strInput, i, i)
		if strTemp == delimit then
			intCount = intCount + 1
			tblSplit[intCount] = trim(strCollect)
			strCollect = ""
		else
			strCollect = strCollect .. strTemp
		end
	end
	intCount = intCount + 1
	tblSplit[intCount] = trim(strCollect)

	return tblSplit
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--function magic()
--This is the main search and replace function
--It does not actually return something but rather does the whole search, replace and checking
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function magic()	
SearchTable = split(itm.SearchforInput:GetText(), ' ' )   --splits the strings
ReplaceTable = split(itm.ReplacewithInput:GetText(), ' ') --into tables
table_length = #ReplaceTable --find out how many inputs the replace with table has
last_input = ReplaceTable[table_length]

if last_input == nil then
last_input = ''
end
			
		for y, current_search in pairs(SearchTable) do --go over all selected tools as many times as there are inputs in the SearchTable

			
a = 0
			repeat

tool_s = current_tool:GetAttrs()

if itm.DoCaseSensitive.Checked == true then
if debugging == true then
print('Case sensitive mode')
end
Repeat = false
Case = true
else
Repeat = true
Case = false
if debugging == true then
print('Case insensitive mode')
end
end


length = string.len(SearchTable[y])


if SearchTable[y] == '' then
				 SearchTable[y] = ' '
end

if SearchTable[y] == '.' then
	 SearchTable[y] = '%.'
	 print('Change Strings will search for ".", Luas "All Characters" searches are not supported, if that was your intention')
end


if SearchTable[y] == '%d' or SearchTable[y] == '%l' or SearchTable[y] == '%u' or SearchTable[y] == '%a' or SearchTable[y] == '%c' or SearchTable[y] == '%p' or SearchTable[y] == '%.' or SearchTable[y] == '%s' then
Case = true
print('TESSSST')
if debugging == true then 
print('Lua Shortcode detected')
if SearchTable[y] == '%d' then
print('Searching for all digits')
elseif SearchTable[y] == '%l' then
print('Searching for all lower case letters')
elseif SearchTable[y] == '%u' then
print('Searching for all upper case letters')
elseif SearchTable[y] == '%a' then
print('Searching for all letters')
elseif SearchTable[y] == '%c' then
print('Searching for all control characters')
elseif SearchTable[y] == '%p' then
print('Searching for all punctuation characters')
elseif SearchTable[y] == '%.' then
print('Searching for all dots')
elseif SearchTable[y] == '%s' then
print('Searching for all spaces')
end

end


--The following is to make % signs possible to search and replace. Not a particular elegant way but it works
 
elseif SearchTable[y] ~= '%d' or SearchTable[y] ~= '%l' or SearchTable[y] ~= '%u' or SearchTable[y] ~= '%a' or SearchTable[y] ~= '%c' or SearchTable[y] ~= '%p' or SearchTable[y] ~= '%.' or SearchTable[y] ~= '%s' then
shortcoded = string.find(SearchTable[y], '%d')
shortcodel = string.find(SearchTable[y], '%l')
shortcodeu = string.find(SearchTable[y], '%u')
shortcodea = string.find(SearchTable[y], '%a')
shortcodec = string.find(SearchTable[y], '%c')
shortcodep = string.find(SearchTable[y], '%p')
shortcodes = string.find(SearchTable[y], '%s')
percentage = string.find(SearchTable[y], '%%')

if percentage ~= nil and shortcodea == nil and shortcodec == nil and shortcoded == nil and shortcodel == nil and shortcodep == nil and shortcodes == nil and shortcodeu == nil then

hack = '%%'
SearchTable[y] = string.gsub(SearchTable[y], '%%', string.rep(hack, 2))
end

if ReplaceTable[y] ~= nil and a == 0 then
if ReplaceTable[y] == '%%%' then
ReplaceTable[y] = '%%%%%%'
else

percentageR = string.find(ReplaceTable[y], '%%')

if percentageR ~= nil then
hack = '%%'
ReplaceTable[y] = string.gsub(ReplaceTable[y], '%%', string.rep(hack, 2))
end

percentageR = string.find(last_input, '%%')
if percentageR ~= nil and a == 0 then
hack = '%%'
ReplaceTable[y] = string.gsub(last_input, '%%', string.rep(hack, 2))
end
end
end
end



		
				if debugging == true then
					 print('')
			  	 print('Current Tool: ', tool_s.TOOLS_Name)
				end
				
				if mode == 'Name' then
				String = tool_s.TOOLS_Name
					if debugging == true then
					print('Running over Names')
				end
				end
				if mode == 'Expression' then
				String = inputs:GetExpression()
				if debugging == true then
					print('Running over Expressions')
					print('Current Expression: ', String)
				end
				end
				if mode == 'Loader' or mode == 'Saver' then
				String = tool_s.TOOLST_Clip_Name[1]
					if debugging == true then
					print('Running over Filepaths in', mode)
				end
				end
				if mode == 'Proxy' then
				String = tool_s.TOOLST_AltClip_Name[1]
					if debugging == true then
					print('Running over Proxy Filepaths')
				end
				end
				if mode == 'Styled Text' then
				CT = composition.CurrentTime
				String = current_tool.StyledText[CT]
				if debugging == true then
					print('Running over Styled Text')
					print('At current time: ', CT)
				end
				end
				if String ~= nil then
					if Case == true then
					search_start, search_end = string.find(String, SearchTable[y])
					else
					search_start, search_end = string.find(string.lower(String), string.lower(SearchTable[y])) --turn everything lower case and find out where in the tools name the current SearchTable Input is
				  end
				
				if search_start ~= nil and String ~= nil then
				pattern = string.sub(String, search_start, search_end)
				print('Pattern: ', pattern)
				end
				
				if ReplaceTable[y] == nil then  --if the ReplaceTable is empty meaning the SearchTable is longer than the ReplaceTable, then it will use the last available ReplaceTable input
				ReplaceTable[y] = last_input
				end
				
					    temporary_ReplaceTable_length = string.len(ReplaceTable[y])
							if ReplaceTable[y] == '%%' or ReplaceTable[y] == '%%%%%%' then
							
							temporary_ReplaceTable = ReplaceTable[y]
								
							else
							temporary_ReplaceTable_a = string.sub(ReplaceTable[y], 1, (temporary_ReplaceTable_length/2))
							temporary_ReplaceTable_b = string.sub(ReplaceTable[y], (temporary_ReplaceTable_length/2+1), -1)
							temporary_ReplaceTable = temporary_ReplaceTable_a .. pattern_breaker .. temporary_ReplaceTable_b
							
							end
						  
							if Case == true and length ~= 1 then
							print('R1')
							new_string, subcount = string.gsub(String, SearchTable[y], temporary_ReplaceTable, limit)
							elseif Case == false and length ~= 1 and percentage == nil and percentageR == nil and pattern ~= nil then
							print('R2 ')
							new_string, subcount = string.gsub(String, pattern, temporary_ReplaceTable, limit)
							pattern = nil
							elseif Case == false and length ~= 1 and percentage ~= nil and percentageR == nil and pattern ~= nil then
							print('R2_2 ')
							new_string, subcount = string.gsub(String, pattern, temporary_ReplaceTable, limit)
							pattern = nil
							prevention = 1
							elseif Case == false and length == 1 then
							print('R3')
							new_string, subcount_a = string.gsub(String, string.lower(SearchTable[y]), ReplaceTable[y], limit)
							new_string, subcount_b = string.gsub(new_string, string.upper(SearchTable[y]), ReplaceTable[y], limit)
							Repeat = false
							elseif Case == false and length ~= 1 and percentage ~= nil and prevention ~= 1 then
							print('R4')
							new_string, subcount_a = string.gsub(String, string.lower(SearchTable[y]), ReplaceTable[y], limit)
							new_string, subcount_b = string.gsub(new_string, string.upper(SearchTable[y]), ReplaceTable[y], limit)
							Repeat = false
							elseif Case == false and length ~= 1 and percentageR ~= nil and prevention ~= 1 then
							print('R5')
							new_string, subcount = string.gsub(String, pattern, temporary_ReplaceTable, limit)
							Repeat = true
							elseif Case == true and length == 1 then
							print('R6')
							new_string, subcount = string.gsub(String, SearchTable[y], ReplaceTable[y], limit)
							end
							
							if debugging == true then
							print('')
							print('Temporary Replacement: ', temporary_ReplaceTable)
							print('')
							print('Doing Search Table Input:')
							dump(SearchTable[y])
							if ReplaceTable[y] == last_input then
							print('Using last Replace Table Input:')
							else
							print('Using this Replace Table Input:')
							end
							dump(ReplaceTable[y])
							
							if subcount == limit or subcount_a == limit or subcount_b == limit then
							print('')
							print('Max Replace limit was reached while doing this replacement')
							print('You might need to increase the Max Replace limit in the Advanced Settings')
							print('Current limit is: ', limit, 'replacements for each', mode)
							print('')
							end
							end

		if new_string ~= nil then
			  if mode == 'Name' then
				current_tool:SetAttrs( { TOOLB_NameSet = true, TOOLS_Name = new_string } ) --make the new_name the tools new name and flag it as having its name changed
				end
				if mode == 'Expression' then
				inputs:SetExpression(new_string)
				end
				if mode == 'Loader' or mode == 'Saver' then
				current_tool.Clip[TIME_UNDEFINED] = new_string
				end
				if mode == 'Proxy' then
				current_tool.ProxyFilename[1] = new_string
				end
				if mode == 'Styled Text' then
				current_tool.StyledText = new_string
				end
				if debugging == true then
				print('Loop: ', y, 'Old',mode,':',String, 'New',mode,':',new_string)
				print('')
			end
				end



a = a+1
if debugging == true and Repeat == true then
print('Repeat to double check. Counter: ', a)
end
else
print('Error cannot replace')
Repeat = false
end

until(search_start == nil or a>limit or Repeat == false)		
	if debugging == true and Repeat == true then
		 print('Loop broken because:')
		if a>limit then
			 print('Max Limit of: ', limit, ' reached')
		else
			 print('Pattern: ', SearchTable[y], ' not found again')
		end
		print('')
	end


		end
		
if mode == 'Name' then
tool_s = current_tool:GetAttrs()
String = tool_s.TOOLS_Name 
end
if mode == 'Expression' then
String = inputs:GetExpression()
end
if mode == 'Loader' or mode == 'Saver' then
tool_s = current_tool:GetAttrs()
String = tool_s.TOOLST_Clip_Name[1]
end
if mode == 'Proxy' then
tool_s = current_tool:GetAttrs()
String = tool_s.TOOLST_AltClip_Name[1]
end
if mode == 'Styled Text' then
String = current_tool.StyledText[CT]
end

if String ~= nil then

new_string = string.gsub(String, pattern_breaker, '')
end


	
if new_string ~= nil then	
	if mode == 'Name' then
	current_tool:SetAttrs( { TOOLB_NameSet = true, TOOLS_Name = new_string } ) --make the new_string the tools new name and flag it as having its name changed	
	end
	if mode == 'Expression' then
	inputs:SetExpression(new_string)
	end
	if mode == 'Loader' or mode == 'Saver' then
	current_tool.Clip[TIME_UNDEFINED] = new_string
	end
	if mode == 'Proxy' then
	current_tool.ProxyFilename[1] = new_string
	end
	if mode == 'Styled Text' then
	current_tool.StyledText[CT] = new_string
	end
	
if debugging == true then
	print('')
	print('Cleaning up the Pattern Breaker: ', pattern_breaker , 'Old',mode,':',String,'New',mode,':',new_string)
	print('')
	
end
new_string = nil 
prevention = nil
end	

end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--This was the main search and replace function
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--function mergetables(table1, table2) returns table3 which is both tables combined
--This is currently only used to to combine the selected tools with the modifiers that are connected to those tools
--It does NOT handle nil in tables but this is not an issue for the current usage
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function mergetables(table1, table2)
if debugging == true then
print('Merging Selected Tools and their connected Modifiers')
end

table3 = {}
count = 1
for e, element in pairs(table1) do
table3[e] = element
count = count + 1
end

for e, element in pairs(table2) do
table3[e+count] = element
end

if debugging == true then
dump('Merged Table: ', table3)
end
return(table3)

end





win = disp:AddWindow({

	ID = 'ChangeStringsWindow',
	WindowTitle = 'Change Strings',
	Geometry = {MouseX+25, MouseY, width, height}, --creates the window at the current mouse position with the same width and height as the window was defined
	Margin = 10, --margin to the window borders

	ui:VGroup{ --This creates a vertical alignment of the UI
		ID ='ChangeStringsroot',
		-- UI Elements are placed here
			
			ui:HGroup{
			
			ui:Button{
			ID = 'QuickSelect',
			Text = 'QuickSelect',
			Weight = 0.1,
			Visible = false --For a future release
			},
			
			ui:Label{
			ID = 'Title',
			Alignment = {AlignHCenter = true, AlignVCenter= true},
			Text = '<h1> Change Strings</h1>',
				},
				
			ui:Button{
			ID = 'AboutButton',
			Text = 'About',
			Weight = 0.1,
			},
			
			},
			
			ui:VGap(5),
			
			ui:HGroup{ --This will force the next elements to be placed horizontally until the next HGroup is opened
			
			ui:Label{ID = 'LabelSearchfor', 
			Text = 'Search for:', 
			Alignment = {AlignHCenter = true, AlignVCenter = true},
			Weight = 0.25, --changes the relative length of the label
			},
			
			
			ui:LineEdit{  
			ID = 'SearchforInput', 
			Text = '', 
			PlaceholderText = ' Seperate with empty spaces. Click the "?" for more info',
			ClearButtonEnabled = true,
			
			},
			Weight = 0.1, --changes the relative height of the text box
								
			ui:Label{
			ID = 'help0',
			HTML = true,
			OpenExternalLinks = true,
			Weight = 0,1,
			Text = '<a href="' .. 'https://noahhaehnel.com/blog/manual-changestrings#Search_for_and_Replace_with_Text_field' .. '">?</a>',
		
			},					
								},
							
	
		ui:HGroup{
		
		ui:HGap(0,0.45),
		
		ui:Button{
		ID = 'Switch',
		Text = '↕',
		Weight = 0.1,
		
		},
		ui:HGap(0,0.45),
		
		},
		
			ui:HGroup{
		
			ui:Label{
			ID = 'LabelReplacewith', 
			Text = 'Replace with:', 
			Alignment = {AlignHCenter = true, AlignVCenter = true},
			Weight = 0.25,
			},
			
			ui:LineEdit{
			ID = 'ReplacewithInput', Text = '', 
			PlaceholderText = ' Seperate with empty spaces',
			ClearButtonEnabled = true,
			
			},
			Weight = 0.1, --changes the relative height of the text box
			
			ui:Label{
			ID = 'help1',
			HTML = true,
			OpenExternalLinks = true,
			Weight = 0,1,
			Text = '<a href="' .. 'https://noahhaehnel.com/blog/manual-changestrings#Search_for_and_Replace_with_Text_field' .. '">?</a>',
		
			},
							},
							
	ui:Label{
		ID = 'LabelReplaceIn',
		Text = '<h3>Replace in:</h3>',
		Alignment = {AlignHCenter = true, AlignVCenter = true},

		
		},
	
		ui:VGroup{

		
		ui:HGroup{
		ui:Label{
		ID = 'Texts',
		Text = 'Texts:',
		},
		
		ui:CheckBox{
		ID = 'DoNames', 
		Text = 'Names',
		Default = 1,
		},
		ui:CheckBox{
		ID = 'DoExpressions', 
		Text = 'Expressions',
	  
		},
		ui:CheckBox{
		ID = 'DoTextbox', 
		Text = 'Styled Text',
	  
		},
		},
		
		
		
	ui:HGroup{
	
		ui:Label{
		ID = 'Filepaths',
		Text = 'Filepaths:',
		},
	
		ui:CheckBox{
		ID = 'DoLoader', 
		Text = 'Loaders',
		},
		
		ui:CheckBox{
		ID = 'DoProxy', 
		Text = 'Proxys',
		},
		ui:CheckBox{
		ID = 'DoSaver', 
		Text = 'Savers',
		},	
		},
		
		ui:Label{
		ID = 'LabelBreaker',
		Text = '_____________________________________________________________________________________________________________',
		Alignment = {AlignHCenter = true, AlignVCenter = true},
		
		},
		ui:VGap(5),
	ui:HGroup{
	
		ui:Label{
		ID = 'QuickSelectStrip',
		Text = 'QuickSelect:',
		},
	
	 ui:Button{
	 ID = 'SelectLoaders',
	 Text = 'Loaders',
							},
	
	 ui:Button{
	 ID = 'SelectLS',
	 Text = 'L + S',
							},
	 ui:Button{
	 ID = 'SelectSavers',
	 Text = 'Savers',
							},						
	 ui:Button{
	 ID = 'SelectPrevious',
	 Text = 'Previous',
							},	
	
	ui:VGap(0,0.5)
	
	},


	},
		
		ui:Label{
		ID = 'LabelBreaker',
		Text = '_____________________________________________________________________________________________________________',
		Alignment = {AlignHCenter = true, AlignVCenter = true},
		
		},
	
	ui:HGroup{
		
		ui:Label{
		ID = 'LabelSettings',
		Text = 'Settings:',
		Weight = 0.2,
		},
		
		ui:CheckBox{
		ID = 'DoCaseSensitive', 
		Text = 'Be Case Sensitive',
		},
		
		ui:CheckBox{
		ID = 'DoModifier', 
		Text = 'Include Modifiers',
		Tristate = true,
		},
		
		ui:CheckBox{
		ID = 'DoRemeber', 
		Text = 'Remember Inputs',
		},
		ui:CheckBox{
		ID = 'DoOpen', 
		Text = 'Stay Open',
		},
		},
		ui:Label{
		ID = 'LabelBreaker',
		Text = '_____________________________________________________________________________________________________________',
		Alignment = {AlignHCenter = true,},
		
		},
		
		ui:HGroup{
		ui:Button{
		ID = 'OkButton',
		Text = 'OK',
		},
		
		ui:Button{
		ID = 'CancelButton',
		Text = 'Cancel',
		},
		
		}
	
	},
	
	})

function AboutWindow()
MouseX = fu:GetMousePos()[1]
MouseY = fu:GetMousePos()[2]
print('Opening About and Settings')


	local width,height = 620, 350
	win = disp:AddWindow({
	ID = 'AboutWindow',
	WindowTitle = 'About Change Strings',
	Window = true,
	Geometry = {MouseX-520, MouseY-50, width, height},
	
	ui:VGroup{
	ID = 'AboutRoot',
	
	ui:Label{
	ID = 'AboutLabel',
	Text = '<h2>About</h2>',
	Alignment = {AlignHCenter = true, AlignTop = true},
	},
	
	ui:Label{
	ID = 'AboutText',
	HTML = true,
	OpenExternalLinks = true,
	Text = '<b><i>ChangeStrings 1.4</i></b> was made by <a href="' .. 'www.noahhaehnel.com' .. '">Noah Hähnel</a> <br>It is designed to find and replace most strings, meaning text, in Fusion. <br> <b> Change Strings might have more features than you realize.</b> <br> Click on the Questionmarks (?) next to the Text Inputs to open the manual <br> on how to use <i>Change Strings</i> to its fullest and see handy shortcodes. <br> <a href= https://noahhaehnel.com/blog/manual-changestrings/2>You can check for updates here.</a> <br> <a href= https://noahhaehnel.com/blog/manual-changestrings>Or click here for the whole manual.</a>',
	Alignment = {AlignHCenter = true,},
	},
	
	ui:VGap(5),
		
	ui:CheckBox{
	ID = 'ACheckbox',
	Text = 'Show Advanced Settings',
	AlignCenter = true,
	Weight = 0.1,
	},
	
	ui:Label{
	ID = 'ASettings',
	Text = '<h3>Advanced Settings:</h3>',
	Alignment = {AlignHCenter = true, AlignTop = true},
	Visible = false
	
	},


	
	ui:HGroup{
		ID = 'PatternBreakerRow',
		Visible = false,
	
	ui:Label{
	ID = 'LabelPatternBreaker',
	Text = 'Pattern Breaker:',
	Alignment = { AlignHCenter = true, },
	},
	
	ui:LineEdit{
	ID = 'PatternBreakerInput',
	PlaceholderText = '  Default Pattern Breaker is "ïèëï". Only change if you know what you are doing',
	Weight = 3.3,
	ClearButtonEnabled = true,
	},
	
	ui:Label{
			ID = 'help3',
			HTML = true,
			OpenExternalLinks = true,
			Weight = 0.1,
			Text = '<a href="' .. 'https://noahhaehnel.com/blog/manual-changestrings#Pattern_Breaker' .. '">?</a>',
		
			},
	},
		ui:HGroup{
		ID = 'LimitRow',
		Visible = false,

	
	ui:Label{
	ID = 'MaxLimit',
	Text = 'Max Replace Limit:',
	Alignment = { AlignHCenter = true, },
	},
	
	ui:LineEdit{
	ID = 'MaxLimitInput',
	PlaceholderText = '  Default Limit is "30". Only change if you know what you are doing.',
	Weight = 3.3,
	ClearButtonEnabled = true,
	},
	ui:Label{
			ID = 'help4',
			HTML = true,
			OpenExternalLinks = true,
			Weight = 0.1,
			Text = '<a href="' .. 'https://noahhaehnel.com/blog/manual-changestrings#Max_Replace_Limit' .. '">?</a>',
		
			},
	},
	
ui:HGroup{
	

	ui:CheckBox{
	ID = "DoResolve",
	Text = "Force Resolve/Global mode",
	Visible = false,
	},
	
	ui:Label{
	ID = 'help5',
	Text = '<a href="' .. 'https://noahhaehnel.com/blog/manual-changestrings/#Force_Resolve_Global_Mode' .. '">?</a>',
	Visible = false,
	OpenExternalLinks = true,
	},
	
		ui:CheckBox{
	ID = 'DoDebugging',
	Text = 'Print Actions',
	Checked = true,
	},
	
	},
	
	ui:HGroup{

	ui:Button{
	ID = 'OkAbout',
	Text = 'Ok and Save',
	},
	
	ui:Button{
	ID = 'CancelAbout',
	Text = 'Cancel',
	},
	},
}
	})
	
itm2 = win:GetItems()


if fusion:GetPrefs('Comp.ChangeStrings.OldDoResolve') == 'Checked' then
itm2.DoResolve.Checked = true
else
itm2.DoResolve.Checked = false
end


if comp:GetPrefs('Comp.ChangeStrings.OldPatternBreakerInput') ~= nil then
	PatternBreakerInput = comp:GetPrefs('Comp.ChangeStrings.OldPatternBreakerInput')
	if PatternBreakerInput ~= nil then
	itm2.PatternBreakerInput.Text = PatternBreakerInput
	end
	else
	itm2.PatternBreakerInput.Text = nil
	end
if comp:GetPrefs('Comp.ChangeStrings.OldMaxLimit') ~= nil then
	MaxLimitInput = comp:GetPrefs('Comp.ChangeStrings.OldMaxLimit')
	if MaxLimitInput ~= nil then
	itm2.MaxLimitInput.Text = MaxLimitInput
	end
	else
	itm2.MaxLimitInput.Text = nil
	end
if comp:GetPrefs('Comp.ChangeStrings.OldDoDebugging') == 'Checked' then
	itm2.DoDebugging.Checked = true
	debugging = true
	else
	debugging = false
	itm2.DoDebugging.Checked = false
	end

if comp:GetPrefs('Comp.ChangeStrings.OldASettings') == 'Checked' then
	itm2.ACheckbox.Checked = true
	else
	itm2.ACheckbox.Checked = false
	end	

if itm2.ACheckbox.Checked == true then
itm2.LimitRow.Visible = true
itm2.PatternBreakerRow.Visible = true
itm2.ASettings.Visible = true
itm2.DoDebugging.Visible = true
if Fusion_S == true then
itm2.DoResolve.Visible = true
itm2.help5.Visible = true
end
else
itm2.DoResolve.Visible = false
itm2.help5.Visible = false
itm2.LimitRow.Visible = false
itm2.PatternBreakerRow.Visible = false
itm2.ASettings.Visible = false
itm2.DoDebugging.Visible = false
end	

function win.On.AboutWindow.Close(ev)
disp:ExitLoop()
end

function win.On.CancelAbout.Clicked(ev)
disp:ExitLoop()
end

function win.On.ACheckbox.Clicked(ev)

if itm2.ACheckbox.Checked == true then
itm2.DoDebugging.Visible = true
if Fusion_S == true then
itm2.DoResolve.Visible = true
itm2.help5.Visible = true
end
itm2.LimitRow.Visible = true
itm2.PatternBreakerRow.Visible = true
itm2.ASettings.Visible = true
if OldData then
OldData.OldASettings = 'Checked'
end
else
if OldData then
OldData.OldASettings = 'Unchecked'
end
itm2.DoDebugging.Visible = false
itm2.help5.Visible = false
itm2.DoResolve.Visible = false
itm2.LimitRow.Visible = false
itm2.PatternBreakerRow.Visible = false
itm2.ASettings.Visible = false
end

end



function win.On.OkAbout.Clicked(ev)

print('')

if Fusion_S == true then
if itm2.DoResolve.Checked == true then
	comp = fusion
	fusion:SetPrefs({['Comp.ChangeStrings.OldDoResolve'] = 'Checked' })
	print('Enabled Resolve/Global Saving mode')
	else
	comp = composition
	fusion:SetPrefs({['Comp.ChangeStrings.OldDoResolve'] = 'Unchecked' })
	print('Local Saving mode')
end
end

if itm2.PatternBreakerInput.Text == '' then
	comp:SetPrefs({['Comp.ChangeStrings.OldPatternBreakerInput'] = '' })
	pattern_breaker = 'ïèëï'
	print('Pattern Breaker is default:', pattern_breaker )
	else 
	PatternBreakerInput = itm2.PatternBreakerInput.Text
  comp:SetPrefs({['Comp.ChangeStrings.OldPatternBreakerInput']=PatternBreakerInput})	
	pattern_breaker = PatternBreakerInput
	print('New Pattern Breaker is: ', pattern_breaker)
	
	end
if itm2.MaxLimitInput.Text == '' or itm2.MaxLimitInput.Text == nil then
	comp:SetPrefs({['Comp.ChangeStrings.OldMaxLimit'] = '' })
	limit = 30
	print('Limit is default:', limit )
	else 
	MaxLimitInput = itm2.MaxLimitInput.Text
  comp:SetPrefs({['Comp.ChangeStrings.OldMaxLimit']=MaxLimitInput})	

	limit = tonumber(MaxLimitInput)
	if limit == nil then
	limit = 30
	comp:SetPrefs({['Comp.ChangeStrings.OldMaxLimit']=''})
	print('Invalid Input. Limit was reset to default: ', limit)
	else
	limit = limit
	print('New Limit is: ', limit)
	end
	end	



	
if itm2.DoDebugging.Checked == true then
	comp:SetPrefs({['Comp.ChangeStrings.OldDoDebugging'] = 'Checked' })
	debugging = true
else 
  comp:SetPrefs({['Comp.ChangeStrings.OldDoDebugging']= 'Unchecked'})	
	
	debugging = false
	
if debugging == true then
print('Prints Actions to the console')
end
end

if itm2.ACheckbox.Checked == true then
	comp:SetPrefs({['Comp.ChangeStrings.OldASettings'] = 'Checked' })
else 
  comp:SetPrefs({['Comp.ChangeStrings.OldASettings']= 'Unchecked'})	
	
	end
	
	if Fusion_S == true then
	print('Saved composition through About window')
  composition:Save()
	else
	pm:SaveProject()
	print('Saved Project through About window.')
	end
	
	
print('')
	
disp:ExitLoop()
end
	
	win:Show()
	disp:RunLoop()
	win:Hide()
	
	return win,win:GetItems()
	end
	-- Window was closed

function win.On.DoModifier.Clicked(ev)

if itm.DoModifier:GetCheckState() == 'PartiallyChecked' then
itm.DoModifier:SetCheckState('Checked')
Check = 0
itm.DoModifier.Text = 'Include Modifiers'
end

if Check == 1 then
itm.DoModifier:SetCheckState('Unchecked')
Check = 2
itm.DoModifier.Text = 'Include Modifiers'
end

if itm.DoModifier:GetCheckState() == 'Unchecked' and Check == 0 then
itm.DoModifier:SetCheckState('PartiallyChecked')
itm.DoModifier.Text = 'Only Modifiers'
Check = 1
end


end

function win.On.SelectLoaders.Clicked(ev)

if PreviousSelected == nil then
PreviousSelected = composition:GetToolList(true)
end
if debugging == true then
print('Selecting Loaders')
end
flow = composition.CurrentFrame.FlowView
flow:Select()

Loaders = composition:GetToolList(false, 'Loader')

for L, tool in pairs(Loaders) do
flow:Select(tool, true)
end

end
function win.On.SelectSavers.Clicked(ev)

if PreviousSelected == nil then
PreviousSelected = composition:GetToolList(true)
end
if debugging == true then
print('Selecting Savers')
end
flow = composition.CurrentFrame.FlowView
flow:Select()

Savers = composition:GetToolList(false, 'Saver')

for L, tool in pairs(Savers) do
flow:Select(tool, true)
end

end

function win.On.SelectLS.Clicked(ev)

if PreviousSelected == nil then
PreviousSelected = composition:GetToolList(true)
end

if debugging == true then
print('Selecting Loaders and Savers')
end

flow = composition.CurrentFrame.FlowView
flow:Select()

Loaders = composition:GetToolList(false, 'Loader')
Savers = composition:GetToolList(false, 'Saver')

for L, tool in pairs(Savers) do
flow:Select(tool, true)
end
for L, tool in pairs(Loaders) do
flow:Select(tool, true)
end


end

function win.On.SelectPrevious.Clicked(ev)
flow = composition.CurrentFrame.FlowView
flow:Select()
if PreviousSelected ~= nil then
if debugging == true then 
print('Restoring Previous Selection')
end
for L, tool in pairs(PreviousSelected) do
flow:Select(tool, true)
end
end
end



function win.On.Switch.Clicked(ev)

Switch_a = itm.SearchforInput.Text
Switch_b = itm.ReplacewithInput.Text

itm.SearchforInput.Text = Switch_b
itm.ReplacewithInput.Text = Switch_a

end
	
	function win.On.ChangeStringsWindow.Close(ev)
			disp:ExitLoop()
			end
	-- GUI element based functions here
	itm = win:GetItems()

	

function win.On.AboutButton.Clicked(ev)
				AboutWindow()
end

function win.On.DoRemeber.Clicked(ev)
	if itm.DoRemeber.Checked == true then
	itm.OkButton.Text = 'OK and Save'
	else
	itm.OkButton.Text = 'OK'
	end
end
	
if OldData then --If there is OldData available it will use these to load previous settings
	if OldData.OldDoExpressions == 'Checked' then
	itm.DoExpressions.Checked = true
	end
	if OldData.OldDoNames == 'Checked' then
	itm.DoNames.Checked = true
	end
	if OldData.OldDoLoader == 'Checked' then
	itm.DoLoader.Checked = true
	end
	if OldData.OldDoProxy == 'Checked' then
	itm.DoProxy.Checked = true
	end
	if OldData.OldDoSaver == 'Checked' then
	itm.DoSaver.Checked = true
	end
	if OldData.OldDoModifier == 'Checked' then
	itm.DoModifier:SetCheckState('Checked')
	itm.DoModifier.Text = 'Include Modifiers'	
	end
	if OldData.OldDoModifier == 'Unchecked' then
	itm.DoModifier:SetCheckState('Unchecked')
	itm.DoModifier.Text = 'Include Modifiers'
	end
	if OldData.OldDoModifier == 'PartiallyChecked' then
	itm.DoModifier:SetCheckState('PartiallyChecked')
	itm.DoModifier.Text = 'Only Modifiers'
	Check = 1
	end
	if OldData.OldDoTextbox == 'Checked' then
	itm.DoTextbox.Checked = true
	end
	if OldData.OldDoOpen == 'Checked' then
	itm.DoOpen.Checked = true
	end
	if OldData.OldDoCaseSensitive == 'Checked' then
	itm.DoCaseSensitive.Checked = true
	end
	if OldData.OldDoRemember == 'Checked' then
	itm.DoRemeber.Checked = true
	itm.OkButton.Text = 'Ok and Save'
	else
	itm.DoRemeber.Checked = false
	itm.OkButton.Text = 'Ok'
	end
	if OldData.OldSearchForInput then
	itm.SearchforInput.Text = OldData.OldSearchForInput
	end
	if OldData.OldReplacewithInput then
	itm.ReplacewithInput.Text = OldData.OldReplacewithInput
	end
else print('Cannot apply any previous Settings')
end



--Closes the window on Button press 
	function win.On.CancelButton.Clicked(ev)
	print('Change Strings was cancelled')
			disp:ExitLoop()
		
		end
	



	
function win.On.OkButton.Clicked(ev)

print('')
print('Clicked OK, Change Strings is running...')
print('')

SelectedTools = composition:GetToolList(true) --Get all selected Tools

if itm.DoModifier:GetCheckState() == 'Checked' or itm.DoModifier:GetCheckState() == 'PartiallyChecked'  then
SelectedModifiers = {}
number = 1
for o, tool in pairs(SelectedTools)do
local inputs = tool:GetInputList()
for q, input in pairs(inputs)do
 local connected = input:GetConnectedOutput()
	if connected ~= nil then
  allconnected = connected:GetTool()
	attrs = allconnected:GetAttrs()
	if attrs.TOOLB_Visible == false then
	
	SelectedModifiers[number] = allconnected
	number = number+1
end
	end
	end
end
if itm.DoModifier:GetCheckState() == 'Checked' then

mergetables(SelectedTools, SelectedModifiers)

SelectedTools = table3
end
if itm.DoModifier:GetCheckState() == 'PartiallyChecked' then
SelectedTools = SelectedModifiers
print('Only doing Modifiers that are connected to currently selected tools.')
print('Those Modifiers are:')
dump(SelectedTools)
end
end




composition:Lock()--Locks the comp so there are no pop ups and stuff


	
if itm.DoNames.Checked == true then 
composition:StartUndo('Change Names')
for x, tool in pairs(SelectedTools) do
mode = 'Name'

current_tool = tool

magic()

end
composition:EndUndo('Change Names')

end



if itm.DoExpressions.Checked == true then


composition:StartUndo('Change Expressions')
for x, tool in pairs(SelectedTools) do

current_tool = tool

	for c, input in pairs(tool:GetInputList()) do
	mode = 'Expression'
	AreExpression = input:GetExpression()
		if AreExpression ~= nil then
		inputs = input
		
		magic()
		
		end
	end

end	
composition:EndUndo('Change Expressions')
end


if itm.DoLoader.Checked == true then
composition:StartUndo('Change Loaders')
for i, tool in pairs(SelectedTools) do
inputs = tool:GetAttrs()
mode = 'Loader'
current_tool = tool

	if inputs.TOOLS_RegID == 'Loader' then
if debugging == true then
print('Getting Loader Settings')
	end
		TrimIn = inputs.TOOLIT_Clip_TrimIn[i]
		TrimOut = inputs.TOOLIT_Clip_TrimOut[i]
		StartFrame = inputs.TOOLNT_Region_Start[i]
		EndFrame = inputs.TOOLNT_Clip_End[i]
		ExtendLast = inputs.TOOLIT_Clip_ExtendLast[i]
		ExtendFirst = inputs.TOOLIT_Clip_ExtendFirst[i]
		Reverse = inputs.TOOLBT_Clip_Reverse[i]
		
magic()			

if debugging == true then
print('Applying previous Loader settings')
end
		tool.GlobalIn[i] = StartFrame
		tool.GlobalOut[i] = EndFrame
		tool.ClipTimeStart[i] = TrimIn
		tool.ClipTimeEnd[i] = TrimOut
		tool.HoldFirstFrame[i] = ExtendFirst
		tool.HoldLastFrame[i] = ExtendLast	
		if Reverse == true then
		tool.Reverse[i] = 1
		else
		tool.Reverse[i] = 1
		end
		end

end
composition:EndUndo('Change Loaders')
end

if itm.DoSaver.Checked == true then

composition:StartUndo('Change Savers')
for i, tool in pairs(SelectedTools) do
inputs = tool:GetAttrs()
mode = 'Saver'
current_tool = tool
if inputs.TOOLS_RegID == 'Saver' then

		
magic()	
		
end

end
composition:EndUndo('Change Savers')
end

if itm.DoProxy.Checked == true then
composition:StartUndo('Change Proxy')

for i, tool in pairs(SelectedTools) do
inputs = tool:GetAttrs()
mode = 'Proxy'
current_tool = tool

if inputs.TOOLS_RegID == 'Loader' then
if debugging == true then
	print('Getting Loader Settings')
	end
		TrimIn = inputs.TOOLIT_Clip_TrimIn[i]
		TrimOut = inputs.TOOLIT_Clip_TrimOut[i]
		StartFrame = inputs.TOOLNT_Region_Start[i]
		EndFrame = inputs.TOOLNT_Clip_End[i]
		ExtendLast = inputs.TOOLIT_Clip_ExtendLast[i]
		ExtendFirst = inputs.TOOLIT_Clip_ExtendFirst[i]
		Reverse = inputs.TOOLBT_Clip_Reverse[i]
		
magic()			

if debugging == true then
print('Applying previous Loader settings')
end
		tool.GlobalIn[i] = StartFrame
		tool.GlobalOut[i] = EndFrame
		tool.ClipTimeStart[i] = TrimIn
		tool.ClipTimeEnd[i] = TrimOut
		tool.HoldFirstFrame[i] = ExtendFirst
		tool.HoldLastFrame[i] = ExtendLast	
		if Reverse == true then
		tool.Reverse[i] = 1
		else
		tool.Reverse[i] = 1
		end
		end
end
composition:EndUndo('Change Proxy')
end

if itm.DoTextbox.Checked == true then 
composition:StartUndo('Change Styled Text')
for x, tool in pairs(SelectedTools) do
mode = 'Styled Text'

current_tool = tool

if current_tool.StyledText ~= nil then

magic()
end
end

composition:EndUndo('Change Styled Text')
end

if itm.DoRemeber.Checked == true then --Saves the current states of the Checkboxes and Strings in the Comp file
	 local NewData =	comp:SetPrefs({['Comp.ChangeStrings.OldDataSaved']='Yes', 
																		 ['Comp.ChangeStrings.OldDoExpressions']=itm.DoExpressions:GetCheckState(),
																		 ['Comp.ChangeStrings.OldDoNames']=itm.DoNames:GetCheckState(),
																		 ['Comp.ChangeStrings.OldDoTextbox']=itm.DoTextbox:GetCheckState(),
																		 ['Comp.ChangeStrings.OldDoLoader']=itm.DoLoader:GetCheckState(),
																		 ['Comp.ChangeStrings.OldDoProxy']=itm.DoProxy:GetCheckState(),
																		 ['Comp.ChangeStrings.OldDoSaver']=itm.DoSaver:GetCheckState(),
																		 ['Comp.ChangeStrings.OldDoModifier']=itm.DoModifier:GetCheckState(),
																		 ['Comp.ChangeStrings.OldDoOpen']=itm.DoOpen:GetCheckState(),
																		 ['Comp.ChangeStrings.OldDoCaseSensitive']=itm.DoCaseSensitive:GetCheckState(),
																		 ['Comp.ChangeStrings.OldDoRemember']=itm.DoRemeber:GetCheckState(),
																		 ['Comp.ChangeStrings.OldSearchForInput']=itm.SearchforInput:GetText(),
																		 ['Comp.ChangeStrings.OldReplacewithInput']=itm.ReplacewithInput:GetText(),
																		 
																		 })
			
			if Fusion_S == true then
			composition:Save()--it has to save the composition in order to apply the inputs the next time
			if comp == fusion then
			print('Change Strings saved your current settings in the Fusion preferences')
			else
			print('Change Strings saved your current settings in the composition file')
			end
		else
		print('Change Strings saved your current settings in the Fusion in Resolve preferences')
		end

		else
		
	comp:SetPrefs({['Comp.ChangeStrings.OldDoRemember'] = itm.DoRemeber:GetCheckState(),}) 
	
	end
 


			


String = nil
new_string = nil

composition:Unlock() --unlocks the comp
if itm.DoOpen.Checked == true then
print('Change Strings stays open')
else


comp = composition
if debugging == true then
print('Checking if variable is back to normal:')
if comp == fusion or comp == nil then
print('comp: INCORRECT might need to reopen composition')
print('comp is: ', comp)
else
print('comp: Correct')
end
if composition == nil then

print('composition: Incorrect. Might need to reopen composition ')
end
end

			print('_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _')
			print(' ')
			print('Change Strings was closed')
			print('_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _')
			print(' ')
			
disp:ExitLoop()
end		
				
			
			end
			win:Show()
			disp:RunLoop()
			win:Hide()
	
				