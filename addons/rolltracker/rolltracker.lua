--Copyright (c) 2013, Thomas Rogers
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--   * Neither the name of cellhelp nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL THOMAS ROGERS BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


_addon = {}
_addon.name = 'RollTracker'
_addon.version = '1.1'

config = require 'config'
settings=config.load(defaults)
chat = require 'chat'
require 'tablehelper'
defaults = {}
defaults.autostop = 0
defaults.bust = 1
defaults.effected = 1
defaults.fold = 1

local symbolnum = require('json').read('../libs/ffxidata.json').chat.chars

function event_addon_command(...)
    
	cmd = {...}
	
	if cmd[1] ~= nil then
		
		if cmd[1]:lower() == "help" then
			write('To stop rolltracker stopping rolls type: //rolltracker autostop')
			write('To restart rolltracker stopping doubleup type //rolltracker Doubleup')	
		end

		if cmd[1]:lower() == "test" then
			for buffs, integers in pairs(get_player()['buffs']) do
				if integers ~= 255 then
					add_to_chat(1,integers)
				end
				if table.contains(buff_id, integers) then
					write('equal value detected')
				end
			end
		end
		
		if cmd[1]:lower() == "autostop" then
			override=1
			write('Disabled Autostopping Double Up')
		end
		
		if cmd[1]:lower() == "doubleup" then
			override=0
			write('Enable Autostoppping Doubleup')
		end
		
	end
end 

function event_load()

	send_command('alias rolltracker lua c rolltracker')
	override= settings['autostop']
	luckyroll = 0
	roll_id ={  97, 98, 99,
				100, 101, 102,
				103, 104, 105,
				106, 107, 108,
				109, 110, 111, 112,
				113, 114, 115, 116,
				117, 118, 119, 120,
				121, 122, 303, 302, 304, 305
			}
	buff_id = { 309, 310, 311,
				312, 313, 314,
				315, 316, 317,
				318, 319, 320,
				321, 322, 323, 324,
				325, 326, 327, 328,
				329, 330, 331, 332,
				333, 334, 335, 336, 337, 338}
	player_color={['p0']=string.char(0x1E, 247),['p1']=string.char(0x1F, 204),['p2']=string.char(0x1E, 156),['p3']=string.char(0x1E,238),['p4']=string.char(0x1E,5),['p5']=string.char(0x1E,6)}
	roll_ident={[97]=' ', ['98']='Fighter\'s',['99']='Monk\'s',['100']='Healer\'s',
						['101']='Wizard\'s',['102']='Warlock\'s',['103']='Rogue\'s',
						['104']='Gallant\'s',['105']='Chaos',['106']='Beast',
						['107']='Choral',['108']='Hunter\'s',['109']='Samurai',
						['110']='Ninja',['111']='Drachen',['112']='Evoker\'s',
						['113']='Magus\'s',['114']='Corsair\'s',['115']='Puppet',
						['116']='Dancer\'s',['117']='Scholar\'s',['118']='Bolter\'s',
						['119']='Caster\'s', ['120']='Courser\'s', ['121']='Blitzer\'s',
						['122']='Tactician\'s',['303']='Miser\'s',['302']='Allies\'', ['304']='Companion\'s',['305']='Avenger\'s'
			}
	roll_luck={ 0,5,3,3,5,4,5,3,4,4,2,4,2,4,4,5,2,5,3,3,2,3,2,3,4,5,5,3,2,4 }
	roll_buff={
				['Chaos']={6,8,9,25,11,13,16,3,17,19,31,"-4", '% Attack!'},
				['Fighter\'s']={ 2,2,3,4,12,5,6,7,1,9,18,'-4','% Double-Attack!'},
				['Wizard\'s']={2,3,4,4,10,5,6,7,1,7,12, "-4", ' MAB'},
				['Evoker\'s']={1,1,1,1,3,2,2,2,1,3,4,'-1', ' Refresh!'},
				['Rogue\'s']={2,2,3,4,12,5,6,6,1,8,19,'-6', '% Critical Hit Rate!'},
				['Corsair\'s']={10, 11, 11, 12, 20, 13, 15, 16, 8, 17, 24, '-6', '% Experience Bonus'},
				['Hunter\'s']={10,13,15,40,18,20,25,5,27,30,50,'-?', ' Accuracy Bonus'},
				['Magus\'s']={5,20,6,8,9,3,10,13,14,15,25,'-8',' Magic Defense Bonus'},
				['Healer\'s']={3,4,12,5,6,7,1,8,9,10,16,'-4','% Cure Potency'},
				['Drachen']={10,13,15,40,18,20,25,5,28,30,50,'-8',' Pet: Accuracy Bonus'},
				['Choral']={8,42,11,15,19,4,23,27,31,35,50,'+25', '- Spell Interruption Rate'},
				['Monk\'s']={8,10,32,12,14,15,4,20,22,24,40,'-?', ' Subtle Blow'},
				['Beast']={6,8,9,25,11,13,16,3,17,19,31,'-10', '% Pet: Attack Bonus'},
				['Samurai']={7,32,10,12,14,4,16,20,22,24,40,'-10',' Store TP Bonus'},
				['Warlock\'s']={2,3,4,12,15,6,7,1,8,9,15,'-5',' Magic Accuracy Bonus'},
				['Puppet']={4,5,18,7,9,10,2,11,13,15,22,'-8',' Pet: Magic Attack Bonus'},
				['Gallant\'s']={4,5,15,6,7,8,3,9,10,11,20,'-10','% Defense Bonus'},
				['Dancer\'s']={3,4,12,5,6,7,1,8,9,10,16,'-4',' Regen'},
				['Bolter\'s']={2,3,12,4,6,7,8,9,5,10,25,'-8','% Movement Speed'},
				['Caster\'s']={6,15,7,8,9,10,5,11,12,13,20,'-10','% Fast Cast'},
				['Tactician\'s']={2,2,2,2,4,2,2,1,3,3,5,'-1',' Regain'},
				['Miser\'s']={3,5,7,9,20,11,2,13,15,17,25,'-?',' Save TP'},
				['Ninja']={'?','?','?','?','?','?','?','?','?','?','?','?',' Evasion Bonus'},
				['Scholar\'s']={'?','?','?','?','?','?','?','?','?','?','?','?',' Conserve MP'},
				['Allies\'']={6,7,17,9,11,13,15,17,17,5,17,'?','% Skillchain Damage'},
				['Companion\'s']={'4HP +2TP','20HP +5TP','6HP +2TP','8HP +2TP','10HP +3TP','12HP +3TP','14HP +3TP','16HP +4TP','18HP +4TP','3HP +1TP','25HP +6TP','-',' Pet: Regen and Regain'},
				['Avenger\'s']={'?','?','?','?','?','?','?','?','?','?','?','?',' Counter Rate'},
				['Blitzer\'s']={2,3.4,4.5,11.3,5.3,6.4,7.2,8.3,1.5,10.2,12.1,'-?', '% Attack delay reduction'},
				['Courser\'s']={'?','?','?','?','?','?','?','?','?','?','?','?',' Snapshot'}
				}
	if get_ffxi_info()['logged_in'] then
        initialize()
    end
				
end


function event_login()
    initialize()
end

function initialize()
    settings = config.load(defaults)
end

function event_incoming_text(old, new, color)
	match_doubleup = old:find (' uses Double')
	battlemod_compat = old:find('.*Roll.*'..string.char(129,168))
	obtained_roll = old:find('.* receives the effect of .* Roll.')
	not_party = old:find ('%('..'%w+'..'%).* Roll ')	
		if battlemod_compat or match_doubleup and not_party~=nil then
			new=''
		end
		if obtained_roll ~= nil then
			new=''
		end
		if not_party then
			new=old
		end
		return new, color
end

function event_action(act)
	id = act['actor_id']
	if act['category']==6 then
		roller = act['param']
		rollnum = act['targets'][1]['actions'][1]['param']
		effected_member={}
		bust_rate(rollnum, id)
		for i=1, #act['targets'] do
			if act['targets'][i]['id'] == get_player()['id'] then
				for i=1, #roll_id do
					if roller == roll_id[i] then
						for n=1, #act['targets'] do
							for z in pairs(get_party()) do
								if get_party()[z]['mob'] ~= nil then
									if act['targets'][n]['id'] == get_party()[z]['mob']['id'] then	
										effected_member[n]=player_color[z]..get_party()[z]['name']..chat.colorcontrols.reset
									end
								end
							end
						end
						local effected_write = table.concat(effected_member, ', ')
						if settings.effected == 1 then 
							effectednumber = '['..#effected_member..'] '
						else
							effectednumber = '' 
						end
						
						luckyroll=0
						
						if #effected_member > 0 then
							if rollnum == roll_luck[i] or rollnum == 11 then 
								luckyroll = 1
								add_to_chat(1, effectednumber..effected_write..chat.colorcontrols.reset..' '..symbolnum['implies']..' '..roll_ident[tostring(roller)]..' Roll '..symbolnum['circle'..rollnum]..string.char(31,158)..' (Lucky!)'..string.char(31,13)..' (+'..roll_buff[roll_ident[tostring(roller)]][rollnum]..roll_buff[roll_ident[tostring(roller)]][13]..')'..bustrate)
							elseif rollnum==12 and #effected_member > 0 then
								add_to_chat(1, string.char(31,167)..effectednumber..'Bust! '..chat.colorcontrols.reset..symbolnum['implies']..' '..effected_write..' '..symbolnum['implies']..' ('..roll_buff[roll_ident[tostring(roller)]][rollnum]..roll_buff[roll_ident[tostring(roller)]][13]..')')
							else
								add_to_chat(1, effectednumber..effected_write..chat.colorcontrols.reset..' '..symbolnum['implies']..' '..roll_ident[tostring(roller)]..' Roll '..symbolnum['circle'..rollnum]..string.char(31,13)..' (+'..roll_buff[roll_ident[tostring(roller)]][rollnum]..roll_buff[roll_ident[tostring(roller)]][13]..')'..bustrate)
							end
						end
					end
				end
			end
		end
	end
end

function bust_rate(num, main)
	if num <= 5 or num == 11 or main ~= get_player()['id'] or settings.bust == 0 then
		bustrate = ''
	else 
		bustrate = '\7  [Chance to Bust]: '..string.format("%.1f",(num-5)*16.67)..'%'
	end
	return bustrate
end

test=0

function event_outgoing_text(original, modified)
	if original:find('/jobability \"Double.*Up') and luckyroll == 1 and override == 0 and id == get_player()['id'] then
		modified=''
		add_to_chat(159,'Attempting to Doubleup on a Lucky Roll: Re-double up to continue.')
		luckyroll=0
		return modified
	end
	
	if original:find('/jobability \"Fold') and settings.fold == 1 then
		a=0
		
		for buffs, integers in pairs(get_player()['buffs']) do
			if table.contains(buff_id, integers) then
				a=a+1
			end
			
			if table.contains(buff_id, integers) then
				if integers == 309 or a==2 then
					gooff='yes'
				else
					gooff='no'
				end
			end
		end
		
		if gooff=='yes' or test==1 then
			modified=original
			test=0
		else
			add_to_chat(159,'No \'Bust\'. Fold again to continue.')
			modified=''
			test=1
		end
		
		return modified
	end
	
end
