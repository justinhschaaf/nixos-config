{ inputs, lib, config, pkgs, ... }: {

    options.js.server.klipper.enable = lib.mkEnableOption "Klipper, a 3d-Printer firmware";

    config = lib.mkIf config.js.server.klipper.enable {

        services.klipper.enable = true;
        services.klipper.settings = {

            ### PRINTER.CFG ###

            # This file contains pin mappings for the stock 2020 Creality Ender 3
            # Pro with the 32-bit Creality 4.2.2 board. To use this config, during
            # "make menuconfig" select the STM32F103 with a "28KiB bootloader" and
            # serial (on USART1 PA10/PA9) communication.

            # It should be noted that newer variations of this printer shipping in
            # 2022 may have GD32F103 chips installed and not STM32F103. You may
            # have to inspect the mainboard to ascertain which one you have. If it
            # is the GD32F103 then please select Disable SWD at startup in the
            # "make menuconfig" along with the same settings for STM32F103.

            # If you prefer a direct serial connection, in "make menuconfig"
            # select "Enable extra low-level configuration options" and select
            # serial (on USART3 PB11/PB10), which is broken out on the 10 pin IDC
            # cable used for the LCD module as follows:
            # 3: Tx, 4: Rx, 9: GND, 10: VCC

            # Flash this firmware by copying "out/klipper.bin" to a SD card and
            # turning on the printer with the card inserted. The firmware
            # filename must end in ".bin" and must not match the last filename
            # that was flashed.

            # See docs/Config_Reference.md for a description of parameters.

            stepper_x = {
                step_pin = "PC2";
                dir_pin = "PB9";
                enable_pin = "!PC3";
                microsteps = 16;
                rotation_distance = 40;
                endstop_pin = "^PA5";
                position_endstop = 0;
                #position_min = 0;
                position_max = 235;
                homing_speed = 50;
            };

            stepper_y = {
                step_pin = "PB8";
                dir_pin = "PB7";
                enable_pin = "!PC3";
                microsteps = 16;
                rotation_distance = 40;
                endstop_pin = "^PA6";
                position_endstop = 0;
                #position_min = 0;
                position_max = 235;
                homing_speed = 50;
            };

            stepper_z = {
                step_pin = "PB6";
                dir_pin = "!PB5";
                enable_pin = "!PC3";
                microsteps = 16;
                rotation_distance = 8;
                #endstop_pin = "^PA7";
                #position_endstop = 0.0;
                endstop_pin = "probe:z_virtual_endstop";
                position_min = -5;
                position_max = 250;
            };

            extruder = {
                max_extrude_only_distance = 100.0;
                step_pin = "PB4";
                dir_pin = "PB3";
                enable_pin = "!PC3";
                microsteps = 16;
                #rotation_distance = 34.406;
                rotation_distance = 31.67;
                nozzle_diameter = 0.400;
                filament_diameter = 1.750;
                heater_pin = "PA1";
                sensor_type = "EPCOS 100K B57560G104F";
                sensor_pin = "PC5";
                #control = "pid";
                pressure_advance = 0.74;
                # tuned for stock hardware with 200 degree Celsius target
                #pid_Kp = 21.527;
                #pid_Ki = 1.063;
                #pid_Kd = 108.982;
                min_temp = 0;
                max_temp = 250;
            };

            heater_bed = {
                heater_pin = "PA2";
                sensor_type = "EPCOS 100K B57560G104F";
                sensor_pin = "PC4";
                control = "pid";
                # tuned for stock hardware with 50 degree Celsius target
                pid_Kp = 54.027;
                pid_Ki = 0.770;
                pid_Kd = 948.182;
                min_temp = 0;
                max_temp = 130;
            };

            fan.pin = "PA0";

            mcu = {
                serial = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
                restart_method = "command";
            };

            # TODO make sure this is running https://www.klipper3d.org/RPi_microcontroller.html
            "mcu rpi".serial = "/tmp/klipper_host_mcu";

            adxl345.cs_pin = "rpi:None";

            resonance_tester = {
                accel_chip = "adxl345";
                probe_points = [ "118, 118, 50" ]; # an example
            };

            input_shaper = {
                shaper_freq_x = 77.0;
                shaper_type_x = "mzv";
                shaper_freq_y = 36.0;
                shaper_type_y = "mzv";
            };

            printer = {
                kinematics = "cartesian";
                max_velocity = 300;
                max_accel = 4500;
                #max_accel_to_decel = 7000;
                max_z_velocity = 5;
                max_z_accel = 100;
            };

            # Pin mappings for BL_T port
            bltouch = {
                sensor_pin = "^PB1";
                control_pin = "PB0";
                x_offset = -47;
                y_offset = -12;
                samples = 2;
                speed = 2;
                z_offset = .05;
            };

            safe_z_home = {
                home_xy_position = "157, 122"; # Change coordinates to the center of your print bed
                speed = 75;
                z_hop = 10; # Move up 10mm
                z_hop_speed = 5;
            };

            bed_mesh = {
                speed = 120;
                mesh_min = "10, 10";
                mesh_max = "173, 208";
                probe_count = "5, 5";
                algorithm = "bicubic";
            };

            display = {
                lcd_type = "st7920";
                cs_pin = "PB12";
                sclk_pin = "PB13";
                sid_pin = "PB15";
                encoder_pins = "^PB14, ^PB10";
                click_pin = "^!PB2";
            };

            #*# <---------------------- SAVE_CONFIG ---------------------->
            #*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.
            #*#
            #*# [bed_mesh default]
            #*# version = 1
            #*# points =
            #*#   0.662500, 0.563750, 0.467500, 0.337500, 0.205000
            #*#   0.511250, 0.601250, 0.597500, 0.482500, 0.427500
            #*#   0.542500, 0.635000, 0.557500, 0.630000, 0.501250
            #*#   0.477500, 0.580000, 0.670000, 0.538750, 0.386250
            #*#   0.571250, 0.578750, 0.507500, 0.465000, 0.327500
            #*# x_count = 5
            #*# y_count = 5
            #*# mesh_x_pps = 2
            #*# mesh_y_pps = 2
            #*# algo = bicubic
            #*# tension = 0.2
            #*# min_x = 10.0
            #*# max_x = 173.0
            #*# min_y = 10.0
            #*# max_y = 208.0
            #*#
            #*# [extruder]
            #*# control = pid
            #*# pid_kp = 26.183
            #*# pid_ki = 1.518
            #*# pid_kd = 112.912

            ### FLUIDD.CFG ###

            ## Client klipper macro definitions
            ##
            ## Copyright (C) 2022 Alex Zellner <alexander.zellner@googlemail.com>
            ##
            ## This file may be distributed under the terms of the GNU GPLv3 license
            ##
            ## !!! This file is read-only. Maybe the used editor indicates that. !!!
            ##
            ## Customization:
            ##   1) copy the gcode_macro _CLIENT_VARIABLE (see below) to your printer.cfg
            ##   2) remove the comment mark (#) from all lines
            ##   3) change any value in there to your needs
            ##
            ## Use the PAUSE macro direct in your M600:
            ##  e.g. with a different park position front left and a minimal height of 50
            ##    [gcode_macro M600]
            ##    description: Filament change
            ##    gcode: PAUSE X=10 Y=10 Z_MIN=50
            ##  Z_MIN will park the toolhead at a minimum of 50 mm above to bed to make it easier for you to swap filament.
            ##
            ## Client variable macro for your printer.cfg
            #[gcode_macro _CLIENT_VARIABLE]
            #variable_use_custom_pos   : False ; use custom park coordinates for x,y [True/False]
            #variable_custom_park_x    : 0.0   ; custom x position; value must be within your defined min and max of X
            #variable_custom_park_y    : 0.0   ; custom y position; value must be within your defined min and max of Y
            #variable_custom_park_dz   : 2.0   ; custom dz value; the value in mm to lift the nozzle when move to park position
            #variable_retract          : 1.0   ; the value to retract while PAUSE
            #variable_cancel_retract   : 5.0   ; the value to retract while CANCEL_PRINT
            #variable_speed_retract    : 35.0  ; retract speed in mm/s
            #variable_unretract        : 1.0   ; the value to unretract while RESUME
            #variable_speed_unretract  : 35.0  ; unretract speed in mm/s
            #variable_speed_hop        : 15.0  ; z move speed in mm/s
            #variable_speed_move       : 100.0 ; move speed in mm/s
            #variable_park_at_cancel   : False ; allow to move the toolhead to park while execute CANCEL_PRINT [True/False]
            #variable_park_at_cancel_x : None  ; different park position during CANCEL_PRINT [None/Position as Float]; park_at_cancel must be True
            #variable_park_at_cancel_y : None  ; different park position during CANCEL_PRINT [None/Position as Float]; park_at_cancel must be True
            ## !!! Caution [firmware_retraction] must be defined in the printer.cfg if you set use_fw_retract: True !!!
            #variable_use_fw_retract   : False ; use fw_retraction instead of the manual version [True/False]
            #variable_idle_timeout     : 0     ; time in sec until idle_timeout kicks in. Value 0 means that no value will be set or restored
            #variable_runout_sensor    : ""    ; If a sensor is defined, it will be used to cancel the execution of RESUME in case no filament is detected.
            ##                                   Specify the config name of the runout sensor e.g "filament_switch_sensor runout". Hint use the same as in your printer.cfg
            ## !!! Custom macros, please use with care and review the section of the corresponding macro.
            ## These macros are for simple operations like setting a status LED. Please make sure your macro does not interfere with the basic macro functions.
            ## Only  single line commands are supported, please create a macro if you need more than one command.
            #variable_user_pause_macro : ""    ; Everything inside the "" will be executed after the klipper base pause (PAUSE_BASE) function
            #variable_user_resume_macro: ""    ; Everything inside the "" will be executed before the klipper base resume (RESUME_BASE) function
            #variable_user_cancel_macro: ""    ; Everything inside the "" will be executed before the klipper base cancel (CANCEL_PRINT_BASE) function
            #gcode:

            virtual_sdcard = {
                path = "${config.services.moonraker.stateDir}/gcodes";
                on_error_gcode = "CANCEL_PRINT";
            };

            # yes, this has to be here. it's fine that it's empty
            pause_resume = {};
            # When capture/restore is enabled, the speed at which to return to
            # the captured position (in mm/s). Default is 50.0 mm/s.
            #recover_velocity: 50.

            # so do these
            display_status = {};
            respond = {};

            "gcode_macro CANCEL_PRINT" = {
                description = "Cancel the actual running print";
                rename_existing = "CANCEL_PRINT_BASE";
                gcode = ''
                    ##### get user parameters or use default #####
                    {% set client = printer['gcode_macro _CLIENT_VARIABLE'] | default({}) %}
                    {% set allow_park = client.park_at_cancel | default(false) | lower == 'true' %}
                    {% set retract = client.cancel_retract | default(5.0) | abs %}
                    ##### define park position #####
                    {% set park_x = "" if (client.park_at_cancel_x | default(none) is none)
                            else "X=" ~ client.park_at_cancel_x %}
                    {% set park_y = "" if (client.park_at_cancel_y | default(none) is none)
                            else "Y=" ~ client.park_at_cancel_y %}
                    {% set custom_park = park_x | length > 0 or park_y | length > 0 %}
                    ##### end of definitions #####
                    # restore idle_timeout time if needed
                    {% if printer['gcode_macro RESUME'].restore_idle_timeout > 0 %}
                    SET_IDLE_TIMEOUT TIMEOUT={printer['gcode_macro RESUME'].restore_idle_timeout}
                    {% endif %}
                    {% if (custom_park or not printer.pause_resume.is_paused) and allow_park %} _TOOLHEAD_PARK_PAUSE_CANCEL {park_x} {park_y} {% endif %}
                    _CLIENT_RETRACT LENGTH={retract}
                    TURN_OFF_HEATERS
                    M106 S0
                    {client.user_cancel_macro | default("")}
                    SET_GCODE_VARIABLE MACRO=RESUME VARIABLE=idle_state VALUE=False
                    # clear pause_next_layer and pause_at_layer as preparation for next print
                    SET_PAUSE_NEXT_LAYER ENABLE=0
                    SET_PAUSE_AT_LAYER ENABLE=0 LAYER=0
                    CANCEL_PRINT_BASE
                '';
            };

            "gcode_macro PAUSE" = {
                description = "Pause the actual running print";
                rename_existing = "PAUSE_BASE";
                # ''' is the escaped version of ''
                gcode = ''
                    ##### get user parameters or use default #####
                    {% set client = printer['gcode_macro _CLIENT_VARIABLE'] | default({}) %}
                    {% set idle_timeout = client.idle_timeout | default(0) %}
                    {% set temp = printer[printer.toolhead.extruder].target if printer.toolhead.extruder != ''' else 0 %}
                    {% set restore = False if printer.toolhead.extruder == '''
                              else True  if params.RESTORE | default(1) | int == 1 else False %}
                    ##### end of definitions #####
                    SET_GCODE_VARIABLE MACRO=RESUME VARIABLE=last_extruder_temp VALUE="{{'restore': restore, 'temp': temp}}"
                    # set a new idle_timeout value
                    {% if idle_timeout > 0 %}
                    SET_GCODE_VARIABLE MACRO=RESUME VARIABLE=restore_idle_timeout VALUE={printer.configfile.settings.idle_timeout.timeout}
                    SET_IDLE_TIMEOUT TIMEOUT={idle_timeout}
                    {% endif %}
                    PAUSE_BASE
                    {client.user_pause_macro | default("")}
                    _TOOLHEAD_PARK_PAUSE_CANCEL {rawparams}
                '';
            };

            "gcode_macro RESUME" = {
                description = "Resume the actual running print";
                rename_existing = "RESUME_BASE";
                variable_last_extruder_temp = "{'restore': False, 'temp': 0}";
                variable_restore_idle_timeout = 0;
                variable_idle_state = false;
                gcode = ''
                    ##### get user parameters or use default #####
                    {% set client = printer['gcode_macro _CLIENT_VARIABLE'] | default({}) %}
                    {% set velocity = printer.configfile.settings.pause_resume.recover_velocity %}
                    {% set sp_move = client.speed_move | default(velocity) %}
                    {% set runout_resume = True if client.runout_sensor | default("") == ""   # no runout
                                      else True if not printer[client.runout_sensor].enabled  # sensor is disabled
                                      else printer[client.runout_sensor].filament_detected %} # sensor status
                    {% set can_extrude = True if printer.toolhead.extruder == '''           # no extruder defined in config
                                    else printer[printer.toolhead.extruder].can_extrude %} # status of active extruder
                    {% set do_resume = False %}
                    {% set prompt_txt = [] %}
                    ##### end of definitions #####
                    #### Printer comming from timeout idle state ####
                    {% if printer.idle_timeout.state | upper == "IDLE" or idle_state %}
                      SET_GCODE_VARIABLE MACRO=RESUME VARIABLE=idle_state VALUE=False
                      {% if last_extruder_temp.restore %}
                        # we need to use the unicode (\u00B0) for the ° as py2 env's would throw an error otherwise
                        RESPOND TYPE=echo MSG='{"Restoring \"%s\" temperature to %3.1f\u00B0C, this may take some time" % (printer.toolhead.extruder, last_extruder_temp.temp) }'
                        M109 S{last_extruder_temp.temp}
                        {% set do_resume = True %}
                      {% elif can_extrude %}
                        {% set do_resume = True %}
                      {% else %}
                        RESPOND TYPE=error MSG='{"Resume aborted !!! \"%s\" not hot enough, please heat up again and press RESUME" % printer.toolhead.extruder}'
                        {% set _d = prompt_txt.append("\"%s\" not hot enough, please heat up again and press RESUME" % printer.toolhead.extruder) %}
                      {% endif %}
                    #### Printer comming out of regular PAUSE state ####
                    {% elif can_extrude %}
                      {% set do_resume = True %}
                    {% else %}
                      RESPOND TYPE=error MSG='{"Resume aborted !!! \"%s\" not hot enough, please heat up again and press RESUME" % printer.toolhead.extruder}'
                      {% set _d = prompt_txt.append("\"%s\" not hot enough, please heat up again and press RESUME" % printer.toolhead.extruder) %}
                    {% endif %}
                    {% if runout_resume %}
                      {% if do_resume %}
                        {% if restore_idle_timeout > 0 %} SET_IDLE_TIMEOUT TIMEOUT={restore_idle_timeout} {% endif %} # restore idle_timeout time
                        {client.user_resume_macro | default("")}
                        _CLIENT_EXTRUDE
                        RESUME_BASE VELOCITY={params.VELOCITY | default(sp_move)}
                      {% endif %}
                    {% else %}
                      RESPOND TYPE=error MSG='{"Resume aborted !!! \"%s\" detects no filament, please load filament and press RESUME" % (client.runout_sensor.split(" "))[1]}'
                      {% set _d = prompt_txt.append("\"%s\" detects no filament, please load filament and press RESUME" % (client.runout_sensor.split(" "))[1]) %}
                    {% endif %}
                    ##### Generate User Information box in case of abort #####
                    {% if not (runout_resume and do_resume) %}
                      RESPOND TYPE=command MSG="action:prompt_begin RESUME aborted !!!"
                      {% for element in prompt_txt %}
                        RESPOND TYPE=command MSG='{"action:prompt_text %s" % element}'
                      {% endfor %}
                      RESPOND TYPE=command MSG="action:prompt_footer_button Ok|RESPOND TYPE=command MSG=action:prompt_end|info"
                      RESPOND TYPE=command MSG="action:prompt_show"
                    {% endif %}
                ''; # ''
            };

            # Usage: SET_PAUSE_NEXT_LAYER [ENABLE=[0 | 1]] [MACRO=<name>]
            "gcode_macro SET_PAUSE_NEXT_LAYER" = {
                description = "Enable a pause if the next layer is reached";
                gcode = ''
                    {% set pause_next_layer = printer['gcode_macro SET_PRINT_STATS_INFO'].pause_next_layer %}
                    {% set ENABLE = params.ENABLE | default(1)|int != 0 %}
                    {% set MACRO = params.MACRO | default(pause_next_layer.call, True) %}
                    SET_GCODE_VARIABLE MACRO=SET_PRINT_STATS_INFO VARIABLE=pause_next_layer VALUE="{{ 'enable': ENABLE, 'call': MACRO }}"
                '';
            };

            # Usage: SET_PAUSE_AT_LAYER [ENABLE=[0 | 1]] [LAYER=<number>] [MACRO=<name>]
            "gcode_macro SET_PAUSE_AT_LAYER" = {
                description = "Enable/disable a pause if a given layer number is reached";
                gcode = ''
                    {% set pause_at_layer = printer['gcode_macro SET_PRINT_STATS_INFO'].pause_at_layer %}
                    {% set ENABLE = params.ENABLE | int != 0 if params.ENABLE is defined
                             else params.LAYER is defined %}
                    {% set LAYER = params.LAYER | default(pause_at_layer.layer) | int %}
                    {% set MACRO = params.MACRO | default(pause_at_layer.call, True) %}
                    SET_GCODE_VARIABLE MACRO=SET_PRINT_STATS_INFO VARIABLE=pause_at_layer VALUE="{{ 'enable': ENABLE, 'layer': LAYER, 'call': MACRO }}"
                '';
            };

            # Usage: SET_PRINT_STATS_INFO [TOTAL_LAYER=<total_layer_count>] [CURRENT_LAYER= <current_layer>]
            "gcode_macro SET_PRINT_STATS_INFO" = {
                rename_existing = "SET_PRINT_STATS_INFO_BASE";
                description = "Overwrite, to get pause_next_layer and pause_at_layer feature";
                variable_pause_next_layer = "{ 'enable': False, 'call': \"PAUSE\" }";
                variable_pause_at_layer = "{ 'enable': False, 'layer': 0, 'call': \"PAUSE\" }";
                gcode = ''
                    {% if pause_next_layer.enable %}
                        RESPOND TYPE=echo MSG='{"%s, forced by pause_next_layer" % pause_next_layer.call}'
                        {pause_next_layer.call} ; execute the given gcode to pause, should be either M600 or PAUSE
                        SET_PAUSE_NEXT_LAYER ENABLE=0
                    {% elif pause_at_layer.enable and params.CURRENT_LAYER is defined and params.CURRENT_LAYER | int == pause_at_layer.layer %}
                        RESPOND TYPE=echo MSG='{"%s, forced by pause_at_layer [%d]" % (pause_at_layer.call, pause_at_layer.layer)}'
                        {pause_at_layer.call} ; execute the given gcode to pause, should be either M600 or PAUSE
                        SET_PAUSE_AT_LAYER ENABLE=0
                    {% endif %}
                    SET_PRINT_STATS_INFO_BASE {rawparams}
                '';
            };

            ##### internal use #####

            "gcode_macro _TOOLHEAD_PARK_PAUSE_CANCEL" = {
                description = "Helper: park toolhead used in PAUSE and CANCEL_PRINT";
                gcode = ''
                    ##### get user parameters or use default #####
                    {% set client = printer['gcode_macro _CLIENT_VARIABLE'] | default({}) %}
                    {% set velocity = printer.configfile.settings.pause_resume.recover_velocity %}
                    {% set use_custom     = client.use_custom_pos | default(false) | lower == 'true' %}
                    {% set custom_park_x  = client.custom_park_x | default(0.0) %}
                    {% set custom_park_y  = client.custom_park_y | default(0.0) %}
                    {% set park_dz        = client.custom_park_dz | default(2.0) | abs %}
                    {% set sp_hop         = client.speed_hop | default(15) * 60 %}
                    {% set sp_move        = client.speed_move | default(velocity) * 60 %}
                    ##### get config and toolhead values #####
                    {% set origin    = printer.gcode_move.homing_origin %}
                    {% set act       = printer.gcode_move.gcode_position %}
                    {% set max       = printer.toolhead.axis_maximum %}
                    {% set cone      = printer.toolhead.cone_start_z | default(max.z) %} ; height as long the toolhead can reach max and min of an delta
                    {% set round_bed = True if printer.configfile.settings.printer.kinematics is in ['delta','polar','rotary_delta','winch']
                                else False %}
                    ##### define park position #####
                    {% set z_min = params.Z_MIN | default(0) | float %}
                    {% set z_park = [[(act.z + park_dz), z_min]|max, (max.z - origin.z)] | min %}
                    {% set x_park = params.X       if params.X is defined
                             else custom_park_x  if use_custom
                             else 0.0            if round_bed
                             else (max.x - 5.0) %}
                    {% set y_park = params.Y       if params.Y is defined
                             else custom_park_y  if use_custom
                             else (max.y - 5.0)  if round_bed and z_park < cone
                             else 0.0            if round_bed
                             else (max.y - 5.0) %}
                    ##### end of definitions #####
                    _CLIENT_RETRACT
                    {% if "xyz" in printer.toolhead.homed_axes %}
                    G90
                    G1 Z{z_park} F{sp_hop}
                    G1 X{x_park} Y{y_park} F{sp_move}
                    {% if not printer.gcode_move.absolute_coordinates %} G91 {% endif %}
                    {% else %}
                    RESPOND TYPE=echo MSG='Printer not homed'
                    {% endif %}
                '';
            };

            "gcode_macro _CLIENT_EXTRUDE" = {
                description = "Extrudes, if the extruder is hot enough";
                gcode = ''
                    ##### get user parameters or use default #####
                    {% set client = printer['gcode_macro _CLIENT_VARIABLE'] | default({}) %}
                    {% set use_fw_retract = (client.use_fw_retract | default(false) | lower == 'true') and (printer.firmware_retraction is defined) %}
                    {% set length = params.LENGTH | default(client.unretract) | default(1.0) | float %}
                    {% set speed = params.SPEED | default(client.speed_unretract) | default(35) %}
                    {% set absolute_extrude = printer.gcode_move.absolute_extrude %}
                    ##### end of definitions #####
                    {% if printer.toolhead.extruder != ''' %}
                        {% if printer[printer.toolhead.extruder].can_extrude %}
                            {% if use_fw_retract %}
                                {% if length < 0 %}
                                    G10
                                {% else %}
                                    G11
                                {% endif %}
                            {% else %}
                                M83
                                G1 E{length} F{(speed | float | abs) * 60}
                                {% if absolute_extrude %}
                                    M82
                                {% endif %}
                            {% endif %}
                        {% else %}
                            RESPOND TYPE=echo MSG='{"\"%s\" not hot enough" % printer.toolhead.extruder}'
                        {% endif %}
                    {% endif %}
                ''; # ''
            };

            "gcode_macro _CLIENT_RETRACT" = {
                description = "Retracts, if the extruder is hot enough";
                gcode = ''
                    {% set client = printer['gcode_macro _CLIENT_VARIABLE'] | default({}) %}
                    {% set length = params.LENGTH | default(client.retract) | default(1.0) | float %}
                    {% set speed = params.SPEED | default(client.speed_retract) | default(35) %}

                    _CLIENT_EXTRUDE LENGTH=-{length | float | abs} SPEED={speed | float | abs}
                '';
            };

        };

    };

}
