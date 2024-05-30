--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws200.lua
* Process: FWS 	 Global Variable Assignment
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
*       					     COPYRIGHT © 2021, 2022
*					 	   L A M I N A R   R E S E A R C H
*								  ALL RIGHTS RESERVED
*****************************************************************************************
--]]


--print("LOAD: A333.ecam_fws200.lua")

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



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             FIND CUSTOM COMMANDS								**--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--



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



--*************************************************************************************--
--** 				                 CREATE OBJECTS              	     			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              FUNCTION DEFINITIONS         	    				 **--
--*************************************************************************************--

function A333_fws_global_variable_assignment()

    AP1CF           = ternary(A333DR_pack1_fault == 1, true, false)
    AP1F            = ternary(A333DR_pack1_fault == 1, true, false)
    AP1FCVFC        = ternary(simDR_bleedair_pack1 == 0, true, false)
    AP1PBOF		    = ternary(A333_switches_pack1_pos == 0, true, false)
    AP2CF           = ternary(A333DR_pack2_fault == 1, true, false)
    AP2F            = ternary(A333DR_pack2_fault == 1, true, false)
    AP2FCVFC        = ternary(simDR_bleedair_pack2 == 0, true, false)
    AP2PBOF		    = ternary(A333_switches_pack2_pos == 0, true, false)
    ARAPBON         = ternary(A333_switches_ram_air_pos == 1, true, false)

    BAPUBPBOF_1     = ternary(A333_switches_apu_bleed_pos == 0.0, true, false)
    BAPUBPBOF_2     = ternary(A333_switches_apu_bleed_pos == 0.0, true, false)
    BAPUBVFC_1      = ternary(A333_annun_apu_bleed_on == 0.0, true, false)
    BAPUBVFC_2      = ternary(A333_annun_apu_bleed_on == 0.0, true, false)
    BE1BPBOF_1      = ternary(A333_eng1_bleed_button_pos == 0.0, true, false)
    BE1BPBOF_2      = ternary(A333_eng1_bleed_button_pos == 0.0, true, false)
    BE1LOTEMP_1     = ternary(A333_precooler1_temp < 150.0, true, false)
    BE1LOTEMP_2     = ternary(A333_precooler1_temp < 150.0, true, false)
    BE2BPBOF_1      = ternary(A333_eng2_bleed_button_pos == 0.0, true, false)
    BE2BPBOF_2      = ternary(A333_eng2_bleed_button_pos == 0.0, true, false)
    BE2LOTEMP_1     = ternary(A333_precooler2_temp < 150.0, true, false)
    BE2LOTEMP_2     = ternary(A333_precooler2_temp < 150.0, true, false)
    BXFVFC_1	    = ternary(A333_isol_valve_right_pos == 0.0, true, false)
    BXFVFC_2	    = ternary(A333_isol_valve_right_pos == 0.0, true, false)
    BXFVFO_1        = ternary(A333_isol_valve_right_pos == 2.0, true, false)
    BXFVFO_2        = ternary(A333_isol_valve_right_pos == 2.0, true, false)

    CFSBLT          = ternary(simDR_switch_seat_belt == 1, true, false)
    CNOSMOK         = ternary(simDR_switch_no_smoking == 1, true, false)

    DLFCDNC         = ternary(simDR_door_open_ratio[0] > 0.0, true, false)
    DRFCDNC         = ternary(simDR_door_open_ratio[1] > 0.0, true, false)
    DLMCDNC         = ternary(simDR_door_open_ratio[2] > 0.0, true, false)
    DRMCDNC         = ternary(simDR_door_open_ratio[3] > 0.0, true, false)
    DLEEDNC         = ternary(simDR_door_open_ratio[4] > 0.0, true, false)
    DREEDNC         = ternary(simDR_door_open_ratio[5] > 0.0, true, false)
    DLACDNC         = ternary(simDR_door_open_ratio[6] > 0.0, true, false)
    DRACDNC         = ternary(simDR_door_open_ratio[7] > 0.0, true, false)

    EAC1OF          = ternary(simDR_bus_volts[0] < 1.0, true, false)
    EAC2OF          = ternary(simDR_bus_volts[1] < 1.0, true, false)
    EACSOF          = ternary((simDR_ESS_bus_assign == 1 and simDR_bus_volts[0] < 1.0) or (simDR_ESS_bus_assign == 2 and simDR_bus_volts[1] < 1.0), true, false )
    EADCGNL         = ternary(simDR_elec_gen1_fail == 6 and simDR_elec_gen2_fail == 6, true, false)
    EAPUGNPBOF      = ternary(A333_buttons_gen_apu_pos == 0, true, false)
    EBA1PBON        = ternary(simDR_battery_on[0] == 1, true, false)
    EBA2PBON        = ternary(simDR_battery_on[1] == 1, true, false)
    EBAT1F          = ternary(simDR_fail_battery1 == 6, true, false)
    EBAT2F          = ternary(simDR_fail_battery2 == 6, true, false)
    EBTIEPBOF       = ternary(A333_buttons_bus_tie_pos == 0.0, true, false)
    EDC1OF          = ternary(simDR_bus_volts[0] < 1.0, true, false)
    EDC2OF          = ternary(simDR_bus_volts[1] < 1.0, true, false)
    EDCSOF          = ternary(simDR_bus_volts[3] < 1.0, true, false)
    EEPWRCON        = ternary(A333_status_GPU_avail == 1, true, false)
    EGN1COF         = ternary(A333_IDG1_status == 0, true, false)
    EGN2COF         = ternary(A333_IDG2_status == 0, true, false)
    EGN1PBOF        = ternary(A333_buttons_gen1_pos == 0, true, false)
    EGN2PBOF        = ternary(A333_buttons_gen2_pos == 0, true, false)
    ENG1INOP        = ternary(simDR_elec_gen1_fail == 6, true, false)
    ENG2INOP        = ternary(simDR_elec_gen2_fail == 6, true, false)
    ENG3INOP        = ternary(simDR_apu_fail == 6, true, false)

    FCTP1COF        = ternary(A333_ECAM_fuel_center_xfer_any == 0, true, false)
    FCTP2COF        = ternary(A333_ECAM_fuel_center_xfer_any == 0, true, false)
    FLTP1LP         = ternary(simDR_tank_pump_psi[0] < 0.0, true, false)
    FLTP12F         = ternary(A333_left_pump1_pos == 1 and A333_left_pump1_pos == 1.0 and simDR_tank_pump_psi[0] < 1.0, true, false)
    FLTP1COF        = ternary(A333_left_pump1_pos == 0.0, true, false)
    FLTP2COF        = ternary(A333_left_pump2_pos == 0.0, true, false)
    FLTP2LP         = ternary(simDR_tank_pump_psi[0] < 0.0, true, false)
    FLWTLLA         = ternary(simDR_fuel_left_wing < 1100.0, true, false)
    FLWTLLB         = ternary(simDR_fuel_left_wing < 1100.0, true, false)
    FRTP1COF        = ternary(A333_right_pump1_pos == 0.0, true, false)
    FRTP12F         = ternary(A333_right_pump1_pos == 1 and A333_right_pump2_pos == 1.0 and simDR_tank_pump_psi[1] < 1.0, true, false)
    FRTP2COF        = ternary(A333_right_pump2_pos == 0.0, true, false)
    FRWTLLA         = ternary(simDR_fuel_right_wing < 1100.0, true, false)
    FRWTLLB         = ternary(simDR_fuel_right_wing < 1100.0, true, false)
    FXFVFC          = ternary(A333_fuel_crossfeed_valve_pos == 0.0, true, false)
    FXFVPBON	    = ternary(A333DR_fuel_wing_crossfeed_pos == 1.0, true, false)

    GBFANCON_1      = ternary(simDR_brake_fan == 1, true, false)
    GBFANCON_2      = ternary(simDR_brake_fan == 1, true, false)
    GBRK1OVHT       = ternary(A333_wheel_brake_temp1 > 300.0, true, false)
    GBRK2OVHT       = ternary(A333_wheel_brake_temp2 > 300.0, true, false)
    GBRK3OVHT       = ternary(A333_wheel_brake_temp3 > 300.0, true, false)
    GBRK4OVHT       = ternary(A333_wheel_brake_temp4 > 300.0, true, false)
    GBRK5OVHT       = ternary(A333_wheel_brake_temp5 > 300.0, true, false)
    GBRK6OVHT       = ternary(A333_wheel_brake_temp6 > 300.0, true, false)
    GBRK7OVHT       = ternary(A333_wheel_brake_temp7 > 300.0, true, false)
    GBRK8OVHT       = ternary(A333_wheel_brake_temp8 > 300.0, true, false)
    GDLORA_1        = ternary(simDR_auto_brake == 4, true, false)
    GDLORA_2        = ternary(simDR_auto_brake == 4, true, false)
    GDMDRA_1        = ternary(simDR_auto_brake == 5, true, false)
    GDMDRA_2        = ternary(simDR_auto_brake == 5, true, false)
    GDMXRA_1        = ternary(simDR_auto_brake == 0, true, false)
    GDMXRA_2        = ternary(simDR_auto_brake == 0, true, false)
    GELLGCOMPR		= ternary(simDR_tire_deflection_mtr[1] > 0.15, true, false)
    GGLSD_1         = ternary(simDR_gear_handle_animation < 1.0, false, true)
    GGLSD_2         = ternary(simDR_gear_handle_animation < 1.0, false, true)
    GGLSUP_1        = ternary(simDR_gear_handle_animation > 0.0, false, true)
    GGLSUP_2        = ternary(simDR_gear_handle_animation > 0.0, false, true)
    GLDNUPL_1       = ternary(simDR_gear_deploy_ratio[1] > 0.1 and simDR_gear_deploy_ratio[1] < 0.9, true, false)
    GLDNUPL_2       = ternary(simDR_gear_deploy_ratio[1] > 0.1 and simDR_gear_deploy_ratio[1] < 0.9, true, false)
    GLGNLUPNSD_1    = ternary(simDR_gear_deploy_ratio[1] > 0.0 and simDR_gear_handle_animation < 1.0, true, false)
    GLGNLUPNSD_2    = ternary(simDR_gear_deploy_ratio[1] > 0.0 and simDR_gear_handle_animation < 1.0, true, false)
    GLLGC_1			= toboolean(simDR_gear_on_ground[1])
    GLLGC_2			= toboolean(simDR_gear_on_ground[1])
    GLLGC_1_INV		= false
    GLLGC_2_INV		= false
    GLLGC_1_NCD		= ternary(simDR_gear_on_ground[1] < 0 or simDR_gear_on_ground[1] > 1, true, false)
    GLLGC_2_NCD		= ternary(simDR_gear_on_ground[1] < 0 or simDR_gear_on_ground[1] > 1, true, false)
    GLGDL_1			= ternary(simDR_gear_deploy_ratio[1] > 0.98, true, false) -- L/G DOWNLOCKED
    GLGDL_2			= ternary(simDR_gear_deploy_ratio[1] > 0.98, true, false)
    GLGNLDSD_1      = ternary(simDR_gear_deploy_ratio[1] < 1.0 and simDR_gear_handle_animation > 0.95, true, false)
    GLGNLDSD_2      = ternary(simDR_gear_deploy_ratio[1] < 1.0 and simDR_gear_handle_animation > 0.95, true, false)
    GLGNLUP_1       = ternary(simDR_gear_deploy_ratio[1] > 0.0, true, false)
    GLGNLUP_2       = ternary(simDR_gear_deploy_ratio[1] > 0.0, true, false)
    GLGNOE_1        = ternary(simDR_tire_deflection_mtr[1] > 0.0, true, false)
    GLGNOE_2        = ternary(simDR_tire_deflection_mtr[1] > 0.0, true, false)
    GLGUWGD_1       = ternary(simDR_gear_deploy_ratio[1] < 0.001 and GLGDL_1, true, false)
    GLGUWGD_2       = ternary(simDR_gear_deploy_ratio[1] < 0.001 and GLGDL_2, true, false)
    GLLGNOLK        = ternary(simDR_gear_deploy_ratio[1] > 0.0 and simDR_gear_deploy_ratio[1] < 1.0, true, false)
    GMLGC_1         = ternary(simDR_tire_deflection_mtr[1] > 0.15 and simDR_tire_deflection_mtr[2] > 0.15, true, false)
    GMLGC_2         = ternary(simDR_tire_deflection_mtr[1] > 0.15 and simDR_tire_deflection_mtr[2] > 0.15, true, false)
    GNDNUPL_1       = ternary(simDR_gear_deploy_ratio[0] > 0.1 and simDR_gear_deploy_ratio[1] < 0.9, true, false)
    GNDNUPL_2       = ternary(simDR_gear_deploy_ratio[0] > 0.1 and simDR_gear_deploy_ratio[1] < 0.9, true, false)
    GNGDL_1			= ternary(simDR_gear_deploy_ratio[0] > 0.98, true, false)
    GNGDL_2			= ternary(simDR_gear_deploy_ratio[0] > 0.98, true, false)
    GNGNLDSD_1      = ternary(simDR_gear_deploy_ratio[0] < 1.0 and simDR_gear_handle_animation > 0.95, true, false)
    GNGNLDSD_2      = ternary(simDR_gear_deploy_ratio[0] < 1.0 and simDR_gear_handle_animation > 0.95, true, false)
    GNGNLUP_1       = ternary(simDR_gear_deploy_ratio[0] > 0.0, true, false)
    GNGNLUP_2       = ternary(simDR_gear_deploy_ratio[0] > 0.0, true, false)
    GNGNLUPNSD_1    = ternary(simDR_gear_deploy_ratio[0] > 0.0 and simDR_gear_handle_animation < 1.0, true, false)
    GNGNLUPNSD_1    = ternary(simDR_gear_deploy_ratio[0] > 0.0 and simDR_gear_handle_animation < 1.0, true, false)
    GNGNOE_1        = ternary(simDR_tire_deflection_mtr[0] > 0.0, true, false)
    GNGNOE_2        = ternary(simDR_tire_deflection_mtr[0] > 0.0, true, false)
    GNGUWGD_1       = ternary(simDR_gear_deploy_ratio[0] < 0.001 and GNGDL_1, true, false)
    GNGUWGD_2       = ternary(simDR_gear_deploy_ratio[0] < 0.001 and GNGDL_2, true, false)
    GNLGNOLK        = ternary(simDR_gear_deploy_ratio[0] > 0.0 and simDR_gear_deploy_ratio[0] < 1.0, true, false)
    GNLLGCOMPR		= ternary(simDR_tire_deflection_mtr[1] > 0.15, true, false)
    GPBRKON         = ternary(simDR_park_brake >= 0.5, true, false)
    GRGDL_1			= ternary(simDR_gear_deploy_ratio[2] > 0.98, true, false)
    GRGDL_2			= ternary(simDR_gear_deploy_ratio[2] > 0.98, true, false)
    GRDNUPL_1       = ternary(simDR_gear_deploy_ratio[2] > 0.1 and simDR_gear_deploy_ratio[1] < 0.9, true, false)
    GRDNUPL_2       = ternary(simDR_gear_deploy_ratio[2] > 0.1 and simDR_gear_deploy_ratio[1] < 0.9, true, false)
    GRETIN_1		= ternary(simDR_gear_retract_fail_1 == 6 or simDR_gear_retract_fail_2 == 6 or simDR_gear_retract_fail_3 == 6, true, false)
    GRETIN_2		= ternary(simDR_gear_retract_fail_1 == 6 or simDR_gear_retract_fail_2 == 6 or simDR_gear_retract_fail_3 == 6, true, false)
    GRGNLDSD_1      = ternary(simDR_gear_deploy_ratio[2] < 1.0 and simDR_gear_handle_animation > 0.95, true, false)
    GRGNLDSD_2      = ternary(simDR_gear_deploy_ratio[2] < 1.0 and simDR_gear_handle_animation > 0.95, true, false)
    GRGNLUP_1       = ternary(simDR_gear_deploy_ratio[2] > 0.0, true, false)
    GRGNLUP_2       = ternary(simDR_gear_deploy_ratio[2] > 0.0, true, false)
    GRGNLUPNSD_1    = ternary(simDR_gear_deploy_ratio[2] > 0.0 and simDR_gear_handle_animation < 1.0, true, false)
    GRGNLUPNSD_1    = ternary(simDR_gear_deploy_ratio[2] > 0.0 and simDR_gear_handle_animation < 1.0, true, false)
    GRGNOE_1        = ternary(simDR_tire_deflection_mtr[2] > 0.0, true, false)
    GRGNOE_2        = ternary(simDR_tire_deflection_mtr[2] > 0.0, true, false)
    GRGUWGD_1       = ternary(simDR_gear_deploy_ratio[2] < 0.001 and GRGDL_1, true, false)
    GRGUWGD_2       = ternary(simDR_gear_deploy_ratio[2] < 0.001 and GRGDL_2, true, false)
    GRLGC_1		    = toboolean(simDR_gear_on_ground[2])
    GRLGC_2		    = toboolean(simDR_gear_on_ground[2])
    GRLGNOLK        = ternary(simDR_gear_deploy_ratio[2] > 0.0 and simDR_gear_deploy_ratio[2] < 1.0, true, false)
    GW1SGT_1        = (simDR_tire_rot_speed_rad_sec[1] * simDR_tire_radius[1]) * 1.94384
    GW1SGT_2        = (simDR_tire_rot_speed_rad_sec[1] * simDR_tire_radius[1]) * 1.94384

    HBEPLP          = ternary(simDR_blue_hydraulic_pressure <= 1450.0, true, false)
    HBEPOF          = ternary(simDR_elec_hydraulic_blue_on == 0.0, true, false)
    HBEPPBOF        = ternary(A333_elec_pump_blue_tog_pos == 0.0, true, false)
    HBRLL           = ternary(HBRQ < 5.0, true, false)
    HBRQ            = BlueMaxLiters * simDR_blue_fluid_ratio
    HBRQLO          = ternary(HBRQ < 5.0, true, false)
    HBSLP           = ternary(A333_ECAM_hyd_blue_status < 1.0, true, false)
    HGPLP           = ternary(simDR_green_hydraulic_pressure <= 1450.0, true, false)
    HGPPBOF         = ternary(A333_engine1_pump_green_pos == 0.0, true, false)
    HGRLL           = ternary(HGRQ < 8.0, true, false)
    HGRQ            = GreenMaxLiters * simDR_green_fluid_ratio
    HGRQLO          = ternary(HGRQ < 8.0, true, false)
    HGSLP           = ternary(A333_ECAM_hyd_green_status < 1.0, true, false)
    HNVMYEPF        = ternary(A333_hyd_elec_yellow_pump_fault == 1, true, false)
    HNVMBEPF        = ternary(A333_hyd_elec_blue_pump_fault == 1, true, false)
    HNVMGEPF        = ternary(A333_hyd_elec_green_pump_fault == 1, true, false)
    HNVMBPF         = ternary(A333_hyd_eng1_blue_pump_fault == 1, true, false)
    HNVMG1PF        = ternary(A333_hyd_eng1_green_pump_fault == 1, true, false)
    HNVMG2PF        = ternary(A333_hyd_eng2_green_pump_fault == 1, true, false)
    HNVMYPF         = ternary(A333_hyd_eng2_yellow_pump_fault == 1, true, false)
    HPRATPBOF       = ternary(A333_rat_button_pos == 0, true, false)
    HRATNFS         = ternary(simDR_rat_on > 0, true, false)
    HYEPPBON        = ternary(A333_elec_pump_yellow_tog_pos == 1.0, true, false)
    HYEPON          = ternary(simDR_elec_hydraulic_yellow_on == 1.0, true, false)
    HYPLP           = ternary(simDR_yellow_hydraulic_pressure <= 1450.0, true, false)
    HYPPBOF         = ternary(A333_engine2_pump_yellow_pos == 0.0, true, false)
    HYRLL           = ternary(HYRQ < 5.0, true, false)
    HYRQ            = YellowMaxLiters * simDR_yellow_fluid_ratio
    HYRQLO          = ternary(HYRQ < 5.0, true, false)
    HYSLP           = ternary(A333_ECAM_hyd_yellow_status < 1.0, true, false)

    IE1AIPBON       = ternary(A333_engine_anti_ice1 == 1, true, false)
    IE1AIVF         = ternary(simDR_engine1_anti_ice_fail == 6, true, false)
    IE1ID           = ternary(simDR_engine1_heat > 0.0, true, false)
    IE2AIPBON       = ternary(A333_engine_anti_ice2 == 1, true, false)
    IE2AIVF         = ternary(simDR_engine2_anti_ice_fail == 6, true, false)
    IE2ID           = ternary(simDR_engine1_heat > 0.0, true, false)
    ILWAILP         = ternary(A333_precooler1_psi < 0.25, true, false)
    ILWAIVC         = ternary(A333_wing_heat_valve_pos_left < 0.01, true, false)
    IRWAILP         = ternary(A333_precooler2_psi < 0.25, true, false)
    IRWAIVC         = ternary(A333_wing_heat_valve_pos_right < 0.01, true, false)
    IWAION		    = ternary(simDR_wing_heat_left == 1 and simDR_wing_heat_right == 1, true, false)
    IWAIPBON        = ternary(A333_wing_anti_ice == 1.0, true, false)

    JML1OFF         = ternary(A333_switches_engine1_start_pos == 0.0 and A333_switches_engine1_start_lift == 0.0, true, false)
    JML1ON			= ternary(A333_switches_engine1_start_pos == 1.0 and A333_switches_engine1_start_lift == 0.0, true, false)
    JML2OFF         = ternary(A333_switches_engine2_start_pos == 0.0 and A333_switches_engine2_start_lift == 0.0, true, false)
    JML2ON			= ternary(A333_switches_engine2_start_pos == 1.0 and A333_switches_engine2_start_lift == 0.0, true, false)


    JR1AIDLE_1A		= ternary(simDR_engine_n1_pct[0] >= 19.0, true, false)
    JR1AIDLE_1B		= ternary(simDR_engine_n1_pct[0] >= 19.0, true, false)
    JR1AUTOST_1A    = Engine1StartSequenceInProgress()
    JR1AUTOST_1B    = Engine2StartSequenceInProgress()
    JR1CONTIGN_1A   = ternary(simDR_igniter_on[0] == 1.0, true, false)
    JR1CONTIGN_1B   = ternary(simDR_igniter_on[0] == 1.0, true, false)
    JR1ESI          = ternary(simDR_engine1_igniter[0] == 1, true, false)
    JR1HGST_1A      = ternary(simDR_eng1_hung_start == 6, true, false)
    JR1HGST_1B      = ternary(simDR_eng1_hung_start == 6, true, false)
    JR1IDLE_1A      = ternary(simDR_engine_n1_pct[0] >= 18.0 and simDR_engine_n1_pct[0] <= 20.0, true, false)
    JR1IDLE_1B      = ternary(simDR_engine_n1_pct[0] >= 18.0 and simDR_engine_n1_pct[0] <= 20.0, true, false)
    JR1IFT          = ternary(imDR_fail_rel_ignitr0 == 6, true, false)
    JRIGNSEL        = ternary(simDR_starter_mode == 1, true, false)
    JR1MINPWR_1A    = ternary(simDR_engine_n1_pct[0] > 19.0 and simDR_engine_n1_pct[0] < 22.0, true, false)
    JR1MINPWR_1B    = ternary(simDR_engine_n1_pct[0] > 19.0 and simDR_engine_n1_pct[0] < 22.0, true, false)
    JR1N1_1A		= simDR_engine_n1_pct[0]
    JR1N1_1B		= simDR_engine_n1_pct[0]
    JR1OOT_1        = 190.0
    JR1OOT_2        = 190.0
    JR1OLP          = ternary(simDR_engine_oil_pressure_psi[0] < 25.0, true, false)
    JR1OT           = simDR_engine_oil_temp_degC[0]
    JR1OTAD_1       = 170.0
    JR1OTAD_2       = 170.0
    JR1REVD_1A      = ternary(simDR_engine_reverse_deploy_ratio[0] > 0.99, true, false)
    JR1REVD_1B      = ternary(simDR_engine_reverse_deploy_ratio[0] > 0.99, true, false)
    JR1REVKO        = ternary(simDR_engine1_reverse_fail == 6, true, false)
    JR1REVUNL_1A    = ternary(simDR_engine_reverse_deploy_ratio[0] > 0.001, true, false)
    JR1REVUNL_1B    = ternary(simDR_engine_reverse_deploy_ratio[0] > 0.001, true, false)
    JR1TLA_1A		= simDR_throttle_ratio[0]
    JR1TLA_1B		= simDR_throttle_ratio[0]
    JR1TRMDB21_1A   = ternary(A333_ECAM_thrust_mode == 2, true, false)
    JR1TRMDB21_1B   = ternary(A333_ECAM_thrust_mode == 2, true, false)

    JR2AIDLE_2A		= ternary(simDR_engine_n1_pct[1] >= 19.0, true, false)
    JR2AIDLE_2B		= ternary(simDR_engine_n1_pct[1] >= 19.0, true, false)
    JR2CONTIGN_2A   = ternary(simDR_igniter_on[1] == 1.0, true, false)
    JR2CONTIGN_2B   = ternary(simDR_igniter_on[1] == 1.0, true, false)
    JR2ESI          = ternary(simDR_engine1_igniter[1] == 1, true, false)
    JR2IFT          = ternary(simDR_fail_rel_ignitr1 == 6, true, false)
    JR2HGST_2A      = ternary(simDR_eng2_hung_start == 6, true, false)
    JR2HGST_2B      = ternary(simDR_eng2_hung_start == 6, true, false)
    JR2IDLE_2A      = ternary(simDR_engine_n1_pct[1] >= 18.0 and simDR_engine_n1_pct[1] <= 20.0, true, false)
    JR2IDLE_2B      = ternary(simDR_engine_n1_pct[1] >= 18.0 and simDR_engine_n1_pct[1] <= 20.0, true, false)
    JR2MINPWR_2A    = ternary(simDR_engine_n1_pct[1] > 19.0 and simDR_engine_n1_pct[1] < 22.0, true, false)
    JR2MINPWR_2B    = ternary(simDR_engine_n1_pct[1] > 19.0 and simDR_engine_n1_pct[1] < 22.0, true, false)
    JR2N1_2A		= simDR_engine_n1_pct[1]
    JR2N1_2B		= simDR_engine_n1_pct[1]
    JR2OOT_1        = 190.0
    JR2OOT_2        = 190.0
    JR2OLP          = ternary(simDR_engine_oil_pressure_psi[1] < 25.0, true, false)
    JR2OT           = simDR_engine_oil_temp_degC[1]
    JR2OTAD_1       = 170.0
    JR2OTAD_2       = 170.0
    JR2REVD_2A      = ternary(simDR_engine_reverse_deploy_ratio[1] > 0.50, true, false)
    JR2REVD_2B      = ternary(simDR_engine_reverse_deploy_ratio[1] > 0.50, true, false)
    JR2REVKO        = ternary(simDR_engine2_reverse_fail == 6, true, false)
    JR2REVUNL_2A    = ternary(simDR_engine_reverse_deploy_ratio[1] > 0.001, true, false)
    JR2REVUNL_2B    = ternary(simDR_engine_reverse_deploy_ratio[1] > 0.001, true, false)
    JR2TLA_2A		= simDR_throttle_ratio[1]
    JR2TLA_2B		= simDR_throttle_ratio[1]

    KAP1EC_1        = toboolean(simDR_ap_servos_on == 1)
    KAP1EM_1        = toboolean(simDR_ap_servos_on == 1)
    KAP2EC_2        = toboolean(simDR_ap_servos2_on == 1)
    KAP2EM_2        = toboolean(simDR_ap_servos2_on == 1)
    KATHRE			= ternary(simDR_ap_autothrottle_on == 1, true, false)
    KCCE            = toboolean(A333DR_fws_aural_alert_ccc == 1)
    KID1APE         = toboolean(A333_capt_priority_pos == 1)
    KID2APE         = toboolean(A333_fo_priority_pos == 1)
    KLONRJ_1        = ternary(simDR_airbus_speed_warn_thro_0 == 1, true, false)
    KLONRJ_2        = ternary(simDR_airbus_speed_warn_thro_1 == 1, true, false)
    KLTRKM_1		= ternary(simDR_ap_approach_status == 2, true, false)
    KLTRKM_2		= ternary(simDR_ap_approach_status == 2, true, false)
    KRTP_1          = simDR_rudder_trim_ratio * 25.0
    KRTP_2          = simDR_rudder_trim_ratio * 25.0
    KSPEEDGEN       = ternary(A333DR_fws_aco_speed_playing == 1, true, false)
    KWINDSD_1       = ternary(simDR_windshear_warning == 1, true, false)
    KWINDSD_2       = ternary(simDR_windshear_warning == 1, true, false)
    KWINDSGEN       = ternary(A333DR_fws_aco_windshear_playing == 1, true, false)

    LSLPBOF         = ternary(A333_strobe_switch_pos == 0, true, false)

    NALTI_1			= simDR_baro_alt_ft_pilot
    NALTI_2			= simDR_baro_alt_ft_copilot
    NALTI_3			= simDR_baro_alt_ft_stby
    NCAS_1			= simDR_cas_kts_pilot
    NCAS_1_INV		= ternary(simDR_airspeed_fail_pilot == 6, true, false)
    NCAS_1_NCD		= ternary(NCAS_1 > 1024.0, true, false)
    NCAS_2			= simDR_cas_kts_copilot
    NCAS_2_INV		= ternary(simDR_airspeed_fail_copilot == 6, true, false)
    NCAS_2_NCD		= ternary(NCAS_2 > 1024.0, true, false)
    NCAS_3			= simDR_cas_kts_stby
    NCAS_3_INV		= false
    NCAS_3_NCD		= ternary(NCAS_3 > 1024.0, true, false)
    NFPBLDG3        = ternary(simDR_flap_handle_ratio == 0.75 and A333_gpws_flap_status == 1, true, false)
    NGPWSFMOF       = ternary(A333_gpws_flap_tog_pos < 0.01, true, false)
    NGPWSM          = false -- TODO: a GPWS aural alert 1 thru 5 is playing
    NGSVA           = toboolean(simDR_gs_annun)
    NHUNABGEN		= ternary(A333DR_fws_aco_hundred_above_playing == 1, true, false)
    NMINGEN         = ternary(A333DR_fws_aco_minimum_playing == 1, true, false)
    NRADH_1			= simDR_radio_alt_ht_pilot
    NRADH_2			= simDR_radio_alt_ht_copilot
    NRADH_1_INV		= ternary(simDR_radio_alt_pilot_fail == 6, true, false)
    NRADH_2_INV		= ternary(simDR_radio_alt_copilot_fail == 6, true, false)
    NRADH_1_NCD		= ternary(simDR_radio_alt_ht_pilot > 8192.0, true, false)
    NRADH_2_NCD		= ternary(simDR_radio_alt_ht_copilot > 8192.0, true, false)
    NSFCONF3NS      = ternary(simDR_CONF_sel == 7, false, true)
    NSTALL1         = ternary(simDR_stall_warning == 1, true, false)
    NTCASINIB       = toboolean(A333_audio_tcas_alert == 1)
    NVMOW_1         = (simDR_airspeed_kts_pilot > 330.0) or (simDR_airspeed_kts_copilot > 330.0) or (simDR_airspeed_kts_stby > 330.0)

    PALTI           = simDR_pressure_altitude
    PAS12F          = toboolean(A333DR_pack1_fault == 1 and A333DR_pack2_fault == 1)
    PS1F_1          = ternary(simDR_hvac_fail == 6, true, false)
    PS2F_2          = ternary(simDR_hvac_fail == 6, true, false)

    QAVAIL          = ternary(A333DR_fws_apu_avail == 1.0, true, false)
    QMSON           = ternary(simDR_apu_switch > 0, true, false)

    SCSSF_1         = toboolean(simDR_priority_side == 2)
    SCSSF_2         = toboolean(simDR_priority_side == 2)
    --SDUALSSI        = toboolean(A333_dual_input == 1)
    SFLPFY          = bOR(SFLPINOP, SFLPLCKD)
    SFLPINOP        = ternary(simDR_flap_act_failure == 6, true, false)
    SFLPLCKD        = ternary(simDR_flap_1_lft_lock == 6 or simDR_flap_1_rgt_lock == 6 or simDR_flap_2_lft_lock == 6 or simDR_flap_2_rgt_lock, true, false)
    SFOSSF_1        = toboolean(simDR_priority_side == 1)
    SFOSSF_2        = toboolean(simDR_priority_side == 1)
    SGNDSPLRA_1     = ternary(simDR_ctrl_speed_brk_ratio == -0.5, true, false)
    SGNDSPLRA_2     = ternary(simDR_ctrl_speed_brk_ratio == -0.5, true, false)
    SLELVBA_1       = ternary(simDR_blue_hydraulic_pressure >= 200, true, false)
    SLELVBA_2       = ternary(simDR_blue_hydraulic_pressure >= 200, true, false)
    SLELVGA_1       = ternary(simDR_green_hydraulic_pressure >= 200, true, false)
    SLELVGA_2       = ternary(simDR_green_hydraulic_pressure >= 200, true, false)
    --SLFLPPOS		= simDR_flap_deg[0]
    --SLSLTPOS        = math.round95(simDR_slat2_deploy_rat * 23.0)
    SPCCMD_1        = simDR_yoke_pitch_ratio_pilot
    SPCCMD_2        = simDR_yoke_pitch_ratio_pilot
    SPFOCMD_1       = simDR_yoke_pitch_ratio_copilot
    SPFOCMD_2       = simDR_yoke_pitch_ratio_copilot
    SRCCMD_1        = simDR_yoke_roll_ratio_pilot
    SRCCMD_2        = simDR_yoke_roll_ratio_pilot
    SRFOCMD_1       = simDR_yoke_roll_ratio_copilot
    SRFOCMD_2       = simDR_yoke_roll_ratio_copilot
    SRELVBA_1       = ternary(simDR_blue_hydraulic_pressure >= 200, true, false)
    SRELVBA_2       = ternary(simDR_blue_hydraulic_pressure >= 200, true, false)
    SRELVYA_1       = ternary(simDR_yellow_hydraulic_pressure >= 200, true, false)
    SRELVYA_2       = ternary(simDR_yellow_hydraulic_pressure >= 200, true, false)
    --SRFLPPOS		= simDR_flap_deg[1]
    --SRSLTPOS        = math.round95(simDR_slat2_deploy_rat * 23.0)

    SS00F00_1       = ternary(simDR_CONF_sel == 0, true, false)
    SS00F00_2       = ternary(simDR_CONF_sel == 0, true, false)
    SS16F00_1       = ternary(simDR_CONF_sel == 1, true, false)
    SS16F00_2       = ternary(simDR_CONF_sel == 1, true, false)
    SS16F08_1       = ternary(simDR_CONF_sel == 2, true, false)
    SS16F08_2       = ternary(simDR_CONF_sel == 2, true, false)
    SS20F14_1       = ternary(simDR_CONF_sel == 4, true, false)
    SS20F14_2       = ternary(simDR_CONF_sel == 4, true, false)
    SS23F22_1       = ternary(simDR_CONF_sel == 6, true, false)
    SS23F22_2       = ternary(simDR_CONF_sel == 6, true, false)
    SS23F32_1       = ternary(simDR_CONF_sel == 7, true, false)
    SS23F32_2       = ternary(simDR_CONF_sel == 7, true, false)

    SSLTFY          = SFLPFY
    SSPBR_1         = ternary(simDR_ctrl_speed_brk_ratio > 0.0, true, false)
    SSPBR_2         = ternary(simDR_ctrl_speed_brk_ratio > 0.0, true, false)
    STAB1POS_1      = simDR_stab_deflection_deg
    STAB1POS_2      = simDR_stab_deflection_deg

    UAPUELP         = ternary(A333_apu_agent_psi < 300.0, true, false)
    UAPUFA			= ternary(simDR_apu_fire == 6, true, false)
    UAPUFB			= ternary(simDR_apu_fire == 6, true, false)
    UAPUFPBOUT		= ternary(A333_apu_fire_handle_pos > 0.99, true, false)
    UE1ABLP         = ternary(A333_eng1_agent2_psi < 300.0, true, false)
    UE1FA           = toboolean(simDR_engine_fire[0])
    UE1FB           = toboolean(simDR_engine_fire[0])
    UE1FBLP         = ternary(A333_eng1_agent1_psi < 300.0, true, false)
    UE1FIRE         = false
    UE1FPBOUT		= ternary(A333_eng1_fire_handle_pos > 0.99, true, false)

    UE2ABLP         = ternary(A333_eng2_agent2_psi < 300.0, true, false)
    UE2FA           = toboolean(simDR_engine_fire[1])
    UE2FB           = toboolean(simDR_engine_fire[1])
    UE2FBLP         = ternary(A333_eng2_agent1_psi < 300.0, true, false)
    UE2FIRE         = false
    UE2FPBOUT		= ternary(A333_eng2_fire_handle_pos > 0.99, true, false)

    VAVEPBO         = ternary(A333_ventilation_extract_ovrd_pos >= 1.0, true, false)

    WALL_2			= ternary(A333_ecam_button_all_pos == 1, true, false)
    WAPU_2			= ternary(A333_ecam_button_apu_pos == 1, true, false)
    WBLD_2			= ternary(A333_ecam_button_bleed_pos == 1, true, false)
    WCB_2		    = ternary(A333_ecam_button_cbs_pos == 1, true, false)
    WCLR1_2			= ternary(A333_ecam_button_clr_capt_pos == 1, true, false)
    WCLR2_2			= ternary(A333_ecam_button_clr_fo_pos == 1, true, false)
    WCOND_2			= ternary(A333_ecam_button_cond_pos == 1, true, false)
    WDH_1           = simDR_radio_altimeter_bug_ft_pilot
    WDH_2           = simDR_radio_altimeter_bug_ft_pilot
    WDH100A         = ternary(NRHV >= (WDH_1 + 100.0) and NRHV <= (WDH_1 + 103.0), true, false)
    WDH100B         = ternary(NRHV >= (WDH_2 + 100.0) and NRHV <= (WDH_2 + 103.0), true, false)
    WDHA            = ternary(NRHV >= WDH_1 and NRHV <= (WDH_1 + 3.0), true, false)
    WDHB            = ternary(NRHV >= WDH_2 and NRHV <= (WDH_2 + 3.0), true, false)
    WDOOR_2			= ternary(A333_ecam_button_door_pos == 1, true, false)
    WEC_2           = ternary(A333_ecam_button_emer_cancel_pos == 1, true, false)
    WELAC_2			= ternary(A333_ecam_button_el_ac_pos == 1, true, false)
    WELDC_2			= ternary(A333_ecam_button_el_dc_pos == 1, true, false)
    WENG_2			= ternary(A333_ecam_button_eng_pos == 1, true, false)
    WFCTL_2			= ternary(A333_ecam_button_f_ctl_pos == 1, true, false)
    WFUEL_2			= ternary(A333_ecam_button_fuel_pos == 1, true, false)
    WHYD_2			= ternary(A333_ecam_button_hyd_pos == 1, true, false)
    WPRESS_2		= ternary(A333_ecam_button_press_pos == 1, true, false)
    WRCL_2			= ternary(A333_ecam_button_rcl_pos == 1, true, false)
    WSTS_2			= ternary(A333_ecam_button_sts_pos == 1, true, false)
    WTOCT_2         = ternary(A333_ecam_button_to_config_pos == 1, true, false)
    WWHL_2			= ternary(A333_ecam_button_wheel_pos == 1, true, false)

    ZNMLSTSPD       = toboolean(A333DR_fws_sts_normal_msg_show)

end





function A333_fws_global_to_dataref()
    A333DR_fws_main_gear_comp_L = bool2logic(GMLGC_1)
    A333DR_fws_main_gear_comp_R = bool2logic(GMLGC_2)

end



--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_200()

    A333_fws_global_variable_assignment()
    A333_fws_global_to_dataref()

end






--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







