poll = {
	closed = true,
	title = "",
	options = {},
	votes = {},
}

voted = {}
for id = 1, 32 do voted[id] = 0 end

function totable(t, match)
	local cmd = {}
	if not match then match = "[^%s]+" end
	for word in string.gmatch(t, match) do
		table.insert(cmd, word)
	end
	return cmd
end

function getquotes(text)
	local t = {}
	for w in string.gmatch(text, '"([^\"]+)"') do
		table.insert(t, w)
	end
	return t
end

function poll:open(title, questions)
	local word = totable(questions, "[^%,]+")
	poll.options = {}
	poll.votes = {}
	poll.title = title
	poll.closed = false
	for k = 1, 9 do
		if word[k] ~= nil then
			poll.options[k] = word[k]
			poll.votes[k] = 0
			parse('hudtxt '.. 39 + k ..' "['.. k ..'] '.. word[k] ..': '.. poll.votes[k] ..'" 100 '.. 100 + (15 * k) ..' 0')
		end
	end
	for id = 1, 32 do 
		voted[id] = 0 
	end
	parse('hudtxt 37 "--[Current poll]--" 100 50 0')
	parse('hudtxt 38 "--[Press [F3] to vote]--" 100 65 0')
	parse('hudtxt 39 "[Q] '.. title ..'" 100 80 0')
	msg('Poll started! "'.. title ..'" Press [F3] to vote!@C')
end

function poll:refresh()
	for k = 1, 9 do
		if poll.options[k] ~= nil then
			parse('hudtxt '.. 39 + k ..' "['.. k ..'] '.. poll.options[k] ..': '.. poll.votes[k] ..'" 100 '.. 100 + (15 * k) ..' 0')
		end
	end
end

function poll:close()
	poll.closed = true
	for txt = 37, 49 do
		parse('hudtxt '.. txt)
	end
end
	
addhook('serveraction', 'serveraction_hook')
function serveraction_hook(id, action)
	if action == 2 then
		if poll.closed == false then
			if voted[id] <= 0 then
				local m = poll.title ..','
				for i = 1, 9 do
					if poll.options[i] ~= nil then
						m = m .. poll.options[i] ..'| Votes: '.. poll.votes[i] ..','
					else
						m = m ..','
					end
				end
				menu(id, m)
			else
				msg2(id, 'You have voted already!')
			end
		end
	end
end

addhook('menu', 'menu_hook')
function menu_hook(id, title, button)
	if title == poll.title then
		voted[id] = button
		poll.votes[button] = poll.votes[button] + 1
		msg2(id, 'You have voted for: '.. poll.options[voted[id]]..'@C')
		poll:refresh()
	end
end

addhook('parse', 'parse_hook')
function parse_hook(text)
	local cmd = totable(text)
	if cmd[1] == "makepoll" then
		if getquotes(text)[1] and getquotes(text)[2] then
			poll:open(getquotes(text)[1], getquotes(text)[2])
			return 1
		end
	end
	if text == "closepoll" then
		poll:close()
		msg("Poll is closed! Thanks for voting!@C")
		return 1
	end
end

addhook('leave', 'leave_hook')
function leave_hook(id, reason)
	voted[id] = 0 
	poll:refresh()
end