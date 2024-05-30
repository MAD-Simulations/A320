--[[
*****************************************************************************************
* Script Name :  A333.controlSurface.lua
* Process: Control Surface(s) Management
*
* Author Name :	Jim Gregory
*
* Revisions:
* -- DATE --  --- REV NO ---  --- DESCRIPTION -------------------------------------------
*
*
*
*
*
*****************************************************************************************
*       					       COPYRIGHT © 2022
*					 	    L A M I N A R   R E S E A R C H
*								  ALL RIGHTS RESERVED
*****************************************************************************************
--]]


--*************************************************************************************--
--** 					                 NOTES            				    		 **--
--*************************************************************************************--
--[[




--]]

--*************************************************************************************--
--** 					              XLUA GLOBALS              				     **--
--*************************************************************************************--

--[[

SIM_PERIOD: this contains the duration of the current frame in seconds (so it is alway a
fraction).  Use this to normalize rates,  e.g. to add 3 units of fuel per second in a
per-frame callback you’d do fuel = fuel + 3 * SIM_PERIOD.


IN_REPLAY: evaluates to 0 if replay is off, 1 if replay mode is on

--]]


--*************************************************************************************--
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--

--[=[
local ELV_DEFLECT_TIME = 0.5

local ELV_ZERO_HYD_PWR = 500.0
local ELV_FULL_HYD_PWR = 1000.0

local STAB_DEFLECT_TIME = 2.0
local STAB_ZERO_HYD_PWR = 500.0
local STAB_FULL_HYD_PWR = 1000.0

local RUDR_DEFLECT_TIME = 0.6
local RUDR_PHASE_OUT_LO = 150.0
local RUDR_PHASE_OUT_HI = 350.0
local RUDR_ZERO_HYD_PWR = 500.0
local RUDR_FULL_HYD_PWR = 1000.0

local GND_SPLR1_EXT_TIME = 1.169
local GND_SPLR2_EXT_TIME = 1.667
local GND_SPLR1_RET_TIME = 7.7
local GND_SPLR2_RET_TIME = 11.0

local SPD_BRK1_EXT_TIME = 1.0
local SPD_BRK2_EXT_TIME = 1.0
local SPD_BRK1_RET_TIME = 2.0
local SPD_BRK2_RET_TIME = 2.0

local SPLR_ZERO_HYD_PWR = 500.0
local SPLR_FULL_HYD_PWR = 1000.0

local AIL_DEFLECT_TIME = 0.4
local AIL_GS_EXT_TIME = 0.5
local AIL_GS_RET_TIME = 5.0
local AIL_FLAP_EXT_TIME = 12.5
local AIL_FAIL_TIME = 20.0
local AIL1_PHASE_OUT_LO = 999.0
local AIL1_PHASE_OUT_HI = 999.0
local AIL2_PHASE_OUT_LO = 999.0
local AIL2_PHASE_OUT_HI = 999.0
local AIL2_PHASE_OUT_LO_CONF0 = 190.0
local AIL2_PHASE_OUT_HI_CONF0 = 195.0
local AIL2_PHASE_OUT_LO_AP_OR_INBD_FAIL = 300.0
local AIL2_PHASE_OUT_HI_AP_OR_INBD_FAIL = 400.0
local AIL_ZERO_HYD_PWR = 500.0
local AIL_FULL_HYD_PWR = 1000.0

local FLAP1_EXT_TIME = 16.0
local FLAP1_RET_TIME = 16.0
local FLAP2_EXT_TIME = 16.0
local FLAP2_RET_TIME = 16.0
local FLAP_4DEG_TIME = 103.0
local FLAP_ZERO_HYD_PWR = 500.0
local FLAP_FULL_HYD_PWR = 1000.0

local SLAT1_EXT_TIME = 21.56
local SLAT2_EXT_TIME = 21.56
local SLAT1_RET_TIME = 21.56
local SLAT2_RET_TIME = 21.56
local SLAT_ZERO_HYD_PWR = 500.0
local SLAT_FULL_HYD_PWR = 1000.0
--]=]



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--

--[=[
local cs = {
	last_time = 0,
	hStabilizer = {},
	elev = {},
	rudder = {},
	spoiler = {},
	aileron = {},
	flapRequestRatio = {
		0.00,
		0.25,
		0.50,
		0.75,
		1.00
	},
	flap1 = {},
	flap2 = {},
	slat1 = {},
	slat2 = {},
	slatAlphSpeedLoc = false,
	flrs = false,
	conf = '',
	lastFlapReqRatio = 0.0,
	lastFlap1Deg0 = 0.0,
	lastFlap1Deg1 = 0.0,
	lastFlap2Deg2 = 0.0,
	lastFlap2Deg3 = 0.0,
	lastSlat1Ratio = 0.0,
	lastSlat2Ratio = 0.0,
	lastRollRatio = 0.0,
	inFlight = false,
	spoilerMode = 'sb', 	-- sb=speedbrake, gs=ground spoiler, rs=roll spoiler
	sbInhibition = false,
	gsRetracted = true,
	hyd = {
		green = {
			source = 0
		},
		blue = {
			source = 0
		},
		yellow = {
			source = 0
		}
	}
}

local hydSourceFactor = {
	0.0, 0.45, 0.18, 1.0, 1.0
}


local inhibit = false


local V = {
	fe0 = 999.0,
	fe1 = 240.0,
	fe1f = 215.0,
	fe1s = 205.0,
	fe2 = 196,
	fe2s = 186,
	fe3 = 186,
	fefull = 180,
	le = 250.0,
	mo = 330.0
}


local CONF = {
	['0'] 		= {reqRatio = 0.00, slatRat = 0.0, 		slatDeg = 00.0, flapDeg =  0.0, ailerons =  0.0, ecamInd = 'n/a', 	Vfe0 = V.fe0},
	['1'] 		= {reqRatio = 0.25, slatRat = 0.695652, slatDeg = 16.0, flapDeg =  0.0, ailerons =  0.0, ecamInd = '1', 	Vfe = V.fe1 },
	['1+F'] 	= {reqRatio = 0.25, slatRat = 0.695652, slatDeg = 16.0, flapDeg =  8.0, ailerons =  5.0, ecamInd = '1+F', 	Vfe = V.fe1f},
	['1s'] 		= {reqRatio = 0.50, slatRat = 0.869565, slatDeg = 20.0, flapDeg =  8.0, ailerons = 10.0, ecamInd = '2', 	Vfe = V.fe1s},
	['2'] 		= {reqRatio = 0.50, slatRat = 0.869565, slatDeg = 20.0, flapDeg = 14.0, ailerons = 10.0, ecamInd = '2', 	Vfe = V.fe2},
	['2s'] 		= {reqRatio = 0.75, slatRat = 1.0, 		slatDeg = 23.0, flapDeg = 14.0, ailerons = 10.0, ecamInd = '3', 	Vfe = V.fe2s},
	['3'] 		= {reqRatio = 0.75, slatRat = 1.0, 		slatDeg = 23.0, flapDeg = 22.0, ailerons = 10.0, ecamInd = '3', 	Vfe = V.fe3},
	['FULL']	= {reqRatio = 1.00, slatRat = 1.0, 		slatDeg = 23.0, flapDeg = 32.0, ailerons = 10.0, ecamInd = 'FULL',  Vfe = V.fefull},
	selected 	= '0'
}

local checkFltToGroundTransition = false
local FltToGroundTransition = false
--]=]


--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

--[=[
simDR_paused = find_dataref('sim/time/paused')
simDR_total_running_time_sec = find_dataref('sim/time/total_running_time_sec')
simDR_override_control_surfaces = find_dataref('sim/operation/override/override_control_surfaces')

simDR_joy_mapped_axis_avail = find_dataref('sim/joystick/joy_mapped_axis_avail')
simDR_joy_mapped_axis_value = find_dataref('sim/joystick/joy_mapped_axis_value')

simDR_radio_alt_ht_pilot =  find_dataref('sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot')
simDR_throttle_ratio = find_dataref('sim/cockpit2/engine/actuators/throttle_jet_rev_ratio')
simDR_tire_rot_speed_rad_sec = find_dataref('sim/flightmodel2/gear/tire_rotation_speed_rad_sec')

simDR_ctrl_speed_brk_ratio = find_dataref('sim/cockpit2/controls/speedbrake_ratio')

simDR_indicated_airspeed = find_dataref('sim/flightmodel/position/indicated_airspeed')

simDR_position_alpha = find_dataref('sim/flightmodel2/position/alpha')

simDR_airbus_speed_warn_thro_0 = find_dataref('sim/flightmodel2/controls/airbus_speed_warn_thro_0')	-- ALPHA FLOOR ACTIVATION ENGINE 1
simDR_airbus_speed_warn_thro_1 = find_dataref('sim/flightmodel2/controls/airbus_speed_warn_thro_1')	-- ALPHA FLOOR ACTIVATION ENGINE 2

simDR_tire_deflection_mtr = find_dataref('sim/flightmodel2/gear/tire_vertical_deflection_mtr')
simDR_gear_deploy_ratio = find_dataref("sim/flightmodel2/gear/deploy_ratio")

simDR_engine1_green_pump_on = find_dataref('sim/cockpit2/hydraulics/actuators/engine_pumpA[0]')
simDR_engine1_blue_pump_on = find_dataref('sim/cockpit2/hydraulics/actuators/engine_pumpC[0]')
simDR_engine2_yellow_pump_on = find_dataref('sim/cockpit2/hydraulics/actuators/engine_pumpB[1]')
simDR_engine2_green_pump_on = find_dataref('sim/cockpit2/hydraulics/actuators/engine_pumpA[1]')

simDR_engine1_pump_fail = find_dataref('sim/operation/failures/rel_hydpmp')
simDR_engine2_pump_fail = find_dataref('sim/operation/failures/rel_hydpmp2')

simDR_elec_green_pump_on = find_dataref('sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump_on')
simDR_elec_blue_pump_on = find_dataref('sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump2_on')
simDR_elec_yellow_pump_on = find_dataref('sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump3_on')

simDR_elec_green_pump_fail = find_dataref('sim/operation/failures/rel_hydpmp_ele')
simDR_elec_blue_pump_fail = find_dataref('sim/operation/failures/rel_hydpmp_el2')
simDR_elec_yellow_pump_fail = find_dataref('sim/operation/failures/rel_hydpmp_el3')

simDR_ram_air_pump_on = find_dataref('sim/cockpit2/hydraulics/actuators/ram_air_turbine_on')

simDR_ram_air_pump_fail = find_dataref('sim/operation/failures/ram_air_turbine_on')

simDR_green_hyd_pressure = find_dataref('sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1')
simDR_yellow_hyd_pressure = find_dataref('sim/cockpit2/hydraulics/indicators/hydraulic_pressure_2')
simDR_blue_hyd_pressure = find_dataref('sim/cockpit2/hydraulics/indicators/hydraulic_pressure_3')

simDR_autopilot_fd_mode	= find_dataref('sim/cockpit2/autopilot/flight_director_mode')
simDR_autopilot_fd2_mode = find_dataref('sim/cockpit2/autopilot/flight_director2_mode')




-----| FLAPS / SLATS |-------------------------------------------------------------------
simDR_flap_handle_request_ratio = find_dataref('sim/cockpit2/controls/flap_handle_request_ratio')

simDR_flap1_deg = find_dataref('sim/flightmodel2/wing/flap1_deg')
simDR_flap2_deg = find_dataref('sim/flightmodel2/wing/flap2_deg')

simDR_slat1_ratio = find_dataref('sim/flightmodel2/controls/slat1_deploy_ratio')
simDR_slat2_ratio = find_dataref('sim/flightmodel2/controls/slat2_deploy_ratio')


-----| SPEEDBRAKES / SPOILERS |----------------------------------------------------------
simDR_speedbrake_handle_request_ratio = find_dataref('sim/cockpit2/controls/speedbrake_ratio')

simDR_speedbrake1_deg = find_dataref('sim/flightmodel2/wing/speedbrake1_deg')
simDR_speedbrake2_deg = find_dataref('sim/flightmodel2/wing/speedbrake2_deg')

simDR_spoiler1_deg = find_dataref('sim/flightmodel2/wing/spoiler1_deg')
simDR_spoiler2_deg = find_dataref('sim/flightmodel2/wing/spoiler2_deg')


-----| AILERONS |------------------------------------------------------------------------
simDR_acf_ail1_up = find_dataref('sim/aircraft/controls/acf_ail1_up')
simDR_acf_ail1_dn = find_dataref('sim/aircraft/controls/acf_ail1_dn')
simDR_acf_ail2_up = find_dataref('sim/aircraft/controls/acf_ail2_up')
simDR_acf_ail2_dn = find_dataref('sim/aircraft/controls/acf_ail2_dn')

simDR_total_roll_ratio_pilot = find_dataref('sim/cockpit2/controls/total_roll_ratio')
simDR_total_roll_ratio_copilot = find_dataref('sim/cockpit2/controls/total_roll_ratio_copilot')

simDR_aileron1_deg = find_dataref('sim/flightmodel2/wing/aileron1_deg')
simDR_aileron2_deg = find_dataref('sim/flightmodel2/wing/aileron2_deg')


-----| ELEVATOR |------------------------------------------------------------------------
simDR_acf_elev_up = find_dataref('sim/aircraft/controls/acf_elev_up')
simDR_acf_elev_dn = find_dataref('sim/aircraft/controls/acf_elev_dn')

simDR_total_pitch_ratio_pilot = find_dataref('sim/cockpit2/controls/total_pitch_ratio')
simDR_total_pitch_ratio_copilot = find_dataref('sim/cockpit2/controls/total_pitch_ratio_copilot')

simDR_elevator1_deg = find_dataref('sim/flightmodel2/wing/elevator1_deg')
simDR_elevator2_deg = find_dataref('sim/flightmodel2/wing/elevator2_deg')


-----| STABILZER |-----------------------------------------------------------------------
simDR_acf_elevator_trim_ratio = find_dataref('sim/flightmodel2/controls/elevator_trim')
simDR_stabilizer_deflection_degrees = find_dataref('sim/flightmodel2/controls/stabilizer_deflection_degrees')


-----| RUDDER |--------------------------------------------------------------------------
simDR_acf_rudd_lr = find_dataref('sim/aircraft/controls/acf_rudd_lr')
simDR_acf_rudd_rr = find_dataref('sim/aircraft/controls/acf_rudd_rr')

simDR_total_heading_ratio = find_dataref('sim/cockpit2/controls/total_heading_ratio')

simDR_rudder1_deg = find_dataref('sim/flightmodel2/wing/rudder1_deg')
simDR_rudder2_deg = find_dataref('sim/flightmodel2/wing/rudder2_deg')
--]=]



--*************************************************************************************--
--** 				             FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

--[=[

A333DR_ecam_testNum = find_dataref('laminar/A333/ecam/testNum')
A333DR_ecam_testString = find_dataref('laminar/A333/ecam/testStr', 'string')


A333DR_flight_phase = find_dataref('laminar/A333/data/flight_phase')
A333DR_flap_handle_lift_pos = find_dataref('laminar/A333/controls/flap_lift_pos')
A333DR_fws_main_gear_comp_L = find_dataref('laminar/A333/fws/main_gear_comp_L')
A333DR_fws_main_gear_comp_R = find_dataref('laminar/A333/fws/main_gear_comp_R')
A333DR_fws_landing_gear_down = find_dataref('laminar/A333/fws/landing_gear_down')
A333DR_fws_tla1_idle = find_dataref('laminar/A333/fws/tla1_idle')
A333DR_fws_tla2_idle = find_dataref('laminar/A333/fws/tla2_idle')
A333DR_fws_tla12_idle = find_dataref('laminar/A333/fws/tla12_idle')
A333DR_fws_tla1_rev = find_dataref('laminar/A333/fws/tla1_rev')
A333DR_fws_tla2_rev = find_dataref('laminar/A333/fws/tla2_rev')
A333DR_tla1_mct = find_dataref('laminar/A333/fws/tla1_mct')
A333DR_tla2_mct = find_dataref('laminar/A333/fws/tla2_mct')
A333DR_fws_zgndi = find_dataref('laminar/A333/fws/zgndi')

A333DR_rat_hyd_pump_rpm = find_dataref('laminar/A333/ecam/hyd/ram_air_turbine_RPM') -- 0.0 - 6500.0
A333DR_eng1_hyd_green_fire_valve_pos = find_dataref('laminar/A333/ecam/hyd_green_eng1_fire_valve_pos')
A333DR_eng1_hyd_blue_fire_valve_pos = find_dataref('laminar/A333/ecam/hyd_blue_eng1_fire_valve_pos')
A333DR_eng2_hyd_yellow_fire_valve_pos = find_dataref('laminar/A333/ecam/hyd_yellow_eng2_fire_valve_pos')
A333DR_eng2_hyd_green_fire_valve_pos = find_dataref('laminar/A333/ecam/hyd_green_eng2_fire_valve_pos')
--]=]


--*************************************************************************************--
--** 				             FIND CUSTOM COMMANDS								**--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

--A333DR_cs_flrs = create_dataref('laminar/A333/cs/flrs', 'number')										--- NEED TO FIX / REPLACE
--A333DR_cs_aLock = create_dataref('laminar/A333/cs/aLock', 'number')
--A333DR_cs_flaps_in_transit = create_dataref('laminar/A333/cs/flaps/in_transit', 'number')
--A333DR_cs_slats_in_transit = create_dataref('laminar/A333/cs/slats/in_transit', 'number')

--A333DR_cs_CONF_sel = create_dataref('laminar/A333/cs/conf_sel', 'string')
--A333DR_cs_CONF_1F_sel = create_dataref('laminar/A333/cs/conf_1F_sel', 'number')
--A333DR_cs_CONF = create_dataref('laminar/A333/cs/conf', 'string')

--A333DR_cs_CONF_slats_agree = create_dataref("laminar/A333/cs/conf_slats_agree", "number")				--- NEED TO FIX / REPLACE
--A333DR_cs_CONF_flaps_agree = create_dataref("laminar/A333/cs/conf_flaps_agree", "number")				--- NEED TO FIX / REPLACE




--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				            CUSTOM COMMAND HANDLERS            				     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				          X-PLANE WRAP COMMAND HANDLERS              	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              WRAP X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				         X-PLANE REPLACE COMMAND HANDLERS              	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				            REPLACE X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					          OBJECT CONSTRUCTORS         		        		 **--
--*************************************************************************************--

--[=[
-----| LINEAR ANIMATION
function cs.newLinearAnim(duration, range)

	local la = {}
	local delay_mark = false

	la.duration		=	duration
	la.range		=	range
	la.target		=	0.0
	la.instv		=	0.0
	la.delta		=	0.0
	la.inTransit	=	false
	la.rollover		=	false								-- useful for animated scrolling wheels
	la.direction	=	0
	la.last_target	=	0
	la.pause		=	false
	la.isHot		=	1									-- option to plug the animation into a power source
	la.delay		=	0
	la.time_step	=	la.range / la.duration				--	time step is in 'units per second'

	function la:setDurationAndRange(duration, range)
		if range then
			self.range = range
		end
		if duration then
			self.duration = duration
		end
		self.time_step = self.range / self.duration
	end

	function la:setDuration(duration)
		if duration then
			self.duration = duration
		end
		self.time_step = self.range / self.duration
	end

	function la:setTimeStep(timeStep)
		self.time_step = timeStep
	end

	function la:setTarget(target)
		self.target = target
	end

	function la:setDelay(delay)
		self.delay = delay
	end

	function la:sync(sync_value)
		self.target = sync_value
		self.instv = sync_value
	end

	function la:update()
		if simDR_paused == 0
			and not self.pause
			and self.isHot == 1
			and self.target
		then
			self.delta = self.target - self.instv
			if math.abs(self.delta) <= self.time_step * SIM_PERIOD then
				self.instv = self.target
				--delay_mark = false
				self.direction = 0
				self.inTransit = false
			else
				--[[if not delay_mark then
					delay_mark = simDR_total_running_time_sec
				end
				if simDR_total_running_time_sec - delay_mark > self.delay then
					self.inTransit = true
					if self.rollover then
						if self.target == 0
							and self.last_target == self.range - 1
						then
							self.instv = -1
						elseif self.target == self.range - 1
							and self.last_target ==0
						then
							self.instv = self.range
						end
					end--]]
					if self.delta < 0 then
						self.instv = self.instv - (self.time_step * SIM_PERIOD)
						self.direction = -1
					else
						self.instv = self.instv + (self.time_step * SIM_PERIOD)
						self.direction = 1
					end
					self.last_target = self.target
				--end
			end  -- delta test
		end -- paused or is hot
	end

	return la

end




function newLeadingEdgeDelayedConfirmation(name, duration)

	local conf = {}

	conf.name			= name
	conf.IN 			= false
	conf.lastIN 		= false
	conf.START			= false
	conf.OUT			= false
	conf.timerFunc		= function() conf.OUT = true end
	conf.timerDuration	= duration

	function conf:update(input)
		self.IN = input
		self.START = ((self.IN ~= self.lastIN) and self.IN and not self.OUT)
		if self.START then
			self:startTimer()
		end
		if not self.IN
			and
			(self.OUT == true or is_timer_scheduled(self.timer))
		then
			self:resetTimer()
		end
		self.lastIN = self.IN
	end

	function conf:startTimer()
		if not is_timer_scheduled(self.timerFunc) then
			run_after_time(self.timerFunc, self.timerDuration)
		end
	end

	function conf:resetTimer()
		if is_timer_scheduled(self.timer) then
			stop_timer(self.timer)
		end
		self.OUT = false
	end

	return conf

end




function newMarginSensor(name, dnOperator, upOperator, dn, up)

	local sensor = {}

	sensor.name			= name
	sensor.input		= 0
	sensor.dnOperator	= dnOperator
	sensor.upOperator	= upOperator
	sensor.dn			= dn
	sensor.up			= up
	sensor.output		= 0

	function sensor:update(input)
		self.input = input
		if self.dnOperator == '[' then
			if self.upOperator == ']' then
				self.output = (self.dn <= self.input and self.input <= self.up)
			elseif self.upOperator == '[' then
				self.output = (self.dn <= self.input and self.input < self.up)
			end
		elseif self.dnOperator == ']' then
			if self.upOperator == ']' then
				self.output = (self.dn < self.input and self.input <= self.up)
			elseif self.upOperator == '[' then
				self.output = (self.dn < self.input and self.input < self.up)
			end
		end
	end

	return sensor

end




function newSpoiler(name, sbDeg, rollDeg, gdPartialDeg, gdFullDeg, spdBrkExtTime, spdBrkRetTime, rollTime, grndExtTime, grndRetTime, rollEngage, rollPhaseOutLO, rollPhaseOutHI, zeroPwr, fullPwr)

	local splr = {}

	splr.name 				= name

	splr.spdBrkDeg			= sbDeg
	splr.rollDeg			= rollDeg
	splr.grndPartialDeg		= gdPartialDeg
	splr.grndFullDeg		= gdFullDeg

	splr.spdBrkExtTime		= spdBrkExtTime
	splr.spdBrkRetTime		= spdBrkRetTime
	splr.spdBrkTimeVar		= 0
	splr.rollTime			= rollTime
	splr.grndExtTime		= grndExtTime
	splr.grndRetTime		= grndRetTime
	splr.grndTimeVar		= 0

	splr.rollEngage			= rollEngage			-- % of AILERON ROLL
	splr.rollPhaseOutLO		= rollPhaseOutLO		-- START OF PHASE-OUT KNOTS
	splr.rollPhaseOutHI		= rollPhaseOutHI		-- END OF PHASE-OUT KNOTS
	splr.rollAdjustL		= 0
	splr.rollAdjustR		= 0
	splr.lastRollAdjustL	= 0
	splr.lastRollAdjustR	= 0

	splr.zeroDeflectPower 	= zeroPwr
	splr.fullDeflectPower 	= fullPwr
	splr.powerFactor		= 0

	return splr

end






function newElevator(name, maxUp, maxDn, zeroPwr, fullPwr)

	local elv = {}

	elv.name 				= name
	elv.deflectTime			= ELV_DEFLECT_TIME
	elv.fullDeflUp			= maxUp
	elv.fullDeflDn			= maxDn
	elv.zeroDeflectPower 	= zeroPwr
	elv.fullDeflectPower 	= fullPwr

	return elv

end





function newHstab(name, maxUp, maxDn, zeroPwr, fullPwr)

	local elv = {}

	elv.name 				= name
	elv.deflectTime			= STAB_DEFLECT_TIME
	elv.fullDeflUp			= maxUp
	elv.fullDeflDn			= maxDn
	elv.zeroDeflectPower 	= zeroPwr
	elv.fullDeflectPower 	= fullPwr
	elv.powerFactor			= 0

	return elv

end





function newRudder(name, maxDefl, zeroPwr, fullPwr)

	local rdr = {}

	rdr.name 				= name
	rdr.deflectTime			= RUDR_DEFLECT_TIME
	rdr.maxDeflect			= maxDefl
	rdr.lastDeflect			= 0
	rdr.zeroDeflectPower 	= zeroPwr
	rdr.fullDeflectPower 	= fullPwr
	rdr.powerFactor			= 0

	return rdr

end





function newAileron(name, maxDefl, fullDeflDn, phaseOutLO, phaseOutHI, zeroPwr, fullPwr)

	local ail = {}

	ail.name 				= name
	ail.deflectTime 		= AIL_DEFLECT_TIME
	ail.failTime			= AIL_FAIL_TIME
	ail.maxDeflect			= maxDefl
	ail.fullDeflDn			= fullDeflDn
	ail.phaseOutLO 			= phaseOutLO
	ail.phaseOutHI 			= phaseOutHI
	ail.zeroDeflectPower 	= zeroPwr
	ail.fullDeflectPower 	= fullPwr
	ail.powerFactor			= 0

	return ail

end






function newFlap(name, extTime, retTime, zeroPwr, fullPwr)

	local flap = {}

	flap.name 				= name
	flap.extTime 			= extTime
	flap.retTime 			= retTime
	flap.zeroDeflectPower 	= zeroPwr
	flap.fullDeflectPower 	= fullPwr
	flap.powerFactor		= 0

	return flap

end




function newSlat(name, extTime, retTime, zeroPwr, fullPwr)

	local slat = {}

	slat.name 				= name
	slat.extTime 			= extTime
	slat.retTime 			= retTime
	slat.zeroDeflectPower 	= zeroPwr
	slat.fullDeflectPower 	= fullPwr
	slat.powerFactor		= 0

	return slat

end
--]=]



--*************************************************************************************--
--** 				                 CREATE OBJECTS              	     			 **--
--*************************************************************************************--

--[=[
function A333_cs_create_objects()

	local clb = 0.53
	local mct = 0.76
	local idle = 0.0
	local hiIdle = 0.01
	local rev = -1.0

	cs.tla1IDLEorBelow = newMarginSensor('tla1IDLEorBelow', '[', '[', rev, hiIdle)
	cs.tla2IDLEorBelow = newMarginSensor('tla2IDLEorBelow', '[', '[', rev, hiIdle)

	cs.tla1CLBorBelow = newMarginSensor('tla1CLBorBelow', '[', '[', rev, clb)
	cs.tla2CLBorBelow = newMarginSensor('tla2CLBorBelow', '[', '[', rev, clb)

	cs.tla1MCTorBelow = newMarginSensor('tla1MCTorBelow', '[', '[', idle, mct)
	cs.tla2MCTorBelow = newMarginSensor('tla2MCTorBelow', '[', '[', idle, mct)






	cs.tla1IDLEbelow6ft = newMarginSensor('tla1IDLEbelow6ft', '[', '[', idle, mct)
	cs.tla2IDLEbelow6ft = newMarginSensor('tla2IDLEbelow6ft', '[', '[', idle, mct)

	cs.tla1IDLEabove6ft = newMarginSensor('tla1IDLEabove6ft', '[', '[', idle, hiIdle)
	cs.tla2IDLEabove6ft = newMarginSensor('tla2IDLEabove6ft', '[', '[', idle, hiIdle)

	cs.tla1REV = newMarginSensor('tla1REV', '[', '[', rev, idle)
	cs.tla2REV = newMarginSensor('tla2REV', '[', '[', rev, idle)

	cs.lgDeComprBoth01 = newLeadingEdgeDelayedConfirmation('lgDeCompr01', 20.0)
	cs.lgComprBothConf01 = newLeadingEdgeDelayedConfirmation('lgComprBothConf01', 2.0)


	cs.elev.L = newElevator('L', -30.0, 15.0, ELV_ZERO_HYD_PWR, ELV_FULL_HYD_PWR)
	cs.elev.R = newElevator('R', -30.0, 15.0, ELV_ZERO_HYD_PWR, ELV_FULL_HYD_PWR)
	cs.elev.L.anm = cs.newLinearAnim(cs.elev.L.deflectTime, 30.0)
	cs.elev.R.anm = cs.newLinearAnim(cs.elev.R.deflectTime, 30.0)


	cs.hStabilizer = newHstab('hStabilizer', 14.0, 2.0, STAB_ZERO_HYD_PWR, STAB_FULL_HYD_PWR)
	cs.hStabilizer.anm = cs.newLinearAnim(cs.hStabilizer.deflectTime, 14.0)


	cs.rudder = newRudder('rudder', 35.0, RUDR_ZERO_HYD_PWR, RUDR_FULL_HYD_PWR)
	cs.rudder.anm = cs.newLinearAnim(cs.rudder.deflectTime, cs.rudder.maxDeflect)



	cs.spoiler.L1 = newSpoiler('L1', 25.0, 0.00, 14.0, 35.0, SPD_BRK1_EXT_TIME, SPD_BRK1_RET_TIME, AIL_DEFLECT_TIME, GND_SPLR1_EXT_TIME, GND_SPLR1_RET_TIME, 0.00, 000.0, 000.0, SPLR_ZERO_HYD_PWR, SPLR_FULL_HYD_PWR)
	cs.spoiler.L2 = newSpoiler('L2', 30.0, 25.0, 20.0, 50.0, SPD_BRK2_EXT_TIME, SPD_BRK2_RET_TIME, AIL_DEFLECT_TIME, GND_SPLR2_EXT_TIME, GND_SPLR2_RET_TIME, 0.85, 180.0, 240.0, SPLR_ZERO_HYD_PWR, SPLR_FULL_HYD_PWR)
	cs.spoiler.L3 = newSpoiler('L3', 30.0, 25.0, 20.0, 50.0, SPD_BRK2_EXT_TIME, SPD_BRK2_RET_TIME, AIL_DEFLECT_TIME, GND_SPLR2_EXT_TIME, GND_SPLR2_RET_TIME, 0.70, 180.0, 240.0, SPLR_ZERO_HYD_PWR, SPLR_FULL_HYD_PWR)
	cs.spoiler.L4 = newSpoiler('L4', 30.0, 25.0, 20.0, 50.0, SPD_BRK2_EXT_TIME, SPD_BRK2_RET_TIME, AIL_DEFLECT_TIME, GND_SPLR2_EXT_TIME, GND_SPLR2_RET_TIME, 0.50, 180.0, 240.0, SPLR_ZERO_HYD_PWR, SPLR_FULL_HYD_PWR)
	cs.spoiler.L5 = newSpoiler('L5', 30.0, 25.0, 20.0, 50.0, SPD_BRK2_EXT_TIME, SPD_BRK2_RET_TIME, AIL_DEFLECT_TIME, GND_SPLR2_EXT_TIME, GND_SPLR2_RET_TIME, 0.50, 180.0, 240.0, SPLR_ZERO_HYD_PWR, SPLR_FULL_HYD_PWR)
	cs.spoiler.L6 = newSpoiler('L6', 30.0, 25.0, 20.0, 50.0, SPD_BRK2_EXT_TIME, SPD_BRK2_RET_TIME, AIL_DEFLECT_TIME, GND_SPLR2_EXT_TIME, GND_SPLR2_RET_TIME, 0.15, 180.0, 240.0, SPLR_ZERO_HYD_PWR, SPLR_FULL_HYD_PWR)
	cs.spoiler.R1 = newSpoiler('R1', 25.0, 0.00, 14.0, 35.0, SPD_BRK1_EXT_TIME, SPD_BRK1_RET_TIME, AIL_DEFLECT_TIME, GND_SPLR1_EXT_TIME, GND_SPLR1_RET_TIME, 0.00, 000.0, 000.0, SPLR_ZERO_HYD_PWR, SPLR_FULL_HYD_PWR)
	cs.spoiler.R2 = newSpoiler('R2', 30.0, 25.0, 20.0, 50.0, SPD_BRK2_EXT_TIME, SPD_BRK2_RET_TIME, AIL_DEFLECT_TIME, GND_SPLR2_EXT_TIME, GND_SPLR2_RET_TIME, 0.85, 180.0, 240.0, SPLR_ZERO_HYD_PWR, SPLR_FULL_HYD_PWR)
	cs.spoiler.R3 = newSpoiler('R3', 30.0, 25.0, 20.0, 50.0, SPD_BRK2_EXT_TIME, SPD_BRK2_RET_TIME, AIL_DEFLECT_TIME, GND_SPLR2_EXT_TIME, GND_SPLR2_RET_TIME, 0.70, 180.0, 240.0, SPLR_ZERO_HYD_PWR, SPLR_FULL_HYD_PWR)
	cs.spoiler.R4 = newSpoiler('R4', 30.0, 25.0, 20.0, 50.0, SPD_BRK2_EXT_TIME, SPD_BRK2_RET_TIME, AIL_DEFLECT_TIME, GND_SPLR2_EXT_TIME, GND_SPLR2_RET_TIME, 0.50, 180.0, 240.0, SPLR_ZERO_HYD_PWR, SPLR_FULL_HYD_PWR)
	cs.spoiler.R5 = newSpoiler('R5', 30.0, 25.0, 20.0, 50.0, SPD_BRK2_EXT_TIME, SPD_BRK2_RET_TIME, AIL_DEFLECT_TIME, GND_SPLR2_EXT_TIME, GND_SPLR2_RET_TIME, 0.50, 180.0, 240.0, SPLR_ZERO_HYD_PWR, SPLR_FULL_HYD_PWR)
	cs.spoiler.R6 = newSpoiler('R6', 30.0, 25.0, 20.0, 50.0, SPD_BRK2_EXT_TIME, SPD_BRK2_RET_TIME, AIL_DEFLECT_TIME, GND_SPLR2_EXT_TIME, GND_SPLR2_RET_TIME, 0.15, 180.0, 240.0, SPLR_ZERO_HYD_PWR, SPLR_FULL_HYD_PWR)
	cs.spoiler.L1.anm = cs.newLinearAnim(cs.spoiler.L1.spdBrkExtTime, cs.spoiler.L1.grndFullDeg)
	cs.spoiler.L2.anm = cs.newLinearAnim(cs.spoiler.L2.spdBrkExtTime, cs.spoiler.L2.grndFullDeg)
	cs.spoiler.L3.anm = cs.newLinearAnim(cs.spoiler.L3.spdBrkExtTime, cs.spoiler.L3.grndFullDeg)
	cs.spoiler.L4.anm = cs.newLinearAnim(cs.spoiler.L4.spdBrkExtTime, cs.spoiler.L4.grndFullDeg)
	cs.spoiler.L5.anm = cs.newLinearAnim(cs.spoiler.L5.spdBrkExtTime, cs.spoiler.L5.grndFullDeg)
	cs.spoiler.L6.anm = cs.newLinearAnim(cs.spoiler.L6.spdBrkExtTime, cs.spoiler.L6.grndFullDeg)
	cs.spoiler.R1.anm = cs.newLinearAnim(cs.spoiler.R1.spdBrkExtTime, cs.spoiler.L1.grndFullDeg)
	cs.spoiler.R2.anm = cs.newLinearAnim(cs.spoiler.R2.spdBrkExtTime, cs.spoiler.L2.grndFullDeg)
	cs.spoiler.R3.anm = cs.newLinearAnim(cs.spoiler.R3.spdBrkExtTime, cs.spoiler.L3.grndFullDeg)
	cs.spoiler.R4.anm = cs.newLinearAnim(cs.spoiler.R4.spdBrkExtTime, cs.spoiler.L4.grndFullDeg)
	cs.spoiler.R5.anm = cs.newLinearAnim(cs.spoiler.R5.spdBrkExtTime, cs.spoiler.L5.grndFullDeg)
	cs.spoiler.R6.anm = cs.newLinearAnim(cs.spoiler.R6.spdBrkExtTime, cs.spoiler.L6.grndFullDeg)

	local x, seed = math.modf(os.clock())
	math.randomseed(seed)
	math.random()
	for _, spoiler in pairs(cs.spoiler) do
		spoiler.spdBrkTimeVar = math.random(-500.0, 500.0) * 0.001
	end

	x, seed = math.modf(os.clock())
	math.randomseed(seed)
	for _, spoiler in pairs(cs.spoiler) do
		spoiler.grndTimeVar = math.random(-500.0, 500.0) * 0.001
	end




	cs.aileron.L1 = newAileron('L1', 25.0,  25.0, AIL1_PHASE_OUT_LO, AIL1_PHASE_OUT_HI, AIL_ZERO_HYD_PWR, AIL_FULL_HYD_PWR)
	cs.aileron.L2 = newAileron('L2', 25.0,  25.0, AIL2_PHASE_OUT_LO, AIL2_PHASE_OUT_HI, AIL_ZERO_HYD_PWR, AIL_FULL_HYD_PWR)
	cs.aileron.R1 = newAileron('R1', 25.0,  25.0, AIL1_PHASE_OUT_LO, AIL1_PHASE_OUT_HI, AIL_ZERO_HYD_PWR, AIL_FULL_HYD_PWR)
	cs.aileron.R2 = newAileron('R2', 25.0,  25.0, AIL2_PHASE_OUT_LO, AIL2_PHASE_OUT_HI, AIL_ZERO_HYD_PWR, AIL_FULL_HYD_PWR)
	cs.aileron.L1.anm = cs.newLinearAnim(cs.aileron.L1.deflectTime, cs.aileron.L1.maxDeflect)
	cs.aileron.L2.anm = cs.newLinearAnim(cs.aileron.L2.deflectTime, cs.aileron.L2.maxDeflect)
	cs.aileron.R1.anm = cs.newLinearAnim(cs.aileron.R1.deflectTime, cs.aileron.R1.maxDeflect)
	cs.aileron.R2.anm = cs.newLinearAnim(cs.aileron.R2.deflectTime, cs.aileron.R2.maxDeflect)

	cs.aileron.flap = {}
	cs.aileron.flap.anm = cs.newLinearAnim(AIL_FLAP_EXT_TIME, 10.0)



	cs.flap1 = newFlap('flap1', FLAP1_EXT_TIME, FLAP1_RET_TIME, FLAP_ZERO_HYD_PWR, FLAP_FULL_HYD_PWR)
	cs.flap2 = newFlap('flap2', FLAP2_EXT_TIME, FLAP2_RET_TIME, FLAP_ZERO_HYD_PWR, FLAP_FULL_HYD_PWR)
	cs.flap1.anm = cs.newLinearAnim(FLAP1_EXT_TIME, 32.0)
	cs.flap2.anm = cs.newLinearAnim(FLAP2_EXT_TIME, 32.0)


	cs.slat1 = newSlat('slat1', SLAT1_EXT_TIME, SLAT1_RET_TIME, SLAT_ZERO_HYD_PWR, SLAT_FULL_HYD_PWR)
	cs.slat2 = newSlat('slat2', SLAT2_EXT_TIME, SLAT2_RET_TIME, SLAT_ZERO_HYD_PWR, SLAT_FULL_HYD_PWR)
	cs.slat1.anm = cs.newLinearAnim(SLAT1_EXT_TIME, 1.0)
	cs.slat2.anm = cs.newLinearAnim(SLAT2_EXT_TIME, 1.0)

end
--]=]



--*************************************************************************************--
--** 				              FUNCTION DEFINITIONS         	    				 **--
--*************************************************************************************--












--[=[


-----| UTIL: TERNARY CONDITIONAL
function ternary(condition, ifTrue, ifFalse)
	if condition then return ifTrue else return ifFalse end
end

-----| UTIL: CONVERT TO TRADITIONAL BOOLEAN
function toboolean(v)
	return v ~= nil and v ~= false and v ~= 0
end

-----| UTIL: BOOLEAN TO LOGIC NUMBER
function bool2logic(bool)
	return ternary(bool == true, 1, 0)
end

-----| UTIL: RESCALE/NORMALIZE
function rescale(in1, out1, in2, out2, x)

	if x < in1 then return out1 end
	if x > in2 then return out2 end
	if in2 - in1 == 0 then return out1 + (out2 - out1) * (x - in1) end
	return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end


-----| REPLAY REWIND
function A333_cs_saveRunningTime()
	cs.last_time = simDR_total_running_time_sec
end

function A333_cs_replayIsRewind()
	return IN_REPLAY == 1 and cs.last_time > simDR_total_running_time_sec
end









function A333_cs_hydraulic_power()

	-----| ELEVATORS |-----
	-- LH - GREEN OR BLUE
	cs.elev.L.powerFactor = rescale(cs.elev.L.zeroDeflectPower, 0.0, cs.elev.L.fullDeflectPower, 1.0, math.max(simDR_green_hyd_pressure, simDR_blue_hyd_pressure))

	-- RH - GREEN OR YELLOW
	cs.elev.R.powerFactor = rescale(cs.elev.R.zeroDeflectPower, 0.0, cs.elev.R.fullDeflectPower, 1.0, math.max(simDR_green_hyd_pressure, simDR_yellow_hyd_pressure))


	-----| HORIZONTAL STABILIZER |-----
	cs.hStabilizer.powerFactor = rescale(cs.hStabilizer.zeroDeflectPower, 0.0, cs.hStabilizer.fullDeflectPower, 1.0, math.max(simDR_blue_hyd_pressure, simDR_yellow_hyd_pressure))


	-----| RUDDER |-----
	-- GREEN OR BLUE OR YELLOW
	cs.rudder.powerFactor = rescale(cs.rudder.zeroDeflectPower, 0.0, cs.rudder.fullDeflectPower, 1.0, math.max(simDR_green_hyd_pressure, simDR_blue_hyd_pressure, simDR_yellow_hyd_pressure))


	-----| AILERONS |-----
	-- INBD - GREEN OR BLUE
	cs.aileron.L1.powerFactor = rescale(cs.aileron.L1.zeroDeflectPower, 0.0, cs.aileron.L1.fullDeflectPower, 1.0, math.max(simDR_green_hyd_pressure, simDR_blue_hyd_pressure))
	cs.aileron.R1.powerFactor = rescale(cs.aileron.R1.zeroDeflectPower, 0.0, cs.aileron.R1.fullDeflectPower, 1.0, math.max(simDR_green_hyd_pressure, simDR_blue_hyd_pressure))

	-- OUTB - GREEN OR YELLOW
	cs.aileron.L2.powerFactor = rescale(cs.aileron.L2.zeroDeflectPower, 0.0, cs.aileron.L2.fullDeflectPower, 1.0, math.max(simDR_green_hyd_pressure, simDR_yellow_hyd_pressure))
	cs.aileron.R2.powerFactor = rescale(cs.aileron.R2.zeroDeflectPower, 0.0, cs.aileron.R2.fullDeflectPower, 1.0, math.max(simDR_green_hyd_pressure, simDR_yellow_hyd_pressure))


	-----| SPEEDBRAKES/SPOILERS |-----
	-- SPLR 1/5 - GREEN
	cs.spoiler.L1.powerFactor = rescale(cs.spoiler.L1.zeroDeflectPower, 0.0, cs.spoiler.L1.fullDeflectPower, 1.0, simDR_green_hyd_pressure)
	cs.spoiler.L5.powerFactor = rescale(cs.spoiler.L5.zeroDeflectPower, 0.0, cs.spoiler.L5.fullDeflectPower, 1.0, simDR_green_hyd_pressure)
	cs.spoiler.R1.powerFactor = rescale(cs.spoiler.R1.zeroDeflectPower, 0.0, cs.spoiler.R1.fullDeflectPower, 1.0, simDR_green_hyd_pressure)
	cs.spoiler.R5.powerFactor = rescale(cs.spoiler.R5.zeroDeflectPower, 0.0, cs.spoiler.R5.fullDeflectPower, 1.0, simDR_green_hyd_pressure)

	-- SPLR 2/3 - BLUE
	cs.spoiler.L2.powerFactor = rescale(cs.spoiler.L2.zeroDeflectPower, 0.0, cs.spoiler.L2.fullDeflectPower, 1.0, simDR_blue_hyd_pressure)
	cs.spoiler.L3.powerFactor = rescale(cs.spoiler.L3.zeroDeflectPower, 0.0, cs.spoiler.L3.fullDeflectPower, 1.0, simDR_blue_hyd_pressure)
	cs.spoiler.R2.powerFactor = rescale(cs.spoiler.R2.zeroDeflectPower, 0.0, cs.spoiler.R2.fullDeflectPower, 1.0, simDR_blue_hyd_pressure)
	cs.spoiler.R3.powerFactor = rescale(cs.spoiler.R3.zeroDeflectPower, 0.0, cs.spoiler.R3.fullDeflectPower, 1.0, simDR_blue_hyd_pressure)

	-- SPLR 4/6 - YELLOW
	cs.spoiler.L4.powerFactor = rescale(cs.spoiler.L4.zeroDeflectPower, 0.0, cs.spoiler.L4.fullDeflectPower, 1.0, simDR_yellow_hyd_pressure)
	cs.spoiler.L6.powerFactor = rescale(cs.spoiler.L6.zeroDeflectPower, 0.0, cs.spoiler.L6.fullDeflectPower, 1.0, simDR_yellow_hyd_pressure)
	cs.spoiler.R4.powerFactor = rescale(cs.spoiler.R4.zeroDeflectPower, 0.0, cs.spoiler.R4.fullDeflectPower, 1.0, simDR_yellow_hyd_pressure)
	cs.spoiler.R6.powerFactor = rescale(cs.spoiler.R6.zeroDeflectPower, 0.0, cs.spoiler.R6.fullDeflectPower, 1.0, simDR_yellow_hyd_pressure)


	-----| SLATS |-----
	-- SLATS - BLUE OR GREEN
	cs.slat1.powerFactor = rescale(cs.slat1.zeroDeflectPower, 0.0, cs.slat1.fullDeflectPower, 1.0, math.max(simDR_green_hyd_pressure, simDR_blue_hyd_pressure))
	cs.slat2.powerFactor = rescale(cs.slat2.zeroDeflectPower, 0.0, cs.slat2.fullDeflectPower, 1.0, math.max(simDR_green_hyd_pressure, simDR_blue_hyd_pressure))


	-----| FLAPS |-----
	-- FLAPS - GREEN OR YELLOW
	cs.flap1.powerFactor = rescale(cs.flap1.zeroDeflectPower, 0.0, cs.flap1.fullDeflectPower, 1.0, math.max(simDR_green_hyd_pressure, simDR_blue_hyd_pressure))
	cs.flap2.powerFactor = rescale(cs.flap2.zeroDeflectPower, 0.0, cs.flap2.fullDeflectPower, 1.0, math.max(simDR_green_hyd_pressure, simDR_blue_hyd_pressure))


end




function A333_cs_hydraulic_source()

	local eng1_green_pump_on = toboolean(simDR_engine1_green_pump_on)
	local eng1_blue_pump_on = toboolean(simDR_engine1_blue_pump_on)
	local eng2_yellow_pump_on = toboolean(simDR_engine2_yellow_pump_on)
	local eng2_green_pump_on = toboolean(simDR_engine2_green_pump_on)

	local eng1_green_pump_fail = ternary(simDR_engine1_pump_fail == 6, true, false)
	local eng1_blue_pump_fail = ternary(simDR_engine1_pump_fail == 6, true, false)
	local eng2_yellow_pump_fail = ternary(simDR_engine2_pump_fail == 6, true, false)
	local eng2_green_pump_fail = ternary(simDR_engine2_pump_fail == 6, true, false)

	local elec_green_pump_on = toboolean(simDR_elec_green_pump_on)
	local elec_blue_pump_on = toboolean(simDR_elec_blue_pump_on)
	local elec_yellow_pump_on = toboolean(simDR_elec_yellow_pump_on)

	local elec_green_pump_fail = ternary(simDR_elec_green_pump_fail == 6, true, false)
	local elec_blue_pump_fail = ternary(simDR_elec_blue_pump_fail == 6, true, false)
	local elec_yellow_pump_fail = ternary(simDR_elec_yellow_pump_fail == 6, true, false)

	local ram_air_pump_on = toboolean(simDR_ram_air_pump_on)
	local ram_air_pump_fail = ternary(simDR_ram_air_pump_fail == 6, true, false)

	local eng1_hyd_green_fire_valve_open = ternary(A333DR_eng1_hyd_green_fire_valve_pos > 0.99, true, false)
	local eng1_hyd_blue_fire_valve_open = ternary(A333DR_eng1_hyd_blue_fire_valve_pos > 0.99, true, false)
	local eng2_hyd_yellow_fire_valve_open = ternary(A333DR_eng2_hyd_yellow_fire_valve_pos > 0.99, true, false)
	local eng2_hyd_green_fire_valve_open = ternary(A333DR_eng2_hyd_green_fire_valve_pos > 0.99, true, false)



	--| GREEN HYD SOURCE
	cs.hyd.green.source = 0	-- 1=NONE, 2=RAT PUMP, 3=ELEC PUMP, 4=ENG1 PUMP, 5=ENG2 PUMP
	if simDR_green_hyd_pressure > 0.0 then

		if eng1_hyd_green_fire_valve_open and eng1_green_pump_on and not eng1_green_pump_fail then
			cs.hyd.green.source = 4
		elseif eng2_hyd_green_fire_valve_open and eng2_green_pump_on and not eng2_green_pump_fail then
			cs.hyd.green.source = 3
		elseif elec_green_pump_on and not elec_green_pump_fail then
			cs.hyd.green.source = 2
		elseif ram_air_pump_on and not ram_air_pump_fail then
			cs.hyd.green.source = 1
		end

	end


	--| BLUE HYD SOURCE
	cs.hyd.blue.source = 0	-- 1=NONE, 2=RAT PUMP, 3=ELEC PUMP, 4=ENG1 PUMP, 5=ENG2 PUMP
	if simDR_blue_hyd_pressure > 0.0 then

		if eng1_hyd_blue_fire_valve_open and eng1_blue_pump_on and not eng1_blue_pump_fail then
			cs.hyd.blue.source = 3
		elseif elec_blue_pump_on and not elec_blue_pump_fail then
			cs.hyd.blue.source = 2
		end

	end


	--| YELLOW HYD SOURCE
	cs.hyd.yellow.source = 0	-- 1=NONE, 2=RAT PUMP, 3=ELEC PUMP, 4=ENG1 PUMP, 5=ENG2 PUMP
	if simDR_yellow_hyd_pressure > 0.0 then

		if eng2_hyd_yellow_fire_valve_open and eng2_yellow_pump_on and not eng2_yellow_pump_fail then
			cs.hyd.yellow.source = 4
		elseif elec_yellow_pump_on and not elec_yellow_pump_fail then
			cs.hyd.yellow.source = 2
		end

	end

end





function A333_cs_hydraulic_flow_factor()		-- UNUSED

	--| RAT
	hydSourceFactor[2] = ternary(simDR_green_hyd_pressure < 450.0,
		rescale(0.0, 0.0, 450.0, 0.18, simDR_green_hyd_pressure),
		rescale(450.0, 0.18, 2500.0, 0.45, simDR_green_hyd_pressure))


	--| ELEVATOR
	local hydSrc = math.max(cs.hyd.green.source, cs.hyd.blue.source)
	cs.elev.L.hydFlowFactor = hydSourceFactor[hydSrc]

	hydSrc = math.max(cs.hyd.green.source, cs.hyd.yellow.source)
	cs.elev.R.hydFlowFactor = hydSourceFactor[hydSrc]


end








function A333_cs_elevator()

	--[[
	If both servojacks are not electrically or hydraulically controlled they are
	automatically switched to the damping mode.
	Damping Mode: Jack follows surface movement.
	--]]

	local elevator_deflection = ternary( simDR_total_pitch_ratio_pilot > 0,
		simDR_total_pitch_ratio_pilot * -simDR_acf_elev_up,
		simDR_total_pitch_ratio_pilot * -simDR_acf_elev_dn
	)

	-- HYD FAIL DAMPING MODE
	local elevator_deflection_L = ternary(cs.elev.L.powerFactor > 0,
		elevator_deflection,
		rescale(0.0, cs.elev.L.fullDeflDn, 100.0, 0.0, simDR_indicated_airspeed)
	)

	local elevator_deflection_R = ternary(cs.elev.R.powerFactor > 0,
		elevator_deflection,
		rescale(0.0, cs.elev.R.fullDeflDn, 100.0, 0.0, simDR_indicated_airspeed)
	)


	cs.elev.L.anm.target = elevator_deflection_L
	cs.elev.R.anm.target = elevator_deflection_R


	cs.elev.L.anm:update()
	cs.elev.R.anm:update()

	simDR_elevator1_deg[8] = cs.elev.L.anm.instv
	simDR_elevator1_deg[9] = cs.elev.R.anm.instv

end





function A333_cs_horizontal_stabilizer()

	local stabilizer_deflection = (simDR_acf_elevator_trim_ratio * -8.0)

	-- HYD FAIL DAMPING
	stabilizer_deflection = ternary(cs.hStabilizer.powerFactor > 0,
		stabilizer_deflection,
		rescale(0.0, cs.hStabilizer.fullDeflDn, 70.0, 0.0, simDR_indicated_airspeed)
	)

	cs.hStabilizer.anm.target = stabilizer_deflection

	cs.hStabilizer.anm:update()

	simDR_stabilizer_deflection_degrees = cs.hStabilizer.anm.instv

end





function A333_cs_rudder()

	local rudder_deflection = ternary(simDR_total_heading_ratio > 0,
		simDR_total_heading_ratio * simDR_acf_rudd_lr,
		simDR_total_heading_ratio * simDR_acf_rudd_rr
	)

	-- AIRSPEED PHASE-OUT
	rudder_deflection = rescale(RUDR_PHASE_OUT_LO, rudder_deflection, RUDR_PHASE_OUT_HI, rudder_deflection * 0.11, simDR_indicated_airspeed)


	-- HYD FAIL DAMPING
	rudder_deflection = ternary(cs.rudder.powerFactor > 0,
		rudder_deflection,
		rescale(0.0, cs.rudder.lastDeflect, 70.0, 0.0, simDR_indicated_airspeed)
	)

	cs.rudder.anm.target = rudder_deflection

	cs.rudder.anm:update()

	-- SET THE DATAREF
	simDR_rudder1_deg[10] = cs.rudder.anm.instv

	-- SAVE THE DEFLECTION FOR HYD FAILURE
	cs.rudder.lastDeflect = rudder_deflection

end






function A333_cs_aileron()

	------------------| GET THE DEFLECTION VALUES & SET TIMING |-----------------

	local inbd_ail_deflection_L = simDR_total_roll_ratio_pilot * cs.aileron.L1.maxDeflect
	local outbd_ail_deflection_L = simDR_total_roll_ratio_pilot * cs.aileron.L2.maxDeflect
	local inbd_ail_deflection_R = -simDR_total_roll_ratio_pilot * cs.aileron.R1.maxDeflect
	local outbd_ail_deflection_R = -simDR_total_roll_ratio_pilot * cs.aileron.R2.maxDeflect

	cs.aileron.L1.anm:setDuration(cs.aileron.L1.deflectTime)
	cs.aileron.L2.anm:setDuration(cs.aileron.L2.deflectTime)
	cs.aileron.R1.anm:setDuration(cs.aileron.R1.deflectTime)
	cs.aileron.R2.anm:setDuration(cs.aileron.R2.deflectTime)


	--| AS GROUND SPOILER
	if cs.spoilerMode == 'gs' then

		cs.aileron.L1.anm:setDuration(AIL_GS_EXT_TIME)
		cs.aileron.L2.anm:setDuration(AIL_GS_EXT_TIME)
		cs.aileron.R1.anm:setDuration(AIL_GS_EXT_TIME)
		cs.aileron.R2.anm:setDuration(AIL_GS_EXT_TIME)

		if A333_fullGroundSpoilerExtension() then
			inbd_ail_deflection_L = rescale(0.0, -25.0, 1.0, 0.0, simDR_total_roll_ratio_pilot)
			outbd_ail_deflection_L = rescale(0.0, -25.0, 1.0, 0.0, simDR_total_roll_ratio_pilot)
			inbd_ail_deflection_R = rescale(-1.0, 0.0, 0.0, -25.0, simDR_total_roll_ratio_pilot)
			outbd_ail_deflection_R = rescale(-1.0, 0.0, 0.0, -25.0, simDR_total_roll_ratio_pilot)


		elseif A333_partialGroundSpoilerExtension() then
			inbd_ail_deflection_L = rescale(0.0, -10.0, 1.0, 0.0, simDR_total_roll_ratio_pilot)
			outbd_ail_deflection_L = rescale(0.0, -10.0, 1.0, 0.0, simDR_total_roll_ratio_pilot)
			inbd_ail_deflection_R = rescale(-1.0, 0.0, 0.0, -10.0, simDR_total_roll_ratio_pilot)
			outbd_ail_deflection_R = rescale(-1.0, 0.0, 0.0, -10.0, simDR_total_roll_ratio_pilot)


		else -- RETRACT FROM GROUND SPOILER POSITION

			if simDR_speedbrake_handle_request_ratio == 0.0 then

				inbd_ail_deflection_L = 0.0
				outbd_ail_deflection_L = 0.0
				inbd_ail_deflection_R = 0.0
				outbd_ail_deflection_R = 0.0

				cs.aileron.L1.anm:setDuration(AIL_GS_RET_TIME)
				cs.aileron.L2.anm:setDuration(AIL_GS_RET_TIME)
				cs.aileron.R1.anm:setDuration(AIL_GS_RET_TIME)
				cs.aileron.R2.anm:setDuration(AIL_GS_RET_TIME)

			end

		end



	--| WITH FLAPS
	else

		cs.aileron.flap.anm.target = CONF[CONF.selected].ailerons
		cs.aileron.flap.anm:update()

		inbd_ail_deflection_L = math.min(cs.aileron.L1.maxDeflect, inbd_ail_deflection_L + cs.aileron.flap.anm.instv)
		outbd_ail_deflection_L = math.min(cs.aileron.L1.maxDeflect, outbd_ail_deflection_L + cs.aileron.flap.anm.instv)
		inbd_ail_deflection_R = math.min(cs.aileron.L1.maxDeflect, inbd_ail_deflection_R + cs.aileron.flap.anm.instv)
		outbd_ail_deflection_R = math.min(cs.aileron.L1.maxDeflect, outbd_ail_deflection_R + cs.aileron.flap.anm.instv)

	end



	--| AUTOPILOT MODE OR INBOARD FAILURE

	--[[
	IN AUTOPILOT MODE, OR IN SOME FAILURE CASES (INBD AIL FAIL - G&B HYD),
	THE OUTBOARD AILERONS ARE USED UP TO 300 KNOTS.
	--]]
	if (simDR_autopilot_fd_mode == 2 or simDR_autopilot_fd2_mode == 2)
		or
		((cs.aileron.L1.powerFactor < 1 and cs.aileron.R1.powerFactor < 1)
		and
		(cs.aileron.L2.powerFactor > 0 and cs.aileron.R2.powerFactor > 0))
	then
		outbd_ail_deflection_L = rescale(AIL2_PHASE_OUT_LO_AP_OR_INBD_FAIL, outbd_ail_deflection_L, AIL2_PHASE_OUT_HI_AP_OR_INBD_FAIL, 0.0, simDR_indicated_airspeed)
		outbd_ail_deflection_R = rescale(AIL2_PHASE_OUT_LO_AP_OR_INBD_FAIL, outbd_ail_deflection_R, AIL2_PHASE_OUT_HI_AP_OR_INBD_FAIL, 0.0, simDR_indicated_airspeed)



	--| AIRSPEED PHASE-OUT

	--[[
	AT HIGH SPEED (ABOVE 190 KNOTS, IN CONF0),
	THE OUTBOARD AILERONS ARE CONTROLLED TO ZERO DEFLECTION.
	--]]
	else
		if A333DR_cs_CONF == '0' and simDR_indicated_airspeed > 190.0 then
			outbd_ail_deflection_L = rescale(AIL2_PHASE_OUT_LO_CONF0, outbd_ail_deflection_L, AIL2_PHASE_OUT_HI_CONF0, 0.0, simDR_indicated_airspeed)
			outbd_ail_deflection_R = rescale(AIL2_PHASE_OUT_LO_CONF0, outbd_ail_deflection_R, AIL2_PHASE_OUT_HI_CONF0, 0.0, simDR_indicated_airspeed)
		end
	end



	-- FAIL DAMPING
	if cs.aileron.L1.powerFactor == 0 then
		cs.aileron.L1.anm:setDuration(rescale(0.0, 15.0, 100.0, cs.aileron.L1.deflectTime, simDR_indicated_airspeed))
		inbd_ail_deflection_L = rescale(0.0, cs.aileron.L1.fullDeflDn, 100.0, 0.0, simDR_indicated_airspeed)
	end

	if cs.aileron.L2.powerFactor == 0 then
		cs.aileron.L2.anm:setDuration(rescale(0.0, 15.0, 100.0, cs.aileron.L2.deflectTime, simDR_indicated_airspeed))
		outbd_ail_deflection_L = rescale(0.0, cs.aileron.L2.fullDeflDn, 100.0, 0.0, simDR_indicated_airspeed)
	end

	if cs.aileron.R1.powerFactor == 0 then
		cs.aileron.R1.anm:setDuration(rescale(0.0, 15.0, 100.0, cs.aileron.R1.deflectTime, simDR_indicated_airspeed))
		inbd_ail_deflection_R = rescale(0.0, cs.aileron.R1.fullDeflDn, 100.0, 0.0, simDR_indicated_airspeed)
	end

	if cs.aileron.R2.powerFactor == 0 then
		cs.aileron.R2.anm:setDuration(rescale(0.0, 15.0, 100.0, cs.aileron.R2.deflectTime, simDR_indicated_airspeed))
		outbd_ail_deflection_R = rescale(0.0, cs.aileron.R2.fullDeflDn, 100.0, 0.0, simDR_indicated_airspeed)
	end



	------------------------| SET THE ANIMATION TARGET VALUES |-------------------------
	cs.aileron.L1.anm.target = inbd_ail_deflection_L
	cs.aileron.L2.anm.target = outbd_ail_deflection_L
	cs.aileron.R1.anm.target = inbd_ail_deflection_R
	cs.aileron.R2.anm.target = outbd_ail_deflection_R


	------------------------| UPDATE THE ANIMATIONS |-----------------------------------
	cs.aileron.L1.anm:update()
	cs.aileron.L2.anm:update()
	cs.aileron.R1.anm:update()
	cs.aileron.R2.anm:update()


	------------------------| SET THE ANIMATION DATAREF VALUES |------------------------
	simDR_aileron1_deg[4] = cs.aileron.L1.anm.instv
	simDR_aileron2_deg[6] = cs.aileron.L2.anm.instv
	simDR_aileron1_deg[5] = cs.aileron.R1.anm.instv
	simDR_aileron2_deg[7] = cs.aileron.R2.anm.instv

end






function A333_fullGroundSpoilerExtension()

	cs.lgComprBothConf01:update(A333_bothMainGearAreCompressed())
	local bothMainGearAreCompressed = cs.lgComprBothConf01.OUT

	-- FLIGHT TO GROUND TRANSITION
	if checkFltToGroundTransition then
		if bothMainGearAreCompressed then
			FltToGroundTransition = true
			checkFltToGroundTransition = false
		end
	else
		if simDR_radio_alt_ht_pilot > 30.0 then
			FltToGroundTransition = false
			checkFltToGroundTransition = true
		end
	end

	-- PRESELECTION CONDITION
	local FSEcond01 = A333_speedBrakeHandleNotRetracted() and A333_mainGearAreDown()
	local FSEcond02 = (A333_TLA1isReverse() and A333_TLA2_atOrAboveIdleAndBelowMCT()) or (A333_TLA2isReverse() and A333_TLA1_atOrAboveIdleAndBelowMCT())
	local FSEcond03 = FSEcond01 or A333_groundSpoilersArmed()
	local FSEcond04 = A333_TLA_bothAreIdleOrBelow() or FSEcond02
	local FSEcond05 = bothMainGearAreCompressed and FSEcond04
	local FSEcond06 = FSEcond03 and FSEcond05

	-- GROUND CONDITION
	local FSEcond07 = A333_groundSpoilersNotArmed()
		and bothMainGearAreCompressed
		and ((A333_TLA1isReverse() and A333_TLA2_atOrAboveIdleAndBelowMCT()) or (A333_TLA2isReverse() and A333_TLA1_atOrAboveIdleAndBelowMCT()))
	local FSEcond08 = A333_radioAltitudeBelow6ft() and FltToGroundTransition
	local FSEcond09 = FSEcond06 or FSEcond07
	local FSEcond10 = (A333_wheelSpeedBothAbove72kts() and not(A333_WheelSpeedInhibition())) or FSEcond08

	return (FSEcond09 and FSEcond10)

end

function A333_partialGroundSpoilerExtension()

	local PSEcond01 = A333_speedBrakeHandleNotRetracted() and A333_mainGearAreDown()
	local PSEcond02 = (A333_TLA1isReverse() and A333_TLA2_atOrAboveIdleAndBelowMCT()) or (A333_TLA2isReverse() and A333_TLA1_atOrAboveIdleAndBelowMCT())
	local PSEcond03 = PSEcond01 or A333_groundSpoilersArmed()
	local PSEcond04 = PSEcond03 and A333_oneMainGearIsCompressed() and A333_TLA_bothAreIdleOrBelow()
	local PSEcond05 = A333_groundSpoilersNotArmed() and A333_oneMainGearIsCompressed() and PSEcond02

	return (PSEcond04 or PSEcond05)

end




function A333_groundSpoilersNotArmed()
	return simDR_speedbrake_handle_request_ratio == 0.0
end

function A333_speedBrakeHandleNotRetracted()
	return simDR_speedbrake_handle_request_ratio > 0.0
end

function A333_groundSpoilersArmed()
	return simDR_speedbrake_handle_request_ratio < 0.0
end

function A333_radioAltitudeBelow6ft()
	return simDR_radio_alt_ht_pilot < 6.0
end



function A333_TLA1_IdleOrBelow()
	cs.tla1IDLEorBelow:update(simDR_throttle_ratio[0])
	return cs.tla1IDLEorBelow.output
end

function A333_TLA2_IdleOrBelow()
	cs.tla2IDLEorBelow:update(simDR_throttle_ratio[1])
	return cs.tla2IDLEorBelow.output
end

function A333_TLA_bothAreIdleOrBelow()
	return A333_TLA1_IdleOrBelow() and A333_TLA2_IdleOrBelow()
end




function A333_TLA1_CLBorBelow()
	cs.tla1CLBorBelow:update(simDR_throttle_ratio[0])
	return cs.tla1CLBorBelow.output
end

function A333_TLA2_CLBorBelow()
	cs.tla2CLBorBelow:update(simDR_throttle_ratio[1])
	return cs.tla2CLBorBelow.output
end

function A333_TLA_bothAreCLBorBelow()
	return A333_TLA1_CLBorBelow() and A333_TLA2_CLBorBelow()
end





function A333_TLA1_atOrAboveIdleAndBelowMCT()
	cs.tla1MCTorBelow:update(simDR_throttle_ratio[0])
	return cs.tla1MCTorBelow.output
end

function A333_TLA2_atOrAboveIdleAndBelowMCT()
	cs.tla2MCTorBelow:update(simDR_throttle_ratio[1])
	return cs.tla2MCTorBelow.output
end

function A333_TLA_bothAtOrAboveIdleAndBelowMCT()
	return A333_TLA1_atOrAboveIdleAndBelowMCT() and A333_TLA2_atOrAboveIdleAndBelowMCT()
end




function A333_TLA1isReverse()
	cs.tla1REV:update(simDR_throttle_ratio[0])
	return cs.tla1REV.output
end




function A333_TLA2isReverse()
	cs.tla2REV:update(simDR_throttle_ratio[0])
	return cs.tla2REV.output
end




function A333_wheelSpeedLeftBelow23kts()
	return toboolean(((simDR_tire_rot_speed_rad_sec[1] * 0.527304) * 1.94384) < 23.0)
end

function A333_wheelSpeedRightBelow23kts()
	return toboolean(((simDR_tire_rot_speed_rad_sec[2] * 0.527304) * 1.94384) < 23.0)
end

function A333_wheelSpeedBothBelow23kts()
	return A333_wheelSpeedLeftBelow23kts() and A333_wheelSpeedRightBelow23kts()
end




function A333_wheelSpeedLeftAbove72kts()
	return toboolean(((simDR_tire_rot_speed_rad_sec[1] * 0.527304) * 1.94384) > 72.0)
end

function A333_wheelSpeedRightAbove72kts()
	return toboolean(((simDR_tire_rot_speed_rad_sec[2] * 0.527304) * 1.94384) > 72.0)
end

function A333_wheelSpeedBothAbove72kts()
	return A333_wheelSpeedLeftAbove72kts() and A333_wheelSpeedRightAbove72kts()
end



function A333_mainGearAreDown()
	return (simDR_gear_deploy_ratio[1] == 1.0 and simDR_gear_deploy_ratio[2] == 1.0)
end



function A333_leftMainGearIsCompressed()
	return simDR_tire_deflection_mtr[1] > 0.18
end

function A333_rightMainGearIsCompressed()
	return simDR_tire_deflection_mtr[2] > 0.18
end

function A333_oneMainGearIsCompressed()
	return A333_leftMainGearIsCompressed() ~= A333_rightMainGearIsCompressed()
end

function A333_bothMainGearAreCompressed()
	return A333_leftMainGearIsCompressed() and A333_rightMainGearIsCompressed()
end



function A333_leftMainGearIsDecompressed()
	return simDR_tire_deflection_mtr[1] < 0.01
end

function A333_rightMainGearIsDecompressed()
	return simDR_tire_deflection_mtr[2] < 0.01
end

function A333_bothMainGearAreDecompressed()
	return A333_leftMainGearIsDecompressed and A333_rightMainGearIsDecompressed
end

function A333_WheelSpeedInhibition()
	return A333_bothMainGearAreDecompressed() and A333_wheelSpeedBothBelow23kts()		-- wheel speed timer needed ???
end


function A333_fltToGroundTransition()
	return checkFltToGroundTransition and bothMainGearAreCompressed()
end






function A333_cs_spoilers()		-- SEC120


	-- GROUND SPOILERS
	--| Ground Spoilers have priority. The spoiler roll function is inhibited when spoilers are
	--| used for the ground spoiler function.

	if A333_fullGroundSpoilerExtension() then
		cs.spoilerMode = 'gs'
		for _, spoiler in pairs(cs.spoiler) do
			spoiler.anm.target = spoiler.grndFullDeg
		end
		cs.gsRetracted = false


	elseif A333_partialGroundSpoilerExtension() then
		cs.spoilerMode = 'gs'
		for _, spoiler in pairs(cs.spoiler) do
			spoiler.anm.target = spoiler.grndPartialDeg
		end
		cs.gsRetracted = false

	else


		-- RETRACT THE GROUND SPOILERS
		cs.gsRetracted = true
		if cs.spoilerMode == 'gs' then
			for _, spoiler in pairs(cs.spoiler) do
				spoiler.anm.target = 0.0
				if spoiler.anm.instv > 0.0 then
					cs.gsRetracted = false
				end
			end
		end

		if cs.gsRetracted
			--and simDR_speedbrake_handle_request_ratio >= 0.0
		then
			cs.spoilerMode = 'sb'
		end



		--| SPEED BRAKES / ROLL SPOILERS
		if cs.spoilerMode == 'sb' then

			-- GET ROLL SPOILER ADJUSTMENT
			for _, spoiler in pairs(cs.spoiler) do

				if tonumber(string.sub(spoiler.name, 2, 2)) > 1 then	-- ONLY OUTER SPOILERS HAVE "ROLL" FEATURE

					local rollLeft = math.max(0.0, -simDR_aileron1_deg[4], -simDR_aileron2_deg[6])
					local rollRight = math.max(0.0, -simDR_aileron1_deg[5], -simDR_aileron2_deg[7])

					-- ROLL SPOILER ENGAGE AS % OF AILERON ROLL
					spoiler.rollAdjustL = rescale(spoiler.rollDeg * spoiler.rollEngage, 0.0, spoiler.rollDeg, spoiler.rollDeg, rollLeft)
					spoiler.rollAdjustR = rescale(spoiler.rollDeg * spoiler.rollEngage, 0.0, spoiler.rollDeg, spoiler.rollDeg, rollRight)

					-- ROLL SPOILER PHASE-OUT FOR AIRSPEED
					spoiler.rollAdjustL = rescale(spoiler.rollPhaseOutLO, spoiler.rollAdjustL, spoiler.rollPhaseOutHI, 0.0, simDR_indicated_airspeed)
					spoiler.rollAdjustR = rescale(spoiler.rollPhaseOutLO, spoiler.rollAdjustR, spoiler.rollPhaseOutHI, 0.0, simDR_indicated_airspeed)

				end

			end


			-- SET INITIAL SPOILER ANIMATION TARGET
			for _, spoiler in pairs(cs.spoiler) do

				-- SPEEDBRAKE INHIBITION
				if speedbrake_ext_inhibit() then

					if is_timer_scheduled(stopSBinhibition) then
						stop_timer(stopSBinhibition)
					end

					spoiler.anm.target = 0.0
					cs.sbInhibition = true


				-- NO SPEEDBRAKE INHIBITION
				else

					-- SPEEDBRAKE INHIBIT FLAG RESET
					if cs.sbInhibition then										-- WAS PREVIOUSLY INHIBITED

						if simDR_speedbrake_handle_request_ratio == 0.0 then	-- INITIATES RESET
							if not is_timer_scheduled(stopSBinhibition) then
								run_after_time(stopSBinhibition, 5.0)			-- 5 SECOND RESET DELAY
							end
						else
							if is_timer_scheduled(stopSBinhibition) then
								stop_timer(stopSBinhibition)					-- CANX RESET IF LEVER IS MOVED BEFORE 5 SECOND DELAY
							end
						end

					else
						local sbReqRatio = rescale(0.0, 0.0, 1.0, 1.0, simDR_speedbrake_handle_request_ratio)
						spoiler.anm.target = sbReqRatio * spoiler.spdBrkDeg
					end

				end


				-- ADJUST SPOILER ANIMATION TARGET FOR ROLL
				if tonumber(string.sub(spoiler.name, 2, 2)) > 1 then	-- NO ROLL ON INNER SPOILER

					if string.sub(spoiler.name, 1, 1) == 'L' then
						spoiler.anm.target = spoiler.anm.target + spoiler.rollAdjustL

					elseif string.sub(spoiler.name, 1, 1) == 'R' then
						spoiler.anm.target = spoiler.anm.target + spoiler.rollAdjustR
					end

					-- ROLL SPOILERS ARE ACTIVE
					if spoiler.rollAdjustL ~= spoiler.lastRollAdjustL
						or spoiler.rollAdjustR ~= spoiler.lastRollAdjustR
					then
						cs.spoilerMode = 'rs'
					end

				end

			end
			cs.spoiler.lastRollAdjustL = cs.spoiler.rollAdjustL
 			cs.spoiler.lastRollAdjustR = cs.spoiler.rollAdjustR


			--TARGET ADJUSTMENT FOR ROLL PRIORITY AND CLAMP (MAX DEFLECTION)
			cs.spoiler.L2.anm.target, cs.spoiler.R2.anm.target = set_roll_priority_and_clamp(cs.spoiler.L2.anm.target, cs.spoiler.R2.anm.target, 30.0)
			cs.spoiler.L3.anm.target, cs.spoiler.R3.anm.target = set_roll_priority_and_clamp(cs.spoiler.L3.anm.target, cs.spoiler.R3.anm.target, 30.0)
			cs.spoiler.L4.anm.target, cs.spoiler.R4.anm.target = set_roll_priority_and_clamp(cs.spoiler.L4.anm.target, cs.spoiler.R4.anm.target, 30.0)
			cs.spoiler.L5.anm.target, cs.spoiler.R5.anm.target = set_roll_priority_and_clamp(cs.spoiler.L5.anm.target, cs.spoiler.R5.anm.target, 30.0)
			cs.spoiler.L6.anm.target, cs.spoiler.R6.anm.target = set_roll_priority_and_clamp(cs.spoiler.L6.anm.target, cs.spoiler.R6.anm.target, 30.0)

			cs.spoiler.R2.anm.target, cs.spoiler.L2.anm.target = set_roll_priority_and_clamp(cs.spoiler.R2.anm.target, cs.spoiler.L2.anm.target, 30.0)
			cs.spoiler.R3.anm.target, cs.spoiler.L3.anm.target = set_roll_priority_and_clamp(cs.spoiler.R3.anm.target, cs.spoiler.L3.anm.target, 30.0)
			cs.spoiler.R4.anm.target, cs.spoiler.L4.anm.target = set_roll_priority_and_clamp(cs.spoiler.R4.anm.target, cs.spoiler.L4.anm.target, 30.0)
			cs.spoiler.R5.anm.target, cs.spoiler.L5.anm.target = set_roll_priority_and_clamp(cs.spoiler.R5.anm.target, cs.spoiler.L5.anm.target, 30.0)
			cs.spoiler.R6.anm.target, cs.spoiler.L6.anm.target = set_roll_priority_and_clamp(cs.spoiler.R6.anm.target, cs.spoiler.L6.anm.target, 30.0)

		end

	end



	--| HYD FAIL DAMPING
	for _, spoiler in pairs(cs.spoiler) do
		spoiler.anm.target = ternary(spoiler.powerFactor > 0,
		spoiler.anm.target, rescale(0.0, spoiler.anm.instv, 150.0, 0.0, simDR_indicated_airspeed))
	end



	--| SET THE SPOILER ANIMATION TIMING
	for _, spoiler in pairs(cs.spoiler) do

		if cs.spoilerMode == 'gs' then
			if spoiler.anm.target > spoiler.anm.instv then
				spoiler.anm:setDuration(spoiler.grndExtTime + spoiler.grndTimeVar)
			else
				spoiler.anm:setDuration(spoiler.grndRetTime + spoiler.grndTimeVar)
			end
		elseif cs.spoilerMode == 'sb'
			and not cs.sbInhibition
		then
			if spoiler.anm.target > spoiler.anm.instv then
				spoiler.anm:setDuration(spoiler.spdBrkExtTime + spoiler.spdBrkTimeVar)
			else
				spoiler.anm:setDuration(spoiler.spdBrkRetTime + spoiler.spdBrkTimeVar)
			end
		elseif cs.spoilerMode == 'rs' then
			if spoiler.anm.target > spoiler.anm.instv then
				spoiler.anm:setDuration(spoiler.rollTime)
			else
				spoiler.anm:setDuration(spoiler.rollTime)
			end
		end

	end





	--| UPDATE THE SPOILER ANIMATION
	for _, spoiler in pairs(cs.spoiler) do
		spoiler.anm:update()
	end

	if A333_cs_replayIsRewind() then
		for _, spoiler in pairs(cs.spoiler) do
			spoiler.anm.instv = spoiler.anm.target
		end
	end



	--| SET THE DATAREFS
	simDR_speedbrake1_deg[0] = cs.spoiler.L1.anm.instv
	simDR_spoiler1_deg[2] = cs.spoiler.L2.anm.instv
	simDR_spoiler2_deg[2] = cs.spoiler.L3.anm.instv
	simDR_spoiler1_deg[4] = cs.spoiler.L4.anm.instv
	simDR_spoiler1_deg[4] = cs.spoiler.L5.anm.instv
	simDR_spoiler2_deg[4] = cs.spoiler.L6.anm.instv

	simDR_speedbrake1_deg[1] = cs.spoiler.R1.anm.instv
	simDR_spoiler1_deg[3] = cs.spoiler.R2.anm.instv
	simDR_spoiler2_deg[3] = cs.spoiler.R3.anm.instv
	simDR_spoiler1_deg[5] = cs.spoiler.R4.anm.instv
	simDR_spoiler1_deg[5] = cs.spoiler.R5.anm.instv
	simDR_spoiler2_deg[5] = cs.spoiler.R6.anm.instv

end

function stopSBinhibition()
	cs.sbInhibition = false
end








function A333_cs_flaps_slats()


	--| JOYSTICK INPUT & DETENT
	if simDR_joy_mapped_axis_avail[11] == 1 then

		for i = 1, 5 do

			local tolerance = 0.05
			local delta = math.abs(cs.flapRequestRatio[i] - simDR_joy_mapped_axis_value[11])
			if delta <= tolerance then
				simDR_flap_handle_request_ratio = cs.flapRequestRatio[i]	-- DETENT
			end

		end
	end



	--| SET THE CONF SELECTED
	if simDR_flap_handle_request_ratio == CONF['0'].reqRatio and A333DR_flap_handle_lift_pos == 0.0 then

		CONF.selected = '0'

		-- SLATS ALPHA/SPEED LOCK
		if cs.lastFlapReqRatio == 0.25 and
			(simDR_indicated_airspeed < 148.0 or simDR_position_alpha > 8.5)
		then
			cs.slatAlphSpeedLock = true
		end

		if cs.slatAlphSpeedLock == true then
			if simDR_indicated_airspeed > 154.0
				or
				simDR_position_alpha < 7.5
			then
				cs.slatAlphSpeedLock = false
			end
		end

		if A333DR_fws_zgndi and simDR_indicated_airspeed < 60.0 then
			cs.slatAlphSpeedLock = false
		end
		cs.flrs = false
		cs.lastFlapReqRatio = 0.0


	elseif simDR_flap_handle_request_ratio == CONF['1'].reqRatio and A333DR_flap_handle_lift_pos == 0.0 then

		--| EXTENSION REQUESTED (0 -> 1)
		if cs.lastFlapReqRatio < 0.25 then
			if simDR_indicated_airspeed > 100.0 then
				CONF.selected = '1'
			elseif simDR_indicated_airspeed <= 100.0 then
				CONF.selected = '1+F'
			end

			--| NO CHANGE IN LEVER POSITION (1 <-> 1)
		elseif cs.lastFlapReqRatio == 0.25 then

			-- AUTOMATIC RETRACTION SYSTEM (ARS)
			if CONF.selected == '1+F' and simDR_indicated_airspeed > 200.0 then
				CONF.selected = '1'
			end

			--| RETRACTION REQUESTED (2 -> 1)
		elseif cs.lastFlapReqRatio > 0.25 then

			if simDR_indicated_airspeed <= 200.0 then
				CONF.selected = '1+F'
			elseif simDR_indicated_airspeed > 200.0 then
				CONF.selected = '1'
			end

		end
		cs.flrs = false
		cs.lastFlapReqRatio = 0.25


	elseif simDR_flap_handle_request_ratio == CONF['2'].reqRatio and A333DR_flap_handle_lift_pos == 0.0 then

		--| EXTENSION REQUESTED (1 -> 2)
		if cs.lastFlapReqRatio < 0.50 then

			if simDR_indicated_airspeed > 198.5 then	-- FLAP LOAD RELIEF SYSTEM (FLRS)
				CONF.selected = '1s'
				cs.flrs = true
			elseif simDR_indicated_airspeed <= 198.5 then
				CONF.selected = '2'
				cs.flrs = false
			end

			--| NO CHANGE IN LEVER POSITION (2 <-> 2)
		elseif cs.lastFlapReqRatio == 0.50 then

			if CONF.selected == '1s' and simDR_indicated_airspeed < 193.5 then	-- FLAP LOAD RELIEF SYSTEM (FLRS)
				CONF.selected = '2'
				cs.flrs = false
			elseif CONF.selected == '2' and simDR_indicated_airspeed >= 198.5 then	-- FLAP LOAD RELIEF SYSTEM (FLRS)
				CONF.selected = '1s'
				cs.flrs = true
			end

			--| RETRACTION REQUESTED (3 -> 2)
		elseif cs.lastFlapReqRatio > 0.50 then

			if simDR_indicated_airspeed <= 198.5 then
				CONF.selected = '2'
				cs.flrs = false
			elseif simDR_indicated_airspeed > 198.5 then	-- FLAP LOAD RELIEF SYSTEM (FLRS)
				CONF.selected = '1s'
				cs.flrs = true
			end

		end
		cs.lastFlapReqRatio = 0.5


	elseif simDR_flap_handle_request_ratio == CONF['3'].reqRatio and A333DR_flap_handle_lift_pos == 0.0 then

		--| EXTENSION REQUESTED (2 -> 3)
		if cs.lastFlapReqRatio < 0.75 then

			if simDR_indicated_airspeed > 188.5 then	-- FLAP LOAD RELIEF SYSTEM (FLRS)
				CONF.selected = '2s'
				cs.flrs = true
			elseif simDR_indicated_airspeed <= 188.5 then
				CONF.selected = '3'
				cs.flrs = false
			end

			--| NO CHANGE IN LEVER POSITION (3 <-> 3)
		elseif cs.lastFlapReqRatio == 0.75 then


			if CONF.selected == '2s' and simDR_indicated_airspeed <= 183.5 then
				CONF.selected = '3'
				cs.flrs = false
			elseif CONF.selected == '3' and simDR_indicated_airspeed > 188.5 then 	-- FLAP LOAD RELIEF SYSTEM (FLRS)
				CONF.selected = '2s'
				cs.flrs = true
			end

			--| RETRACTION REQUESTED (FULL -> 3)
		elseif cs.lastFlapReqRatio > 0.75 then

			if simDR_indicated_airspeed <= 188.5 then
				CONF.selected = '3'
				cs.flrs = false

				-- FLAP LOAD RELIEF SYSTEM (FLRS)
			elseif simDR_indicated_airspeed > 188.5 then	-- FLAP LOAD RELIEF SYSTEM (FLRS)
				CONF.selected = '2s'
				cs.flrs = true
			end


		end
		cs.lastFlapReqRatio = 0.75

	elseif simDR_flap_handle_request_ratio == CONF['FULL'].reqRatio and A333DR_flap_handle_lift_pos == 0.0 then

		--| EXTENSION REQUESTED (3 -> FULL)
		if cs.lastFlapReqRatio < 1.0 then

			if simDR_indicated_airspeed <= 182.5 then
				CONF.selected = 'FULL'
				cs.flrs = false
			end

			--| NO CHANGE IN LEVER POSITION (FULL <-> FULL)
		elseif cs.lastFlapReqRatio == 1.0 then

			-- FLAP LOAD RELIEF SYSTEM (FLRS)
			if CONF.selected == '3' and simDR_indicated_airspeed < 177.5 then
				cs.flrs = false
				CONF.selected = 'FULL'
			elseif CONF.selected == 'FULL' and simDR_indicated_airspeed > 182.5 then		-- FLAP LOAD RELIEF SYSTEM (FLRS)
				CONF.selected = '3'
				cs.flrs = true
			end

		end
		cs.lastFlapReqRatio = 1.0

	end




	--| SET THE FLAP AMIMATION TARGET
	cs.flap1.anm.target = CONF[CONF.selected].flapDeg
	cs.flap2.anm.target = CONF[CONF.selected].flapDeg

	--| FLAP HYD FAIL DAMPING
	cs.flap1.anm.target = ternary(cs.flap1.powerFactor > 0,
		cs.flap1.anm.target, rescale(0.0, cs.flap1.anm.instv, 100.0, 0.0, simDR_indicated_airspeed)
	)

	cs.flap2.anm.target = ternary(cs.flap2.powerFactor > 0,
		cs.flap2.anm.target, rescale(0.0, cs.flap2.anm.instv, 100.0, 0.0, simDR_indicated_airspeed)
	)



	--| SET THE SLAT AMIMATION TARGET
	if cs.slatAlphSpeedLock then
		cs.slat1.anm.target = CONF['1'].slatRat
		cs.slat2.anm.target = CONF['1'].slatRat
	else
		cs.slat1.anm.target = CONF[CONF.selected].slatRat
		cs.slat2.anm.target = CONF[CONF.selected].slatRat
	end

	--| SLAT HYD FAIL DAMPING
	cs.slat1.anm.target = ternary(cs.slat1.powerFactor > 0,
		cs.slat1.anm.target, cs.slat1.anm.instv)

	cs.slat2.anm.target = ternary(cs.slat2.powerFactor > 0,
		cs.slat2.anm.target, cs.slat2.anm.instv)





	--| SET THE FLAP TIMING
	if CONF[CONF.selected].flapDeg > simDR_flap1_deg[0] or CONF[CONF.selected].flapDeg > simDR_flap1_deg[1] then
		cs.flap1.anm:setDuration(FLAP1_EXT_TIME)
		if simDR_flap1_deg[0] < 4.0 or simDR_flap1_deg[1] < 4.0 then
			cs.flap1.anm:setDuration(FLAP_4DEG_TIME)		-- ADJUSTMENT FOR BLENDER DATAREF KEYFRAM VALUE OF 4.0 v 8.0
		end
	else
		cs.flap1.anm:setDuration(FLAP1_RET_TIME)
		if simDR_flap1_deg[0] < 4.0 or simDR_flap1_deg[1] < 4.0 then
			cs.flap1.anm:setDuration(FLAP_4DEG_TIME)		-- ADJUSTMENT FOR BLENDER DATAREF KEYFRAM VALUE OF 4.0 v 8.0
		end
	end


	if CONF[CONF.selected].flapDeg > simDR_flap2_deg[2] or CONF[CONF.selected].flapDeg > simDR_flap2_deg[3] then
		cs.flap2.anm:setDuration(FLAP2_EXT_TIME)
		if simDR_flap2_deg[2] < 4.0 or simDR_flap2_deg[3] < 4.0 then
			cs.flap2.anm:setDuration(FLAP_4DEG_TIME)
		end
	else
		cs.flap2.anm:setDuration(FLAP2_RET_TIME)
		if simDR_flap2_deg[2] < 4.0 or simDR_flap2_deg[3] < 4.0 then
			cs.flap2.anm:setDuration(FLAP_4DEG_TIME)
		end
	end


	--| SET THE SLAT TIMING
	if CONF[CONF.selected].slatRat > simDR_slat1_ratio then
		cs.slat1.anm:setDuration(SLAT1_EXT_TIME)
	else
		cs.slat1.anm:setDuration(SLAT1_RET_TIME)
	end


	if CONF[CONF.selected].slatRat > simDR_slat2_ratio then
		cs.slat2.anm:setDuration(SLAT2_EXT_TIME)
	else
		cs.slat2.anm:setDuration(SLAT2_RET_TIME)
	end





	--| UPDATE THE ANIMATION VALUES
	cs.flap1.anm:update()
	cs.flap2.anm:update()
	cs.slat1.anm:update()
	cs.slat2.anm:update()

	if A333_cs_replayIsRewind() then
		cs.flap1.anm.instv = cs.flap1.anm.target
		cs.flap2.anm.instv = cs.flap2.anm.target
		cs.slat1.anm.instv = cs.slat1.anm.target
		cs.slat2.anm.instv = cs.slat2.anm.target
	end



	--| SET THE ANIMATION DATAREFS
	simDR_flap1_deg[0] = cs.flap1.anm.instv		-- LEFT INNER/OUTER
	simDR_flap1_deg[1] = cs.flap1.anm.instv 	-- RIGHT INNER/OUTER
	simDR_flap1_deg[2] = cs.flap1.anm.instv		-- LEFT INNER/OUTER
	simDR_flap1_deg[3] = cs.flap1.anm.instv 	-- RIGHT INNER/OUTER

	simDR_flap2_deg[2] = cs.flap2.anm.instv		-- LEFT OUTER
	simDR_flap2_deg[3] = cs.flap2.anm.instv		-- RIGHT OUTER
	simDR_flap2_deg[4] = cs.flap2.anm.instv		-- LEFT OUTER
	simDR_flap2_deg[5] = cs.flap2.anm.instv		-- RIGHT OUTER

	simDR_slat1_ratio = cs.slat1.anm.instv		-- INNER
	simDR_slat2_ratio = cs.slat2.anm.instv		-- OUTER



	--| SET THE MISC DATAREFS
	A333DR_cs_aLock = bool2logic(cs.slatAlphSpeedLock)
	A333DR_cs_flrs = bool2logic(cs.flrs)
	A333DR_cs_CONF_sel = CONF.selected
	A333DR_cs_CONF = get_conf()
	A333DR_cs_CONF_1F_sel = ternary((simDR_flap_handle_request_ratio == CONF['1'].reqRatio and CONF.selected == '1+F'), 1, 0)
	A333DR_cs_flaps_in_transit = get_flap_status()
	A333DR_cs_slats_in_transit = get_slats_status()
	A333DR_cs_CONF_slats_agree = get_slats_agree()
	A333DR_cs_CONF_flaps_agree = get_flaps_agree()

end















function speedbrake_ext_inhibit()

	local tla1_mct = toboolean(A333DR_tla1_mct)
	local tla2_mct = toboolean(A333DR_tla2_mct)

	if  -- MLA (MANUEVER LOAD ALLEVIATION) IS ACTIVATED
		--or
		-- AOA PROTECTION IS ACTIVE
		--or
		-- LOW SPEED STABILITY IS ACTIVE
		--or
		-- FLAPS ARE IN CONF FULL
		get_conf() == 'FULL'
		or
		-- AT LEAST ONE THRUST LEVER IS ABOVE MCT
		(tla1_mct or tla2_mct)
		or
		-- ALPHA FLOOR ACTIVATION
		(simDR_airbus_speed_warn_thro_0 == 1 or simDR_airbus_speed_warn_thro_1 == 1)
	then
		inhibit = true
	else
		if inhibit and simDR_speedbrake_handle_request_ratio == 0.0 then
			inhibit = false
		end
	end

	return inhibit

end





function set_roll_priority_and_clamp(sp1, sp2, range)
	if sp1 > range then
		local max_retraction = sp1 - range
		local retraction = math.min(sp2, max_retraction)
		return math.max(0.0, sp1 - max_retraction), math.max(0.0, sp2 - retraction)
	else
		return sp1, sp2
	end
end







function get_conf()

	if simDR_flap1_deg[0] == 0.0
		and simDR_flap1_deg[1] == 0.0
		and simDR_flap2_deg[2] == 0.0
		and simDR_flap2_deg[3] == 0.0
		and tonumber(string.format('%.1f', simDR_slat1_ratio)) == 0.0
		and tonumber(string.format('%.1f', simDR_slat2_ratio)) == 0.0
	then
		cs.conf = '0'
	end

	if simDR_flap1_deg[0] == 0.0
		and simDR_flap1_deg[1] == 0.0
		and simDR_flap2_deg[2] == 0.0
		and simDR_flap2_deg[3] == 0.0
		and tonumber(string.format('%.3f', simDR_slat1_ratio)) >= 0.696
		and tonumber(string.format('%.3f', simDR_slat2_ratio)) >= 0.696
	then
		cs.conf = '1'
	end

	if simDR_flap1_deg[0] >= 8.0
		and simDR_flap1_deg[1] >= 8.0
		and simDR_flap2_deg[2] >= 8.0
		and simDR_flap2_deg[3] >= 8.0
		and simDR_flap2_deg[4] >= 8.0
		and simDR_flap2_deg[5] >= 8.0
		and tonumber(string.format('%.3f', simDR_slat1_ratio)) >= 0.696
		and tonumber(string.format('%.3f', simDR_slat2_ratio)) >= 0.696
	then
		cs.conf = '1+F'
	end

	if simDR_flap1_deg[0] >= 8.0
		and simDR_flap1_deg[1] >= 8.0
		and simDR_flap2_deg[2] >= 8.0
		and simDR_flap2_deg[3] >= 8.0
		and simDR_flap2_deg[4] >= 8.0
		and simDR_flap2_deg[5] >= 8.0
		and tonumber(string.format('%.3f', simDR_slat1_ratio)) >= 0.870
		and tonumber(string.format('%.3f', simDR_slat2_ratio)) >= 0.870
	then
		cs.conf = '1s'

	end

	if simDR_flap1_deg[0] >= 14.0
		and simDR_flap1_deg[1] >= 14.0
		and simDR_flap2_deg[2] >= 14.0
		and simDR_flap2_deg[3] >= 14.0
		and simDR_flap2_deg[4] >= 14.0
		and simDR_flap2_deg[5] >= 14.0
		and tonumber(string.format('%.3f', simDR_slat1_ratio)) >= 0.870
		and tonumber(string.format('%.3f', simDR_slat2_ratio)) >= 0.870
	then
		cs.conf = '2'
	end

	if simDR_flap1_deg[0] >= 14.0
		and simDR_flap1_deg[1] >= 14.0
		and simDR_flap2_deg[2] >= 14.0
		and simDR_flap2_deg[3] >= 14.0
		and simDR_flap2_deg[4] >= 14.0
		and simDR_flap2_deg[5] >= 14.0
		and tonumber(string.format('%.3f', simDR_slat1_ratio)) >= 1.0
		and tonumber(string.format('%.3f', simDR_slat2_ratio)) >= 1.0
	then
		cs.conf = '2s'
	end

	if simDR_flap1_deg[0] >= 22.0
		and simDR_flap1_deg[1] >= 22.0
		and simDR_flap2_deg[2] >= 22.0
		and simDR_flap2_deg[3] >= 22.0
		and simDR_flap2_deg[4] >= 22.0
		and simDR_flap2_deg[5] >= 22.0
		and tonumber(string.format('%.3f', simDR_slat1_ratio)) >= 1.0
		and tonumber(string.format('%.3f', simDR_slat2_ratio)) >= 1.0
	then
		cs.conf = '3'
	end

	if simDR_flap1_deg[0] >= 32.0
		and simDR_flap1_deg[1] >= 32.0
		and simDR_flap2_deg[2] >= 32.0
		and simDR_flap2_deg[3] >= 32.0
		and simDR_flap2_deg[4] >= 32.0
		and simDR_flap2_deg[5] >= 32.0
		and tonumber(string.format('%.1f', simDR_slat1_ratio)) == 1.0
		and tonumber(string.format('%.1f', simDR_slat2_ratio)) == 1.0
	then
		cs.conf = 'FULL'
	end

	return cs.conf

end










function get_flap_status()

	local flapsInTransit = 0

	if simDR_flap1_deg[0] < cs.lastFlap1Deg0
		or simDR_flap1_deg[1] < cs.lastFlap1Deg1
		or simDR_flap2_deg[2] < cs.lastFlap2Deg2
		or simDR_flap2_deg[3] < cs.lastFlap2Deg3
	then
		flapsInTransit = -1

	elseif simDR_flap1_deg[0] > cs.lastFlap1Deg0
		or simDR_flap1_deg[1] > cs.lastFlap1Deg1
		or simDR_flap2_deg[2] > cs.lastFlap2Deg2
		or simDR_flap2_deg[3] > cs.lastFlap2Deg3
	then
		flapsInTransit = 1

	end

	cs.lastFlap1Deg0 = simDR_flap1_deg[0]
	cs.lastFlap1Deg1 = simDR_flap1_deg[1]
	cs.lastFlap2Deg2 = simDR_flap2_deg[2]
	cs.lastFlap2Deg3 = simDR_flap2_deg[3]

	return flapsInTransit


end






function get_slats_status()

	local slatsInTransit = 0

	if simDR_slat1_ratio < cs.lastSlat1Ratio
		or simDR_slat2_ratio < cs.lastSlat2Ratio
	then
		slatsInTransit = -1

	elseif simDR_slat1_ratio > cs.lastSlat1Ratio
		or simDR_slat1_ratio > cs.lastSlat2Ratio
	then
		slatsInTransit = 1
	end

	cs.lastSlat1Ratio = simDR_slat1_ratio
	cs.lastSlat2Ratio = simDR_slat2_ratio

	return slatsInTransit

end


function get_slats_agree()

	local slats_agree = 0

	if CONF[CONF.selected].slatRat < (simDR_slat1_ratio + 0.001) and CONF[CONF.selected].slatRat > (simDR_slat1_ratio - 0.001)
		and CONF[CONF.selected].slatRat < (simDR_slat2_ratio + 0.001) and CONF[CONF.selected].slatRat > (simDR_slat2_ratio - 0.001)
	then
		slats_agree = 1
	end

	return slats_agree

end

function get_flaps_agree()

	local flaps_agree = 0

	if CONF[CONF.selected].flapDeg == simDR_flap1_deg[0]
		and CONF[CONF.selected].flapDeg == simDR_flap1_deg[1]
		and CONF[CONF.selected].flapDeg == simDR_flap2_deg[2]
		and CONF[CONF.selected].flapDeg == simDR_flap2_deg[3]
	then
		flaps_agree = 1
	end

	return flaps_agree

end

--]=]








--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--
--[[
function aircraft_load() end

function aircraft_unload() end

function flight_start() end

function after_physics() end

function after_replay() end
--]]


--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile('fileName.lua')




