-- *******************************************************************
-- Simple GPWS implementation (according to Honeywell MK VIII)
-- Daniela Rodríguez Careri <daniela@x-plane.com>
-- Laminar Research
-- *******************************************************************

DR_gs_annun = find_dataref("sim/cockpit/warnings/annunciators/glideslope")
DR_pull_up_annun = find_dataref("sim/cockpit2/annunciators/GPWS")
DR_rad_alt = find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")
DR_vario = find_dataref("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")
DR_dh_annun = find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_dh_lit_pilot") -- FIXME: not trusty on replay
DR_windshear_annun = find_dataref("sim/cockpit2/annunciators/windshear_warning")
DR_roll_indicator = find_dataref("sim/cockpit2/gauges/indicators/roll_AHARS_deg_pilot")
DR_autopilot_on = find_dataref("sim/cockpit2/autopilot/autopilot_on")

--DR_flap_ratio = find_dataref("sim/flightmodel2/controls/flap_handle_deploy_ratio")    -- deprecated
DR_flap_ratio = find_dataref("sim/cockpit2/controls/flap_system_deploy_ratio")

DR_gear_ratio = find_dataref("sim/flightmodel2/gear/deploy_ratio[0]") -- FIXME: should do for now
DR_airspeed = find_dataref("sim/flightmodel/position/indicated_airspeed2")
DR_on_ground = find_dataref("sim/flightmodel/failures/onground_any")
DR_throttle_lever_1 = find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[0]")
DR_throttle_lever_2 = find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[1]")
DR_running_time = find_dataref("sim/time/total_running_time_sec")
DR_flap_CONF = find_dataref('sim/cockpit2/controls/flap_config')

A333DR_fws_aco_5 = find_dataref("laminar/A333/fws/aco_5")
A333DR_fws_aco_10 = find_dataref("laminar/A333/fws/aco_10")
A333DR_fws_aco_20 = find_dataref("laminar/A333/fws/aco_20")
A333DR_fws_aco_30 = find_dataref("laminar/A333/fws/aco_30")
A333DR_fws_aco_40 = find_dataref("laminar/A333/fws/aco_40")
A333DR_fws_aco_50 = find_dataref("laminar/A333/fws/aco_50")
A333DR_fws_aco_100 = find_dataref("laminar/A333/fws/aco_100")
A333DR_fws_aco_200 = find_dataref("laminar/A333/fws/aco_200")
A333DR_fws_aco_300 = find_dataref("laminar/A333/fws/aco_300")
A333DR_fws_aco_400 = find_dataref("laminar/A333/fws/aco_400")
A333DR_fws_aco_500 = find_dataref("laminar/A333/fws/aco_500")
A333DR_fws_aco_1000 = find_dataref("laminar/A333/fws/aco_1000")
A333DR_fws_aco_2000 = find_dataref("laminar/A333/fws/aco_2000")
A333DR_fws_aco_2500 = find_dataref("laminar/A333/fws/aco_2500")
A333DR_fws_aco_2500B = find_dataref("laminar/A333/fws/aco_2500B")
A333DR_fws_aco_10_retard = find_dataref("laminar/A333/fws/aco_10_retard")
A333DR_fws_aco_20_retard= find_dataref("laminar/A333/fws/aco_20_retard")
A333DR_fws_aco_retard = find_dataref("laminar/A333/fws/aco_retard")
A333DR_fws_aco_stall = find_dataref("laminar/A333/fws/aco_stall")
A333DR_fws_aco_windshear = find_dataref("laminar/A333/fws/aco_windshear")
A333DR_fws_aco_speed = find_dataref("laminar/A333/fws/aco_speed")
A333DR_fws_aco_hndrd_abv = find_dataref("laminar/A333/fws/aco_hndrd_abv")
A333DR_fws_aco_minimum = find_dataref("laminar/A333/fws/aco_minimum")

A333DR_fws_aco_priority_left = find_dataref("laminar/A333/fws/aco_priority_left")
A333DR_fws_aco_priority_right = find_dataref("laminar/A333/fws/aco_priority_right")
A333DR_fws_aco_dual_input = find_dataref("laminar/A333/fws/aco_dual_input")

A333DR_fws_aco_ap_off = find_dataref("laminar/A333/fws/aco_ap_off")



A333DR_fws_aco_5_playing = create_dataref("laminar/A333/aco_5_playing", "number")
A333DR_fws_aco_10_playing = create_dataref("laminar/A333/aco_10_playing", "number")
A333DR_fws_aco_20_playing = create_dataref("laminar/A333/aco_20_playing", "number")
A333DR_fws_aco_30_playing = create_dataref("laminar/A333/aco_30_playing", "number")
A333DR_fws_aco_40_playing = create_dataref("laminar/A333/aco_40_playing", "number")
A333DR_fws_aco_50_playing = create_dataref("laminar/A333/aco_50_playing", "number")
A333DR_fws_aco_100_playing = create_dataref("laminar/A333/aco_100_playing", "number")
A333DR_fws_aco_200_playing = create_dataref("laminar/A333/aco_200_playing", "number")
A333DR_fws_aco_300_playing = create_dataref("laminar/A333/aco_300_playing", "number")
A333DR_fws_aco_400_playing = create_dataref("laminar/A333/aco_400_playing", "number")
A333DR_fws_aco_500_playing = create_dataref("laminar/A333/aco_500_playing", "number")
A333DR_fws_aco_500C_playing = create_dataref("laminar/A333/aco_500C_playing", "number")
A333DR_fws_aco_1000_playing = create_dataref("laminar/A333/aco_1000_playing", "number")
A333DR_fws_aco_2000_playing = create_dataref("laminar/A333/aco_2000_playing", "number")
A333DR_fws_aco_2500_playing = create_dataref("laminar/A333/aco_2500_playing", "number")
A333DR_fws_aco_2500B_playing = create_dataref("laminar/A333/aco_2500B_playing", "number")
A333DR_fws_aco_stall_playing = create_dataref("laminar/A333/aco_stall_playing", "number")
A333DR_fws_aco_windshear_playing = create_dataref("laminar/A333/aco_windshear_playing", "number")
A333DR_fws_aco_speed_playing = create_dataref("laminar/A333/aco_speed_playing", "number")
A333DR_fws_aco_hundred_above_playing = create_dataref("laminar/A333/aco_hundred_above_playing", "number")
A333DR_fws_aco_minimum_playing = create_dataref("laminar/A333/aco_minimum_playing", "number")
A333DR_fws_aco_10_retard_playing = create_dataref("laminar/A333/fws/aco_10_retard_playing", "number")
A333DR_fws_aco_20_retard_playing = create_dataref("laminar/A333/fws/aco_20_retard_playing", "number")
A333DR_fws_aco_retard_playing = create_dataref("laminar/A333/fws/aco_retard_playing", "number")

A333DR_fws_aco_priority_left_playing = create_dataref("laminar/A333/aco_priority_left_playing", "number")
A333DR_fws_aco_priority_right_playing = create_dataref("laminar/A333/aco_priority_right_playing", "number")
A333DR_fws_aco_dual_input_playing = create_dataref("laminar/A333/aco_dual_input_playing", "number")

A333DR_fws_aco_ap_off_playing = create_dataref("laminar/A333/fws/aco_ap_off_playing", "number")

DR_gpws_message = create_dataref("laminar/gpws/message", "number")
DR_gpws_message_debug = create_dataref("laminar/gpws/message_debug", "string")

-- Be sure to sync the ids with the FMOD event names (and durations)
-- This list establishes message priority as per the Honeywell MK VI & VIII manual
-- FIXME: made local because of https://github.com/X-Plane/XLua/issues/4
local messages
local message_count
local is_bank_angle_played
local is_sinkrate_played
local is_mode4a_2lowgear_played
local is_mode4a_2lowterrain_played
local is_mode4b_2lowflaps_played
local is_mode4b_2lowterrain_played

local is_replay_initialized
local last_time

function bool2logic(bool)
	return ternary(bool == true, 1, 0)
end

function initialize()
    messages = {

        -- Honeywell
        [1] = { id = 'pull_up', is_playing = false, wants_play = false, duration = 1900 },
        [2] = { id = 'whoop_pull_up', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [3] = { id = 'terrain_x2', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [4] = { id = 'terrain_ahead', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [5] = { id = 'obstacle_ahead', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [6] = { id = 'terrain', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [7] = { id = 'caution_terrain', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [8] = { id = 'caution_obstacle', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [9] = { id = 'too_low_terrain', is_playing = false, wants_play = false, duration = 1400 },

        -- Airbus
        [10] = { id = 'stall', is_playing = false, wants_play = false, duration = 2400 },
        [11] = { id = 'windshear', is_playing = false, wants_play = false, duration = 2100 },
        [12] = { id = 'speed', is_playing = false, wants_play = false, duration = 3000 },
        [13] = { id = 'hundred_above', is_playing = false, wants_play = false, duration = 900 },
        [14] = { id = 'minimums', is_playing = false, wants_play = false, duration = 720 },

        [15] = { id = '50ft', is_playing = false, wants_play = false, duration = 600 },
        [16] = { id = '5ft', is_playing = false, wants_play = false, duration = 420 },
        [17] = { id = '10ft', is_playing = false, wants_play = false, duration = 650 },
        [18] = { id = '20ft', is_playing = false, wants_play = false, duration = 650 },
        [19] = { id = '30ft', is_playing = false, wants_play = false, duration = 650 },
        [20] = { id = '40ft', is_playing = false, wants_play = false, duration = 650 },
        [21] = { id = '100ft', is_playing = false, wants_play = false, duration = 750 },
        [22] = { id = '200ft', is_playing = false, wants_play = false, duration = 800 },
        [23] = { id = '300ft', is_playing = false, wants_play = false, duration = 800 },
        [24] = { id = '400ft', is_playing = false, wants_play = false, duration = 800 },
        [25] = { id = '500ft', is_playing = false, wants_play = false, duration = 800 },
        [26] = { id = '1000ft', is_playing = false, wants_play = false, duration = 900 },
        [27] = { id = '2000ft', is_playing = false, wants_play = false, duration = 900 },
        [28] = { id = '2500Bft', is_playing = false, wants_play = false, duration = 1500 },
        [29] = { id = '2500ft', is_playing = false, wants_play = false, duration = 1500 },
        [30] = { id = '10ft_retard', is_playing = false, wants_play = false, duration = 1300 },
        [31] = { id = '20ft_retard', is_playing = false, wants_play = false, duration = 1400 },
        [32] = { id = 'retard', is_playing = false, wants_play = false, duration = 1400 },

        -- Honeywell
        [33] = { id = 'too_low_flaps', is_playing = false, wants_play = false, duration = 1800 },
        [34] = { id = 'too_low_gear', is_playing = false, wants_play = false, duration = 1800 },
        [35] = { id = 'sinkrate', is_playing = false, wants_play = false, duration = 1800 },
        [36] = { id = 'dont_sink', is_playing = false, wants_play = false, duration = 2000 }, -- TODO
        [37] = { id = 'glideslope', is_playing = false, wants_play = false, duration = 800 },
        [38] = { id = 'bank_angle', is_playing = false, wants_play = false, duration = 1800 },
        [39] = { id = 'bank_angle_x2', is_playing = false, wants_play = false, duration = 2000 }, -- TODO

        -- Airbus
        [40] = { id = 'priority_left', is_playing = false, wants_play = false, duration = 1400 },
        [41] = { id = 'priority_right', is_playing = false, wants_play = false, duration = 1400 },
        [42] = { id = 'dual_input', is_playing = false, wants_play = false, duration = 1400 },

        [43] = { id = 'ap_off', is_playing = false, wants_play = false, duration = 1400 }
    }

    message_count = #messages
    is_bank_angle_played = false
    is_sinkrate_played = false
    is_mode4a_2lowgear_played = false
    is_mode4a_2lowterrain_played = false
    is_mode4b_2lowflaps_played = false
    is_mode4b_2lowterrain_played = false
    is_replay_initialized = false
    last_time = 0

    --print('[GPWS] Init: Total messages', message_count)
end

function set_gpws_message()

    local highest_playing = message_count + 1
    local clear_rest = false

    for i = 1, message_count do
        local cur_message = messages[i]

        if clear_rest then
            cur_message.is_playing = false
            cur_message.wants_play = false
        end

        if (cur_message.is_playing and i < highest_playing) then
            highest_playing = i
            clear_rest = true
        end

        if (cur_message.wants_play and highest_playing > i) then

            if (not cur_message.is_playing) then
                --print('[GPWS] Triggering now:', cur_message.id)
                cur_message.is_playing = true

                run_after_time(function()
                    if (cur_message.is_playing) then
                        --print('[GPWS] Trigger ended:', cur_message.id)
                        cur_message.is_playing = false
                    end
                end, cur_message.duration / 1000)

                cur_message.wants_play = false
                highest_playing = i
                clear_rest = true

            end
        end
    end
    if (messages[highest_playing] ~= nil and messages[highest_playing].is_playing) then
        DR_gpws_message = highest_playing
        DR_gpws_message_debug = messages[highest_playing].id
    else
        DR_gpws_message = 0
        DR_gpws_message_debug = "-"
    end
end

function get_message_by_id(id)
    for i = 1, message_count do
        local message = messages[i]
        if ( message['id'] == id ) then
            return message
        end
    end
    return nil
end

function play_message(id, val)
    local message = get_message_by_id(id)
    if val then
        if (not message.is_playing and not message.wants_play) then
            --print('[GPWS] Requesting:', message.id)
            message.wants_play = true
        end
    else
        if message.wants_play or message.is_playing then
            --print('[GPWS] Unrequesting:', message.id)
            message.wants_play = false
            message.is_playing = false
        end
    end
end

function mode_5_glideslope()
    if DR_gs_annun == 1 then
        play_message('glideslope', true)
    end
end

function mode_1_pull_up()
    if DR_pull_up_annun == 1 and DR_vario < 0 then
        play_message('pull_up', true)
    end
end


function airbus_overrides()

    -- ORDERED ACCORDING TO AIRBUS DOCS
    if A333DR_fws_aco_stall == 1 then play_message('stall', true) end                   -- 'STALL'
    if A333DR_fws_aco_windshear == 1 then play_message('windshear', true) end           -- 'WINDSHEAR, WINDSHEAR, WINDSHEAR'
    if A333DR_fws_aco_speed == 1 then play_message('speed', true) end                   -- 'SPEED, SPEED, SPEED'
    if A333DR_fws_aco_hndrd_abv == 1 then play_message('hundred_above', true) end       -- 'HUNDRED ABOVE'
    if A333DR_fws_aco_minimum == 1 then play_message('minimums', true) end              -- 'MINIMUM'

    if A333DR_fws_aco_50 == 1 then play_message('50ft', true) end                       -- 'FIFTY'
    if A333DR_fws_aco_5 == 1 then play_message('5ft', true) end                         -- 'FIVE'
    if A333DR_fws_aco_10 == 1 then play_message('10ft', true) end                       -- 'TEN'
    if A333DR_fws_aco_20 == 1 then play_message('20ft', true) end                       -- 'TWENTY'
    if A333DR_fws_aco_30 == 1 then play_message('30ft', true) end                       -- 'THIRTY'
    if A333DR_fws_aco_40 == 1 then play_message('40ft', true) end                       -- 'FORTY'
    if A333DR_fws_aco_100 == 1 then play_message('100ft', true) end                     -- 'ONE HUNDRED'
    if A333DR_fws_aco_200 == 1 then play_message('200ft', true) end                     -- 'TWO HUNDRED'
    if A333DR_fws_aco_300 == 1 then play_message('300ft', true) end                     -- 'THREE HUNDRED'
    if A333DR_fws_aco_400 == 1 then play_message('400ft', true) end                     -- 'FOUR HUNDRED'
    if A333DR_fws_aco_500 == 1 then play_message('500ft', true) end                     -- 'FIVE HUNDRED'
    if A333DR_fws_aco_1000 == 1 then play_message('1000ft', true) end                   -- 'ONE THOUSAND'
    if A333DR_fws_aco_2000 == 1 then play_message('2000ft', true) end                    -- 'TWO THOUSAND'
    if A333DR_fws_aco_2500B == 1 then play_message('2500Bft', true) end                 -- 'TWENTY FIVE HUNDRED'
    if A333DR_fws_aco_2500 == 1 then play_message('2500ft', true) end                   -- 'TWO THOUSAND FIVE HUNDRED'

    if A333DR_fws_aco_10_retard == 1 then play_message('10ft_retard', true) end         -- 'TEN, RETARD'
    if A333DR_fws_aco_20_retard == 1 then play_message('20ft_retard', true) end         -- 'TWENTY, RETARD'
    if A333DR_fws_aco_retard == 1 then play_message('retard', true) end                 -- 'RETARD'

    if A333DR_fws_aco_priority_left == 1 then play_message('priority_left', true) end   -- 'PRIORITY LEFT'
    if A333DR_fws_aco_priority_right == 1 then play_message('priority_right', true) end -- 'PRIORITY RIGHT'
    if A333DR_fws_aco_dual_input == 1 then play_message('dual_input', true) end         -- 'DUAL INPUT'

    A333DR_fws_aco_stall_playing = bool2logic(messages[10].is_playing)
    A333DR_fws_aco_windshear_playing = bool2logic(messages[11].is_playing)
    A333DR_fws_aco_speed_playing = bool2logic(messages[12].is_playing)
    A333DR_fws_aco_hundred_above_playing = bool2logic(messages[13].is_playing)
    A333DR_fws_aco_minimum_playing = bool2logic(messages[14].is_playing)

    A333DR_fws_aco_50_playing = bool2logic(messages[15].is_playing)
    A333DR_fws_aco_5_playing = bool2logic(messages[16].is_playing)
    A333DR_fws_aco_10_playing = bool2logic(messages[17].is_playing)
    A333DR_fws_aco_20_playing = bool2logic(messages[18].is_playing)
    A333DR_fws_aco_30_playing = bool2logic(messages[19].is_playing)
    A333DR_fws_aco_40_playing = bool2logic(messages[20].is_playing)
    A333DR_fws_aco_100_playing = bool2logic(messages[21].is_playing)
    A333DR_fws_aco_200_playing = bool2logic(messages[22].is_playing)
    A333DR_fws_aco_300_playing = bool2logic(messages[23].is_playing)
    A333DR_fws_aco_400_playing = bool2logic(messages[24].is_playing)
    A333DR_fws_aco_500_playing = bool2logic(messages[25].is_playing)
    A333DR_fws_aco_1000_playing = bool2logic(messages[26].is_playing)
    A333DR_fws_aco_2000_playing = bool2logic(messages[27].is_playing)
    A333DR_fws_aco_2500B_playing = bool2logic(messages[28].is_playing)
    A333DR_fws_aco_2500_playing = bool2logic(messages[29].is_playing)

    A333DR_fws_aco_10_retard_playing = bool2logic(messages[30].is_playing)
    A333DR_fws_aco_20_retard_playing = bool2logic(messages[31].is_playing)
    A333DR_fws_aco_retard_playing = bool2logic(messages[32].is_playing)

    A333DR_fws_aco_priority_left_playing = bool2logic(messages[40].is_playing)
    A333DR_fws_aco_priority_right_playing = bool2logic(messages[41].is_playing)
    A333DR_fws_aco_dual_input_playing = bool2logic(messages[42].is_playing)


end







-- TODO: Make it insist at 20% increase & additional 20% increase.
function mode_6_bank_angle()
    local roll_angle = math.abs(DR_roll_indicator)

    if DR_autopilot_on == 0 then

        if DR_rad_alt > 5 and DR_rad_alt < 30 then
            if roll_angle >= 10 then
                if not is_bank_angle_played then
                    play_message('bank_angle', true)
                    is_bank_angle_played = true
                end
            end
        elseif DR_rad_alt >= 30 and DR_rad_alt < 150 then
            local min_alt = 4 * roll_angle - 10;
            if roll_angle >= 10 and roll_angle < 40 and DR_rad_alt < min_alt then
                if not is_bank_angle_played then
                    play_message('bank_angle', true)
                    is_bank_angle_played = true
                end
            end
        elseif DR_rad_alt >= 150 and DR_rad_alt < 2450 then
            local min_alt = 153.333 * roll_angle - 5983.33;
            if roll_angle >= 40 and roll_angle < 55 and DR_rad_alt < min_alt then
                if not is_bank_angle_played then
                    play_message('bank_angle', true)
                    is_bank_angle_played = true
                end
            end
        elseif DR_rad_alt >= 2450 then
            if roll_angle >= 55 then
                if not is_bank_angle_played then
                    play_message('bank_angle', true)
                    is_bank_angle_played = true
                end
            end
        end

    elseif DR_autopilot_on == 1 then

        if DR_rad_alt > 5 and DR_rad_alt < 30 then
            if roll_angle >= 10 then
                if not is_bank_angle_played then
                    play_message('bank_angle', true)
                    is_bank_angle_played = true
                end
            end
        elseif DR_rad_alt >= 30 and DR_rad_alt < 122 then
            local min_alt = 4 * roll_angle - 10;
            if roll_angle >= 10 and roll_angle < 33 and DR_rad_alt < min_alt then
                if not is_bank_angle_played then
                    play_message('bank_angle', true)
                    is_bank_angle_played = true
                end
            end
        elseif DR_rad_alt >= 122 then
            if roll_angle >= 33 then
                if not is_bank_angle_played then
                    play_message('bank_angle', true)
                    is_bank_angle_played = true
                end
            end
        end

    end

    -- Reset if bank angle is recentered
    if is_bank_angle_played and roll_angle < 10 then
        is_bank_angle_played = false
    end
end

-- TODO: Make it insist at 20% additional penetration and see if there's need to implement the second zone for pull_up
function mode_1_sinkrate()
    local min_alt = 0.64473 * math.abs(DR_vario) - 644.73
    if DR_rad_alt < 2450 and DR_vario < 0 and DR_vario > -4800 and DR_rad_alt < min_alt then
        if not is_sinkrate_played then
            play_message('sinkrate', true)
            is_sinkrate_played = true
        end
    else
        -- Reset if out of the zone
        if is_sinkrate_played then
            is_sinkrate_played = false
        end
    end
end

function mode_4_too_low()

--    local flaps_not_in_landing_config = (A333DR_cs_CONF == '1' or A333DR_cs_CONF == '1+F' or A333DR_cs_CONF == '1s' or A333DR_cs_CONF == '2' or A333DR_cs_CONF == '2s')

    -- Mode 4a
    if DR_gear_ratio < 1 and DR_on_ground == 0 then

        if DR_airspeed < 190 and DR_rad_alt < 500 and DR_vario < -300 then
            if not is_mode4a_2lowgear_played then
                play_message('too_low_gear', true)
                run_after_time(function()
                    -- Only mark played if actually played or else will be always obscured by '500ft'
                    if get_message_by_id('too_low_gear').is_playing then
                        is_mode4a_2lowgear_played = true
                    end
                end, 1)
            end
        else
            -- Reset if out of the zone
            if is_mode4a_2lowgear_played then
                is_mode4a_2lowgear_played = false
            end
        end

        local min_alt = 2.3809 * DR_airspeed + 47.6190
        if DR_airspeed >= 190 and DR_rad_alt < 1000 and DR_rad_alt < min_alt and DR_vario < -300 then
            if not is_mode4a_2lowterrain_played then
                play_message('too_low_terrain', true)
                run_after_time(function()
                    -- Only mark played if actually played or else will be always obscured by '500ft'
                    if  get_message_by_id('too_low_terrain').is_playing then
                        is_mode4a_2lowterrain_played = true
                    end
                end, 1)
            end
        else
            -- Reset if out of the zone
            if is_mode4a_2lowterrain_played then
                is_mode4a_2lowterrain_played = false
            end
        end

        -- Mode 4b
    elseif DR_gear_ratio == 1 and --[[DR_flap_ratio < 0.625--]] --[[flaps_not_in_landing_config--]] DR_flap_CONF <= 5 and DR_on_ground == 0 and DR_vario < -300 then


        if DR_airspeed < 150 and (DR_rad_alt < 245 and DR_rad_alt > 30) then
            if not is_mode4b_2lowflaps_played then
                play_message('too_low_flaps', true)
                is_mode4b_2lowflaps_played = true
            end
        else
            -- Reset if out of the zone
            if is_mode4b_2lowflaps_played then
                is_mode4b_2lowflaps_played = false
            end
        end

        local min_alt = 7.55 * DR_airspeed - 887.5
        if DR_airspeed >= 150 and DR_rad_alt < 1000 and DR_rad_alt < min_alt and DR_vario < -300 then
            if not is_mode4b_2lowterrain_played then
                play_message('too_low_terrain', true)
                is_mode4b_2lowterrain_played = true
            end
        else
            -- Reset if out of the zone
            if is_mode4b_2lowterrain_played then
                is_mode4b_2lowterrain_played = false
            end
        end


    end

end

function save_current_time()
    last_time = DR_running_time;
end

-- Ensure reset status of GPWS on replay
function update_replay_status()

    -- It's not enough to know if we're in replay, we also must reset if the playhead goes back in time
    if (IN_REPLAY == 1 or last_time > DR_running_time) then
        if not is_replay_initialized then
            --print('[GPWS] In replay, reinitialize')
            initialize()
            is_replay_initialized = true
        end
    else
        if is_replay_initialized then
            --print('[GPWS] Not in replay')
            is_replay_initialized = false
        end
    end

end


function ternary(condition, ifTrue, ifFalse)
	if condition then return ifTrue else return ifFalse end
end


-- *******************************************************************
-- Hooks
-- *******************************************************************

function update_datarefs()
    mode_1_pull_up()
    mode_1_sinkrate()
    mode_4_too_low()
    mode_5_glideslope()
    mode_6_bank_angle()
    airbus_overrides()
    set_gpws_message()
    update_replay_status()
    save_current_time() -- must always be last
end

function after_physics()
    update_datarefs()
end

function after_replay()
    update_datarefs()
end

function flight_start()
    initialize()
end
