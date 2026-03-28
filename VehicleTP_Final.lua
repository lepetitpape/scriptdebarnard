local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local CONFIG = {
    ALLOW_FLIGHT = false,
    MIN_SPEED = 100,
    MAX_SPEED = 200,
    STEP_MAX = 4,
    ARRIVAL_TOLERANCE = 2,
    NEAR_TARGET_SNAP_DISTANCE = 20,
    MIN_ALLOWED_Y = -32.252,
    GROUND_RAY_HEIGHT = 80,
    GROUND_RAY_LENGTH = 220,
    GROUND_CLEARANCE = 0.35,
    GROUND_NEAR_PROBE_UP = 3,
    GROUND_NEAR_PROBE_DOWN = 90,
    GROUND_GUARD_INTERVAL = 0.05,
    GROUND_GUARD_RAY_HEIGHT = 220,
    GROUND_GUARD_RAY_LENGTH = 5000,
    GROUND_GUARD_NEAR_PROBE_DOWN = 180,
    GROUND_GUARD_CLEARANCE = 0.45,
    GROUND_GUARD_MAX_CORRECTION = 1.75,
    UNDERMAP_DEPTH_TRIGGER = 2.0,
    AIRBORNE_GROUND_EPSILON = 1.2,
    MAX_AIRBORNE_TIME = 1.0,
    MAX_VERTICAL_TRAVEL = 18,
    BLOCKED_CYCLE_ABORT = 160,
    WALL_PASS_INITIAL_BURST = 0.9,
    WALL_PASS_RETRY_BURST = 0.75,
    WALL_PASS_RETRY_COOLDOWN = 0.12,
    WALL_PASS_STAY_ACTIVE = true,
    PHASE_INSIDE_MAX_TIME = 0.2,
    PHASE_BLOCKED_TP_STEP = 12,
    WALL_UNSTICK_MAX_ATTEMPTS = 6,
    WALL_UNSTICK_EMERGENCY_UP = 10,
    MAX_STEP_RISE = 6,
    MAX_STEP_DROP = 8,
    MIN_GROUND_NORMAL_Y = 0.35,
    AUTO_CLIMB_STEP = 8,
    AUTO_CLIMB_MAX = 45,
    AUTO_CLIMB_CLEARANCE = 4,
    STUCK_TIMEOUT = 3,
    STUCK_MIN_MOVE = 0.15,
    STUCK_NUDGE_TIMEOUT = 0.5,
    STUCK_NUDGE_DISTANCE = 5,
    LOW_Y_RESCUE_MARGIN = 0.35,
    LOW_Y_RESCUE_STEP = 8,
    STUCK_CLIMB_BOOST = 10,
    RECOVERY_SIDE_STEP = 5,
    RECOVERY_UP_STEP = 9,
    PLAYER_WALK_DISTANCE_MAX = 140,
    PLAYER_PREFER_TARGET_Y_DISTANCE = 120,
    WALK_SPEED = 28,
    WALK_STEP_MAX = 1.6,
    WALK_AUTO_CLIMB_MAX = 10,
    WALK_AUTO_CLIMB_STEP = 3,
    WALK_STUCK_CLIMB_BOOST = 4,
    WALK_RECOVERY_SIDE_STEP = 2.5,
    WALK_RECOVERY_UP_STEP = 3.5,
    PHASE_RESOLVE_MAX_UP_STEPS = 22,
    PHASE_RESOLVE_UP_STEP = 4,
    PHASE_RESOLVE_MAX_RADIUS = 64,
    PHASE_RESOLVE_RADIUS_STEP = 6,
    FOLLOW_LOOP_DELAY = 0.02,
    FOLLOW_MIN_DISTANCE = 2,
    FOLLOW_HOLD_DISTANCE = 0.35,
    ORBIT_TARGET_Y_OFFSET = 1.1,
    ORBIT_VERTICAL_SPEED = 3.5,
    ORBIT_PRECISION_SNAP_DISTANCE = 1.8,
    TROLL_ORBIT_MIN_RADIUS = 0.2,
    TROLL_ORBIT_MAX_RADIUS = 12,
    TROLL_ORBIT_ANGULAR_SPEED = 5.5,
    TROLL_INWARD_WOBBLE = 2.5,
    TROLL_MOVE_SPEED = 260,
    TROLL_STEP_MAX = 16,
    TROLL_SPIN_REV_PER_SEC = 14,
    TROLL_NOISE_SPEED = 7.5,
    TROLL_GROUND_STICK = 1.0,
    JUMP_MODE_CRUISE_HEIGHT = 65,
    JUMP_ASCEND_RATE = 150,
    JUMP_DESCEND_RATE = 170,
    JUMP_DESCEND_DISTANCE = 48,
    JUMP_BURST_UP = 16,
    BRING_SIDE_OFFSET = 10,
    BRING_FORWARD_OFFSET = 2,
    MAP_WAYPOINT_DUPLICATE_DISTANCE = 5,
    PLAYER_REFRESH_DELAY = 2,
}

local state = {
    speed = 180,
    isTPing = false,
    cachedVehicle = nil,
    mainGui = nil,
    openGui = nil,
    jumpMode = false,
    followEnabled = false,
    orbitRotationEnabled = false,
    orbitToggleKey = Enum.KeyCode.O,
    accelKey = Enum.KeyCode.F,
    followTarget = nil,
    followTargetPart = nil,
    followLoopRunning = false,
    mirrorEnabled = false,
    mirrorTargetPart = nil,
    mirrorLastCFrame = nil,
    mirrorStuds = 8,

    trollAngle = 0,
    trollTime = 0,
    trollNoClipCache = nil,
    trollCharNoClipCache = nil,
    trollNoClipActive = false,
    waypoints = {},
    waypointCounter = 0,
    selectedWaypointId = nil,
    waypointMarker = nil,
    groundGuardRunning = false,
    vehiclePings = {},
    lang = "fr",
    horseEnabled = false,
    horseModel = nil,
    horsePonies = nil,
    poneySoundEnabled = true,
    policeSoundEnabled = true,
    policeNotifEnabled = true,
    roleDisplayEnabled = true,
    policeDetectDist = 250,
    vehSimEnabled = false,
    simFwdKey = Enum.KeyCode.W,
    simRevKey = Enum.KeyCode.S,
    simMaxFwd = 150,
    simMaxRev = 15,
    simAccel  = 70,
    occPanelEnabled = true,
}

-- ===== SYSTEME DE TRADUCTION =====
local TRANSLATIONS = {
    fr = {
        menu_teleport   = "TELEPORTER",
        menu_waypoints  = "HOME / WAYPOINTS",
        menu_custom     = "⚙ CUSTOM VEHICULE",
        menu_delete     = "SUPPRIMER UI",
        menu_respawn    = "💀 RÉAPPARAÎTRE",
        kb_accel_label  = "Boost vitesse — touche acceleration",
        kb_accel_change = "CHANGER TOUCHE",
        kb_accel_saved  = "Touche sauvegardee !",
        kb_accel_listen = "Appuie sur une touche...",
        kb_hud_section  = "Affichage HUD",
        kb_police_notif_on  = "🚔 Notif policier : ON",
        kb_police_notif_off = "🚔 Notif policier : OFF",
        kb_role_badge_on    = "🏷 Badge role : ON",
        kb_role_badge_off   = "🏷 Badge role : OFF",
        kb_police_dist  = "Detection policier (metres)",
        notif_police_one  = "🚔 Policier detecte",
        notif_police_many = "🚔 %d policiers detectes",
        notif_police_sub  = "Plus proche : %d studs",
        menu_items      = "🎒 ITEMS",
        items_title     = "ITEMS — ReplicatedStorage",
        items_hint      = "Clique pour equiper un outil",
        items_none      = "Aucun outil trouve dans ReplicatedStorage.Tools",
        items_given     = "Equipe : %s",
        items_back      = "← RETOUR",
        items_remove    = "🗑 RETIRER ITEM",
        items_removed   = "Item retire",
        btn_instant     = "⚡ INSTANT",
        btn_roof        = "🏠 TOIT",
        status_instant  = "⚡ TP instant : ",
        status_roof     = "🏠 Toit : ",
        tab_building    = "BATIMENTS",
        tab_robbery     = "DESTINATIONS",
        tab_dealer      = "DEALER",
        tab_players     = "JOUEURS",
        tab_vehicles    = "VEHICLES",
        btn_back        = "RETOUR",
        btn_cancel      = "ANNULER TP",
        btn_orbit_off   = "ORBIT: OFF",
        btn_orbit_on    = "ORBIT: ON",
        btn_rot_off     = "ROTATION: OFF",
        btn_rot_on      = "ROTATION: ON",
        btn_mirror_off  = "DETECTIVES: OFF",
        btn_mirror_on   = "DETECTIVES: ON",
        status_mirror_on   = "DETECTIVES: %s",
        status_mirror_off  = "Detectives Bizard desactive",
        status_mirror_stop = "Detectives Bizard: cible perdue",
        status_mirror_noveh= "Detectives Bizard: pas dans un vehicule",
        kb_poney_snd_on = "🐴 Son poneys : ON",
        kb_poney_snd_off= "🐴 Son poneys : OFF",
        kb_police_snd_on= "🚔 Sirene police : ON",
        kb_police_snd_off="🚔 Sirene police : OFF",
        kb_vehsim_on         = "Sim vehicule : ON",
        kb_vehsim_off        = "Sim vehicule : OFF",
        kb_vehsim_contact_on = "⚠ Contact ON — sim inactif",
        kb_sim_fwd_label     = "Sim — touche avancer",
        kb_sim_rev_label     = "Sim — touche reculer",
        kb_sim_speed_fwd     = "Vitesse max avancer (studs/s)",
        kb_sim_speed_rev     = "Vitesse max reculer (studs/s)",
        kb_sim_accel_label   = "Acceleration (studs/s²)",
        notif_airborne       = "🚗 Sim vehicule",
        notif_airborne_sub   = "En l'air — controle coupe",
        kb_occ_panel_on  = "👥 Panel véhicule : ON",
        kb_occ_panel_off = "👥 Panel véhicule : OFF",
        veh_btn_details  = "INFO",
        veh_details_title = "👥 Occupants & Vitesse",
        veh_driver_label  = "🚗 CONDUCTEUR",
        veh_passenger_label = "👤 Passager",
        veh_speed_label  = "⚡ Vitesse : %d km/h",
        veh_no_occupants = "Aucun occupant",
        orbit_label     = "Cible orbit: aucune",
        status_ready    = "Pret",
        status_no_target= "Selectionne un joueur d'abord",
        status_no_veh   = "Monte dans ton vehicule d'abord",
        status_cancel   = "TP annule",
        status_unavail  = "Destination indisponible",
        status_orbit_off= "ORBIT desactive",
        status_orbit_stop_gone  = "ORBIT stop: cible absente",
        status_orbit_stop_part  = "ORBIT stop: vehicle cible disparu",
        status_orbit_stop_noveh = "ORBIT stop: plus dans vehicule",
        status_orbit_stop_drive = "ORBIT stop: conduite manuelle",
        wp_title        = "HOME / WAYPOINTS",
        wp_hint         = "Creer, voir en direct, TP et supprimer tes waypoints",
        wp_live         = "Position live: -",
        wp_sel_none     = "Selection: aucune",
        wp_placeholder  = "Nom du waypoint (optionnel)",
        wp_create       = "CREER",
        wp_tp_sel       = "TP SELECT",
        wp_delete       = "SUPPRIMER",
        wp_status_none  = "Aucun waypoint",
        wp_export_title = "Liste nom + coordonnees",
        wp_generate     = "GENERER",
        wp_copy         = "COPIER",
        wp_export_hint  = "Clique GENERER puis COPIER, ensuite colle le texte ici dans le chat.",
        wp_add          = "AJOUTER WAYPOINT ICI",
        wp_back         = "← RETOUR",
        wp_none         = "Aucun waypoint sauvegarde.",
        wp_go           = "ALLER",
        wp_del          = "SUP",
        wp_back_menu    = "RETOUR MENU",
        wp_import       = "IMPORT BRAQUAGES",
        wp_live_fmt     = "Position live: %s",
        wp_live_unavail = "Position live: indisponible",
        wp_sel_fmt      = "Selection: %s | %s%s",
        wp_sel_none_dyn = "Selection: aucune",
        wp_st_selected  = "Waypoint selectionne: %s",
        wp_st_tp        = "TP vers %s ...",
        wp_st_deleted   = "Waypoint supprime: %s",
        wp_st_impossible= "Impossible de recuperer la position",
        wp_st_created   = "Waypoint cree (%s): %s",
        wp_st_sel_first = "Selectionne un waypoint",
        wp_st_no_sel    = "Aucun waypoint selectionne",
        wp_st_generated = "Liste waypoint generee",
        wp_st_empty     = "Liste vide",
        wp_st_copied    = "Liste copiee dans le presse-papiers",
        wp_st_no_clip   = "Clipboard indispo: copie manuelle dans la box",
        wp_st_no_new    = "Import: aucun nouveau point",
        wp_st_imported  = "Import: %d point(s) ajoute(s)",
        cv_title        = "⚙  CUSTOM VEHICULE  (client only)",
        cv_back         = "← RETOUR",
        cv_refresh      = "↺ RAFRAICHIR",
        cv_parts        = "PARTIES DU VEHICULE",
        cv_all          = "★ TOUT LE VEHICULE",
        cv_none_sel     = "Cible : aucune",
        cv_sel_all      = "Cible : TOUT LE VEHICULE",
        cv_target       = "Cible : ",
        cv_color        = "COULEUR",
        cv_material     = "MATERIAU",
        cv_transp       = "TRANSPARENCE",
        cv_other_key    = "AUTRE TOUCHE",
        cv_apply_info   = "Touche active.\nAppuie en jeu pour\nactiver / desactiver l'orbit.",
        cv_listen       = "En attente...\nAppuie sur n'importe\nquelle touche clavier.",
        cv_updated      = "Touche mise a jour !",
        cv_no_veh       = "Monte dans ton vehicule d'abord",
        cv_no_veh2      = "Aucun vehicule trouve",
        cv_veh_fmt      = "Vehicule: %s",
        cv_applied_all  = "%s applique sur %d parties",
        cv_applied_one  = "%s applique sur %s",
        cv_invalid_part = "Partie invalide",
        cv_cast_shadow_on  = "CAST SHADOW : ON",
        cv_cast_shadow_off = "CAST SHADOW : OFF",
        cv_speed_label  = "VITESSE VEHICULE",
        cv_speed_reset  = "RESET",
        btn_horse_on    = "🐴 JUMENT: ON",
        btn_horse_off   = "🐴 JUMENT: OFF",
        status_orbit_veh_off = "ORBIT vehicule desactive",
        status_orbit_veh_on  = "ORBIT vehicule: %s",
        status_no_veh_folder = "Dossier Vehicles introuvable",
        kb_title        = "⚙  ELIW LMOD — Touche raccourci orbit",
        kb_quick        = "CHOIX RAPIDE",
        kb_listen       = "Appuie sur une touche pour changer...",
        kb_close        = "FERMER",
        veh_not_found   = "Dossier Vehicles introuvable",
        veh_tp_fmt      = "TP vers vehicle %s ...",
        deal_tp_fmt     = "TP vers %s ...",
        dest_bateaux1   = "BATEAUX 1",
        dest_bateaux2   = "BATEAUX 2",
        dest_banque     = "BANQUE",
        dest_bijouterie = "BIJOUTERIE",
        dest_nuits      = "BOITE DE NUITS",
        dest_prison     = "PRISON",
        dest_garage     = "GARAGE",
        dest_conces     = "CONCESSIONNAIRE",
        dest_home       = "HOME",
    },
    en = {
        menu_teleport   = "TELEPORT",
        menu_waypoints  = "HOME / WAYPOINTS",
        menu_custom     = "⚙ CUSTOM VEHICLE",
        menu_delete     = "DELETE UI",
        menu_respawn    = "💀 RESPAWN",
        kb_accel_label  = "Speed boost — accel key",
        kb_accel_change = "CHANGE KEY",
        kb_accel_saved  = "Key saved!",
        kb_accel_listen = "Press any key...",
        kb_hud_section  = "HUD Display",
        kb_police_notif_on  = "🚔 Police notif : ON",
        kb_police_notif_off = "🚔 Police notif : OFF",
        kb_role_badge_on    = "🏷 Role badge : ON",
        kb_role_badge_off   = "🏷 Role badge : OFF",
        kb_police_dist  = "Police detection (metres)",
        notif_police_one  = "🚔 Officer detected",
        notif_police_many = "🚔 %d officers detected",
        notif_police_sub  = "Closest: %d studs",
        menu_items      = "🎒 ITEMS",
        items_title     = "ITEMS — ReplicatedStorage",
        items_hint      = "Click to equip a tool",
        items_none      = "No tools found in ReplicatedStorage.Tools",
        items_given     = "Equipped: %s",
        items_back      = "← BACK",
        items_remove    = "🗑 REMOVE ITEM",
        items_removed   = "Item removed",
        btn_instant     = "⚡ INSTANT",
        btn_roof        = "🏠 ROOF",
        status_instant  = "⚡ Instant TP: ",
        status_roof     = "🏠 Roof: ",
        tab_building    = "BUILDINGS",
        tab_robbery     = "DESTINATIONS",
        tab_dealer      = "DEALER",
        tab_players     = "PLAYERS",
        tab_vehicles    = "CARS",
        btn_back        = "BACK",
        btn_cancel      = "CANCEL TP",
        btn_orbit_off   = "ORBIT: OFF",
        btn_orbit_on    = "ORBIT: ON",
        btn_rot_off     = "ROTATION: OFF",
        btn_rot_on      = "ROTATION: ON",
        btn_mirror_off  = "DETECTIVES: OFF",
        btn_mirror_on   = "DETECTIVES: ON",
        status_mirror_on   = "DETECTIVES: %s",
        status_mirror_off  = "Detectives Bizard off",
        status_mirror_stop = "Detectives Bizard: target lost",
        status_mirror_noveh= "Detectives Bizard: not in a vehicle",
        kb_poney_snd_on = "🐴 Pony sound : ON",
        kb_poney_snd_off= "🐴 Pony sound : OFF",
        kb_police_snd_on= "🚔 Police siren : ON",
        kb_police_snd_off="🚔 Police siren : OFF",
        kb_vehsim_on         = "Vehicle sim : ON",
        kb_vehsim_off        = "Vehicle sim : OFF",
        kb_vehsim_contact_on = "⚠ Contact ON — sim inactive",
        kb_sim_fwd_label     = "Sim — fwd key",
        kb_sim_rev_label     = "Sim — rev key",
        kb_sim_speed_fwd     = "Max fwd speed (studs/s)",
        kb_sim_speed_rev     = "Max rev speed (studs/s)",
        kb_sim_accel_label   = "Acceleration (studs/s²)",
        notif_airborne       = "🚗 Vehicle sim",
        notif_airborne_sub   = "Airborne — control cut",
        kb_occ_panel_on  = "👥 Vehicle panel: ON",
        kb_occ_panel_off = "👥 Vehicle panel: OFF",
        veh_btn_details  = "INFO",
        veh_details_title = "👥 Occupants & Speed",
        veh_driver_label  = "🚗 DRIVER",
        veh_passenger_label = "👤 Passenger",
        veh_speed_label  = "⚡ Speed: %d km/h",
        veh_no_occupants = "No occupants",
        orbit_label     = "Orbit target: none",
        status_ready    = "Ready",
        status_no_target= "Select a player first",
        status_no_veh   = "Get in your vehicle first",
        status_cancel   = "TP cancelled",
        status_unavail  = "Destination unavailable",
        status_orbit_off= "ORBIT disabled",
        status_orbit_stop_gone  = "ORBIT stop: target gone",
        status_orbit_stop_part  = "ORBIT stop: target vehicle gone",
        status_orbit_stop_noveh = "ORBIT stop: not in vehicle",
        status_orbit_stop_drive = "ORBIT stop: manual drive",
        wp_title        = "HOME / WAYPOINTS",
        wp_hint         = "Create, view live, TP and delete your waypoints",
        wp_live         = "Live position: -",
        wp_sel_none     = "Selected: none",
        wp_placeholder  = "Waypoint name (optional)",
        wp_create       = "CREATE",
        wp_tp_sel       = "TP SELECT",
        wp_delete       = "DELETE",
        wp_status_none  = "No waypoints",
        wp_export_title = "Name + coordinates list",
        wp_generate     = "GENERATE",
        wp_copy         = "COPY",
        wp_export_hint  = "Click GENERATE then COPY, then paste the text in chat.",
        wp_add          = "ADD WAYPOINT HERE",
        wp_back         = "← BACK",
        wp_none         = "No saved waypoint.",
        wp_go           = "GO",
        wp_del          = "DEL",
        wp_back_menu    = "BACK TO MENU",
        wp_import       = "IMPORT ROBBERIES",
        wp_live_fmt     = "Live position: %s",
        wp_live_unavail = "Live position: unavailable",
        wp_sel_fmt      = "Selected: %s | %s%s",
        wp_sel_none_dyn = "Selected: none",
        wp_st_selected  = "Waypoint selected: %s",
        wp_st_tp        = "TP to %s ...",
        wp_st_deleted   = "Waypoint deleted: %s",
        wp_st_impossible= "Unable to get position",
        wp_st_created   = "Waypoint created (%s): %s",
        wp_st_sel_first = "Select a waypoint first",
        wp_st_no_sel    = "No waypoint selected",
        wp_st_generated = "Waypoint list generated",
        wp_st_empty     = "List is empty",
        wp_st_copied    = "List copied to clipboard",
        wp_st_no_clip   = "Clipboard unavailable: copy manually from box",
        wp_st_no_new    = "Import: no new points",
        wp_st_imported  = "Import: %d point(s) added",
        cv_title        = "⚙  CUSTOM VEHICLE  (client only)",
        cv_back         = "← BACK",
        cv_refresh      = "↺ REFRESH",
        cv_parts        = "VEHICLE PARTS",
        cv_all          = "★ ENTIRE VEHICLE",
        cv_none_sel     = "Target: none",
        cv_sel_all      = "Target: ENTIRE VEHICLE",
        cv_target       = "Target: ",
        cv_color        = "COLOR",
        cv_material     = "MATERIAL",
        cv_transp       = "TRANSPARENCY",
        cv_other_key    = "OTHER KEY",
        cv_apply_info   = "Key active.\nPress in-game to\ntoggle orbit on/off.",
        cv_listen       = "Waiting...\nPress any keyboard key.",
        cv_updated      = "Key updated!",
        cv_no_veh       = "Get in your vehicle first",
        cv_no_veh2      = "No vehicle found",
        cv_veh_fmt      = "Vehicle: %s",
        cv_applied_all  = "%s applied to %d parts",
        cv_applied_one  = "%s applied to %s",
        cv_invalid_part = "Invalid part",
        cv_cast_shadow_on  = "CAST SHADOW : ON",
        cv_cast_shadow_off = "CAST SHADOW : OFF",
        cv_speed_label  = "VEHICLE SPEED",
        cv_speed_reset  = "RESET",
        btn_horse_on    = "🐴 HORSE: ON",
        btn_horse_off   = "🐴 HORSE: OFF",
        status_orbit_veh_off = "ORBIT vehicle disabled",
        status_orbit_veh_on  = "ORBIT vehicle: %s",
        status_no_veh_folder = "Vehicles folder not found",
        kb_title        = "⚙  ELIW LMOD — Orbit shortcut key",
        kb_quick        = "QUICK PICK",
        kb_listen       = "Press a key to change...",
        kb_close        = "CLOSE",
        veh_not_found   = "Vehicles folder not found",
        veh_tp_fmt      = "TP to vehicle %s ...",
        deal_tp_fmt     = "TP to %s ...",
        dest_bateaux1   = "BOATS 1",
        dest_bateaux2   = "BOATS 2",
        dest_banque     = "BANK",
        dest_bijouterie = "JEWELRY STORE",
        dest_nuits      = "NIGHTCLUB",
        dest_prison     = "PRISON",
        dest_garage     = "GARAGE",
        dest_conces     = "DEALERSHIP",
        dest_home       = "HOME",
    },
}

local langLabels = {}  -- { inst=TextInstance, key=string }

local function t(key)
    local l = TRANSLATIONS[state.lang]
    return (l and l[key]) or (TRANSLATIONS.fr[key]) or key
end

local function tReg(inst, key)
    inst.Text = t(key)
    table.insert(langLabels, { inst = inst, key = key })
    return inst
end

local function refreshLang()
    for _, e in ipairs(langLabels) do
        if e.updateFn then
            e.updateFn()
        elseif e.inst and e.inst.Parent then
            e.inst.Text = t(e.key)
        end
    end
end

local function findBasePart(obj)
    if not obj then
        return nil
    end

    if obj:IsA("BasePart") then
        return obj
    end

    for _, child in ipairs(obj:GetChildren()) do
        local part = findBasePart(child)
        if part then
            return part
        end
    end

    return nil
end

local function isPlayerVehicleModel(vehicle)
    if not vehicle or not vehicle:IsA("Model") then
        return false
    end

    if vehicle.Name == player.Name then
        return true
    end

    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        for _, seat in ipairs(vehicle:GetDescendants()) do
            if (seat:IsA("VehicleSeat") or seat:IsA("Seat")) and seat.Occupant == humanoid then
                return true
            end
        end
    end

    local owner = vehicle:FindFirstChild("Owner") or vehicle:FindFirstChild("owner")
    if owner then
        if owner:IsA("StringValue") and owner.Value == player.Name then
            return true
        end
        if owner:IsA("ObjectValue") and owner.Value == player then
            return true
        end
    end

    return false
end

local _lastDescendantScan = 0
local _lastVehicleScan = 0
local function findVehicle()
    if state.cachedVehicle and state.cachedVehicle.Parent and isPlayerVehicleModel(state.cachedVehicle) then
        return state.cachedVehicle
    end
    state.cachedVehicle = nil

    -- Throttle: si le joueur n'est pas assis, pas besoin de scanner 20x/sec
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then
        local now = tick()
        if (now - _lastVehicleScan) < 1.0 then
            return nil
        end
        _lastVehicleScan = now
    end

    local vehiclesFolder = workspace:FindFirstChild("Vehicles")
    if vehiclesFolder then
        local byName = vehiclesFolder:FindFirstChild(player.Name)
        if byName and byName:IsA("Model") then
            state.cachedVehicle = byName
            return byName
        end

        for _, model in ipairs(vehiclesFolder:GetChildren()) do
            if model:IsA("Model") and isPlayerVehicleModel(model) then
                state.cachedVehicle = model
                return model
            end
        end
    end

    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.SeatPart then
            local model = humanoid.SeatPart:FindFirstAncestorOfClass("Model")
            if model then
                state.cachedVehicle = model
                return model
            end
        end

        -- GetDescendants uniquement si le joueur EST assis quelque part
        -- (SeatPart nil = pas de siege = scan inutile)
        if humanoid and humanoid.SeatPart then
            local now = tick()
            if (now - _lastDescendantScan) >= 2 then
                _lastDescendantScan = now
                for _, seat in ipairs(workspace:GetDescendants()) do
                    if (seat:IsA("VehicleSeat") or seat:IsA("Seat")) and seat.Occupant == humanoid then
                        local model = seat:FindFirstAncestorOfClass("Model")
                        if model then
                            state.cachedVehicle = model
                            return model
                        end
                    end
                end
            end
        end
    end

    return nil
end

local function getVehicleRoot(vehicle)
    if not vehicle then
        return nil
    end

    if vehicle.PrimaryPart then
        return vehicle.PrimaryPart
    end

    return findBasePart(vehicle)
end

local function dampenVehicleVelocity(vehicle)
    local root = getVehicleRoot(vehicle)
    if not root then
        return
    end

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function clampPivotMinY(pivotCFrame)
    local minY = CONFIG.MIN_ALLOWED_Y
    if not minY then
        return pivotCFrame
    end

    local currentY = pivotCFrame.Position.Y
    if currentY >= minY then
        return pivotCFrame
    end

    return pivotCFrame + Vector3.new(0, minY - currentY, 0)
end

local function pivotVehicleBy(vehicle, offset, dampVelocity)
    if not vehicle then
        return false
    end

    local targetPivot = clampPivotMinY(vehicle:GetPivot() + offset)
    vehicle:PivotTo(targetPivot)
    if dampVelocity ~= false then
        dampenVehicleVelocity(vehicle)
    end
    return true
end

local function pivotVehicleTo(vehicle, pivotCFrame, dampVelocity)
    if not vehicle then
        return false
    end

    vehicle:PivotTo(clampPivotMinY(pivotCFrame))
    if dampVelocity ~= false then
        dampenVehicleVelocity(vehicle)
    end
    return true
end

local function isLocalPlayerSeatedInVehicle(vehicle)
    if not vehicle then
        return false
    end

    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local seatPart = humanoid and humanoid.SeatPart
    return seatPart and seatPart:IsDescendantOf(vehicle) or false
end

local function isLocalPlayerDrivingInputActive(vehicle)
    if not vehicle then
        return false
    end

    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local seatPart = humanoid and humanoid.SeatPart
    if not seatPart or not seatPart:IsDescendantOf(vehicle) then
        return false
    end

    if seatPart:IsA("VehicleSeat") then
        local throttle = math.abs(seatPart.ThrottleFloat or 0)
        local steer = math.abs(seatPart.SteerFloat or 0)
        if throttle > 0.05 or steer > 0.05 then
            return true
        end
    end

    if humanoid and humanoid.MoveDirection.Magnitude > 0.15 then
        return true
    end

    return false
end

local function getVehicleHalfHeight(vehicle)
    local root = getVehicleRoot(vehicle)
    if root then
        return math.clamp(root.Size.Y * 0.5, 1.5, 8)
    end

    local ok, _, size = pcall(function()
        return vehicle:GetBoundingBox()
    end)
    if ok and size then
        return math.clamp(size.Y * 0.25, 1.5, 8)
    end

    return 3
end

local function buildRaycastParams(vehicle)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true

    local excluded = {}
    if vehicle then
        table.insert(excluded, vehicle)
    end
    if player.Character then
        table.insert(excluded, player.Character)
    end
    params.FilterDescendantsInstances = excluded

    return params
end

local function isValidGroundHit(hit)
    return hit and hit.Instance and hit.Instance.CanCollide and hit.Normal.Y >= CONFIG.MIN_GROUND_NORMAL_Y
end

local function projectOnGround(x, z, preferredY, vehicle, halfHeight, allowSnap)
    local params = buildRaycastParams(vehicle)

    local nearOriginY = preferredY + CONFIG.GROUND_NEAR_PROBE_UP
    local nearOrigin = Vector3.new(x, nearOriginY, z)
    local nearDirection = Vector3.new(0, -(CONFIG.GROUND_NEAR_PROBE_UP + CONFIG.GROUND_NEAR_PROBE_DOWN), 0)
    local nearHit = workspace:Raycast(nearOrigin, nearDirection, params)

    local farOriginY = math.max(preferredY + CONFIG.GROUND_RAY_HEIGHT, halfHeight + 12, 600)
    local farOrigin = Vector3.new(x, farOriginY, z)
    local farDirection = Vector3.new(0, -(farOriginY + CONFIG.GROUND_RAY_LENGTH), 0)
    local farHit = workspace:Raycast(farOrigin, farDirection, params)

    local bestY = nil

    if isValidGroundHit(nearHit) then
        bestY = nearHit.Position.Y + halfHeight + CONFIG.GROUND_CLEARANCE
    end

    if isValidGroundHit(farHit) then
        local farY = farHit.Position.Y + halfHeight + CONFIG.GROUND_CLEARANCE
        if (not bestY) or math.abs(farY - preferredY) < math.abs(bestY - preferredY) then
            bestY = farY
        end
    end

    if bestY then
        local y = bestY
        if not allowSnap then
            y = math.clamp(y, preferredY - CONFIG.MAX_STEP_DROP, preferredY + CONFIG.MAX_STEP_RISE)
        end
        return Vector3.new(x, y, z), true
    end

    return Vector3.new(x, preferredY, z), false
end

local function placeVehicleOnGround(vehicle, samplePos, preferredY)
    local root = getVehicleRoot(vehicle)
    if not root then
        return false
    end

    local targetX = samplePos and samplePos.X or root.Position.X
    local targetZ = samplePos and samplePos.Z or root.Position.Z
    local targetY = preferredY or root.Position.Y

    local halfHeight = getVehicleHalfHeight(vehicle)
    local targetPos, hitGround = projectOnGround(
        targetX,
        targetZ,
        targetY,
        vehicle,
        halfHeight,
        true
    )
    if not hitGround then
        return false
    end
    local delta = targetPos - root.Position

    if delta.Magnitude > 0.01 then
        pivotVehicleBy(vehicle, delta, true)
    end

    return true
end

local function projectGroundForGuard(x, z, preferredY, vehicle, halfHeight)
    local params = buildRaycastParams(vehicle)

    local nearOriginY = preferredY + CONFIG.GROUND_NEAR_PROBE_UP
    local nearOrigin = Vector3.new(x, nearOriginY, z)
    local nearDirection = Vector3.new(0, -(CONFIG.GROUND_NEAR_PROBE_UP + CONFIG.GROUND_GUARD_NEAR_PROBE_DOWN), 0)
    local nearHit = workspace:Raycast(nearOrigin, nearDirection, params)

    local farOriginY = math.max(preferredY + CONFIG.GROUND_GUARD_RAY_HEIGHT, halfHeight + 20, 1200)
    local farOrigin = Vector3.new(x, farOriginY, z)
    local farDirection = Vector3.new(0, -(farOriginY + CONFIG.GROUND_GUARD_RAY_LENGTH), 0)
    local farHit = workspace:Raycast(farOrigin, farDirection, params)

    local bestY = nil

    if isValidGroundHit(nearHit) then
        bestY = nearHit.Position.Y + halfHeight + CONFIG.GROUND_GUARD_CLEARANCE
    end

    if isValidGroundHit(farHit) then
        local farY = farHit.Position.Y + halfHeight + CONFIG.GROUND_GUARD_CLEARANCE
        if (not bestY) or math.abs(farY - preferredY) < math.abs(bestY - preferredY) then
            bestY = farY
        end
    end

    if bestY then
        return Vector3.new(x, bestY, z), true
    end

    return Vector3.new(x, preferredY, z), false
end

local function enforceVehicleAboveGround(vehicle, forceFullSnap)
    local root = getVehicleRoot(vehicle)
    if not root then
        return false
    end

    local halfHeight = getVehicleHalfHeight(vehicle)
    local safePos, hasGround = projectGroundForGuard(
        root.Position.X,
        root.Position.Z,
        root.Position.Y,
        vehicle,
        halfHeight
    )
    if not hasGround then
        return false
    end

    local depth = safePos.Y - root.Position.Y
    if depth <= CONFIG.UNDERMAP_DEPTH_TRIGGER then
        return false
    end

    local correction = forceFullSnap and depth or math.min(depth, CONFIG.GROUND_GUARD_MAX_CORRECTION)
    pivotVehicleBy(vehicle, Vector3.new(0, correction, 0), true)
    return true
end

local function startGroundGuard()
    if state.groundGuardRunning then
        return
    end

    state.groundGuardRunning = true
    task.spawn(function()
        while state.groundGuardRunning do
            task.wait(CONFIG.GROUND_GUARD_INTERVAL)
            local vehicle = findVehicle()
            if vehicle and vehicle.Parent then
                local activeScriptMove = state.isTPing or state.followEnabled or state.trollNoClipActive
                if activeScriptMove then
                    enforceVehicleAboveGround(vehicle)
                else
                    -- Do not fight manual driving. Only rescue if deeply under the map.
                    if isLocalPlayerSeatedInVehicle(vehicle) then
                        continue
                    end

                    local root = getVehicleRoot(vehicle)
                    if root then
                        local halfHeight = getVehicleHalfHeight(vehicle)
                        local safePos, hasGround = projectGroundForGuard(
                            root.Position.X,
                            root.Position.Z,
                            root.Position.Y,
                            vehicle,
                            halfHeight
                        )
                        if hasGround and (safePos.Y - root.Position.Y) > (CONFIG.UNDERMAP_DEPTH_TRIGGER * 3) then
                            enforceVehicleAboveGround(vehicle, true)
                        end
                    end
                end
            end
        end
    end)
end

local function hasObstacleAhead(vehicle, currentPos, direction, distance)
    if distance <= 0 then
        return false, nil
    end

    local halfHeight = math.max(getVehicleHalfHeight(vehicle), 2)
    local origin = currentPos + Vector3.new(0, halfHeight * 0.5, 0)
    local ray = direction * (distance + 1)
    local hit = workspace:Raycast(origin, ray, buildRaycastParams(vehicle))

    if hit and hit.Instance and hit.Instance.CanCollide then
        return true, hit
    end

    return false, nil
end

local function setVehicleNoClip(vehicle, enabled, cache)
    if not vehicle then
        return
    end

    for _, obj in ipairs(vehicle:GetDescendants()) do
        if obj:IsA("BasePart") then
            if enabled then
                if cache and not cache[obj] then
                    cache[obj] = {
                        CanCollide = obj.CanCollide,
                        CanTouch = obj.CanTouch,
                        CanQuery = obj.CanQuery,
                    }
                end
                obj.CanCollide = false
                obj.CanTouch = false
            else
                local original = cache and cache[obj]
                if original then
                    if obj.Parent then
                        obj.CanCollide = original.CanCollide
                        obj.CanTouch = original.CanTouch
                        obj.CanQuery = original.CanQuery
                    end
                elseif obj.Parent then
                    obj.CanCollide = true
                    obj.CanTouch = true
                end
            end
        end
    end
end

local function setCharacterNoClip(enabled, cache)
    local character = player.Character
    if not character then
        return
    end

    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            if enabled then
                if cache and not cache[obj] then
                    cache[obj] = {
                        CanCollide = obj.CanCollide,
                        CanTouch = obj.CanTouch,
                        CanQuery = obj.CanQuery,
                    }
                end
                obj.CanCollide = false
                obj.CanTouch = false
            else
                local original = cache and cache[obj]
                if original and obj.Parent then
                    obj.CanCollide = original.CanCollide
                    obj.CanTouch = original.CanTouch
                    obj.CanQuery = original.CanQuery
                end
            end
        end
    end
end

local function setPassengersNoClip(vehicle, cache)
    if not vehicle or not vehicle.Parent then
        return
    end

    for _, seat in ipairs(vehicle:GetDescendants()) do
        if seat:IsA("VehicleSeat") or seat:IsA("Seat") then
            local humanoid = seat.Occupant
            local character = humanoid and humanoid.Parent
            if character and character:IsA("Model") and character ~= player.Character then
                for _, obj in ipairs(character:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        if cache and not cache[obj] then
                            cache[obj] = {
                                CanCollide = obj.CanCollide,
                                CanTouch = obj.CanTouch,
                                CanQuery = obj.CanQuery,
                            }
                        end
                        obj.CanCollide = false
                        obj.CanTouch = false
                    end
                end
            end
        end
    end
end

local function restoreCollisionFromCache(cache)
    if not cache then
        return
    end

    for part, original in pairs(cache) do
        if part and part.Parent and original then
            part.CanCollide = original.CanCollide
            part.CanTouch = original.CanTouch
            part.CanQuery = original.CanQuery
        end
    end
end

local function isVehicleInsideWall(vehicle)
    if not vehicle or not vehicle.Parent then
        return false
    end

    local ok, boxCf, boxSize = pcall(function()
        return vehicle:GetBoundingBox()
    end)
    if not ok or not boxCf or not boxSize then
        return false
    end

    local overlap = OverlapParams.new()
    overlap.FilterType = Enum.RaycastFilterType.Exclude
    overlap.FilterDescendantsInstances = { vehicle }

    local parts = workspace:GetPartBoundsInBox(boxCf, boxSize, overlap)
    for _, part in ipairs(parts) do
        if part and part.Parent and part.CanCollide and part.Transparency < 1 then
            return true
        end
    end

    return false
end

local function resolveVehicleOutsideWalls(vehicle)
    if not vehicle or not vehicle.Parent then
        return false
    end

    if not isVehicleInsideWall(vehicle) then
        return true
    end

    local basePivot = vehicle:GetPivot()
    local directions = {
        Vector3.new(1, 0, 0),
        Vector3.new(-1, 0, 0),
        Vector3.new(0, 0, 1),
        Vector3.new(0, 0, -1),
        Vector3.new(1, 0, 1).Unit,
        Vector3.new(-1, 0, 1).Unit,
        Vector3.new(1, 0, -1).Unit,
        Vector3.new(-1, 0, -1).Unit,
    }

    for upStep = 0, CONFIG.PHASE_RESOLVE_MAX_UP_STEPS do
        local up = Vector3.new(0, upStep * CONFIG.PHASE_RESOLVE_UP_STEP, 0)
        for radius = 0, CONFIG.PHASE_RESOLVE_MAX_RADIUS, CONFIG.PHASE_RESOLVE_RADIUS_STEP do
            for _, dir in ipairs(directions) do
                local offset = up + dir * radius
                pivotVehicleTo(vehicle, basePivot + offset, true)
                enforceVehicleAboveGround(vehicle)
                if not isVehicleInsideWall(vehicle) then
                    placeVehicleOnGround(vehicle)
                    if not isVehicleInsideWall(vehicle) then
                        return true
                    end
                end
            end
        end
    end

    -- Hard fallback: push vertically if still trapped.
    for _ = 1, 14 do
        pivotVehicleBy(vehicle, Vector3.new(0, CONFIG.PHASE_RESOLVE_UP_STEP * 2, 0), true)
        enforceVehicleAboveGround(vehicle)
        if not isVehicleInsideWall(vehicle) then
            placeVehicleOnGround(vehicle)
            if not isVehicleInsideWall(vehicle) then
                return true
            end
        end
    end

    pivotVehicleTo(vehicle, basePivot, true)
    return false
end

local function forceVehicleUnstuck(vehicle, samplePos, preferredY)
    if not vehicle or not vehicle.Parent then
        return false
    end

    if not isVehicleInsideWall(vehicle) then
        return true
    end

    if resolveVehicleOutsideWalls(vehicle) and not isVehicleInsideWall(vehicle) then
        return true
    end

    local basePivot = vehicle:GetPivot()
    for attempt = 1, CONFIG.WALL_UNSTICK_MAX_ATTEMPTS do
        local upOffset = Vector3.new(0, CONFIG.WALL_UNSTICK_EMERGENCY_UP * attempt, 0)
        pivotVehicleTo(vehicle, basePivot + upOffset, true)
        if samplePos then
            placeVehicleOnGround(vehicle, samplePos, preferredY)
        else
            placeVehicleOnGround(vehicle)
        end
        if not isVehicleInsideWall(vehicle) then
            return true
        end
    end

    return not isVehicleInsideWall(vehicle)
end

local function enableTrollNoClip(vehicle)
    if not vehicle then
        return
    end

    if not state.trollNoClipActive then
        state.trollNoClipCache = {}
        state.trollCharNoClipCache = {}
        state.trollNoClipActive = true
    end

    setVehicleNoClip(vehicle, true, state.trollNoClipCache)
    setCharacterNoClip(true, state.trollCharNoClipCache)
end

local function stopTrollNoClipAndResolve()
    if not state.trollNoClipActive then
        return
    end

    restoreCollisionFromCache(state.trollNoClipCache)
    restoreCollisionFromCache(state.trollCharNoClipCache)
    state.trollNoClipCache = nil
    state.trollCharNoClipCache = nil
    state.trollNoClipActive = false

    local vehicle = findVehicle()
    if vehicle then
        resolveVehicleOutsideWalls(vehicle)
        placeVehicleOnGround(vehicle)
    end
end

local function computeTrollOrbitPosition(targetHrp, vehicleRoot, dt)
    -- Positionner le vehicle sous les pieds de la cible:
    -- feetY = bas du HRP = niveau du sol de la cible
    -- vehicleRoot doit etre a feetY - vehicleHalfHeight pour que le toit touche les pieds.
    local char = targetHrp.Parent
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hipHeight = (hum and hum.HipHeight) or 2
    local hrpHalfY = targetHrp.Size.Y * 0.5
    local feetY = targetHrp.Position.Y - hipHeight - hrpHalfY
    local headY = targetHrp.Position.Y + hipHeight + hrpHalfY
    local vehicleHalfHeight = vehicleRoot and math.clamp(vehicleRoot.Size.Y * 0.5, 1.5, 8) or 2
    -- Oscillation verticale pieds <-> tete via sin(trollTime)
    local t = math.sin(state.trollTime * CONFIG.ORBIT_VERTICAL_SPEED * math.pi * 2) * 0.5 + 0.5
    local currentY = (feetY - vehicleHalfHeight) + (headY - feetY) * t

    -- Toujours incrementer trollTime pour que l'oscillation verticale fonctionne dans les deux modes.
    state.trollTime = state.trollTime + dt

    state.trollAngle = state.trollAngle + (CONFIG.TROLL_ORBIT_ANGULAR_SPEED * math.pi * 2 * dt)

    local right = targetHrp.CFrame.RightVector
    local look = targetHrp.CFrame.LookVector

    local swirl = (right * math.cos(state.trollAngle)) + (look * math.sin(state.trollAngle))
    local noiseX = math.noise(state.trollTime * CONFIG.TROLL_NOISE_SPEED, 0, 0)
    local noiseZ = math.noise(0, state.trollTime * CONFIG.TROLL_NOISE_SPEED, 0)
    local chaos = (right * noiseX) + (look * noiseZ)
    local dir = swirl + (chaos * 1.35)
    if dir.Magnitude < 0.001 then
        dir = swirl
    end
    dir = dir.Unit

    local wobble = (math.sin(state.trollAngle * 2.9) * 0.5 + 0.5)
    local radius = CONFIG.TROLL_ORBIT_MIN_RADIUS + (CONFIG.TROLL_ORBIT_MAX_RADIUS - CONFIG.TROLL_ORBIT_MIN_RADIUS) * wobble
    radius = math.max(0.1, radius - (math.sin(state.trollAngle * 5.1) * CONFIG.TROLL_INWARD_WOBBLE))

    -- Fonce regulierement sur la cible depuis toutes les directions.
    if math.sin(state.trollTime * 8.8) > 0.76 then
        radius = 0.05
    end

    local aroundPos = targetHrp.Position + (dir * radius)
    -- Y oscille pieds <-> tete independamment du mouvement horizontal.
    return Vector3.new(aroundPos.X, currentY, aroundPos.Z)
end

local function performTrollStep(targetHrp, statusLabel, dt)
    local vehicle = findVehicle()
    local root = vehicle and getVehicleRoot(vehicle)
    if not vehicle or not root then
        return false
    end

    enableTrollNoClip(vehicle)

    local desiredPos = computeTrollOrbitPosition(targetHrp, root, dt)

    local delta = desiredPos - root.Position
    local distance = delta.Magnitude
    if distance < 0.01 then
        return true
    end

    local nextPos
    if distance <= CONFIG.ORBIT_PRECISION_SNAP_DISTANCE then
        nextPos = desiredPos
    else
        local step = math.min(CONFIG.TROLL_MOVE_SPEED * dt, CONFIG.TROLL_STEP_MAX, distance)
        nextPos = root.Position + (delta.Unit * step)
    end

    local moveOffset = nextPos - root.Position
    local spinAngle = state.orbitRotationEnabled and (CONFIG.TROLL_SPIN_REV_PER_SEC * math.pi * 2 * dt) or 0
    local movedPivot = vehicle:GetPivot() + moveOffset
    if spinAngle ~= 0 then
        pivotVehicleTo(vehicle, movedPivot * CFrame.Angles(0, spinAngle, 0), true)
    else
        pivotVehicleTo(vehicle, movedPivot, true)
    end
    -- Ne pas corriger le sol si le vehicule est dans un mur (joueur dans un batiment)
    if not isVehicleInsideWall(vehicle) then
        enforceVehicleAboveGround(vehicle)
    end

    if statusLabel then
        local modeLabel = state.orbitRotationEnabled and "ROT" or "SUIVI"
        statusLabel.Text = string.format(
            "ORBIT %s %s | X:%.0f Y:%.0f Z:%.0f",
            modeLabel,
            targetHrp.Parent and targetHrp.Parent.Name or "?",
            targetHrp.Position.X,
            targetHrp.Position.Y,
            targetHrp.Position.Z
        )
    end

    return true
end

local function microTeleport(targetPos, statusLabel, options)
    options = options or {}

    if state.isTPing then
        if statusLabel then
            statusLabel.Text = "TP deja en cours..."
        end
        return false
    end

    local vehicle = findVehicle()
    if not vehicle then
        if statusLabel then
            statusLabel.Text = "Vehicule introuvable"
        end
        return false
    end

    local root = getVehicleRoot(vehicle)
    if not root then
        if statusLabel then
            statusLabel.Text = "Aucune BasePart vehicule"
        end
        return false
    end

    state.isTPing = true

    local reached = false
    local blockedBy = nil
    local climbedBudgetUsed = 0
    local stuckTime = 0
    local lastPos = nil
    local blockedCycles = 0
    local snappedNearTarget = false
    local lastGroundTouch = os.clock()

    local walkMode = options.walkMode == true
    local preferTargetY = options.preferTargetY == true
    local exactTargetY = options.exactTargetY == true
    local wallPass = options.wallPass
    if wallPass == nil then
        wallPass = true
    end

    local jumpMode = options.jumpMode
    if jumpMode == nil then
        jumpMode = state.jumpMode
    end
    if not CONFIG.ALLOW_FLIGHT then
        jumpMode = false
    end

    local activeSpeed = walkMode and CONFIG.WALK_SPEED or state.speed
    local activeStepMax = walkMode and CONFIG.WALK_STEP_MAX or CONFIG.STEP_MAX
    local activeAutoClimbMax = walkMode and CONFIG.WALK_AUTO_CLIMB_MAX or CONFIG.AUTO_CLIMB_MAX
    local activeAutoClimbStep = walkMode and CONFIG.WALK_AUTO_CLIMB_STEP or CONFIG.AUTO_CLIMB_STEP
    local activeStuckBoost = walkMode and CONFIG.WALK_STUCK_CLIMB_BOOST or CONFIG.STUCK_CLIMB_BOOST
    local activeRecoverySide = walkMode and CONFIG.WALK_RECOVERY_SIDE_STEP or CONFIG.RECOVERY_SIDE_STEP
    local activeRecoveryUp = walkMode and CONFIG.WALK_RECOVERY_UP_STEP or CONFIG.RECOVERY_UP_STEP
    local jumpCruiseY = nil
    local tpCollisionCache = wallPass and {} or nil
    local tpCharCollisionCache = (wallPass and not state.trollNoClipActive) and {} or nil
    local tpPassengerCollisionCache = wallPass and {} or nil
    local wallPassActive = false
    local wallPassUntil = 0
    local wallPassRetryAt = 0
    local wallPassPersistent = wallPass and CONFIG.WALL_PASS_STAY_ACTIVE
    local insidePhaseTime = 0

    local function disableWallPass()
        if not wallPassActive then
            return
        end
        restoreCollisionFromCache(tpCollisionCache)
        if tpCharCollisionCache then
            restoreCollisionFromCache(tpCharCollisionCache)
        end
        if tpPassengerCollisionCache then
            restoreCollisionFromCache(tpPassengerCollisionCache)
        end
        wallPassActive = false
    end

    local function burstWallPass(duration)
        if not wallPass then
            return
        end

        if wallPassPersistent then
            wallPassUntil = math.huge
        else
            wallPassUntil = math.max(wallPassUntil, os.clock() + duration)
        end
        if wallPassActive then
            return
        end

        setVehicleNoClip(vehicle, true, tpCollisionCache)
        if tpCharCollisionCache then
            setCharacterNoClip(true, tpCharCollisionCache)
        end
        if tpPassengerCollisionCache then
            setPassengersNoClip(vehicle, tpPassengerCollisionCache)
        end
        wallPassActive = true
    end

    if wallPass then
        burstWallPass(CONFIG.WALL_PASS_INITIAL_BURST)
    end
    local initialGroundPos, initialHasGround = projectOnGround(
        root.Position.X,
        root.Position.Z,
        root.Position.Y,
        vehicle,
        getVehicleHalfHeight(vehicle),
        true
    )
    local lastKnownGroundY = (initialHasGround and initialGroundPos and initialGroundPos.Y) or root.Position.Y

    while state.isTPing do
        if not vehicle or not vehicle.Parent then
            vehicle = findVehicle()
            if not vehicle then
                if statusLabel then
                    statusLabel.Text = "Recherche vehicule..."
                end
                RunService.Heartbeat:Wait()
                continue
            end
            if wallPassActive then
                setVehicleNoClip(vehicle, true, tpCollisionCache)
                if tpCharCollisionCache then
                    setCharacterNoClip(true, tpCharCollisionCache)
                end
                if tpPassengerCollisionCache then
                    setPassengersNoClip(vehicle, tpPassengerCollisionCache)
                end
            end

        end

        root = getVehicleRoot(vehicle)
        if not root then
            if statusLabel then
                statusLabel.Text = "Recherche base vehicule..."
            end
            RunService.Heartbeat:Wait()
            continue
        end

        -- Annuler le TP si le joueur n'est plus assis dans le vehicule
        if not walkMode and not isLocalPlayerSeatedInVehicle(vehicle) then
            state.isTPing = false
            if wallPassActive then
                disableWallPass()
            end
            if statusLabel then
                statusLabel.Text = "TP annule: siege vide"
            end
            break
        end

        -- Ne pas forcer le sol quand on passe a travers les murs (joueur peut etre dans un batiment)
        if not wallPassActive then
            enforceVehicleAboveGround(vehicle)
        end
        root = getVehicleRoot(vehicle)
        if not root then
            RunService.Heartbeat:Wait()
            continue
        end

        if wallPassActive then
            -- Re-apply no-clip while active so game scripts cannot silently re-enable collisions.
            setVehicleNoClip(vehicle, true, tpCollisionCache)
            if tpCharCollisionCache then
                setCharacterNoClip(true, tpCharCollisionCache)
            end
            if tpPassengerCollisionCache then
                setPassengersNoClip(vehicle, tpPassengerCollisionCache)
            end
        end

        if (not wallPassPersistent) and wallPassActive and os.clock() >= wallPassUntil then
            disableWallPass()
        end

        -- Cache une seule fois par frame (appel GetPartBoundsInBox couteux)
        local distToTarget2D_early = (
            Vector3.new(targetPos.X, 0, targetPos.Z) - Vector3.new(root.Position.X, 0, root.Position.Z)
        ).Magnitude
        local nearDestination = distToTarget2D_early <= CONFIG.NEAR_TARGET_SNAP_DISTANCE * 2.5
        -- Quand on est proche de la destination: desactiver insideWall pour ne pas forcer
        -- la montee vers un toit et laisser le snap d'arrivee placer precisement le vehicule.
        local insideWall = wallPassActive and (not nearDestination) and isVehicleInsideWall(vehicle)

        local current = root.Position
        local currentHalfHeight = getVehicleHalfHeight(vehicle)
        local currentGround, currentHasGround = projectOnGround(
            current.X,
            current.Z,
            current.Y,
            vehicle,
            currentHalfHeight,
            true
        )

        if currentHasGround then
            -- Sur un toit (wallPass actif): ne jamais laisser lastKnownGroundY redescendre
            -- sous la position actuelle, pour eviter que maxAllowedY combatte le snap du toit.
            if wallPassActive then
                if currentGround.Y > lastKnownGroundY then
                    lastKnownGroundY = currentGround.Y
                end
            else
                lastKnownGroundY = currentGround.Y
            end
            local undergroundDepth = currentGround.Y - current.Y
            if undergroundDepth > CONFIG.UNDERMAP_DEPTH_TRIGGER then
                pivotVehicleBy(vehicle, Vector3.new(0, undergroundDepth, 0), true)
                lastGroundTouch = os.clock()
                stuckTime = 0
                lastPos = nil
                if statusLabel then
                    statusLabel.Text = "Anti sous-map: correction verticale"
                end
                RunService.Heartbeat:Wait()
                continue
            end

            if current.Y <= currentGround.Y + CONFIG.AIRBORNE_GROUND_EPSILON then
                lastGroundTouch = os.clock()
            end
        end

        -- Snap vers le toit dans deux cas precis pour eviter les faux positifs en eau
        -- (ex: pont au-dessus de l'ocean snappait le vehicule et causait oscillation).
        -- Ne pas snapper sur le toit quand on est proche de la destination: laisser l'arrivee
        -- placer le vehicule precisement a l'endroit cible (pas sur le toit du batiment).
        if wallPassActive and not nearDestination then
            local roofParams = buildRaycastParams(vehicle)
            -- Cas 1: mur epais (GetPartBoundsInBox detecte un overlap)
            local shouldSnapToRoof = insideWall
            -- Cas 2: toit fin / haie traverse trop vite en 1 frame.
            -- Rayon court vers le haut: plafond juste au-dessus = on vient de le traverser.
            if not shouldSnapToRoof then
                local thinHit = workspace:Raycast(
                    Vector3.new(current.X, current.Y + currentHalfHeight + 0.1, current.Z),
                    Vector3.new(0, currentHalfHeight + 1, 0),
                    roofParams
                )
                if thinHit and thinHit.Instance and thinHit.Instance.CanCollide
                    and thinHit.Normal.Y <= -0.3 then
                    shouldSnapToRoof = true
                end
            end
            if shouldSnapToRoof then
                local roofOriginY = math.max(current.Y + CONFIG.GROUND_RAY_HEIGHT, 600)
                local roofHit = workspace:Raycast(
                    Vector3.new(current.X, roofOriginY, current.Z),
                    Vector3.new(0, -(roofOriginY + CONFIG.GROUND_RAY_LENGTH), 0),
                    roofParams
                )
                if isValidGroundHit(roofHit) then
                    local surfaceY = roofHit.Position.Y
                    local roofY = surfaceY + currentHalfHeight + CONFIG.GROUND_CLEARANCE
                    if surfaceY > current.Y + 0.1 and roofY > current.Y + CONFIG.UNDERMAP_DEPTH_TRIGGER then
                        pivotVehicleBy(vehicle, Vector3.new(0, roofY - current.Y, 0), true)
                        lastGroundTouch = os.clock()
                        lastKnownGroundY = roofY
                        stuckTime = 0
                        lastPos = nil
                        if statusLabel then
                            statusLabel.Text = "Toit: sortie mur"
                        end
                        RunService.Heartbeat:Wait()
                        continue
                    end
                end
            end
        end

        if current.Y <= (CONFIG.MIN_ALLOWED_Y + CONFIG.LOW_Y_RESCUE_MARGIN) then
            local rescueTargetY = math.max(targetPos.Y, CONFIG.MIN_ALLOWED_Y + CONFIG.LOW_Y_RESCUE_STEP)
            local rescueUp = math.max(0, math.min(CONFIG.LOW_Y_RESCUE_STEP, rescueTargetY - current.Y))
            if rescueUp > 0.05 then
                pivotVehicleBy(vehicle, Vector3.new(0, rescueUp, 0), true)
                -- Reset le timer pour eviter que MAX_AIRBORNE_TIME repousse immediatement vers le bas
                lastGroundTouch = os.clock()
                lastKnownGroundY = current.Y + rescueUp
                stuckTime = 0
                lastPos = nil
                if statusLabel then
                    statusLabel.Text = "Rescue bas Y"
                end
                RunService.Heartbeat:Wait()
                continue
            end
        end

        local groundRefY = lastKnownGroundY
        local maxAllowedY = groundRefY + CONFIG.MAX_VERTICAL_TRAVEL
        -- wallPassActive = on est sur un toit ou en transit -> ne pas forcer la descente
        if (not wallPassActive) and current.Y > (maxAllowedY + 2) then
            local snappedDown = placeVehicleOnGround(vehicle, current, current.Y)
            if snappedDown then
                -- Reset le timer apres correction de hauteur
                lastGroundTouch = os.clock()
                if statusLabel then
                    statusLabel.Text = "Securite hauteur: retour au sol"
                end
                RunService.Heartbeat:Wait()
                continue
            end
        end

        if (not wallPassActive) and (os.clock() - lastGroundTouch) > CONFIG.MAX_AIRBORNE_TIME then
            local resetDone = placeVehicleOnGround(vehicle, current, current.Y)
            if not resetDone then
                resetDone = enforceVehicleAboveGround(vehicle, true)
            end
            if not resetDone then
                local deepGround, deepFound = projectGroundForGuard(
                    current.X,
                    current.Z,
                    current.Y,
                    vehicle,
                    currentHalfHeight
                )
                if deepFound then
                    lastKnownGroundY = deepGround.Y
                    local yDelta = deepGround.Y - current.Y
                    -- Ne jamais pousser vers le bas via ce fallback (evite le cycle eau)
                    if yDelta > 0 then
                        pivotVehicleBy(vehicle, Vector3.new(0, yDelta, 0), true)
                    end
                    resetDone = true
                end
            end

            if resetDone then
                lastGroundTouch = os.clock()
                climbedBudgetUsed = 0
                stuckTime = 0
                lastPos = nil
                jumpCruiseY = nil
                if statusLabel then
                    statusLabel.Text = "Anti-fly: retour au sol rapide"
                end
                RunService.Heartbeat:Wait()
                continue
            end
        end

        local activeTargetPos = targetPos

        local halfHeight = getVehicleHalfHeight(vehicle)
        -- exactTargetY = arriver pile au Y specifie (destinations), sinon +1.25 pour joueur
        local targetYForPlayer = exactTargetY and targetPos.Y or (targetPos.Y + 1.25)
        local targetGround
        if preferTargetY then
            targetGround = Vector3.new(activeTargetPos.X, targetYForPlayer, activeTargetPos.Z)
        else
            targetGround = projectOnGround(
                activeTargetPos.X,
                activeTargetPos.Z,
                activeTargetPos.Y,
                vehicle,
                halfHeight,
                true
            )
        end
        -- En eau / zone basse: verrouille le Y cible au plancher minimum pour avancer
        -- a cette hauteur sans osciller entre Rescue bas Y et Securite hauteur.
        local waterCruiseY = CONFIG.MIN_ALLOWED_Y + CONFIG.LOW_Y_RESCUE_STEP
        if current.Y < waterCruiseY + 2 then
            targetGround = Vector3.new(
                targetGround.X,
                math.max(targetGround.Y, waterCruiseY),
                targetGround.Z
            )
        end

        if jumpMode then
            local baseY = math.max(current.Y, targetGround.Y)
            local wantedCruise = baseY + CONFIG.JUMP_MODE_CRUISE_HEIGHT
            jumpCruiseY = jumpCruiseY and math.max(jumpCruiseY, wantedCruise) or wantedCruise
        end

        local toTarget = targetGround - current
        local horizontal = Vector3.new(toTarget.X, 0, toTarget.Z)
        local distance = horizontal.Magnitude
        local finalDistance = (
            Vector3.new(targetPos.X, 0, targetPos.Z) - Vector3.new(current.X, 0, current.Z)
        ).Magnitude
        local verticalDistance = preferTargetY and math.abs(current.Y - targetYForPlayer) or 0

        -- Zone de descente pour exactTargetY: commencer a corriger le Y bien avant le snap final
        -- Evite de rester sur un grand toit jusqu'aux 7 dernieres unites
        if exactTargetY and not preferTargetY then
            local yDiff = current.Y - targetYForPlayer
            local descentRadius = math.max(CONFIG.NEAR_TARGET_SNAP_DISTANCE * 4, math.abs(yDiff) * 1.5)
            if finalDistance <= descentRadius and math.abs(yDiff) > 0.5 then
                local dropLimit = math.max(CONFIG.MAX_STEP_DROP, state.speed * 0.016 * 0.55)
                local climbLimit = math.max(2.2, CONFIG.MAX_STEP_RISE + 1.0)
                local correctedY
                if yDiff > 0 then
                    correctedY = math.max(targetYForPlayer, current.Y - dropLimit)
                else
                    correctedY = math.min(targetYForPlayer, current.Y + climbLimit)
                end
                local root2 = getVehicleRoot(vehicle)
                if root2 then
                    pivotVehicleBy(vehicle, Vector3.new(0, correctedY - current.Y, 0), true)
                    lastGroundTouch = os.clock()
                end
            end
        end

        if finalDistance <= CONFIG.NEAR_TARGET_SNAP_DISTANCE then
            snappedNearTarget = true
            local snapPos = nil
            if preferTargetY or exactTargetY then
                -- preferTargetY = joueur (Y+1.25), exactTargetY = destination (Y exact)
                snapPos = Vector3.new(targetPos.X, targetYForPlayer, targetPos.Z)
            else
                local projected, hasProjected = projectOnGround(
                    targetPos.X,
                    targetPos.Z,
                    targetPos.Y,
                    vehicle,
                    halfHeight,
                    true
                )
                if hasProjected then
                    snapPos = projected
                else
                    snapPos = Vector3.new(targetPos.X, current.Y, targetPos.Z)
                end
            end

            local snapOffset = snapPos - current
            if snapOffset.Magnitude > 0.01 then
                pivotVehicleBy(vehicle, snapOffset, true)
            end
            if wallPassActive then
                disableWallPass()
            end
            reached = true
            break
        end

        if finalDistance <= CONFIG.ARRIVAL_TOLERANCE and (not preferTargetY or verticalDistance <= 3.5) then
            reached = true
            break
        end

        local dt = RunService.Heartbeat:Wait()

        if insideWall then
            insidePhaseTime = insidePhaseTime + dt
            if insidePhaseTime >= CONFIG.PHASE_INSIDE_MAX_TIME and distance > CONFIG.ARRIVAL_TOLERANCE then
                insidePhaseTime = 0
                lastGroundTouch = os.clock()
                stuckTime = 0
                lastPos = nil
                if exactTargetY then
                    -- Destination TP: snap instantane sur le toit
                    enforceVehicleAboveGround(vehicle, true)
                    if statusLabel then
                        statusLabel.Text = "Securite: sortie mur"
                    end
                else
                    if statusLabel then
                        statusLabel.Text = "Phase: navigation interieur"
                    end
                end
            end
        else
            insidePhaseTime = 0
        end

        if lastPos then
            local moved = (current - lastPos).Magnitude
            if moved < CONFIG.STUCK_MIN_MOVE then
                stuckTime = stuckTime + dt
            else
                stuckTime = 0
            end
        end

        if stuckTime >= CONFIG.STUCK_NUDGE_TIMEOUT and distance > CONFIG.ARRIVAL_TOLERANCE then
            local nudgeDir = horizontal.Magnitude > 0.001 and horizontal.Unit or nil
            if nudgeDir then
                if wallPass and (not wallPassActive) and os.clock() >= wallPassRetryAt then
                    burstWallPass(CONFIG.WALL_PASS_RETRY_BURST)
                    wallPassRetryAt = os.clock() + CONFIG.WALL_PASS_RETRY_COOLDOWN
                end

                local nudgeStep = math.min(CONFIG.STUCK_NUDGE_DISTANCE, distance)
                local nudgeXZ = current + (nudgeDir * nudgeStep)
                local nudgePos = Vector3.new(nudgeXZ.X, current.Y, nudgeXZ.Z)

                if not preferTargetY then
                    local nudgeGround, nudgeFound = projectOnGround(
                        nudgeXZ.X,
                        nudgeXZ.Z,
                        current.Y,
                        vehicle,
                        halfHeight,
                        false
                    )
                    if nudgeFound then
                        nudgePos = Vector3.new(nudgeXZ.X, nudgeGround.Y, nudgeXZ.Z)
                    end
                end

                pivotVehicleBy(vehicle, (nudgePos - current), true)
                enforceVehicleAboveGround(vehicle)
                stuckTime = 0
                lastPos = nil

                if statusLabel then
                    statusLabel.Text = "Micro debloquage: +5 studs"
                end
                RunService.Heartbeat:Wait()
                continue
            end
        end

        if stuckTime >= CONFIG.STUCK_TIMEOUT then
            if wallPass and (not wallPassActive) and os.clock() >= wallPassRetryAt then
                burstWallPass(CONFIG.WALL_PASS_RETRY_BURST)
                wallPassRetryAt = os.clock() + CONFIG.WALL_PASS_RETRY_COOLDOWN
                stuckTime = 0
                if statusLabel then
                    statusLabel.Text = "Deblocage phase..."
                end
                RunService.Heartbeat:Wait()
                continue
            end

            -- Avec wallPassActive: pas de budget ni de plafond -> monter sans limite vers le toit.
            -- Cela debloquer les clotures / haies ou le vehicule reste coince malgre le noClip.
            local available, climbCap
            if wallPassActive then
                available = activeStuckBoost * 2
                climbCap = math.huge
            else
                available = activeAutoClimbMax - climbedBudgetUsed
                if available <= 0.1 then available = 0 end
                climbCap = maxAllowedY
            end

            local climb = math.clamp(
                math.max(activeAutoClimbStep, activeStuckBoost),
                0,
                math.max(available, 0)
            )
            climb = math.max(0, math.min(climb, climbCap - current.Y))

            if climb > 0.1 then
                pivotVehicleBy(vehicle, Vector3.new(0, climb, 0), true)
                enforceVehicleAboveGround(vehicle)
                climbedBudgetUsed = climbedBudgetUsed + climb
                stuckTime = 0
                lastPos = nil
                if statusLabel then
                    statusLabel.Text = "Bloque 3s, montee forcee..."
                end
                RunService.Heartbeat:Wait()
                continue
            end
        end

        local direction = horizontal.Unit
        local step = math.clamp(activeSpeed * dt, 0.4, activeStepMax)
        step = math.min(step, distance)

        local blocked, hit = false, nil
        if not wallPassActive then
            blocked, hit = hasObstacleAhead(vehicle, current, direction, step)
        end
        if blocked then
            if wallPass and os.clock() >= wallPassRetryAt then
                burstWallPass(CONFIG.WALL_PASS_RETRY_BURST)
                wallPassRetryAt = os.clock() + CONFIG.WALL_PASS_RETRY_COOLDOWN
                local passStep = math.min(CONFIG.STUCK_NUDGE_DISTANCE, distance)
                if passStep > 0.01 then
                    local passPos = current + (direction * passStep)
                    pivotVehicleBy(vehicle, passPos - current, true)
                    enforceVehicleAboveGround(vehicle)
                    lastPos = nil
                end
                if statusLabel then
                    statusLabel.Text = "Obstacle: phase"
                end
                RunService.Heartbeat:Wait()
                continue
            end

            blockedCycles = blockedCycles + 1
            if blockedCycles >= CONFIG.BLOCKED_CYCLE_ABORT then
                blockedBy = "obstacle persistant"
                break
            end

            if jumpMode then
                local jumpUp = math.max(CONFIG.JUMP_BURST_UP, activeAutoClimbStep)
                jumpUp = math.max(0, math.min(jumpUp, maxAllowedY - current.Y))
                if jumpUp <= 0.1 then
                    blockedBy = "obstacle en hauteur"
                    break
                end
                pivotVehicleBy(vehicle, Vector3.new(0, jumpUp, 0), true)
                enforceVehicleAboveGround(vehicle)
                jumpCruiseY = math.max(jumpCruiseY or (current.Y + jumpUp), current.Y + jumpUp)
                stuckTime = 0
                lastPos = nil
                if statusLabel then
                    statusLabel.Text = "SAUT obstacle..."
                end
                RunService.Heartbeat:Wait()
                continue
            end

            local wantedClimb = activeAutoClimbStep
            if hit then
                local wantedY = hit.Position.Y + halfHeight + CONFIG.AUTO_CLIMB_CLEARANCE
                wantedClimb = math.max(wantedClimb, wantedY - current.Y)
            end

            local available = activeAutoClimbMax - climbedBudgetUsed
            if available <= 0.1 then
                available = 0
            end
            local climb = math.clamp(wantedClimb, 0, math.max(available, 0))
            climb = math.max(0, math.min(climb, maxAllowedY - current.Y))

            if climb > 0.1 then
                pivotVehicleBy(vehicle, Vector3.new(0, climb, 0), true)
                enforceVehicleAboveGround(vehicle)
                climbedBudgetUsed = climbedBudgetUsed + climb
                lastPos = nil
                if statusLabel then
                    statusLabel.Text = "Obstacle detecte, montee..."
                end
                RunService.Heartbeat:Wait()
                continue
            end

            local side = Vector3.new(-direction.Z, 0, direction.X)
            if side.Magnitude < 0.001 then
                side = Vector3.new(1, 0, 0)
            else
                side = side.Unit
            end

            if math.floor(os.clock() * 10) % 2 == 0 then
                side = -side
            end

            local usedRecoveryUp = activeRecoveryUp
            local recoveryOffset = side * activeRecoverySide + Vector3.new(0, activeRecoveryUp, 0)
            if activeRecoveryUp > 0 then
                local safeUp = math.max(0, math.min(activeRecoveryUp, maxAllowedY - current.Y))
                usedRecoveryUp = safeUp
                recoveryOffset = side * activeRecoverySide + Vector3.new(0, safeUp, 0)
            end
            pivotVehicleBy(vehicle, recoveryOffset, true)
            enforceVehicleAboveGround(vehicle)
            climbedBudgetUsed = climbedBudgetUsed + usedRecoveryUp
            stuckTime = 0
            lastPos = nil
            if statusLabel then
                statusLabel.Text = "Obstacle, contournement..."
            end
            RunService.Heartbeat:Wait()
            continue
        end

        blockedCycles = 0

        local nextXZ = current + direction * step
        local groundPreferenceY = current.Y
        local nextPos
        local hasGround = false

        if jumpMode then
            local nearTarget = distance <= CONFIG.JUMP_DESCEND_DISTANCE
            if not nearTarget then
                local rise = CONFIG.JUMP_ASCEND_RATE * dt
                local targetY = jumpCruiseY or current.Y
                local y = current.Y < targetY and math.min(targetY, current.Y + rise) or current.Y
                nextPos = Vector3.new(nextXZ.X, y, nextXZ.Z)
            else
                local nextGround, groundFound = projectOnGround(
                    nextXZ.X,
                    nextXZ.Z,
                    groundPreferenceY,
                    vehicle,
                    halfHeight,
                    true
                )
                hasGround = groundFound
                local y = current.Y
                if groundFound then
                    y = current.Y > nextGround.Y
                        and math.max(nextGround.Y, current.Y - (CONFIG.JUMP_DESCEND_RATE * dt))
                        or nextGround.Y
                end
                nextPos = Vector3.new(nextXZ.X, y, nextXZ.Z)
            end
        elseif preferTargetY then
            -- preferTargetY: suivre le Y de la cible directement
            local climbLimit = math.max(2.2, CONFIG.MAX_STEP_RISE + 1.0)
            local dropLimit = math.max(CONFIG.MAX_STEP_DROP, activeSpeed * dt * 0.55)
            local y = current.Y
            if current.Y < targetYForPlayer then
                y = math.min(targetYForPlayer, current.Y + climbLimit)
            else
                y = math.max(targetYForPlayer, current.Y - dropLimit)
            end
            hasGround = true
            nextPos = Vector3.new(nextXZ.X, y, nextXZ.Z)
        elseif insideWall then
            -- Dans un batiment: monter agressivement vers le toit.
            -- Le snap de toit (lignes 1100-1141) place le vehicule precisement sur le toit via continue,
            -- ce code ne s'execute donc que si le snap a echoue: on continue a monter.
            local riseStep = math.max(activeAutoClimbStep, activeSpeed * dt * 0.5)
            hasGround = true
            nextPos = Vector3.new(nextXZ.X, current.Y + riseStep, nextXZ.Z)
        else
            local nextGround, groundFound = projectOnGround(
                nextXZ.X,
                nextXZ.Z,
                groundPreferenceY,
                vehicle,
                halfHeight,
                false
            )
            if not groundFound then
                local guardGround, guardFound = projectGroundForGuard(
                    nextXZ.X,
                    nextXZ.Z,
                    current.Y,
                    vehicle,
                    halfHeight
                )
                if guardFound then
                    groundFound = true
                    local maxDrop = math.max(CONFIG.MAX_STEP_DROP, CONFIG.JUMP_DESCEND_RATE * dt)
                    local descentY = current.Y > guardGround.Y
                        and math.max(guardGround.Y, current.Y - maxDrop)
                        or guardGround.Y
                    nextGround = Vector3.new(nextXZ.X, descentY, nextXZ.Z)
                end
            end
            hasGround = groundFound
            if groundFound then
                -- Limiter la chute par step pour eviter les sauts au bord des toits/falaises.
                -- Si le prochain sol est bien en dessous, on descend progressivement.
                local maxDropThisStep = math.max(CONFIG.MAX_STEP_DROP, activeSpeed * dt * 0.6)
                local limitedY = math.max(nextGround.Y, current.Y - maxDropThisStep)
                nextPos = Vector3.new(nextXZ.X, limitedY, nextXZ.Z)
            else
                -- No reliable ground at this step: keep altitude so movement does not sink/freeze underwater.
                nextPos = Vector3.new(nextXZ.X, current.Y, nextXZ.Z)
            end
        end

        pivotVehicleBy(vehicle, (nextPos - current), true)
        -- Skip ground correction quand on navigue a l'interieur d'un batiment
        if not insideWall then
            enforceVehicleAboveGround(vehicle)
        end

        if hasGround and nextPos.Y < current.Y then
            climbedBudgetUsed = math.max(0, climbedBudgetUsed - (current.Y - nextPos.Y))
        end

        lastPos = nextPos
    end

    state.isTPing = false

    if wallPassActive then
        disableWallPass()
    end

    local finalVehicle = findVehicle()
    if wallPass then
        restoreCollisionFromCache(tpCollisionCache)
        if tpCharCollisionCache then
            restoreCollisionFromCache(tpCharCollisionCache)
        end
        if tpPassengerCollisionCache then
            restoreCollisionFromCache(tpPassengerCollisionCache)
        end
    end
    if finalVehicle then
        local finalRoot = getVehicleRoot(finalVehicle)
        local targetYForPlayer = targetPos.Y + 1.25
        if preferTargetY and finalRoot then
            local aimed = Vector3.new(targetPos.X, targetYForPlayer, targetPos.Z)
            pivotVehicleBy(finalVehicle, aimed - finalRoot.Position, true)
            forceVehicleUnstuck(finalVehicle, aimed, targetYForPlayer)
            enforceVehicleAboveGround(finalVehicle)
            if snappedNearTarget and (not isVehicleInsideWall(finalVehicle)) then
                local lockRoot = getVehicleRoot(finalVehicle)
                if lockRoot then
                    local exact = Vector3.new(targetPos.X, targetYForPlayer, targetPos.Z)
                    local lockOffset = exact - lockRoot.Position
                    if lockOffset.Magnitude > 0.05 then
                        pivotVehicleBy(finalVehicle, lockOffset, true)
                    end
                end
            end
        else
            local finalPreferredY = targetPos.Y
            if reached then
                placeVehicleOnGround(finalVehicle, targetPos, finalPreferredY)
            else
                placeVehicleOnGround(finalVehicle)
            end
            forceVehicleUnstuck(finalVehicle, targetPos, finalPreferredY)
            if snappedNearTarget and (not isVehicleInsideWall(finalVehicle)) then
                placeVehicleOnGround(finalVehicle, targetPos, finalPreferredY)
            end
            if isVehicleInsideWall(finalVehicle) then
                enforceVehicleAboveGround(finalVehicle, true)
            end
        end
    end

    if statusLabel then
        if reached then
            statusLabel.Text = "Arrive au sol"
        elseif blockedBy then
            statusLabel.Text = "Stop (mur): " .. blockedBy
        else
            statusLabel.Text = t("status_cancel")
        end
    end

    return reached
end

local function getCurrentSavePosition()
    local character = player.Character
    if character then
        local upperTorso = character:FindFirstChild("UpperTorso")
        if upperTorso and upperTorso:IsA("BasePart") then
            return upperTorso.Position, "torso"
        end

        local torso = character:FindFirstChild("Torso")
        if torso and torso:IsA("BasePart") then
            return torso.Position, "torso"
        end
    end

    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if hrp then
        return hrp.Position, "root"
    end

    local vehicle = findVehicle()
    local root = vehicle and getVehicleRoot(vehicle)
    if root then
        return root.Position, "vehicule"
    end

    return nil, nil
end

local function getPlayerRoleLabel(plr)
    if not plr then
        return "?"
    end

    local function readRoleFrom(container)
        if not container then
            return nil
        end

        local keys = { "Role", "Job", "Metier", "Faction", "Rank", "Grade" }
        for _, key in ipairs(keys) do
            local v = container:FindFirstChild(key)
            if v and v:IsA("StringValue") and v.Value ~= "" then
                return v.Value
            end
        end
        return nil
    end

    local attrKeys = { "Role", "Job", "Metier", "Faction", "Rank", "Grade" }
    for _, key in ipairs(attrKeys) do
        local a = plr:GetAttribute(key)
        if typeof(a) == "string" and a ~= "" then
            return a
        end
    end

    local fromPlayer = readRoleFrom(plr)
    if fromPlayer then
        return fromPlayer
    end

    local leaderstats = plr:FindFirstChild("leaderstats")
    local fromLeaderstats = readRoleFrom(leaderstats)
    if fromLeaderstats then
        return fromLeaderstats
    end

    if plr.Team and plr.Team.Name ~= "" then
        return plr.Team.Name
    end

    return "Aucun role"
end

local function findWaypointById(id)
    if not id then
        return nil, nil
    end

    for index, waypoint in ipairs(state.waypoints) do
        if waypoint.id == id then
            return index, waypoint
        end
    end

    return nil, nil
end

local function removeWaypointById(id)
    local index = findWaypointById(id)
    if index then
        table.remove(state.waypoints, index)
        return true
    end

    return false
end

local function clearWaypointMarker()
    if state.waypointMarker then
        state.waypointMarker:Destroy()
        state.waypointMarker = nil
    end
end

local function setWaypointMarker(waypoint)
    if not waypoint or not waypoint.pos then
        clearWaypointMarker()
        return
    end

    local marker = state.waypointMarker
    if not marker or not marker.Parent then
        marker = Instance.new("Part")
        marker.Name = "ELIX_WaypointMarker"
        marker.Anchored = true
        marker.CanCollide = false
        marker.CanQuery = false
        marker.CanTouch = false
        marker.Material = Enum.Material.Neon
        marker.Color = Color3.fromRGB(0, 200, 255)
        marker.Transparency = 0.35
        marker.Size = Vector3.new(1.5, 1.5, 1.5)
        marker.Parent = workspace

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "Tag"
        billboard.Size = UDim2.new(0, 200, 0, 44)
        billboard.StudsOffset = Vector3.new(0, 1.8, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = marker

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(0, 225, 255)
        label.TextStrokeTransparency = 0.15
        label.TextSize = 16
        label.Font = Enum.Font.GothamBold
        label.Text = "WAYPOINT"
        label.Parent = billboard

        state.waypointMarker = marker
    end

    marker.Position = waypoint.pos + Vector3.new(0, 2.5, 0)
    local billboard = marker:FindFirstChild("Tag")
    if billboard and billboard:IsA("BillboardGui") then
        local text = billboard:FindFirstChild("Text")
        if text and text:IsA("TextLabel") then
            text.Text = waypoint.name
        end
    end
end


local policeSirens = {}  -- { [player] = Sound }  (declare ici pour destroyTeleportUI)

local function destroyTeleportUI()
    state.isTPing = false
    state.followEnabled = false
    state.followTarget = nil
    state.mirrorEnabled = false
    state.mirrorTargetPart = nil
    state.mirrorLastCFrame = nil
    state.selectedWaypointId = nil
    stopTrollNoClipAndResolve()
    clearWaypointMarker()

    -- Couper sons poneys
    if state.horsePonies then
        for _, entry in ipairs(state.horsePonies) do
            if entry.sound and entry.sound.Parent then
                entry.sound:Stop()
            end
        end
    end

    -- Couper sirenes police
    if policeSirens then
        for _, snd in pairs(policeSirens) do
            if snd and snd.Parent then
                snd:Stop()
            end
        end
    end

    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        local main = playerGui:FindFirstChild("VehicleTPUI")
        if main then
            main:Destroy()
        end

        local open = playerGui:FindFirstChild("VehicleTP_Open")
        if open then
            open:Destroy()
        end
    end

    state.mainGui = nil
    state.openGui = nil
end

local function createRounded(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
    return corner
end

local function createDragBehavior(frame)
    local dragging = false
    local dragStart
    local startPos

    frame.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function createSpeedSlider(parent, onChanged)
    local row = Instance.new("Frame")
    row.Name = "SpeedRow"
    row.Size = UDim2.new(1, -20, 0, 54)
    row.Position = UDim2.new(0, 10, 0, 46)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 110, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 245, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Text = "Vitesse"
    label.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 120, 1, 0)
    valueLabel.Position = UDim2.new(1, -120, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(120, 255, 190)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = ""
    valueLabel.Parent = row

    local sliderBack = Instance.new("Frame")
    sliderBack.Size = UDim2.new(1, -250, 0, 10)
    sliderBack.Position = UDim2.new(0, 120, 0.5, -5)
    sliderBack.BackgroundColor3 = Color3.fromRGB(38, 55, 80)
    sliderBack.BorderSizePixel = 0
    sliderBack.Parent = row
    createRounded(sliderBack, 10)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 230)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBack
    createRounded(sliderFill, 10)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(230, 245, 255)
    knob.BorderSizePixel = 0
    knob.Parent = sliderBack
    createRounded(knob, 16)

    local dragging = false

    local function setByRatio(rawRatio)
        local ratio = math.clamp(rawRatio, 0, 1)
        local speed = math.floor(CONFIG.MIN_SPEED + (CONFIG.MAX_SPEED - CONFIG.MIN_SPEED) * ratio + 0.5)
        state.speed = speed

        sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, 0, 0.5, 0)
        valueLabel.Text = tostring(speed) .. " studs/s"

        if onChanged then
            onChanged(speed)
        end
    end

    local function setByInputX(x)
        local left = sliderBack.AbsolutePosition.X
        local width = sliderBack.AbsoluteSize.X
        if width <= 0 then
            return
        end
        setByRatio((x - left) / width)
    end

    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setByInputX(input.Position.X)
        end
    end)

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setByInputX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setByInputX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local initialRatio = (state.speed - CONFIG.MIN_SPEED) / (CONFIG.MAX_SPEED - CONFIG.MIN_SPEED)
    setByRatio(initialRatio)
end

local function removeVehiclePing(veh)
    local entry = state.vehiclePings[veh]
    if not entry then return end
    if entry.conn then entry.conn:Disconnect() end
    if entry.billboard and entry.billboard.Parent then
        entry.billboard:Destroy()
    end
    state.vehiclePings[veh] = nil
end

local function createVehiclePing(veh)
    if state.vehiclePings[veh] then return end
    local root = veh:IsA("Model") and (veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")) or veh
    if not root then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "VehiclePing"
    bb.Size = UDim2.new(0, 190, 0, 54)
    bb.StudsOffset = Vector3.new(0, 5, 0)
    bb.AlwaysOnTop = true
    bb.ResetOnSpawn = false
    bb.Adornee = root
    bb.Parent = root

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(8, 14, 22)
    bg.BackgroundTransparency = 0.25
    bg.BorderSizePixel = 0
    bg.Parent = bb
    createRounded(bg, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 210, 120)
    stroke.Thickness = 2
    stroke.Parent = bg

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -8, 0, 26)
    nameLbl.Position = UDim2.new(0, 6, 0, 2)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextColor3 = Color3.fromRGB(200, 245, 215)
    nameLbl.TextSize = 12
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.Text = "📍 " .. veh.Name
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = bg

    local distLbl = Instance.new("TextLabel")
    distLbl.Size = UDim2.new(1, -8, 0, 20)
    distLbl.Position = UDim2.new(0, 6, 0, 30)
    distLbl.BackgroundTransparency = 1
    distLbl.TextColor3 = Color3.fromRGB(120, 255, 190)
    distLbl.TextSize = 11
    distLbl.Font = Enum.Font.Gotham
    distLbl.Text = "-- studs"
    distLbl.TextXAlignment = Enum.TextXAlignment.Left
    distLbl.Parent = bg

    local removeConn = veh.AncestryChanged:Connect(function()
        if not veh.Parent then
            removeVehiclePing(veh)
        end
    end)

    state.vehiclePings[veh] = { billboard = bb, distLabel = distLbl, conn = removeConn }
end

-- Boucle mise a jour distance des pings
task.spawn(function()
    while true do
        task.wait(0.15)
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        for veh, entry in pairs(state.vehiclePings) do
            if not veh.Parent then
                removeVehiclePing(veh)
                continue
            end
            if not hrp then continue end
            local root = veh:IsA("Model") and (veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")) or veh
            if not root then continue end
            local dist = (root.Position - hrp.Position).Magnitude
            local distColor = dist < 60
                and Color3.fromRGB(80, 255, 160)
                or dist < 200 and Color3.fromRGB(255, 200, 50)
                or Color3.fromRGB(220, 80, 80)
            entry.distLabel.Text = string.format("%.1f studs", dist)
            entry.distLabel.TextColor3 = distColor
            -- Mise a jour label sur le bouton revendeur si present
            if entry.btnDistLabel and entry.btnDistLabel.Parent then
                entry.btnDistLabel.Text = string.format("📍 %.0f studs", dist)
                entry.btnDistLabel.TextColor3 = distColor
            end
        end
    end
end)

-- ===== PONEYS SUR LE TOIT =====
-- Sons : neigh bizarre (proximity) + sirene police
local PONY_WEIRD_SOUND   = "rbxassetid://130973511966646"
local POLICE_SIREN_SOUND = "rbxassetid://106711182836568"

-- 1 poney par vehicule, 4 studs au dessus (espace local)
local PONY_ROOF_OFFSET = CFrame.new(0, 8, 0)

-- Couleurs variées pour les poneys
local PONY_COLORS = {
    { body = Color3.fromRGB(255, 182, 193), mane = Color3.fromRGB(255, 105, 180) }, -- rose
    { body = Color3.fromRGB(180, 120, 220), mane = Color3.fromRGB(100, 50, 180) },  -- violet
    { body = Color3.fromRGB(100, 200, 120), mane = Color3.fromRGB(30, 140, 60) },   -- vert
    { body = Color3.fromRGB(255, 220, 80),  mane = Color3.fromRGB(220, 140, 0) },   -- jaune
    { body = Color3.fromRGB(80, 180, 240),  mane = Color3.fromRGB(20, 100, 200) },  -- bleu
}

local function buildPonyModel(colorSet, withSound)
    local horseColor = colorSet.body
    local maneColor  = colorSet.mane

    local model = Instance.new("Model")
    model.Name = "PoneySuiveur"

    local function makePart(sx, sy, sz, ox, oy, oz, col)
        local p = Instance.new("Part")
        p.Size = Vector3.new(sx, sy, sz)
        p.CFrame = CFrame.new(ox, oy, oz)
        p.Color = col or horseColor
        p.Material = Enum.Material.SmoothPlastic
        p.CanCollide = false
        p.Anchored = true
        p.CastShadow = false
        p.Parent = model
        return p
    end

    local body = makePart(2.4, 1.8, 5, 0, 0, 0)
    model.PrimaryPart = body

    local neck = makePart(1, 2, 1, 0, 1.4, 2.1)
    neck.CFrame = CFrame.new(0, 1.4, 2.1) * CFrame.Angles(math.rad(-28), 0, 0)

    makePart(1, 1, 2, 0, 2.5, 3.2)
    makePart(1, 0.5, 0.7, 0, 1.9, 4.0)
    makePart(0.25, 0.65, 0.25, -0.32, 3.1, 3.05, maneColor)
    makePart(0.25, 0.65, 0.25,  0.32, 3.1, 3.05, maneColor)
    makePart(0.3, 1.6, 0.3, 0, 2.4, 2.4, maneColor)
    makePart(0.55, 2.4, 0.55, -0.85, -2.0,  1.8)
    makePart(0.55, 2.4, 0.55,  0.85, -2.0,  1.8)
    makePart(0.55, 2.4, 0.55, -0.85, -2.0, -1.8)
    makePart(0.55, 2.4, 0.55,  0.85, -2.0, -1.8)
    makePart(0.65, 0.5, 0.65, -0.85, -3.45,  1.8, maneColor)
    makePart(0.65, 0.5, 0.65,  0.85, -3.45,  1.8, maneColor)
    makePart(0.65, 0.5, 0.65, -0.85, -3.45, -1.8, maneColor)
    makePart(0.65, 0.5, 0.65,  0.85, -3.45, -1.8, maneColor)
    local tail = makePart(0.5, 2.4, 0.5, 0, -0.3, -2.9, maneColor)
    tail.CFrame = CFrame.new(0, -0.3, -2.9) * CFrame.Angles(math.rad(38), 0, 0)

    -- Son bizarre de proximite sur chaque poney
    if withSound then
        local snd = Instance.new("Sound")
        snd.Name = "PoneySound"
        snd.SoundId = PONY_WEIRD_SOUND
        snd.Looped = false
        snd.Volume = 2
        snd.RollOffMode = Enum.RollOffMode.Linear
        snd.RollOffMinDistance = 5
        snd.RollOffMaxDistance = 45
        snd.Parent = body
        -- Relance automatique quand le son se termine (boucle naturelle)
        snd.Ended:Connect(function()
            if snd.Parent and state.poneySoundEnabled then
                snd:Play()
            end
        end)
        if state.poneySoundEnabled then
            snd:Play()
        end
    end

    return model
end

local horseVehicleAddedConn = nil

local function spawnPoniesOnVehicle(veh)
    if not state.horsePonies then return end
    local root = veh:IsA("Model") and (veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart"))
              or (veh:IsA("BasePart") and veh)
    if not root then return end
    -- 1 seul poney par vehicule, couleur aleatoire
    local col = PONY_COLORS[math.random(1, #PONY_COLORS)]
    local pony = buildPonyModel(col, true)
    pony.Parent = workspace
    local snd = pony.PrimaryPart and pony.PrimaryPart:FindFirstChild("PoneySound")
    table.insert(state.horsePonies, { model = pony, root = root, sound = snd, angle = 0 })
end

local function createHorse()
    if state.horseModel then return end
    state.horseModel = true
    state.horsePonies = {}

    local vehiclesFolder = workspace:FindFirstChild("Vehicles")
    if vehiclesFolder then
        for _, veh in ipairs(vehiclesFolder:GetChildren()) do
            spawnPoniesOnVehicle(veh)
        end
        -- Nouveaux vehicules ajoutés pendant que le mode est actif
        horseVehicleAddedConn = vehiclesFolder.ChildAdded:Connect(function(veh)
            if state.horseEnabled and state.horsePonies then
                spawnPoniesOnVehicle(veh)
            end
        end)
    end
end

local function destroyHorse()
    if horseVehicleAddedConn then
        horseVehicleAddedConn:Disconnect()
        horseVehicleAddedConn = nil
    end
    if state.horsePonies then
        for _, entry in ipairs(state.horsePonies) do
            if entry.model and entry.model.Parent then
                entry.model:Destroy()
            end
        end
        state.horsePonies = nil
    end
    state.horseModel = nil
end

local function updateHorse(dt)
    if not state.horseEnabled or not state.horseModel then return end
    if not state.horsePonies then return end
    local spinSpeed = math.rad(120)  -- 120 deg/s
    for i = #state.horsePonies, 1, -1 do
        local entry = state.horsePonies[i]
        if not entry.root or not entry.root.Parent or not entry.root:IsDescendantOf(workspace) then
            if entry.model and entry.model.Parent then entry.model:Destroy() end
            table.remove(state.horsePonies, i)
        else
            if entry.model and entry.model.Parent then
                entry.angle = (entry.angle + spinSpeed * dt) % (math.pi * 2)
                local cf = entry.root.CFrame * PONY_ROOF_OFFSET * CFrame.Angles(0, entry.angle, 0)
                entry.model:PivotTo(cf)
            end
        end
    end
end

local function refreshPoneySounds()
    if not state.horsePonies then return end
    for _, entry in ipairs(state.horsePonies) do
        if entry.sound and entry.sound.Parent then
            if state.poneySoundEnabled then
                if not entry.sound.IsPlaying then entry.sound:Play() end
            else
                entry.sound:Stop()
            end
        end
    end
end

-- ===== SIMULATION VEHICULE (IsOn = false) =====
local vehSimData = {}   -- { [veh] = { wheelAngle = 0, baseSuspY = nil } }
local vehAirTime = {}   -- { [veh] = secondes en l'air }

local function updateVehicleSim(dt)
    if not state.vehSimEnabled then return end
    local vehiclesFolder = workspace:FindFirstChild("Vehicles")
    if not vehiclesFolder then return end

    -- Nettoyer entrees de vehicules detruits
    for veh in pairs(vehSimData) do
        if not veh.Parent then vehSimData[veh] = nil vehAirTime[veh] = nil end
    end

    for _, veh in ipairs(vehiclesFolder:GetChildren()) do
        if not veh:IsA("Model") then continue end
        local isOn = veh:GetAttribute("IsOn")
        if isOn then continue end  -- le jeu gere, on skip

        local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
        if not root or not root:IsDescendantOf(workspace) then continue end

        local vel = root.AssemblyLinearVelocity
        local speed = vel.Magnitude
        local forwardSpeed = root.CFrame.LookVector:Dot(vel)
        local angVel = root.AssemblyAngularVelocity

        -- Controle W/S/A/D pour le vehicule du joueur local
        local playerInThisVeh = isLocalPlayerSeatedInVehicle(veh)
        if playerInThisVeh then
            local wDown = UserInputService:IsKeyDown(state.simFwdKey)
            local sDown = UserInputService:IsKeyDown(state.simRevKey)
            local aDown = UserInputService:IsKeyDown(Enum.KeyCode.A)
            local dDown = UserInputService:IsKeyDown(Enum.KeyCode.D)
            local SIM_ACCEL   = state.simAccel
            local SIM_BRAKE   = 25
            local SIM_MAX_FWD = state.simMaxFwd
            local SIM_MAX_REV = state.simMaxRev
            local SIM_TURN    = 1.4  -- vitesse rotation (rad/s)

            -- Detection vol : si vel.Y depasse ce que la pente exige depuis plus de 0.3s → couper mouvement
            local expectedSlopeY = root.CFrame.LookVector.Y * math.abs(forwardSpeed)
            if vel.Y > expectedSlopeY + 5 then
                vehAirTime[veh] = (vehAirTime[veh] or 0) + dt
            else
                vehAirTime[veh] = 0
            end
            local isAirborne = (vehAirTime[veh] or 0) >= 0.3

            -- Vitesse avant/arriere
            local newFwd
            if isAirborne then
                -- En l'air depuis 0.3s : freinage forcé, plus d'acceleration
                newFwd = forwardSpeed * math.max(0, 1 - 8 * dt)
                if math.abs(newFwd) < 0.3 then newFwd = 0 end
            elseif wDown and not sDown then
                newFwd = math.min(forwardSpeed + SIM_ACCEL * dt, SIM_MAX_FWD)
            elseif sDown and not wDown then
                newFwd = math.max(forwardSpeed - SIM_BRAKE * dt, -SIM_MAX_REV)
            else
                newFwd = forwardSpeed * math.max(0, 1 - 4 * dt)
                if math.abs(newFwd) < 0.3 then newFwd = 0 end
            end
            -- Cap vel.Y
            local safeY = math.clamp(vel.Y, -200, 1.5)
            root.AssemblyLinearVelocity = root.CFrame.LookVector * newFwd + Vector3.new(0, safeY, 0)

            -- Rotation A/D (sens inverse en marche arriere)
            local turnInput = (dDown and 1 or 0) - (aDown and 1 or 0)
            local speedFactor = math.clamp(math.abs(newFwd) / 10, 0, 1)
            local reverseSign = newFwd < 0 and -1 or 1
            local targetAngY = -turnInput * SIM_TURN * speedFactor * reverseSign
            root.AssemblyAngularVelocity = Vector3.new(0, targetAngY, 0)

            -- Attributs visuels
            pcall(function() veh:SetAttribute("Throttle", math.clamp(newFwd / 30, -1, 1)) end)
            pcall(function() veh:SetAttribute("Steering", turnInput) end)
        else
            -- Autre vehicule sans conducteur : maintenir la vitesse (contrer friction)
            root.AssemblyLinearVelocity = vel
            pcall(function() veh:SetAttribute("Throttle", math.clamp(forwardSpeed / 30, -1, 1)) end)
            pcall(function() veh:SetAttribute("Steering", math.clamp(-angVel.Y / 1.5, -1, 1)) end)
        end

        -- Init data par vehicule
        if not vehSimData[veh] then
            local baseSusp = veh:GetAttribute("SuspensionOffset")
            vehSimData[veh] = {
                wheelAngle = 0,
                baseSuspY  = baseSusp and baseSusp.Y or nil,
            }
        end
        local data = vehSimData[veh]

        -- Rotation des roues via Motor6D
        local wheelsFolder = veh:FindFirstChild("Wheels", true)
        if wheelsFolder and speed > 0.1 then
            local radius = 1.0
            local firstPart = wheelsFolder:FindFirstChildWhichIsA("BasePart")
            if firstPart then
                radius = math.clamp(math.max(firstPart.Size.Y, firstPart.Size.Z) * 0.5, 0.3, 3.0)
            end
            local rotDelta = (forwardSpeed / radius) * dt
            data.wheelAngle = data.wheelAngle + rotDelta
            for _, motor in ipairs(wheelsFolder:GetDescendants()) do
                if motor:IsA("Motor6D") then
                    motor.DesiredAngle = data.wheelAngle
                    motor.CurrentAngle = data.wheelAngle
                end
            end
        end

        -- Rebond suspension selon vitesse
        if data.baseSuspY and speed > 0.5 then
            local bounce = math.sin(tick() * 10) * math.clamp(speed / 200, 0, 0.06)
            local baseSusp = veh:GetAttribute("SuspensionOffset")
            if baseSusp then
                pcall(function()
                    veh:SetAttribute("SuspensionOffset", Vector3.new(baseSusp.X, data.baseSuspY + bounce, baseSusp.Z))
                end)
            end
        end
    end
end

-- ===== SIRENE POLICE (sur le joueur avec role police) =====
local function isPoliceRole(roleLabel)
    return roleLabel:lower():find("police") ~= nil
end

-- policeSirens est declare plus haut, avant destroyTeleportUI

local function refreshPoliceSounds()
    for _, snd in pairs(policeSirens) do
        if snd and snd.Parent then
            if state.policeSoundEnabled then
                snd.Volume = 1
                if not snd.IsPlaying then snd:Play() end
            else
                snd.Volume = 0
                snd:Stop()
            end
        end
    end
end

local function attachPoliceSirenToPlayer(plr)
    if policeSirens[plr] then return end
    local role = getPlayerRoleLabel(plr)
    if not isPoliceRole(role) then return end
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local snd = Instance.new("Sound")
    snd.SoundId = POLICE_SIREN_SOUND
    snd.Looped = true
    snd.Volume = 1
    snd.RollOffMode = Enum.RollOffMode.Linear
    snd.RollOffMinDistance = 10
    snd.RollOffMaxDistance = 120
    snd.Parent = hrp
    if state.policeSoundEnabled then
        snd:Play()
    else
        snd.Volume = 0
    end
    policeSirens[plr] = snd
    -- Nettoyage si le joueur quitte ou respawn
    plr.AncestryChanged:Connect(function()
        if not plr.Parent then
            if snd and snd.Parent then snd:Destroy() end
            policeSirens[plr] = nil
        end
    end)
    plr.CharacterRemoving:Connect(function()
        if snd and snd.Parent then snd:Destroy() end
        policeSirens[plr] = nil
    end)
end

-- Scan initial + surveillance
task.spawn(function()
    task.wait(1)
    local Players = game:GetService("Players")
    -- Joueurs deja connectes
    for _, plr in ipairs(Players:GetPlayers()) do
        attachPoliceSirenToPlayer(plr)
    end
    -- Nouveaux joueurs
    Players.PlayerAdded:Connect(function(plr)
        -- Attendre que le personnage soit charge et que le role soit attribue
        task.wait(3)
        attachPoliceSirenToPlayer(plr)
    end)
    -- Respawn : re-attacher sur le nouveau personnage
    Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function()
            task.wait(2)
            policeSirens[plr] = nil  -- forcer re-attachement
            attachPoliceSirenToPlayer(plr)
        end)
    end)
    for _, plr in ipairs(Players:GetPlayers()) do
        plr.CharacterAdded:Connect(function()
            task.wait(2)
            policeSirens[plr] = nil
            attachPoliceSirenToPlayer(plr)
        end)
    end
    -- Boucle re-scan toutes les 10s (role peut changer en cours de jeu)
    while true do
        task.wait(10)
        for _, plr in ipairs(Players:GetPlayers()) do
            attachPoliceSirenToPlayer(plr)
        end
        -- Nettoyer joueurs deconnectes
        for plr, snd in pairs(policeSirens) do
            if not plr.Parent then
                if snd and snd.Parent then snd:Destroy() end
                policeSirens[plr] = nil
            end
        end
    end
end)

local function createMainUI()
    local playerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VehicleTPUI"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999
    screenGui.Parent = playerGui

    -- Badge role haut-gauche
    local badgeStroke = Instance.new("UIStroke")
    badgeStroke.Color = Color3.fromRGB(60, 70, 100)
    badgeStroke.Thickness = 1.5
    badgeStroke.Parent = roleBadge

    local roleDot = Instance.new("Frame")
    roleDot.Size = UDim2.new(0, 20, 0, 20)
    roleDot.Position = UDim2.new(0, 9, 0.5, -10)
    roleDot.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
    roleDot.BorderSizePixel = 0
    roleDot.Parent = roleBadge
    createRounded(roleDot, 10)

    local roleText = Instance.new("TextLabel")
    roleText.Size = UDim2.new(1, -40, 1, 0)
    roleText.Position = UDim2.new(0, 36, 0, 0)
    roleText.BackgroundTransparency = 1
    roleText.TextColor3 = Color3.fromRGB(230, 230, 230)
    roleText.TextSize = 13
    roleText.Font = Enum.Font.GothamBold
    roleText.TextXAlignment = Enum.TextXAlignment.Left
    roleText.Text = "..."
    roleText.Parent = roleBadge

    local function getRoleColor(role)
        local r = role:lower()
        if r:find("police") then
            return Color3.fromRGB(50, 110, 220), "POLICE"
        elseif r:find("prisoner") then
            return Color3.fromRGB(220, 160, 30), "PRISONNIER"
        elseif r:find("firedepartment") or r:find("fire") then
            return Color3.fromRGB(220, 60, 30), "POMPIER"
        elseif r:find("hars") then
            return Color3.fromRGB(30, 190, 140), "HARS"
        elseif r:find("buscompany") or r:find("bus") then
            return Color3.fromRGB(220, 180, 0), "BUS"
        elseif r:find("truckcompany") or r:find("truck") then
            return Color3.fromRGB(130, 100, 60), "TRUCK"
        elseif r:find("citizen") then
            return Color3.fromRGB(80, 180, 80), "CITIZEN"
        else
            return Color3.fromRGB(160, 160, 160), role:upper()
        end
    end

    local function updateRoleBadge()
        local role = getPlayerRoleLabel(player)
        local color, label = getRoleColor(role)
        roleDot.BackgroundColor3 = color
        roleText.Text = label
    end

    updateRoleBadge()
    task.spawn(function()
        while screenGui.Parent do
            task.wait(2)
            updateRoleBadge()
        end
    end)

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 760, 0, 640)
    main.Position = UDim2.new(0.5, -380, 0.5, -320)
    main.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
    main.BorderSizePixel = 0
    main.Parent = screenGui
    createRounded(main, 14)

    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(0, 130, 200)
    border.Thickness = 2
    border.Parent = main

    createDragBehavior(main)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 72)
    header.BackgroundColor3 = Color3.fromRGB(24, 34, 52)
    header.BorderSizePixel = 0
    header.Parent = main
    createRounded(header, 14)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(80, 220, 255)
    title.TextSize = 30
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "ELIX MOD MENU"
    title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 38, 0, 38)
    closeBtn.Position = UDim2.new(1, -48, 0.5, -19)
    closeBtn.BackgroundColor3 = Color3.fromRGB(210, 70, 70)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 22
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "X"
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = header
    createRounded(closeBtn, 8)

    local deleteBtn = Instance.new("TextButton")
    deleteBtn.Size = UDim2.new(0, 52, 0, 38)
    deleteBtn.Position = UDim2.new(1, -106, 0.5, -19)
    deleteBtn.BackgroundColor3 = Color3.fromRGB(145, 45, 45)
    deleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    deleteBtn.TextSize = 12
    deleteBtn.Font = Enum.Font.GothamBold
    deleteBtn.Text = "DEL"
    deleteBtn.BorderSizePixel = 0
    deleteBtn.Parent = header
    createRounded(deleteBtn, 8)

    -- Bouton langue FR / EN
    local langBtn = Instance.new("TextButton")
    langBtn.Size = UDim2.new(0, 52, 0, 38)
    langBtn.Position = UDim2.new(1, -164, 0.5, -19)
    langBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 100)
    langBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    langBtn.TextSize = 13
    langBtn.Font = Enum.Font.GothamBold
    langBtn.Text = "FR"
    langBtn.BorderSizePixel = 0
    langBtn.Parent = header
    createRounded(langBtn, 8)

    langBtn.MouseButton1Click:Connect(function()
        state.lang = (state.lang == "fr") and "en" or "fr"
        langBtn.Text = state.lang:upper()
        langBtn.BackgroundColor3 = state.lang == "en"
            and Color3.fromRGB(30, 80, 160)
            or Color3.fromRGB(40, 60, 100)
        refreshLang()
    end)

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -72)
    content.Position = UDim2.new(0, 0, 0, 72)
    content.BackgroundTransparency = 1
    content.Parent = main

    local menuScreen = Instance.new("Frame")
    menuScreen.Name = "Menu"
    menuScreen.Size = UDim2.new(1, 0, 1, 0)
    menuScreen.BackgroundTransparency = 1
    menuScreen.Parent = content

    local menuLayout = Instance.new("UIListLayout")
    menuLayout.FillDirection = Enum.FillDirection.Vertical
    menuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    menuLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    menuLayout.Padding = UDim.new(0, 16)
    menuLayout.Parent = menuScreen

    local teleportScreen = Instance.new("Frame")
    teleportScreen.Name = "Teleport"
    teleportScreen.Size = UDim2.new(1, 0, 1, 0)
    teleportScreen.BackgroundTransparency = 1
    teleportScreen.Visible = false
    teleportScreen.Parent = content

    local waypointScreen = Instance.new("Frame")
    waypointScreen.Name = "Waypoints"
    waypointScreen.Size = UDim2.new(1, 0, 1, 0)
    waypointScreen.BackgroundTransparency = 1
    waypointScreen.Visible = false
    waypointScreen.Parent = content

    local customScreen = Instance.new("Frame")
    customScreen.Name = "Custom"
    customScreen.Size = UDim2.new(1, 0, 1, 0)
    customScreen.BackgroundTransparency = 1
    customScreen.Visible = false
    customScreen.Parent = content

    local itemsScreen = Instance.new("Frame")
    itemsScreen.Name = "Items"
    itemsScreen.Size = UDim2.new(1, 0, 1, 0)
    itemsScreen.BackgroundTransparency = 1
    itemsScreen.Visible = false
    itemsScreen.Parent = content

    local function showScreen(screenKey)
        menuScreen.Visible     = screenKey == "menu"
        teleportScreen.Visible = screenKey == "teleport"
        waypointScreen.Visible = screenKey == "waypoints"
        customScreen.Visible   = screenKey == "custom"
        itemsScreen.Visible    = screenKey == "items"
    end

    -- ===== CUSTOM VEHICULE UI =====
    do
        local cvApplyProp  -- forward declare (utilisee dans closures avant definition)

        -- Barre haut
        local cvBack = Instance.new("TextButton")
        cvBack.Size = UDim2.new(0, 110, 0, 34)
        cvBack.Position = UDim2.new(0, 10, 0, 8)
        cvBack.BackgroundColor3 = Color3.fromRGB(38, 52, 82)
        cvBack.TextColor3 = Color3.fromRGB(200, 220, 255)
        cvBack.TextSize = 12
        cvBack.Font = Enum.Font.GothamBold
        tReg(cvBack, "cv_back")
        cvBack.BorderSizePixel = 0
        cvBack.Parent = customScreen
        createRounded(cvBack, 8)

        local cvTitle = Instance.new("TextLabel")
        cvTitle.Size = UDim2.new(1, -260, 0, 34)
        cvTitle.Position = UDim2.new(0, 130, 0, 8)
        cvTitle.BackgroundTransparency = 1
        cvTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
        cvTitle.TextSize = 15
        cvTitle.Font = Enum.Font.GothamBold
        tReg(cvTitle, "cv_title")
        cvTitle.Parent = customScreen

        local cvRefresh = Instance.new("TextButton")
        cvRefresh.Size = UDim2.new(0, 110, 0, 34)
        cvRefresh.Position = UDim2.new(1, -120, 0, 8)
        cvRefresh.BackgroundColor3 = Color3.fromRGB(38, 52, 82)
        cvRefresh.TextColor3 = Color3.fromRGB(200, 220, 255)
        cvRefresh.TextSize = 12
        cvRefresh.Font = Enum.Font.GothamBold
        tReg(cvRefresh, "cv_refresh")
        cvRefresh.BorderSizePixel = 0
        cvRefresh.Parent = customScreen
        createRounded(cvRefresh, 8)

        -- Status
        local cvStatus = Instance.new("TextLabel")
        cvStatus.Size = UDim2.new(1, -20, 0, 22)
        cvStatus.Position = UDim2.new(0, 10, 1, -28)
        cvStatus.BackgroundTransparency = 1
        cvStatus.TextColor3 = Color3.fromRGB(120, 255, 190)
        cvStatus.TextSize = 12
        cvStatus.Font = Enum.Font.Gotham
        cvStatus.TextXAlignment = Enum.TextXAlignment.Left
        cvStatus.Text = ""
        cvStatus.Parent = customScreen

        -- ---- PANEL GAUCHE : liste pieces ----
        local leftPanel = Instance.new("Frame")
        leftPanel.Size = UDim2.new(0, 240, 1, -58)
        leftPanel.Position = UDim2.new(0, 10, 0, 50)
        leftPanel.BackgroundColor3 = Color3.fromRGB(18, 22, 36)
        leftPanel.BorderSizePixel = 0
        leftPanel.Parent = customScreen
        createRounded(leftPanel, 10)

        local leftTitle = Instance.new("TextLabel")
        leftTitle.Size = UDim2.new(1, -10, 0, 26)
        leftTitle.Position = UDim2.new(0, 8, 0, 4)
        leftTitle.BackgroundTransparency = 1
        leftTitle.TextColor3 = Color3.fromRGB(130, 160, 200)
        leftTitle.TextSize = 11
        leftTitle.Font = Enum.Font.GothamBold
        tReg(leftTitle, "cv_parts")
        leftTitle.TextXAlignment = Enum.TextXAlignment.Left
        leftTitle.Parent = leftPanel

        local allBtn = Instance.new("TextButton")
        allBtn.Size = UDim2.new(1, -16, 0, 30)
        allBtn.Position = UDim2.new(0, 8, 0, 32)
        allBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 130)
        allBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        allBtn.TextSize = 12
        allBtn.Font = Enum.Font.GothamBold
        tReg(allBtn, "cv_all")
        allBtn.BorderSizePixel = 0
        allBtn.Parent = leftPanel
        createRounded(allBtn, 7)

        local partsScroll = Instance.new("ScrollingFrame")
        partsScroll.Size = UDim2.new(1, -16, 1, -72)
        partsScroll.Position = UDim2.new(0, 8, 0, 66)
        partsScroll.BackgroundColor3 = Color3.fromRGB(22, 28, 44)
        partsScroll.BorderSizePixel = 0
        partsScroll.ScrollBarThickness = 4
        partsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        partsScroll.Parent = leftPanel
        createRounded(partsScroll, 8)

        local partsLayout = Instance.new("UIListLayout")
        partsLayout.Padding = UDim.new(0, 3)
        partsLayout.Parent = partsScroll

        -- ---- PANEL DROIT : proprietes ----
        local rightPanel = Instance.new("Frame")
        rightPanel.Size = UDim2.new(1, -270, 1, -58)
        rightPanel.Position = UDim2.new(0, 260, 0, 50)
        rightPanel.BackgroundColor3 = Color3.fromRGB(18, 22, 36)
        rightPanel.BorderSizePixel = 0
        rightPanel.Parent = customScreen
        createRounded(rightPanel, 10)

        local selectedLabel = Instance.new("TextLabel")
        selectedLabel.Size = UDim2.new(1, -16, 0, 28)
        selectedLabel.Position = UDim2.new(0, 8, 0, 6)
        selectedLabel.BackgroundTransparency = 1
        selectedLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        selectedLabel.TextSize = 13
        selectedLabel.Font = Enum.Font.GothamBold
        tReg(selectedLabel, "cv_none_sel")
        selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
        selectedLabel.Parent = rightPanel

        -- Couleur
        local colorLabel = Instance.new("TextLabel")
        colorLabel.Size = UDim2.new(1, -16, 0, 18)
        colorLabel.Position = UDim2.new(0, 8, 0, 38)
        colorLabel.BackgroundTransparency = 1
        colorLabel.TextColor3 = Color3.fromRGB(130, 160, 200)
        colorLabel.TextSize = 11
        colorLabel.Font = Enum.Font.GothamBold
        tReg(colorLabel, "cv_color")
        colorLabel.TextXAlignment = Enum.TextXAlignment.Left
        colorLabel.Parent = rightPanel

        local colorPalette = {
            Color3.fromRGB(255,255,255), Color3.fromRGB(20,20,20),   Color3.fromRGB(160,160,160),
            Color3.fromRGB(200,0,0),     Color3.fromRGB(0,120,200),  Color3.fromRGB(0,180,60),
            Color3.fromRGB(239,184,56),  Color3.fromRGB(220,120,0),  Color3.fromRGB(140,0,200),
            Color3.fromRGB(0,200,200),   Color3.fromRGB(220,180,140),Color3.fromRGB(100,50,20),
            Color3.fromRGB(255,150,180), Color3.fromRGB(150,255,150),Color3.fromRGB(150,180,255),
            Color3.fromRGB(255,255,100), Color3.fromRGB(30,80,30),   Color3.fromRGB(80,0,0),
            Color3.fromRGB(0,0,80),      Color3.fromRGB(60,60,40),
        }
        local SW = 36
        local SW_PAD = 4
        local SW_COLS = 10

        local selectedSwatchBorder = nil

        for i, col in ipairs(colorPalette) do
            local cx = (i-1) % SW_COLS
            local cy = math.floor((i-1) / SW_COLS)
            local sw = Instance.new("TextButton")
            sw.Size = UDim2.new(0, SW, 0, SW)
            sw.Position = UDim2.new(0, 8 + cx*(SW+SW_PAD), 0, 60 + cy*(SW+SW_PAD))
            sw.BackgroundColor3 = col
            sw.Text = ""
            sw.BorderSizePixel = 0
            sw.Parent = rightPanel
            createRounded(sw, 6)

            local border = Instance.new("UIStroke")
            border.Color = Color3.fromRGB(255,255,255)
            border.Thickness = 2
            border.Enabled = false
            border.Parent = sw

            sw.MouseButton1Click:Connect(function()
                if selectedSwatchBorder then selectedSwatchBorder.Enabled = false end
                border.Enabled = true
                selectedSwatchBorder = border
                cvApplyProp("Color", col)
            end)
        end

        -- Materiau
        local matY = 60 + 2*(SW+SW_PAD) + 12

        local matLabel = Instance.new("TextLabel")
        matLabel.Size = UDim2.new(1, -16, 0, 18)
        matLabel.Position = UDim2.new(0, 8, 0, matY)
        matLabel.BackgroundTransparency = 1
        matLabel.TextColor3 = Color3.fromRGB(130, 160, 200)
        matLabel.TextSize = 11
        matLabel.Font = Enum.Font.GothamBold
        tReg(matLabel, "cv_material")
        matLabel.TextXAlignment = Enum.TextXAlignment.Left
        matLabel.Parent = rightPanel

        local matScroll = Instance.new("ScrollingFrame")
        matScroll.Size = UDim2.new(1, -16, 0, 120)
        matScroll.Position = UDim2.new(0, 8, 0, matY + 22)
        matScroll.BackgroundColor3 = Color3.fromRGB(22, 28, 44)
        matScroll.BorderSizePixel = 0
        matScroll.ScrollBarThickness = 4
        matScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        matScroll.Parent = rightPanel
        createRounded(matScroll, 8)

        local matGrid = Instance.new("UIGridLayout")
        matGrid.CellSize = UDim2.new(0.5, -6, 0, 26)
        matGrid.CellPadding = UDim2.new(0, 4, 0, 4)
        matGrid.Parent = matScroll

        matGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            matScroll.CanvasSize = UDim2.new(0, 0, 0, matGrid.AbsoluteContentSize.Y + 8)
        end)

        local materialList = {
            Enum.Material.SmoothPlastic, Enum.Material.Metal,
            Enum.Material.Neon,          Enum.Material.Glass,
            Enum.Material.Wood,          Enum.Material.Brick,
            Enum.Material.Grass,         Enum.Material.DiamondPlate,
            Enum.Material.Foil,          Enum.Material.Marble,
            Enum.Material.Granite,       Enum.Material.Cobblestone,
            Enum.Material.Sand,          Enum.Material.Fabric,
            Enum.Material.Concrete,      Enum.Material.Cardboard,
            Enum.Material.Carpet,        Enum.Material.Asphalt,
            Enum.Material.Ice,           Enum.Material.Air,
        }

        local selectedMatBtn = nil

        for _, mat in ipairs(materialList) do
            local matName = tostring(mat):gsub("Enum.Material.", "")
            local mb = Instance.new("TextButton")
            mb.BackgroundColor3 = Color3.fromRGB(35, 44, 68)
            mb.TextColor3 = Color3.fromRGB(200, 215, 240)
            mb.TextSize = 11
            mb.Font = Enum.Font.GothamBold
            mb.Text = matName
            mb.BorderSizePixel = 0
            mb.Parent = matScroll
            createRounded(mb, 6)

            mb.MouseEnter:Connect(function()
                if mb ~= selectedMatBtn then mb.BackgroundColor3 = Color3.fromRGB(55, 65, 95) end
            end)
            mb.MouseLeave:Connect(function()
                if mb ~= selectedMatBtn then mb.BackgroundColor3 = Color3.fromRGB(35, 44, 68) end
            end)
            mb.MouseButton1Click:Connect(function()
                if selectedMatBtn then selectedMatBtn.BackgroundColor3 = Color3.fromRGB(35, 44, 68) end
                selectedMatBtn = mb
                mb.BackgroundColor3 = Color3.fromRGB(0, 140, 80)
                cvApplyProp("Material", mat)
            end)
        end

        -- Transparence
        local trY = matY + 22 + 120 + 12

        local trLabel = Instance.new("TextLabel")
        trLabel.Size = UDim2.new(0, 140, 0, 18)
        trLabel.Position = UDim2.new(0, 8, 0, trY)
        trLabel.BackgroundTransparency = 1
        trLabel.TextColor3 = Color3.fromRGB(130, 160, 200)
        trLabel.TextSize = 11
        trLabel.Font = Enum.Font.GothamBold
        tReg(trLabel, "cv_transp")
        trLabel.TextXAlignment = Enum.TextXAlignment.Left
        trLabel.Parent = rightPanel

        local trValLabel = Instance.new("TextLabel")
        trValLabel.Size = UDim2.new(0, 60, 0, 18)
        trValLabel.Position = UDim2.new(0, 150, 0, trY)
        trValLabel.BackgroundTransparency = 1
        trValLabel.TextColor3 = Color3.fromRGB(120, 255, 190)
        trValLabel.TextSize = 11
        trValLabel.Font = Enum.Font.GothamBold
        trValLabel.Text = "0.00"
        trValLabel.Parent = rightPanel

        local trBack = Instance.new("Frame")
        trBack.Size = UDim2.new(1, -26, 0, 10)
        trBack.Position = UDim2.new(0, 8, 0, trY + 22)
        trBack.BackgroundColor3 = Color3.fromRGB(38, 55, 80)
        trBack.BorderSizePixel = 0
        trBack.Parent = rightPanel
        createRounded(trBack, 10)

        local trFill = Instance.new("Frame")
        trFill.Size = UDim2.new(0, 0, 1, 0)
        trFill.BackgroundColor3 = Color3.fromRGB(0, 170, 230)
        trFill.BorderSizePixel = 0
        trFill.Parent = trBack
        createRounded(trFill, 10)

        local trKnob = Instance.new("Frame")
        trKnob.Size = UDim2.new(0, 16, 0, 16)
        trKnob.AnchorPoint = Vector2.new(0.5, 0.5)
        trKnob.Position = UDim2.new(0, 0, 0.5, 0)
        trKnob.BackgroundColor3 = Color3.fromRGB(230, 245, 255)
        trKnob.BorderSizePixel = 0
        trKnob.Parent = trBack
        createRounded(trKnob, 16)

        local trDragging = false
        local cvTransparency = 0

        local function setTransparency(ratio)
            ratio = math.clamp(ratio, 0, 1)
            cvTransparency = ratio
            trFill.Size = UDim2.new(ratio, 0, 1, 0)
            trKnob.Position = UDim2.new(ratio, 0, 0.5, 0)
            trValLabel.Text = string.format("%.2f", ratio)
            cvApplyProp("Transparency", ratio)
        end

        local function trSetByX(absX)
            local abs = trBack.AbsolutePosition.X
            local w = trBack.AbsoluteSize.X
            setTransparency((absX - abs) / w)
        end

        trBack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                trDragging = true
                trSetByX(input.Position.X)
            end
        end)
        trKnob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then trDragging = true end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if trDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                trSetByX(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then trDragging = false end
        end)

        -- CastShadow toggle
        local csY = trY + 22 + 18

        local csBtn = Instance.new("TextButton")
        csBtn.Size = UDim2.new(0, 180, 0, 28)
        csBtn.Position = UDim2.new(0, 8, 0, csY)
        csBtn.BackgroundColor3 = Color3.fromRGB(60, 165, 95)
        csBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        csBtn.TextSize = 12
        csBtn.Font = Enum.Font.GothamBold
        csBtn.Text = t("cv_cast_shadow_on")
        csBtn.BorderSizePixel = 0
        csBtn.Parent = rightPanel
        createRounded(csBtn, 7)

        local cvCastShadow = true
        csBtn.MouseButton1Click:Connect(function()
            cvCastShadow = not cvCastShadow
            csBtn.Text = cvCastShadow and t("cv_cast_shadow_on") or t("cv_cast_shadow_off")
            csBtn.BackgroundColor3 = cvCastShadow and Color3.fromRGB(60,165,95) or Color3.fromRGB(145,45,45)
            cvApplyProp("CastShadow", cvCastShadow)
        end)

        -- ---- VITESSE VEHICULE ----
        local speedY = csY + 36

        local speedLabel = Instance.new("TextLabel")
        speedLabel.Size = UDim2.new(0, 180, 0, 18)
        speedLabel.Position = UDim2.new(0, 8, 0, speedY)
        speedLabel.BackgroundTransparency = 1
        speedLabel.TextColor3 = Color3.fromRGB(180, 210, 255)
        speedLabel.TextSize = 12
        speedLabel.Font = Enum.Font.GothamBold
        speedLabel.TextXAlignment = Enum.TextXAlignment.Left
        speedLabel.Text = t("cv_speed_label")
        speedLabel.Parent = rightPanel

        local speedValLabel = Instance.new("TextLabel")
        speedValLabel.Size = UDim2.new(0, 60, 0, 18)
        speedValLabel.Position = UDim2.new(0, 150, 0, speedY)
        speedValLabel.BackgroundTransparency = 1
        speedValLabel.TextColor3 = Color3.fromRGB(120, 255, 190)
        speedValLabel.TextSize = 12
        speedValLabel.Font = Enum.Font.GothamBold
        speedValLabel.Text = "?"
        speedValLabel.Parent = rightPanel

        local speedBtnY = speedY + 22

        local speedMinusBtn = Instance.new("TextButton")
        speedMinusBtn.Size = UDim2.new(0, 36, 0, 26)
        speedMinusBtn.Position = UDim2.new(0, 8, 0, speedBtnY)
        speedMinusBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
        speedMinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        speedMinusBtn.TextSize = 14
        speedMinusBtn.Font = Enum.Font.GothamBold
        speedMinusBtn.Text = "-"
        speedMinusBtn.BorderSizePixel = 0
        speedMinusBtn.Parent = rightPanel
        createRounded(speedMinusBtn, 6)

        local speedPlusBtn = Instance.new("TextButton")
        speedPlusBtn.Size = UDim2.new(0, 36, 0, 26)
        speedPlusBtn.Position = UDim2.new(0, 50, 0, speedBtnY)
        speedPlusBtn.BackgroundColor3 = Color3.fromRGB(50, 140, 80)
        speedPlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        speedPlusBtn.TextSize = 14
        speedPlusBtn.Font = Enum.Font.GothamBold
        speedPlusBtn.Text = "+"
        speedPlusBtn.BorderSizePixel = 0
        speedPlusBtn.Parent = rightPanel
        createRounded(speedPlusBtn, 6)

        local speedResetBtn = Instance.new("TextButton")
        speedResetBtn.Size = UDim2.new(0, 90, 0, 26)
        speedResetBtn.Position = UDim2.new(0, 92, 0, speedBtnY)
        speedResetBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        speedResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        speedResetBtn.TextSize = 11
        speedResetBtn.Font = Enum.Font.GothamBold
        speedResetBtn.Text = t("cv_speed_reset")
        speedResetBtn.BorderSizePixel = 0
        speedResetBtn.Parent = rightPanel
        createRounded(speedResetBtn, 6)

        local cvSpeedStep    = 0.5  -- increment du multiplicateur par clic
        local cvSpeedMult    = 1.5  -- multiplicateur actif (1.5 = boost par defaut)
        local cvSpeedLoopOn  = false

        local function getCylindricalConstraints(veh)
            local constraints = {}
            for _, d in ipairs(veh:GetDescendants()) do
                if d:IsA("CylindricalConstraint") then
                    table.insert(constraints, d)
                end
            end
            return constraints
        end

        local function getVehicleSeats(veh)
            local seats = {}
            for _, d in ipairs(veh:GetDescendants()) do
                if d:IsA("VehicleSeat") then
                    table.insert(seats, d)
                end
            end
            return seats
        end

        local function updateSpeedDisplay()
            local pct = math.floor((cvSpeedMult - 1) * 100)
            local sign = pct >= 0 and "+" or ""
            speedValLabel.Text = "x" .. string.format("%.1f", cvSpeedMult)
            if cvSpeedMult > 1 then
                speedValLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
            elseif cvSpeedMult < 1 then
                speedValLabel.TextColor3 = Color3.fromRGB(255, 100, 80)
            else
                speedValLabel.TextColor3 = Color3.fromRGB(120, 255, 190)
            end
        end

        -- Boucle : booste directement la velocite physique du vehicule
        local cvSpeedConnection = nil
        local cvBaseSpeed = nil  -- vitesse naturelle capturée une fois
        local function startSpeedLoop()
            if cvSpeedConnection then return end
            cvBaseSpeed = nil
            cvSpeedConnection = RunService.Heartbeat:Connect(function()
                if cvSpeedMult == 1.0 then return end
                -- Lookup rapide uniquement (pas de GetDescendants = pas de freeze)
                local veh = state.cachedVehicle
                if not veh or not veh.Parent then
                    local char = player.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.SeatPart then
                        local m = hum.SeatPart:FindFirstAncestorOfClass("Model")
                        if m then state.cachedVehicle = m veh = m end
                    end
                end
                if not veh then return end
                -- Verifier que le joueur accelere (W ou fleche haut)
                local accelerating = UserInputService:IsKeyDown(state.accelKey)
                if not accelerating then
                    cvBaseSpeed = nil  -- reset pour recapturer quand il reaccélère
                    return
                end
                local root = veh.PrimaryPart or getVehicleRoot(veh)
                if not root then return end
                local vel = root.AssemblyLinearVelocity
                local spd = vel.Magnitude
                if spd < 1 then return end
                -- Capturer la vitesse naturelle la premiere fois
                if not cvBaseSpeed then
                    cvBaseSpeed = spd
                end
                -- Viser une vitesse cible fixe (pas de compoundage)
                local target = cvBaseSpeed * cvSpeedMult
                root.AssemblyLinearVelocity = vel.Unit * target
            end)
        end

        local function stopSpeedLoop()
            if cvSpeedConnection then
                cvSpeedConnection:Disconnect()
                cvSpeedConnection = nil
            end
        end

        speedPlusBtn.MouseButton1Click:Connect(function()
            cvSpeedMult = math.min(cvSpeedMult + cvSpeedStep, 3.0)
            cvBaseSpeed = nil  -- recapturer la base au prochain tick
            updateSpeedDisplay()
            startSpeedLoop()
            cvStatus.Text = state.lang == "en" and ("Speed x" .. string.format("%.1f", cvSpeedMult)) or ("Vitesse x" .. string.format("%.1f", cvSpeedMult))
        end)

        speedMinusBtn.MouseButton1Click:Connect(function()
            cvSpeedMult = math.max(cvSpeedMult - cvSpeedStep, 1.0)
            cvBaseSpeed = nil
            updateSpeedDisplay()
            startSpeedLoop()
            cvStatus.Text = state.lang == "en" and ("Speed x" .. string.format("%.1f", cvSpeedMult)) or ("Vitesse x" .. string.format("%.1f", cvSpeedMult))
        end)

        speedResetBtn.MouseButton1Click:Connect(function()
            cvSpeedMult = 1.5
            cvBaseSpeed = nil
            updateSpeedDisplay()
            startSpeedLoop()
            cvStatus.Text = state.lang == "en" and "Speed reset to normal" or "Vitesse remise a la normale"
        end)

        updateSpeedDisplay()
        startSpeedLoop()  -- demarrer le boost par defaut a x1.5

        -- ---- LOGIQUE APPLY ----
        local cvTargetAll = true
        local cvSelectedPart = nil

        cvApplyProp = function(prop, value)
            local veh = findVehicle()
            if not veh then
                cvStatus.Text = t("cv_no_veh")
                return
            end
            if cvTargetAll then
                local count = 0
                for _, p in ipairs(veh:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if prop == "Color" then p.Color = value
                        elseif prop == "Material" then p.Material = value
                        elseif prop == "Transparency" then p.Transparency = value
                        elseif prop == "CastShadow" then p.CastShadow = value
                        end
                        count += 1
                    end
                end
                cvStatus.Text = string.format(t("cv_applied_all"), prop, count)
            else
                if not cvSelectedPart or not cvSelectedPart.Parent then
                    cvStatus.Text = t("cv_invalid_part")
                    return
                end
                if prop == "Color" then cvSelectedPart.Color = value
                elseif prop == "Material" then cvSelectedPart.Material = value
                elseif prop == "Transparency" then cvSelectedPart.Transparency = value
                elseif prop == "CastShadow" then cvSelectedPart.CastShadow = value
                end
                cvStatus.Text = string.format(t("cv_applied_one"), prop, cvSelectedPart.Name)
            end
        end

        -- ---- LISTE PIECES ----
        local partBtnSelected = nil

        local function refreshPartsList()
            for _, c in ipairs(partsScroll:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            local veh = findVehicle()
            if not veh then
                cvStatus.Text = t("cv_no_veh2")
                return
            end
            cvStatus.Text = string.format(t("cv_veh_fmt"), veh.Name)
            for _, p in ipairs(veh:GetDescendants()) do
                if p:IsA("BasePart") then
                    local pb = Instance.new("TextButton")
                    pb.Size = UDim2.new(1, 0, 0, 28)
                    pb.BackgroundColor3 = Color3.fromRGB(30, 38, 58)
                    pb.TextColor3 = Color3.fromRGB(190, 210, 240)
                    pb.TextSize = 11
                    pb.Font = Enum.Font.Gotham
                    pb.Text = p.Name
                    pb.BorderSizePixel = 0
                    pb.Parent = partsScroll
                    createRounded(pb, 5)

                    pb.MouseEnter:Connect(function()
                        if pb ~= partBtnSelected then pb.BackgroundColor3 = Color3.fromRGB(45, 55, 80) end
                    end)
                    pb.MouseLeave:Connect(function()
                        if pb ~= partBtnSelected then pb.BackgroundColor3 = Color3.fromRGB(30, 38, 58) end
                    end)
                    pb.MouseButton1Click:Connect(function()
                        if partBtnSelected then partBtnSelected.BackgroundColor3 = Color3.fromRGB(30, 38, 58) end
                        partBtnSelected = pb
                        pb.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
                        cvTargetAll = false
                        cvSelectedPart = p
                        allBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 130)
                        selectedLabel.Text = t("cv_target") .. p.Name
                    end)
                end
            end
            partsScroll.CanvasSize = UDim2.new(0, 0, 0, partsLayout.AbsoluteContentSize.Y + 6)
        end

        allBtn.MouseButton1Click:Connect(function()
            if partBtnSelected then
                partBtnSelected.BackgroundColor3 = Color3.fromRGB(30, 38, 58)
                partBtnSelected = nil
            end
            cvTargetAll = true
            cvSelectedPart = nil
            allBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
            selectedLabel.Text = t("cv_sel_all")
        end)

        cvBack.MouseButton1Click:Connect(function() showScreen("menu") end)
        cvRefresh.MouseButton1Click:Connect(refreshPartsList)

        customScreen:GetPropertyChangedSignal("Visible"):Connect(function()
            if customScreen.Visible then refreshPartsList() end
        end)
    end -- do custom

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 1, -145)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(120, 255, 190)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.GothamBold
    tReg(statusLabel, "status_ready")
    statusLabel.Parent = teleportScreen

    local selectedFollowLabel = Instance.new("TextLabel")
    selectedFollowLabel.Size = UDim2.new(1, -20, 0, 22)
    selectedFollowLabel.Position = UDim2.new(0, 10, 1, -166)
    selectedFollowLabel.BackgroundTransparency = 1
    selectedFollowLabel.TextColor3 = Color3.fromRGB(170, 210, 255)
    selectedFollowLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedFollowLabel.TextSize = 13
    selectedFollowLabel.Font = Enum.Font.GothamBold
    tReg(selectedFollowLabel, "orbit_label")
    selectedFollowLabel.Parent = teleportScreen

    local categories = {
        { name = "BUILDING", key = "building" },
        { name = "DESTINATIONS", key = "robbery" },
        { name = "DEALER", key = "dealer" },
        { name = "JOUEURS", key = "players" },
        { name = "VEHICLES", key = "vehicles" },
    }

    local tabButtons = {}
    local tabContents = {}
    local currentTab = "building"
    local knownDealers = {}
    local dealerRefreshBtn = nil

    local tabsFrame = Instance.new("Frame")
    tabsFrame.Size = UDim2.new(1, -20, 0, 50)
    tabsFrame.Position = UDim2.new(0, 10, 0, 10)
    tabsFrame.BackgroundTransparency = 1
    tabsFrame.Parent = teleportScreen

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.FillDirection = Enum.FillDirection.Horizontal
    tabsLayout.Padding = UDim.new(0, 6)
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabsLayout.Parent = tabsFrame

    for _, cat in ipairs(categories) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = cat.key .. "Tab"
        tabBtn.Size = UDim2.new(0, 132, 0, 36)
        tabBtn.BackgroundColor3 = Color3.fromRGB(38, 52, 82)
        tabBtn.TextColor3 = Color3.fromRGB(150, 160, 180)
        tabBtn.TextSize = 12
        tabBtn.Font = Enum.Font.GothamBold
        tReg(tabBtn, "tab_" .. cat.key)
        tabBtn.BorderSizePixel = 0
        tabBtn.Parent = tabsFrame
        createRounded(tabBtn, 7)

        tabButtons[cat.key] = tabBtn

        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name = cat.key .. "Content"
        scrollFrame.Size = UDim2.new(1, -20, 1, -220)
        scrollFrame.Position = UDim2.new(0, 10, 0, 70)
        scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 6
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.Visible = cat.key == "building"
        scrollFrame.Parent = teleportScreen
        createRounded(scrollFrame, 10)

        local gridLayout = Instance.new("UIGridLayout")
        gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
        gridLayout.CellSize = UDim2.new(0.5, -8, 0, cat.key == "dealer" and 92 or 66)
        gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        gridLayout.Parent = scrollFrame

        gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y + 20)
        end)

        tabContents[cat.key] = scrollFrame

        tabBtn.MouseButton1Click:Connect(function()
            currentTab = cat.key
            for key, btn in pairs(tabButtons) do
                local selected = key == currentTab
                btn.BackgroundColor3 = selected and Color3.fromRGB(0, 150, 220) or Color3.fromRGB(38, 52, 82)
                btn.TextColor3 = selected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 160, 180)
                tabContents[key].Visible = selected
            end
            if cat.key == "vehicles" then
                refreshVehiclesTab()
            elseif cat.key == "players" then
                refreshPlayersTab()
            end
            if dealerRefreshBtn then
                dealerRefreshBtn.Visible = (cat.key == "dealer")
            end
        end)
    end

    tabButtons[currentTab].BackgroundColor3 = Color3.fromRGB(0, 150, 220)
    tabButtons[currentTab].TextColor3 = Color3.fromRGB(255, 255, 255)

    -- Bouton refresh dealer (au-dessus du scrollFrame dealer)
    do
        local rb = Instance.new("TextButton")
        rb.Size = UDim2.new(1, -20, 0, 26)
        rb.Position = UDim2.new(0, 10, 0, 70)
        rb.BackgroundColor3 = Color3.fromRGB(30, 70, 40)
        rb.TextColor3 = Color3.fromRGB(160, 255, 190)
        rb.TextSize = 12
        rb.Font = Enum.Font.GothamBold
        rb.Text = "🔄  Actualiser les dealers"
        rb.BorderSizePixel = 0
        rb.Visible = false
        rb.Parent = teleportScreen
        createRounded(rb, 5)
        dealerRefreshBtn = rb

        -- Decaler le scrollFrame dealer pour laisser la place
        if tabContents["dealer"] then
            tabContents["dealer"].Position = UDim2.new(0, 10, 0, 100)
            tabContents["dealer"].Size = UDim2.new(1, -20, 1, -250)
        end
    end

    -- L'onglet vehicles utilise une liste verticale (pas de grille) pour afficher plus d'info
    if tabContents["vehicles"] then
        local vGrid = tabContents["vehicles"]:FindFirstChildOfClass("UIGridLayout")
        if vGrid then vGrid:Destroy() end
        local vList = Instance.new("UIListLayout")
        vList.Padding = UDim.new(0, 5)
        vList.Parent = tabContents["vehicles"]
        vList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContents["vehicles"].CanvasSize = UDim2.new(0, 0, 0, vList.AbsoluteContentSize.Y + 10)
        end)
    end

    local controlPanel = Instance.new("Frame")
    controlPanel.Size = UDim2.new(1, -20, 0, 100)
    controlPanel.Position = UDim2.new(0, 10, 1, -110)
    controlPanel.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
    controlPanel.BorderSizePixel = 0
    controlPanel.Parent = teleportScreen
    createRounded(controlPanel, 10)

    createSpeedSlider(controlPanel)

    local backBtn = Instance.new("TextButton")
    backBtn.Size = UDim2.new(0, 120, 0, 34)
    backBtn.Position = UDim2.new(0, 10, 0, 8)
    backBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    backBtn.TextSize = 13
    backBtn.Font = Enum.Font.GothamBold
    tReg(backBtn, "btn_back")
    backBtn.BorderSizePixel = 0
    backBtn.Parent = controlPanel
    createRounded(backBtn, 8)

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0, 120, 0, 34)
    cancelBtn.Position = UDim2.new(0, 140, 0, 8)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(210, 70, 70)
    cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelBtn.TextSize = 13
    cancelBtn.Font = Enum.Font.GothamBold
    tReg(cancelBtn, "btn_cancel")
    cancelBtn.BorderSizePixel = 0
    cancelBtn.Parent = controlPanel
    createRounded(cancelBtn, 8)

    local followBtn = Instance.new("TextButton")
    followBtn.Size = UDim2.new(0, 100, 0, 34)
    followBtn.Position = UDim2.new(0, 270, 0, 8)
    followBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    followBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    followBtn.TextSize = 13
    followBtn.Font = Enum.Font.GothamBold
    tReg(followBtn, "btn_orbit_off")
    followBtn.BorderSizePixel = 0
    followBtn.Parent = controlPanel
    createRounded(followBtn, 8)

    local rotationBtn = Instance.new("TextButton")
    rotationBtn.Size = UDim2.new(0, 100, 0, 34)
    rotationBtn.Position = UDim2.new(0, 375, 0, 8)
    rotationBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    rotationBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rotationBtn.TextSize = 12
    rotationBtn.Font = Enum.Font.GothamBold
    tReg(rotationBtn, "btn_rot_off")
    rotationBtn.BorderSizePixel = 0
    rotationBtn.Parent = controlPanel
    createRounded(rotationBtn, 8)

    local horseBtn = Instance.new("TextButton")
    horseBtn.Size = UDim2.new(0, 110, 0, 34)
    horseBtn.Position = UDim2.new(0, 480, 0, 8)
    horseBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    horseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    horseBtn.TextSize = 12
    horseBtn.Font = Enum.Font.GothamBold
    horseBtn.Text = t("btn_horse_off")
    horseBtn.BorderSizePixel = 0
    horseBtn.Parent = controlPanel
    createRounded(horseBtn, 8)

    horseBtn.MouseButton1Click:Connect(function()
        state.horseEnabled = not state.horseEnabled
        if state.horseEnabled then
            createHorse()
            horseBtn.Text = t("btn_horse_on")
            horseBtn.BackgroundColor3 = Color3.fromRGB(110, 70, 20)
        else
            destroyHorse()
            horseBtn.Text = t("btn_horse_off")
            horseBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)

    local mirrorBtn = Instance.new("TextButton")
    mirrorBtn.Size = UDim2.new(0, 100, 0, 34)
    mirrorBtn.Position = UDim2.new(0, 595, 0, 8)
    mirrorBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    mirrorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mirrorBtn.TextSize = 11
    mirrorBtn.Font = Enum.Font.GothamBold
    tReg(mirrorBtn, "btn_mirror_off")
    mirrorBtn.BorderSizePixel = 0
    mirrorBtn.Parent = controlPanel
    createRounded(mirrorBtn, 8)


    local function refreshModeButtons()
        followBtn.Text = state.followEnabled and t("btn_orbit_on") or t("btn_orbit_off")
        followBtn.BackgroundColor3 = state.followEnabled and Color3.fromRGB(170, 75, 210) or Color3.fromRGB(90, 90, 90)

        rotationBtn.Text = state.orbitRotationEnabled and t("btn_rot_on") or t("btn_rot_off")
        rotationBtn.BackgroundColor3 = state.orbitRotationEnabled and Color3.fromRGB(60, 165, 95) or Color3.fromRGB(90, 90, 90)

        mirrorBtn.Text = state.mirrorEnabled and t("btn_mirror_on") or t("btn_mirror_off")
        mirrorBtn.BackgroundColor3 = state.mirrorEnabled and Color3.fromRGB(30, 140, 200) or Color3.fromRGB(80, 80, 80)


        local targetName = state.followTargetPart and state.followTargetPart.Parent and state.followTargetPart.Parent.Name
            or (state.followTarget and state.followTarget.Name)
            or (state.lang == "en" and "none" or "aucune")
        local mode = state.orbitRotationEnabled and (state.lang == "en" and "rotation" or "rotation") or (state.lang == "en" and "follow" or "suivi")
        selectedFollowLabel.Text = (state.lang == "en" and "Orbit target: " or "Cible orbit: ") .. targetName .. " | " .. mode
    end

    local waypointTitle = Instance.new("TextLabel")
    waypointTitle.Size = UDim2.new(1, -20, 0, 34)
    waypointTitle.Position = UDim2.new(0, 10, 0, 10)
    waypointTitle.BackgroundTransparency = 1
    waypointTitle.TextColor3 = Color3.fromRGB(80, 220, 255)
    waypointTitle.TextXAlignment = Enum.TextXAlignment.Left
    waypointTitle.TextSize = 24
    waypointTitle.Font = Enum.Font.GothamBold
    tReg(waypointTitle, "wp_title")
    waypointTitle.Parent = waypointScreen

    local waypointHint = Instance.new("TextLabel")
    waypointHint.Size = UDim2.new(1, -20, 0, 20)
    waypointHint.Position = UDim2.new(0, 10, 0, 44)
    waypointHint.BackgroundTransparency = 1
    waypointHint.TextColor3 = Color3.fromRGB(155, 185, 220)
    waypointHint.TextXAlignment = Enum.TextXAlignment.Left
    waypointHint.TextSize = 12
    waypointHint.Font = Enum.Font.Gotham
    tReg(waypointHint, "wp_hint")
    waypointHint.Parent = waypointScreen

    local livePosLabel = Instance.new("TextLabel")
    livePosLabel.Size = UDim2.new(1, -20, 0, 20)
    livePosLabel.Position = UDim2.new(0, 10, 0, 72)
    livePosLabel.BackgroundTransparency = 1
    livePosLabel.TextColor3 = Color3.fromRGB(120, 255, 190)
    livePosLabel.TextXAlignment = Enum.TextXAlignment.Left
    livePosLabel.TextSize = 13
    livePosLabel.Font = Enum.Font.GothamBold
    tReg(livePosLabel, "wp_live")
    livePosLabel.Parent = waypointScreen

    local selectedWaypointLabel = Instance.new("TextLabel")
    selectedWaypointLabel.Size = UDim2.new(1, -20, 0, 20)
    selectedWaypointLabel.Position = UDim2.new(0, 10, 0, 94)
    selectedWaypointLabel.BackgroundTransparency = 1
    selectedWaypointLabel.TextColor3 = Color3.fromRGB(170, 210, 255)
    selectedWaypointLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedWaypointLabel.TextSize = 13
    selectedWaypointLabel.Font = Enum.Font.GothamBold
    tReg(selectedWaypointLabel, "wp_sel_none")
    selectedWaypointLabel.Parent = waypointScreen

    local waypointControl = Instance.new("Frame")
    waypointControl.Size = UDim2.new(1, -20, 0, 112)
    waypointControl.Position = UDim2.new(0, 10, 0, 120)
    waypointControl.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
    waypointControl.BorderSizePixel = 0
    waypointControl.Parent = waypointScreen
    createRounded(waypointControl, 10)

    local nameBox = Instance.new("TextBox")
    nameBox.Size = UDim2.new(1, -20, 0, 34)
    nameBox.Position = UDim2.new(0, 10, 0, 10)
    nameBox.BackgroundColor3 = Color3.fromRGB(34, 42, 63)
    nameBox.BorderSizePixel = 0
    nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameBox.PlaceholderColor3 = Color3.fromRGB(150, 165, 185)
    nameBox.PlaceholderText = t("wp_placeholder")
    nameBox.ClearTextOnFocus = false
    nameBox.Text = ""
    nameBox.TextSize = 13
    nameBox.Font = Enum.Font.Gotham
    nameBox.Parent = waypointControl
    createRounded(nameBox, 8)

    local createWaypointBtn = Instance.new("TextButton")
    createWaypointBtn.Size = UDim2.new(0.34, -8, 0, 32)
    createWaypointBtn.Position = UDim2.new(0, 10, 0, 52)
    createWaypointBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
    createWaypointBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    createWaypointBtn.TextSize = 13
    createWaypointBtn.Font = Enum.Font.GothamBold
    tReg(createWaypointBtn, "wp_create")
    createWaypointBtn.BorderSizePixel = 0
    createWaypointBtn.Parent = waypointControl
    createRounded(createWaypointBtn, 8)

    local tpWaypointBtn = Instance.new("TextButton")
    tpWaypointBtn.Size = UDim2.new(0.33, -8, 0, 32)
    tpWaypointBtn.Position = UDim2.new(0.34, 4, 0, 52)
    tpWaypointBtn.BackgroundColor3 = Color3.fromRGB(70, 170, 120)
    tpWaypointBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tpWaypointBtn.TextSize = 13
    tpWaypointBtn.Font = Enum.Font.GothamBold
    tReg(tpWaypointBtn, "wp_tp_sel")
    tpWaypointBtn.BorderSizePixel = 0
    tpWaypointBtn.Parent = waypointControl
    createRounded(tpWaypointBtn, 8)

    local deleteWaypointBtn = Instance.new("TextButton")
    deleteWaypointBtn.Size = UDim2.new(0.33, -8, 0, 32)
    deleteWaypointBtn.Position = UDim2.new(0.67, 0, 0, 52)
    deleteWaypointBtn.BackgroundColor3 = Color3.fromRGB(145, 45, 45)
    deleteWaypointBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    deleteWaypointBtn.TextSize = 13
    deleteWaypointBtn.Font = Enum.Font.GothamBold
    tReg(deleteWaypointBtn, "wp_delete")
    deleteWaypointBtn.BorderSizePixel = 0
    deleteWaypointBtn.Parent = waypointControl
    createRounded(deleteWaypointBtn, 8)

    local waypointStatusLabel = Instance.new("TextLabel")
    waypointStatusLabel.Size = UDim2.new(1, -20, 0, 18)
    waypointStatusLabel.Position = UDim2.new(0, 10, 0, 88)
    waypointStatusLabel.BackgroundTransparency = 1
    waypointStatusLabel.TextColor3 = Color3.fromRGB(185, 210, 240)
    waypointStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    waypointStatusLabel.TextSize = 12
    waypointStatusLabel.Font = Enum.Font.Gotham
    tReg(waypointStatusLabel, "wp_status_none")
    waypointStatusLabel.Parent = waypointControl

    local exportFrame = Instance.new("Frame")
    exportFrame.Size = UDim2.new(1, -20, 0, 108)
    exportFrame.Position = UDim2.new(0, 10, 0, 240)
    exportFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
    exportFrame.BorderSizePixel = 0
    exportFrame.Parent = waypointScreen
    createRounded(exportFrame, 10)

    local exportTitle = Instance.new("TextLabel")
    exportTitle.Size = UDim2.new(1, -280, 0, 24)
    exportTitle.Position = UDim2.new(0, 10, 0, 8)
    exportTitle.BackgroundTransparency = 1
    exportTitle.TextColor3 = Color3.fromRGB(190, 225, 255)
    exportTitle.TextXAlignment = Enum.TextXAlignment.Left
    exportTitle.TextSize = 12
    exportTitle.Font = Enum.Font.GothamBold
    tReg(exportTitle, "wp_export_title")
    exportTitle.Parent = exportFrame

    local refreshExportBtn = Instance.new("TextButton")
    refreshExportBtn.Size = UDim2.new(0, 126, 0, 24)
    refreshExportBtn.Position = UDim2.new(1, -272, 0, 8)
    refreshExportBtn.BackgroundColor3 = Color3.fromRGB(55, 95, 140)
    refreshExportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshExportBtn.TextSize = 12
    refreshExportBtn.Font = Enum.Font.GothamBold
    tReg(refreshExportBtn, "wp_generate")
    refreshExportBtn.BorderSizePixel = 0
    refreshExportBtn.Parent = exportFrame
    createRounded(refreshExportBtn, 7)

    local copyExportBtn = Instance.new("TextButton")
    copyExportBtn.Size = UDim2.new(0, 126, 0, 24)
    copyExportBtn.Position = UDim2.new(1, -136, 0, 8)
    copyExportBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
    copyExportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyExportBtn.TextSize = 12
    copyExportBtn.Font = Enum.Font.GothamBold
    tReg(copyExportBtn, "wp_copy")
    copyExportBtn.BorderSizePixel = 0
    copyExportBtn.Parent = exportFrame
    createRounded(copyExportBtn, 7)

    local exportBox = Instance.new("TextBox")
    exportBox.Size = UDim2.new(1, -20, 0, 64)
    exportBox.Position = UDim2.new(0, 10, 0, 36)
    exportBox.BackgroundColor3 = Color3.fromRGB(34, 42, 63)
    exportBox.BorderSizePixel = 0
    exportBox.TextColor3 = Color3.fromRGB(220, 235, 255)
    exportBox.PlaceholderColor3 = Color3.fromRGB(150, 165, 185)
    exportBox.PlaceholderText = t("wp_export_hint")
    exportBox.ClearTextOnFocus = false
    exportBox.Text = ""
    exportBox.TextSize = 12
    exportBox.Font = Enum.Font.Code
    exportBox.TextXAlignment = Enum.TextXAlignment.Left
    exportBox.TextYAlignment = Enum.TextYAlignment.Top
    exportBox.MultiLine = true
    exportBox.Parent = exportFrame
    createRounded(exportBox, 8)

    local waypointList = Instance.new("ScrollingFrame")
    waypointList.Size = UDim2.new(1, -20, 1, -408)
    waypointList.Position = UDim2.new(0, 10, 0, 356)
    waypointList.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
    waypointList.BorderSizePixel = 0
    waypointList.ScrollBarThickness = 6
    waypointList.CanvasSize = UDim2.new(0, 0, 0, 0)
    waypointList.Parent = waypointScreen
    createRounded(waypointList, 10)

    local waypointLayout = Instance.new("UIListLayout")
    waypointLayout.Padding = UDim.new(0, 8)
    waypointLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    waypointLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    waypointLayout.Parent = waypointList

    waypointLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        waypointList.CanvasSize = UDim2.new(0, 0, 0, waypointLayout.AbsoluteContentSize.Y + 10)
    end)

    local waypointBackBtn = Instance.new("TextButton")
    waypointBackBtn.Size = UDim2.new(0, 150, 0, 36)
    waypointBackBtn.Position = UDim2.new(0, 10, 1, -42)
    waypointBackBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    waypointBackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    waypointBackBtn.TextSize = 13
    waypointBackBtn.Font = Enum.Font.GothamBold
    tReg(waypointBackBtn, "wp_back_menu")
    waypointBackBtn.BorderSizePixel = 0
    waypointBackBtn.Parent = waypointScreen
    createRounded(waypointBackBtn, 8)

    local importRobberyBtn = Instance.new("TextButton")
    importRobberyBtn.Size = UDim2.new(0, 190, 0, 36)
    importRobberyBtn.Position = UDim2.new(1, -200, 1, -42)
    importRobberyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
    importRobberyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    importRobberyBtn.TextSize = 13
    importRobberyBtn.Font = Enum.Font.GothamBold
    tReg(importRobberyBtn, "wp_import")
    importRobberyBtn.BorderSizePixel = 0
    importRobberyBtn.Parent = waypointScreen
    createRounded(importRobberyBtn, 8)

    local function formatWaypointPos(pos)
        return string.format("X:%.1f Y:%.1f Z:%.1f", pos.X, pos.Y, pos.Z)
    end

    local function trimText(value)
        return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
    end

    local function insertWaypointUnique(name, pos, source)
        if not pos then
            return false, nil
        end

        local p = Vector3.new(pos.X, pos.Y, pos.Z)
        for _, waypoint in ipairs(state.waypoints) do
            local d = (Vector3.new(waypoint.pos.X, waypoint.pos.Y, waypoint.pos.Z) - p).Magnitude
            if d <= CONFIG.MAP_WAYPOINT_DUPLICATE_DISTANCE then
                return false, waypoint
            end
        end

        state.waypointCounter = state.waypointCounter + 1
        local newWaypoint = {
            id = state.waypointCounter,
            name = name or ("Waypoint " .. tostring(state.waypointCounter)),
            pos = p,
            source = source or "manual",
        }

        table.insert(state.waypoints, 1, newWaypoint)
        return true, newWaypoint
    end

    local function buildWaypointExportText()
        local lines = { "index;name;x;y;z" }
        if #state.waypoints == 0 then
            table.insert(lines, "-- Aucun waypoint --")
            return table.concat(lines, "\n")
        end

        for index, waypoint in ipairs(state.waypoints) do
            local safeName = (waypoint.name or ""):gsub("[;\r\n]", " ")
            table.insert(lines, string.format(
                "%d;%s;%.3f;%.3f;%.3f",
                index,
                safeName,
                waypoint.pos.X,
                waypoint.pos.Y,
                waypoint.pos.Z
            ))
        end

        return table.concat(lines, "\n")
    end

    local function refreshWaypointExport()
        exportBox.Text = buildWaypointExportText()
    end

    local function copyWaypointExportToClipboard(text)
        local ok, copied = pcall(function()
            if type(setclipboard) == "function" then
                setclipboard(text)
                return true
            end
            if type(toclipboard) == "function" then
                toclipboard(text)
                return true
            end
            if type(clipboard_copy) == "function" then
                clipboard_copy(text)
                return true
            end
            return false
        end)

        return ok and copied == true
    end

    local function refreshWaypointLiveLabels()
        local currentPos = getCurrentSavePosition()
        if currentPos then
            livePosLabel.Text = string.format(t("wp_live_fmt"), formatWaypointPos(currentPos))
        else
            livePosLabel.Text = t("wp_live_unavail")
        end

        local _, selected = findWaypointById(state.selectedWaypointId)
        if selected then
            local distInfo = ""
            if currentPos then
                local horizontalDistance = (
                    Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(selected.pos.X, 0, selected.pos.Z)
                ).Magnitude
                distInfo = string.format(" | Dist %.0f", horizontalDistance)
            end
            selectedWaypointLabel.Text = string.format(t("wp_sel_fmt"), selected.name, formatWaypointPos(selected.pos), distInfo)
        else
            selectedWaypointLabel.Text = t("wp_sel_none_dyn")
        end
    end

    local function refreshWaypointList()
        refreshWaypointExport()

        for _, child in ipairs(waypointList:GetChildren()) do
            if child:IsA("Frame") or child.Name == "EmptyWaypointsLabel" then
                child:Destroy()
            end
        end

        if #state.waypoints == 0 then
            local emptyLabel = Instance.new("TextLabel")
            emptyLabel.Name = "EmptyWaypointsLabel"
            emptyLabel.Size = UDim2.new(1, -14, 0, 40)
            emptyLabel.BackgroundTransparency = 1
            emptyLabel.TextColor3 = Color3.fromRGB(155, 170, 195)
            emptyLabel.TextSize = 13
            emptyLabel.Font = Enum.Font.Gotham
            emptyLabel.Text = "Aucun waypoint, cree ton premier point."
            emptyLabel.Parent = waypointList
            return
        end

        for index, waypoint in ipairs(state.waypoints) do
            local selected = state.selectedWaypointId == waypoint.id

            local row = Instance.new("Frame")
            row.Name = "WaypointRow"
            row.Size = UDim2.new(1, -14, 0, 72)
            row.BackgroundColor3 = selected and Color3.fromRGB(33, 78, 108) or Color3.fromRGB(35, 45, 70)
            row.BorderSizePixel = 0
            row.Parent = waypointList
            createRounded(row, 8)

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -220, 0, 24)
            nameLabel.Position = UDim2.new(0, 10, 0, 7)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.fromRGB(230, 245, 255)
            nameLabel.TextSize = 14
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Text = string.format("%d. %s", index, waypoint.name)
            nameLabel.Parent = row

            local posLabel = Instance.new("TextLabel")
            posLabel.Size = UDim2.new(1, -220, 0, 20)
            posLabel.Position = UDim2.new(0, 10, 0, 34)
            posLabel.BackgroundTransparency = 1
            posLabel.TextColor3 = Color3.fromRGB(170, 210, 255)
            posLabel.TextSize = 12
            posLabel.Font = Enum.Font.Gotham
            posLabel.TextXAlignment = Enum.TextXAlignment.Left
            posLabel.Text = formatWaypointPos(waypoint.pos)
            posLabel.Parent = row

            local selectBtn = Instance.new("TextButton")
            selectBtn.Size = UDim2.new(0, 58, 0, 28)
            selectBtn.Position = UDim2.new(1, -200, 0.5, -14)
            selectBtn.BackgroundColor3 = selected and Color3.fromRGB(0, 175, 245) or Color3.fromRGB(55, 75, 110)
            selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            selectBtn.TextSize = 12
            selectBtn.Font = Enum.Font.GothamBold
            selectBtn.Text = "SEL"
            selectBtn.BorderSizePixel = 0
            selectBtn.Parent = row
            createRounded(selectBtn, 7)

            local tpBtnRow = Instance.new("TextButton")
            tpBtnRow.Size = UDim2.new(0, 58, 0, 28)
            tpBtnRow.Position = UDim2.new(1, -134, 0.5, -14)
            tpBtnRow.BackgroundColor3 = Color3.fromRGB(70, 170, 120)
            tpBtnRow.TextColor3 = Color3.fromRGB(255, 255, 255)
            tpBtnRow.TextSize = 12
            tpBtnRow.Font = Enum.Font.GothamBold
            tpBtnRow.Text = "TP"
            tpBtnRow.BorderSizePixel = 0
            tpBtnRow.Parent = row
            createRounded(tpBtnRow, 7)

            local delBtnRow = Instance.new("TextButton")
            delBtnRow.Size = UDim2.new(0, 58, 0, 28)
            delBtnRow.Position = UDim2.new(1, -68, 0.5, -14)
            delBtnRow.BackgroundColor3 = Color3.fromRGB(145, 45, 45)
            delBtnRow.TextColor3 = Color3.fromRGB(255, 255, 255)
            delBtnRow.TextSize = 12
            delBtnRow.Font = Enum.Font.GothamBold
            delBtnRow.Text = "DEL"
            delBtnRow.BorderSizePixel = 0
            delBtnRow.Parent = row
            createRounded(delBtnRow, 7)

            selectBtn.MouseButton1Click:Connect(function()
                state.selectedWaypointId = waypoint.id
                setWaypointMarker(waypoint)
                refreshWaypointList()
                refreshWaypointLiveLabels()
                waypointStatusLabel.Text = string.format(t("wp_st_selected"), waypoint.name)
            end)

            tpBtnRow.MouseButton1Click:Connect(function()
                state.selectedWaypointId = waypoint.id
                setWaypointMarker(waypoint)
                refreshWaypointList()
                refreshWaypointLiveLabels()
                waypointStatusLabel.Text = string.format(t("wp_st_tp"), waypoint.name)
                task.spawn(function()
                    microTeleport(waypoint.pos, waypointStatusLabel, { walkMode = true })
                end)
            end)

            delBtnRow.MouseButton1Click:Connect(function()
                local removed = removeWaypointById(waypoint.id)
                if not removed then
                    return
                end

                if state.selectedWaypointId == waypoint.id then
                    state.selectedWaypointId = nil
                    clearWaypointMarker()
                end

                refreshWaypointList()
                refreshWaypointLiveLabels()
                waypointStatusLabel.Text = string.format(t("wp_st_deleted"), waypoint.name)
            end)
        end
    end

    createWaypointBtn.MouseButton1Click:Connect(function()
        local pos, src = getCurrentSavePosition()
        if not pos then
            waypointStatusLabel.Text = t("wp_st_impossible")
            return
        end

        state.waypointCounter = state.waypointCounter + 1
        local waypointName = trimText(nameBox.Text)
        if waypointName == "" then
            waypointName = "Waypoint " .. tostring(state.waypointCounter)
        end

        local newWaypoint = {
            id = state.waypointCounter,
            name = waypointName,
            pos = Vector3.new(pos.X, pos.Y, pos.Z),
            source = src,
        }

        table.insert(state.waypoints, 1, newWaypoint)
        state.selectedWaypointId = newWaypoint.id
        setWaypointMarker(newWaypoint)
        nameBox.Text = ""
        refreshWaypointList()
        refreshWaypointLiveLabels()
        waypointStatusLabel.Text = string.format(t("wp_st_created"), src, waypointName)
    end)

    tpWaypointBtn.MouseButton1Click:Connect(function()
        local _, selected = findWaypointById(state.selectedWaypointId)
        if not selected then
            waypointStatusLabel.Text = t("wp_st_sel_first")
            return
        end

        setWaypointMarker(selected)
        refreshWaypointLiveLabels()
        waypointStatusLabel.Text = string.format(t("wp_st_tp"), selected.name)
        task.spawn(function()
            microTeleport(selected.pos, waypointStatusLabel, { walkMode = true })
        end)
    end)

    deleteWaypointBtn.MouseButton1Click:Connect(function()
        local _, selected = findWaypointById(state.selectedWaypointId)
        if not selected then
            waypointStatusLabel.Text = t("wp_st_no_sel")
            return
        end

        local selectedName = selected.name
        removeWaypointById(selected.id)
        state.selectedWaypointId = nil
        clearWaypointMarker()
        refreshWaypointList()
        refreshWaypointLiveLabels()
        waypointStatusLabel.Text = string.format(t("wp_st_deleted"), selectedName)
    end)

    refreshExportBtn.MouseButton1Click:Connect(function()
        refreshWaypointExport()
        waypointStatusLabel.Text = t("wp_st_generated")
    end)

    copyExportBtn.MouseButton1Click:Connect(function()
        refreshWaypointExport()
        local textToCopy = exportBox.Text
        if textToCopy == "" then
            waypointStatusLabel.Text = t("wp_st_empty")
            return
        end

        if copyWaypointExportToClipboard(textToCopy) then
            waypointStatusLabel.Text = t("wp_st_copied")
            return
        end

        waypointStatusLabel.Text = t("wp_st_no_clip")
        exportBox:CaptureFocus()
    end)

    -- color: 1=braquage(rouge), 2=prison(orange), 3=divers(bleu)
    local PRESET_DESTINATIONS = {
        { nameKey = "dest_bateaux1", pos = Vector3.new( 1129.006, 28.810, 2334.301), color = 1 },
        { nameKey = "dest_bateaux2", pos = Vector3.new( 1135.699, 28.800, 2183.101), color = 1 },
        { nameKey = "dest_banque",   pos = Vector3.new(-1242.763,  7.856, 3146.274), color = 1 },
        { nameKey = "dest_bijouterie", pos = Vector3.new( -427.967, 21.395, 3555.956), color = 1 },
        { nameKey = "dest_nuits",    pos = Vector3.new(-1750.880, 11.243, 3017.405), color = 1 },
        { nameKey = "dest_prison",   pos = Vector3.new( -604.927,  9.833, 3051.886), color = 2 },
        { nameKey = "dest_garage",   pos = Vector3.new(-1441.704,  5.339,  138.320), color = 3 },
        { nameKey = "dest_conces",   pos = Vector3.new(-1404.890,  5.613,  991.290), color = 3 },
    }

    importRobberyBtn.MouseButton1Click:Connect(function()
        local addedCount = 0
        local lastAdded = nil

        for _, preset in ipairs(PRESET_DESTINATIONS) do
            local added, wp = insertWaypointUnique(t(preset.nameKey or "dest_banque"), preset.pos, "robbery")
            if added then
                addedCount = addedCount + 1
                lastAdded = wp
            end
        end

        if addedCount == 0 then
            waypointStatusLabel.Text = t("wp_st_no_new")
            return
        end

        state.selectedWaypointId = lastAdded and lastAdded.id or state.selectedWaypointId
        if lastAdded then
            setWaypointMarker(lastAdded)
        end
        refreshWaypointList()
        refreshWaypointLiveLabels()
        waypointStatusLabel.Text = string.format(t("wp_st_imported"), addedCount)
    end)

    waypointBackBtn.MouseButton1Click:Connect(function()
        showScreen("menu")
    end)

    local function makeMenuButton(text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 360, 0, 58)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 17
        btn.Font = Enum.Font.GothamBold
        btn.Text = text
        btn.BorderSizePixel = 0
        btn.Parent = menuScreen
        createRounded(btn, 10)

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(
                math.clamp(color.R * 255 + 20, 0, 255),
                math.clamp(color.G * 255 + 20, 0, 255),
                math.clamp(color.B * 255 + 20, 0, 255)
            )
        end)

        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = color
        end)

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local function addDestinationButton(tabKey, text, color, getTargetPosition, pingModel)
        local parent = tabContents[tabKey]
        if not parent then
            return
        end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 66)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(230, 245, 255)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = parent
        createRounded(btn, 8)

        -- Si pingModel fourni : layout avec nom + distance + bouton ping
        local btnDistLabel = nil
        if pingModel then
            btn.Text = ""

            local nameL = Instance.new("TextLabel")
            nameL.Size = UDim2.new(1, -50, 0, 32)
            nameL.Position = UDim2.new(0, 8, 0, 4)
            nameL.BackgroundTransparency = 1
            nameL.TextColor3 = Color3.fromRGB(230, 245, 255)
            nameL.TextSize = 12
            nameL.Font = Enum.Font.GothamBold
            nameL.TextXAlignment = Enum.TextXAlignment.Left
            nameL.TextTruncate = Enum.TextTruncate.AtEnd
            nameL.Text = text
            nameL.ZIndex = 2
            nameL.Parent = btn

            btnDistLabel = Instance.new("TextLabel")
            btnDistLabel.Size = UDim2.new(1, -50, 0, 22)
            btnDistLabel.Position = UDim2.new(0, 8, 0, 36)
            btnDistLabel.BackgroundTransparency = 1
            btnDistLabel.TextColor3 = Color3.fromRGB(140, 200, 170)
            btnDistLabel.TextSize = 11
            btnDistLabel.Font = Enum.Font.Gotham
            btnDistLabel.TextXAlignment = Enum.TextXAlignment.Left
            btnDistLabel.ZIndex = 2
            btnDistLabel.Parent = btn

            -- Distance initiale
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local root = pingModel:IsA("Model")
                and (pingModel.PrimaryPart or pingModel:FindFirstChildWhichIsA("BasePart"))
                or (pingModel:IsA("BasePart") and pingModel or nil)
            if hrp and root then
                local d = (root.Position - hrp.Position).Magnitude
                btnDistLabel.Text = string.format("📍 %.0f studs", d)
            else
                btnDistLabel.Text = ""
            end

            -- Bouton ping
            local pingActive = state.vehiclePings[pingModel] ~= nil
            local pingBtn = Instance.new("TextButton")
            pingBtn.Size = UDim2.new(0, 40, 0, 58)
            pingBtn.Position = UDim2.new(1, -46, 0, 4)
            pingBtn.BackgroundColor3 = pingActive and Color3.fromRGB(0, 160, 80) or Color3.fromRGB(38, 52, 70)
            pingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pingBtn.TextSize = 14
            pingBtn.Font = Enum.Font.GothamBold
            pingBtn.Text = "📍"
            pingBtn.BorderSizePixel = 0
            pingBtn.ZIndex = 3
            pingBtn.Parent = btn
            createRounded(pingBtn, 6)

            pingBtn.MouseButton1Click:Connect(function()
                if state.vehiclePings[pingModel] then
                    removeVehiclePing(pingModel)
                    pingBtn.BackgroundColor3 = Color3.fromRGB(38, 52, 70)
                else
                    -- Passe le label distance pour mise a jour temps reel
                    createVehiclePing(pingModel)
                    if state.vehiclePings[pingModel] then
                        state.vehiclePings[pingModel].btnDistLabel = btnDistLabel
                    end
                    pingBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 80)
                end
            end)
        else
            btn.Text = text
        end

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(
                math.clamp(color.R * 255 + 15, 0, 255),
                math.clamp(color.G * 255 + 15, 0, 255),
                math.clamp(color.B * 255 + 15, 0, 255)
            )
        end)

        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = color
        end)

        btn.MouseButton1Click:Connect(function()
            local result = getTargetPosition()
            local targetPos = result
            local customStatus = nil
            local customTpOptions = nil
            local onSelect = nil

            if typeof(result) == "table" then
                targetPos = result.pos
                customStatus = result.statusText
                customTpOptions = result.tpOptions
                onSelect = result.onSelect
            end

            if onSelect then
                onSelect()
                refreshModeButtons()
            end

            if not targetPos then
                statusLabel.Text = t("status_unavail")
                return
            end

            statusLabel.Text = customStatus or ("TP vers " .. text .. " ...")
            task.spawn(function()
                microTeleport(targetPos, statusLabel, customTpOptions)
            end)
        end)

        -- Bouton TP instant (visible seulement si <= 50 studs)
        local instantBtn = Instance.new("TextButton")
        instantBtn.Size = UDim2.new(1, 0, 0, 24)
        instantBtn.Position = UDim2.new(0, 0, 0, 66)
        instantBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 90)
        instantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        instantBtn.TextSize = 12
        instantBtn.Font = Enum.Font.GothamBold
        instantBtn.Text = t("btn_instant")
        instantBtn.BorderSizePixel = 0
        instantBtn.ZIndex = 4
        instantBtn.Visible = false
        instantBtn.Parent = btn
        createRounded(instantBtn, 5)
        local instGrad = Instance.new("UIGradient")
        instGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 230, 110)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 60)),
        })
        instGrad.Rotation = 90
        instGrad.Parent = instantBtn
        local instStroke = Instance.new("UIStroke")
        instStroke.Color = Color3.fromRGB(80, 255, 150)
        instStroke.Transparency = 0.6
        instStroke.Thickness = 1
        instStroke.Parent = instantBtn

        instantBtn.MouseButton1Click:Connect(function()
            local result = getTargetPosition()
            local targetPos = typeof(result) == "table" and result.pos or result
            if not targetPos then return end
            local vehicle = findVehicle()
            if vehicle then
                local root = getVehicleRoot(vehicle)
                if root then
                    local halfH = getVehicleHalfHeight(vehicle)
                    local dest = Vector3.new(targetPos.X, targetPos.Y + halfH, targetPos.Z)
                    root.CFrame = CFrame.new(dest) * CFrame.Angles(0, root.CFrame:ToEulerAnglesYXZ())
                    statusLabel.Text = t("status_instant") .. text
                end
            else
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(targetPos)
                    statusLabel.Text = t("status_instant") .. text
                end
            end
        end)

        -- Bouton TP TOIT (visible a <= 25 studs)
        local roofBtn = Instance.new("TextButton")
        roofBtn.Size = UDim2.new(0.5, -1, 0, 24)
        roofBtn.Position = UDim2.new(0.5, 1, 0, 66)
        roofBtn.BackgroundColor3 = Color3.fromRGB(200, 110, 0)
        roofBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        roofBtn.TextSize = 12
        roofBtn.Font = Enum.Font.GothamBold
        roofBtn.Text = t("btn_roof")
        roofBtn.BorderSizePixel = 0
        roofBtn.ZIndex = 4
        roofBtn.Visible = false
        roofBtn.Parent = btn
        createRounded(roofBtn, 5)
        local roofGrad = Instance.new("UIGradient")
        roofGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 140, 20)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 75, 0)),
        })
        roofGrad.Rotation = 90
        roofGrad.Parent = roofBtn
        local roofStroke = Instance.new("UIStroke")
        roofStroke.Color = Color3.fromRGB(255, 190, 60)
        roofStroke.Transparency = 0.6
        roofStroke.Thickness = 1
        roofStroke.Parent = roofBtn

        -- Ajuster instant a moitie du bouton
        instantBtn.Size = UDim2.new(0.5, -1, 0, 24)
        instantBtn.Position = UDim2.new(0, 0, 0, 66)

        roofBtn.MouseButton1Click:Connect(function()
            local result = getTargetPosition()
            local targetPos = typeof(result) == "table" and result.pos or result
            if not targetPos then return end
            -- Raycast depuis le haut pour trouver le toit
            local rayOrigin = Vector3.new(targetPos.X, targetPos.Y + 300, targetPos.Z)
            local rayResult = workspace:Raycast(rayOrigin, Vector3.new(0, -350, 0))
            local destPos = targetPos
            if rayResult then
                local vehicle = findVehicle()
                local halfH = vehicle and getVehicleHalfHeight(vehicle) or 3
                destPos = Vector3.new(targetPos.X, rayResult.Position.Y + halfH + 0.5, targetPos.Z)
            end
            local vehicle = findVehicle()
            if vehicle then
                local root = getVehicleRoot(vehicle)
                if root then
                    root.CFrame = CFrame.new(destPos) * CFrame.Angles(0, root.CFrame:ToEulerAnglesYXZ())
                end
            else
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = CFrame.new(destPos) end
            end
            statusLabel.Text = t("status_roof") .. text
        end)

        -- Boucle de proximite pour afficher/cacher les boutons
        task.spawn(function()
            while btn and btn.Parent do
                local result = getTargetPosition()
                local targetPos = typeof(result) == "table" and result.pos or result
                local isFallback = typeof(result) == "table" and result.isFallback
                if targetPos then
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if isFallback then
                            instantBtn.Visible = false
                            roofBtn.Visible    = false
                            if btnDistLabel and btnDistLabel.Parent then
                                btnDistLabel.Text = string.format("📍 hors portée  X:%.0f  Z:%.0f", targetPos.X, targetPos.Z)
                                btnDistLabel.TextColor3 = Color3.fromRGB(220, 170, 60)
                            end
                        else
                            local dist = (Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z) - hrp.Position).Magnitude
                            instantBtn.Visible = dist <= 50
                            roofBtn.Visible    = dist <= 25
                        end
                    end
                else
                    instantBtn.Visible = false
                    roofBtn.Visible    = false
                end
                task.wait(0.5)
            end
        end)

        return btn
    end

    local function categorize(name)
        local n = name:lower()
        if n:find("dealer") or n:find("drug") then
            return "dealer"
        end
        return "building"
    end

    local function isAutoRobberyName(name)
        local n = name:lower()
        return n:find("robbery")
            or n:find("bank")
            or n:find("jewel")
            or n:find("gas")
            or n:find("store")
    end

    local function loadBuildings()
        local buildingsFolder = workspace:FindFirstChild("Buildings")
        if not buildingsFolder then
            return
        end

        for _, item in ipairs(buildingsFolder:GetChildren()) do
            if item:IsA("Folder") or item:IsA("Model") then
                if isAutoRobberyName(item.Name) then
                    continue
                end

                local tabKey = categorize(item.Name)
                local color = tabKey == "dealer" and Color3.fromRGB(65, 110, 65)
                    or Color3.fromRGB(40, 56, 88)

                addDestinationButton(tabKey, item.Name, color, function()
                    local part = findBasePart(item)
                    if not part then
                        return nil
                    end
                    return {
                        pos = part.Position,
                    }
                end, tabKey == "dealer" and item or nil)
            end
        end
    end


    local function loadPresetDestinations()
        local colorMap = {
            [1] = Color3.fromRGB(125, 65,  65),  -- braquage: rouge
            [2] = Color3.fromRGB(160, 90,  30),  -- prison: orange
            [3] = Color3.fromRGB( 40, 80, 140),  -- divers: bleu
        }
        local btnIndex = 0

        for _, preset in ipairs(PRESET_DESTINATIONS) do
            btnIndex = btnIndex + 1
            local color = colorMap[preset.color] or colorMap[1]
            local captured = preset
            local idx = btnIndex
            local btn = addDestinationButton("robbery", "", color, function()
                local name = t(captured.nameKey)
                return {
                    pos = captured.pos,
                    statusText = string.format(
                        "%s | X:%.1f Y:%.1f Z:%.1f",
                        name, captured.pos.X, captured.pos.Y, captured.pos.Z
                    ),
                    tpOptions = { exactTargetY = true },
                }
            end)
            if btn then
                -- Enregistre le bouton pour mise a jour dynamique via tReg personnalise
                local function updatePresetBtnText()
                    local name = t(captured.nameKey)
                    btn.Text = string.format("%d. %s | X:%.0f Y:%.0f Z:%.0f",
                        idx, name, captured.pos.X, captured.pos.Y, captured.pos.Z)
                end
                updatePresetBtnText()
                table.insert(langLabels, { inst = nil, key = captured.nameKey, updateFn = updatePresetBtnText })
            end
        end
    end

    local function addHomeDestination()
        local homeBtn = addDestinationButton("building", t("dest_home"), Color3.fromRGB(70, 100, 160), function()
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local p = hrp.Position
                return {
                    pos = p,
                    statusText = string.format("HOME | X:%.0f Y:%.0f Z:%.0f", p.X, p.Y, p.Z),
                    tpOptions = { walkMode = true },
                }
            end

            local spawn = player.RespawnLocation or workspace:FindFirstChildOfClass("SpawnLocation")
            if spawn then
                local p = spawn.Position
                return {
                    pos = p,
                    statusText = string.format("HOME Spawn | X:%.0f Y:%.0f Z:%.0f", p.X, p.Y, p.Z),
                }
            end

            return nil
        end)
        if homeBtn then tReg(homeBtn, "dest_home") end
    end

    local function refreshDealers()
        local dealersFolder = workspace:FindFirstChild("Dealers")
        if not dealersFolder then return 0 end

        local addedCount = 0

        -- Passe 1 : modeles avec Humanoid
        local foundWithHumanoid = false
        for _, dealer in ipairs(dealersFolder:GetDescendants()) do
            if dealer:IsA("Model") and dealer:FindFirstChildOfClass("Humanoid") then
                foundWithHumanoid = true
                if not knownDealers[dealer] then
                    knownDealers[dealer] = true
                    local captured = dealer
                    local lastKnownPos = nil
                    addDestinationButton("dealer", captured.Name, Color3.fromRGB(65, 110, 65), function()
                        local part = findBasePart(captured)
                        if part then
                            lastKnownPos = part.Position
                            return { pos = part.Position }
                        end
                        if lastKnownPos then
                            return { pos = lastKnownPos, isFallback = true }
                        end
                        return nil
                    end, captured)
                    addedCount = addedCount + 1
                end
            end
        end

        -- Passe 2 (fallback) : si aucun Humanoid trouve, prendre tous les modeles
        if not foundWithHumanoid then
            for _, dealer in ipairs(dealersFolder:GetChildren()) do
                if dealer:IsA("Model") and not knownDealers[dealer] then
                    knownDealers[dealer] = true
                    local captured = dealer
                    local lastKnownPos = nil
                    addDestinationButton("dealer", captured.Name, Color3.fromRGB(65, 110, 65), function()
                        local part = findBasePart(captured)
                        if part then
                            lastKnownPos = part.Position
                            return { pos = part.Position }
                        end
                        if lastKnownPos then
                            return { pos = lastKnownPos, isFallback = true }
                        end
                        return nil
                    end, captured)
                    addedCount = addedCount + 1
                end
            end
        end

        return addedCount
    end

    local function loadDealersFolder()
        local dealersFolder = workspace:FindFirstChild("Dealers")
        if dealersFolder then
            refreshDealers()
        else
            task.spawn(function()
                local found = workspace:WaitForChild("Dealers", 10)
                if found then
                    refreshDealers()
                end
            end)
        end

        -- Connecter le bouton refresh
        if dealerRefreshBtn then
            dealerRefreshBtn.MouseButton1Click:Connect(function()
                dealerRefreshBtn.Text = "⏳  Scan en cours..."
                dealerRefreshBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 20)
                local n = refreshDealers()
                task.wait(0.4)
                if n > 0 then
                    dealerRefreshBtn.Text = string.format("✅  +%d dealer(s) ajouté(s)", n)
                else
                    dealerRefreshBtn.Text = "🔄  Aucun nouveau dealer"
                end
                task.wait(2)
                dealerRefreshBtn.Text = "🔄  Actualiser les dealers"
                dealerRefreshBtn.BackgroundColor3 = Color3.fromRGB(30, 70, 40)
            end)
        end
    end

    local VEHICLE_IMAGES = {
        ["wolfsburg marin"]              = "rbxassetid://136954682361477",
        ["wolfsburg discovery"]          = "rbxassetid://122748784320202",
        ["wolfsburg classic"]            = "rbxassetid://110059610469692",
        ["bkm 1 series cabriolet"]       = "rbxassetid://112313814318039",
        ["bkm 1200 tourer"]              = "rbxassetid://133198444458637",
        ["quad"]                         = "rbxassetid://71059559323691",
        ["wolfsburg handel"]             = "rbxassetid://118821587795127",
        ["avantismo s5"]                 = "rbxassetid://113139066871015",
        ["wolfsburg karen"]              = "rbxassetid://86036843509559",
        ["utv"]                          = "rbxassetid://92900661682348",
        ["stuttgart w123"]               = "rbxassetid://71240751312893",
        ["nordforge striker 450"]        = "rbxassetid://90183714198895",
        ["stuttgart kasten"]             = "rbxassetid://92830230563452",
        ["stuttgart ekasten"]            = "rbxassetid://138346512135759",
        ["stuttgart executive"]          = "rbxassetid://83078299137593",
        ["avantismo a3"]                 = "rbxassetid://84119312202792",
        ["stuttgart jogger"]             = "rbxassetid://136954289219952",
        ["wolfsburg t6"]                 = "rbxassetid://130052167450404",
        ["bkm m3 e90"]                   = "rbxassetid://85315453493112",
        ["stuttgart gma 63"]             = "rbxassetid://82501332308157",
        ["vellfire xy6"]                 = "rbxassetid://86780823921686",
        ["falcon traveller"]             = "rbxassetid://101541756629366",
        ["wolfsburg pick-up"]            = "rbxassetid://130464748199250",
        ["avantismo q4 electron"]        = "rbxassetid://117222789599282",
        ["tractor"]                      = "rbxassetid://111202381452906",
        ["cuvora atrica"]                = "rbxassetid://99792532607274",
        ["avantismo a6"]                 = "rbxassetid://110620350619431",
        ["celestial type s"]             = "rbxassetid://85180380274141",
        ["avantismo q5"]                 = "rbxassetid://72786552206019",
        ["vellfire r1"]                  = "rbxassetid://94219986437325",
        ["stuttgart gma c63 facelift"]   = "rbxassetid://102223289380423",
        ["bkm m2"]                       = "rbxassetid://106918702540098",
        ["stuttgart landschaft"]         = "rbxassetid://97727653328630",
        ["avantismo r8"]                 = "rbxassetid://73212357665071",
        ["stuttgart gma roadster"]       = "rbxassetid://111967777105631",
        ["bkm x3"]                       = "rbxassetid://109993024692705",
        ["bkm m5"]                       = "rbxassetid://129744716451596",
        ["stuttgart gma sport"]          = "rbxassetid://91554778867581",
        ["bkm m3 g80"]                   = "rbxassetid://87539218007954",
        ["ferdinand 911"]                = "rbxassetid://134717429142107",
        ["ferdinand 911 cabriolet"]      = "rbxassetid://137813994499303",
        ["stuttgart gma commute"]        = "rbxassetid://116615567513165",
        ["bullhorn prancer sfp fury"]    = "rbxassetid://77610409837699",
        ["avantismo rs4"]                = "rbxassetid://84621492587361",
        ["ferdinand jalapeno"]           = "rbxassetid://82966408195579",
        ["silhouette urano"]             = "rbxassetid://134910445352825",
        ["maranello catania"]            = "rbxassetid://71354116425947",
        ["chryslus champion limousine"]  = "rbxassetid://121955033294438",
        ["ferdinand vivo"]               = "rbxassetid://112505363404417",
        ["stuttgart royal majestic"]     = "rbxassetid://76122451173112",
        ["silhouette carbon"]            = "rbxassetid://122241004372489",
        ["mauntley national gt"]         = "rbxassetid://139555617429662",
        ["strugatti ettore"]             = "rbxassetid://135449333925410",
        ["nyberg eskon"]                 = "rbxassetid://131958370992616",
    }
    local function getVehicleImage(name)
        local key = string.lower(name):gsub("_", " "):gsub("%s+", " "):match("^%s*(.-)%s*$")
        return VEHICLE_IMAGES[key]
    end

    -- Retourne la liste des { name, seat, isDriver } pour un vehicle
    local function getVehicleOccupants(veh)
        local result = {}
        for _, seat in ipairs(veh:GetDescendants()) do
            if (seat:IsA("VehicleSeat") or seat:IsA("Seat")) and seat.Occupant then
                local hum = seat.Occupant
                local isDriver = seat:IsA("VehicleSeat")
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("Humanoid") == hum then
                        local role = getPlayerRoleLabel(p)
                        table.insert(result, { name = p.Name, seat = seat.Name, isDriver = isDriver, role = role })
                        break
                    end
                end
            end
        end
        -- Conducteur en premier
        table.sort(result, function(a, b) return (a.isDriver and 1 or 0) > (b.isDriver and 1 or 0) end)
        return result
    end

    -- ===== POPUP DETAILS VEHICULE (persistant dans main) =====
    local vehDetailsPopup = Instance.new("Frame")
    vehDetailsPopup.Name = "VehicleDetailsPopup"
    vehDetailsPopup.Size = UDim2.new(0, 290, 0, 30)
    vehDetailsPopup.Position = UDim2.new(0, 400, 0, 60)
    vehDetailsPopup.BackgroundColor3 = Color3.fromRGB(14, 18, 30)
    vehDetailsPopup.BorderSizePixel = 0
    vehDetailsPopup.Visible = false
    vehDetailsPopup.ZIndex = 15
    vehDetailsPopup.Parent = main
    createRounded(vehDetailsPopup, 10)

    local vdpStroke = Instance.new("UIStroke")
    vdpStroke.Color = Color3.fromRGB(255, 200, 60)
    vdpStroke.Thickness = 1.5
    vdpStroke.Parent = vehDetailsPopup

    local vdpTitle = Instance.new("TextLabel")
    vdpTitle.Size = UDim2.new(1, -40, 0, 26)
    vdpTitle.Position = UDim2.new(0, 8, 0, 4)
    vdpTitle.BackgroundTransparency = 1
    vdpTitle.TextColor3 = Color3.fromRGB(255, 220, 60)
    vdpTitle.TextSize = 13
    vdpTitle.Font = Enum.Font.GothamBold
    vdpTitle.TextXAlignment = Enum.TextXAlignment.Left
    vdpTitle.Text = "---"
    vdpTitle.ZIndex = 16
    vdpTitle.Parent = vehDetailsPopup

    local vdpCloseBtn = Instance.new("TextButton")
    vdpCloseBtn.Size = UDim2.new(0, 26, 0, 26)
    vdpCloseBtn.Position = UDim2.new(1, -30, 0, 4)
    vdpCloseBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
    vdpCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    vdpCloseBtn.TextSize = 14
    vdpCloseBtn.Font = Enum.Font.GothamBold
    vdpCloseBtn.Text = "✕"
    vdpCloseBtn.BorderSizePixel = 0
    vdpCloseBtn.ZIndex = 16
    vdpCloseBtn.Parent = vehDetailsPopup
    createRounded(vdpCloseBtn, 6)

    vdpCloseBtn.MouseButton1Click:Connect(function()
        vehDetailsPopup.Visible = false
    end)

    local vdpSpeedLine = Instance.new("TextLabel")
    vdpSpeedLine.Size = UDim2.new(1, -16, 0, 18)
    vdpSpeedLine.Position = UDim2.new(0, 8, 0, 34)
    vdpSpeedLine.BackgroundTransparency = 1
    vdpSpeedLine.TextColor3 = Color3.fromRGB(100, 220, 255)
    vdpSpeedLine.TextSize = 12
    vdpSpeedLine.Font = Enum.Font.GothamBold
    vdpSpeedLine.TextXAlignment = Enum.TextXAlignment.Left
    vdpSpeedLine.Text = ""
    vdpSpeedLine.ZIndex = 16
    vdpSpeedLine.Parent = vehDetailsPopup

    local vdpOccLines = {}
    for i = 1, 6 do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -16, 0, 17)
        lbl.Position = UDim2.new(0, 8, 0, 56 + (i - 1) * 18)
        lbl.BackgroundTransparency = 1
        lbl.TextSize = 12
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Text = ""
        lbl.Visible = false
        lbl.ZIndex = 16
        lbl.Parent = vehDetailsPopup
        vdpOccLines[i] = lbl
    end

    local currentDetailsVeh = nil

    local function openDetailsPopup(veh)
        currentDetailsVeh = veh
        local root = veh:IsA("Model") and (veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")) or veh
        -- Titre
        vdpTitle.Text = t("veh_details_title") .. "  —  " .. veh.Name
        -- Vitesse
        local speedKmh = 0
        if root then
            speedKmh = math.floor(root.AssemblyLinearVelocity.Magnitude * 1.071)
        end
        vdpSpeedLine.Text = string.format(t("veh_speed_label"), speedKmh)
        -- Occupants
        local occs = getVehicleOccupants(veh)
        local lineCount = 0
        for i = 1, 6 do
            local occ = occs[i]
            if occ then
                local roleTag = (occ.role and occ.role ~= "" and occ.role ~= "—") and (" [" .. occ.role .. "]") or ""
                if occ.isDriver then
                    vdpOccLines[i].Text = t("veh_driver_label") .. "  " .. occ.name .. roleTag
                    vdpOccLines[i].TextColor3 = Color3.fromRGB(255, 220, 60)
                else
                    vdpOccLines[i].Text = t("veh_passenger_label") .. "  " .. occ.name .. roleTag
                    vdpOccLines[i].TextColor3 = Color3.fromRGB(200, 200, 200)
                end
                vdpOccLines[i].Visible = true
                lineCount = i
            else
                vdpOccLines[i].Text = ""
                vdpOccLines[i].Visible = false
            end
        end
        if lineCount == 0 then
            vdpOccLines[1].Text = t("veh_no_occupants")
            vdpOccLines[1].TextColor3 = Color3.fromRGB(150, 150, 150)
            vdpOccLines[1].Visible = true
            lineCount = 1
        end
        -- Resize popup
        local totalH = 56 + lineCount * 18 + 8
        vehDetailsPopup.Size = UDim2.new(0, 290, 0, totalH)
        vehDetailsPopup.Visible = true
    end

    -- Boucle de rafraichissement du popup details (vitesse live)
    task.spawn(function()
        while main.Parent do
            task.wait(0.3)
            if vehDetailsPopup.Visible and currentDetailsVeh and currentDetailsVeh.Parent then
                pcall(function()
                    local root = currentDetailsVeh:IsA("Model") and
                        (currentDetailsVeh.PrimaryPart or currentDetailsVeh:FindFirstChildWhichIsA("BasePart"))
                        or currentDetailsVeh
                    if root then
                        local speedKmh = math.floor(root.AssemblyLinearVelocity.Magnitude * 1.071)
                        vdpSpeedLine.Text = string.format(t("veh_speed_label"), speedKmh)
                    end
                end)
            end
        end
    end)

    local function refreshVehiclesTab()
        local vehiclesFrame = tabContents.vehicles
        if not vehiclesFrame then return end

        for _, child in ipairs(vehiclesFrame:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end
        end

        local vehiclesFolder = workspace:FindFirstChild("Vehicles")
        if not vehiclesFolder then
            statusLabel.Text = t("status_no_veh_folder")
            return
        end

        for _, veh in ipairs(vehiclesFolder:GetChildren()) do
            if not (veh:IsA("Model") or veh:IsA("BasePart")) then continue end

            local root = veh:IsA("Model") and (veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")) or veh
            if not root then continue end

            local pos = root.Position

            -- Lecture des attributs
            local rimVal    = veh:GetAttribute("rim")          or "?"
            local fuelVal   = veh:GetAttribute("currentFuel")  or "?"
            local healthVal = veh:GetAttribute("currentHealth") or "?"

            local fuelNum   = tonumber(fuelVal)
            local healthNum = tonumber(healthVal)

            -- Couleur dot fuel (vert>jaune>rouge)
            local fuelColor = Color3.fromRGB(80, 220, 120)
            if fuelNum then
                if fuelNum < 20 then fuelColor = Color3.fromRGB(220, 60, 60)
                elseif fuelNum < 50 then fuelColor = Color3.fromRGB(240, 190, 40) end
            end

            -- Occupants
            local occupants = veh:IsA("Model") and getVehicleOccupants(veh) or {}
            local isOccupied = #occupants > 0

            local btnColor = isOccupied and Color3.fromRGB(48, 38, 18) or Color3.fromRGB(30, 48, 38)
            local cardHeight = isOccupied and 96 or 76
            local vBtn = Instance.new("TextButton")
            vBtn.Size = UDim2.new(1, 0, 0, cardHeight)
            vBtn.BackgroundColor3 = btnColor
            vBtn.Text = ""
            vBtn.BorderSizePixel = 0
            vBtn.Parent = vehiclesFrame
            createRounded(vBtn, 8)

            -- Image du vehicule (si correspondance sur nom ou rim)
            local imgId = getVehicleImage(veh.Name) or getVehicleImage(tostring(rimVal))
            local xOff = 0
            if imgId then
                xOff = 74
                local imgLabel = Instance.new("ImageLabel")
                imgLabel.Size = UDim2.new(0, 70, 0, 70)
                imgLabel.Position = UDim2.new(0, 2, 0, 3)
                imgLabel.BackgroundTransparency = 1
                imgLabel.Image = imgId
                imgLabel.ScaleType = Enum.ScaleType.Fit
                imgLabel.ZIndex = 2
                imgLabel.Parent = vBtn
            end

            -- Dot etat
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 12, 0, 12)
            dot.Position = UDim2.new(0, 10 + xOff, 0, 10)
            dot.BackgroundColor3 = fuelColor
            dot.BorderSizePixel = 0
            dot.ZIndex = 2
            dot.Parent = vBtn
            createRounded(dot, 6)

            -- Ligne 1 : nom + position
            local lblName = Instance.new("TextLabel")
            lblName.Size = UDim2.new(1, -30 - xOff, 0, 28)
            lblName.Position = UDim2.new(0, 26 + xOff, 0, 4)
            lblName.BackgroundTransparency = 1
            lblName.TextColor3 = Color3.fromRGB(200, 240, 210)
            lblName.TextSize = 12
            lblName.Font = Enum.Font.GothamBold
            lblName.TextXAlignment = Enum.TextXAlignment.Left
            lblName.Text = string.format("%s  |  X:%.0f Y:%.0f Z:%.0f", veh.Name, pos.X, pos.Y, pos.Z)
            lblName.ZIndex = 2
            lblName.Parent = vBtn

            -- Separateur interne
            local sep = Instance.new("Frame")
            sep.Size = UDim2.new(1, -20 - xOff, 0, 1)
            sep.Position = UDim2.new(0, 10 + xOff, 0, 34)
            sep.BackgroundColor3 = Color3.fromRGB(50, 80, 60)
            sep.BorderSizePixel = 0
            sep.ZIndex = 2
            sep.Parent = vBtn

            -- Ligne 2 : rim + fuel + health
            local fuelStr   = fuelNum   and string.format("%.1f", fuelNum)   or tostring(fuelVal)
            local healthStr = healthNum and string.format("%.1f", healthNum) or tostring(healthVal)

            local lblInfo = Instance.new("TextLabel")
            lblInfo.Size = UDim2.new(1, -16 - xOff, 0, 34)
            lblInfo.Position = UDim2.new(0, 10 + xOff, 0, 38)
            lblInfo.BackgroundTransparency = 1
            lblInfo.TextColor3 = Color3.fromRGB(160, 210, 180)
            lblInfo.TextSize = 11
            lblInfo.Font = Enum.Font.Gotham
            lblInfo.TextXAlignment = Enum.TextXAlignment.Left
            lblInfo.Text = string.format("⚙ Rim: %s     ⛽ Fuel: %s     ❤ Health: %s", tostring(rimVal), fuelStr, healthStr)
            lblInfo.ZIndex = 2
            lblInfo.Parent = vBtn

            -- Ligne occupants (si vehicle occupé)
            if isOccupied then
                local names = {}
                for _, occ in ipairs(occupants) do
                    local roleTag = (occ.role and occ.role ~= "" and occ.role ~= "—") and (" [" .. occ.role .. "]") or ""
                    local label = occ.isDriver and ("🚗 " .. occ.name .. roleTag) or ("👤 " .. occ.name .. roleTag)
                    table.insert(names, label)
                end
                local lblOcc = Instance.new("TextLabel")
                lblOcc.Size = UDim2.new(1, -16 - xOff, 0, 16)
                lblOcc.Position = UDim2.new(0, 10 + xOff, 0, 76)
                lblOcc.BackgroundTransparency = 1
                lblOcc.TextColor3 = Color3.fromRGB(255, 200, 80)
                lblOcc.TextSize = 11
                lblOcc.Font = Enum.Font.GothamBold
                lblOcc.TextXAlignment = Enum.TextXAlignment.Left
                lblOcc.TextTruncate = Enum.TextTruncate.AtEnd
                lblOcc.Text = "👤 " .. table.concat(names, "  •  ")
                lblOcc.ZIndex = 2
                lblOcc.Parent = vBtn
            end

            -- Bouton PING
            local pingActive = state.vehiclePings[veh] ~= nil
            local pingBtn = Instance.new("TextButton")
            pingBtn.Size = UDim2.new(0, 46, 1, -8)
            pingBtn.Position = UDim2.new(1, -202, 0, 4)
            pingBtn.BackgroundColor3 = pingActive and Color3.fromRGB(0, 160, 80) or Color3.fromRGB(38, 52, 70)
            pingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pingBtn.TextSize = 14
            pingBtn.Font = Enum.Font.GothamBold
            pingBtn.Text = "📍"
            pingBtn.BorderSizePixel = 0
            pingBtn.ZIndex = 3
            pingBtn.Parent = vBtn
            createRounded(pingBtn, 6)

            pingBtn.MouseButton1Click:Connect(function()
                if state.vehiclePings[veh] then
                    removeVehiclePing(veh)
                    pingBtn.BackgroundColor3 = Color3.fromRGB(38, 52, 70)
                else
                    createVehiclePing(veh)
                    pingBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 80)
                end
            end)

            -- Bouton CIBLE (suit le vehicle, orbit)
            local vehRoot = veh:IsA("Model") and (veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")) or veh
            local targetActive = state.followTargetPart == vehRoot
            local targetBtn = Instance.new("TextButton")
            targetBtn.Size = UDim2.new(0, 46, 1, -8)
            targetBtn.Position = UDim2.new(1, -152, 0, 4)
            targetBtn.BackgroundColor3 = targetActive and Color3.fromRGB(200, 60, 0) or Color3.fromRGB(38, 52, 70)
            targetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            targetBtn.TextSize = 14
            targetBtn.Font = Enum.Font.GothamBold
            targetBtn.Text = "🎯"
            targetBtn.BorderSizePixel = 0
            targetBtn.ZIndex = 3
            targetBtn.Parent = vBtn
            createRounded(targetBtn, 6)

            targetBtn.MouseButton1Click:Connect(function()
                local root = veh:IsA("Model") and (veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")) or veh
                if not root then return end
                if state.followTargetPart == root then
                    -- Desactiver
                    state.followEnabled = false
                    state.followTargetPart = nil
                    stopTrollNoClipAndResolve()
                    refreshModeButtons()
                    targetBtn.BackgroundColor3 = Color3.fromRGB(38, 52, 70)
                    statusLabel.Text = t("status_orbit_veh_off")
                else
                    local localVehicle = findVehicle()
                    if not localVehicle or not isLocalPlayerSeatedInVehicle(localVehicle) then
                        statusLabel.Text = t("status_no_veh")
                        return
                    end
                    -- Stop mirror si actif
                    if state.mirrorEnabled then
                        state.mirrorEnabled = false
                        state.mirrorTargetPart = nil
                        state.mirrorLastCFrame = nil
                    end
                    state.followTargetPart = root
                    state.followTarget = nil
                    state.followEnabled = true
                    state.trollAngle = 0
                    state.trollTime = 0
                    refreshModeButtons()
                    targetBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 0)
                    statusLabel.Text = string.format(t("status_orbit_veh_on"), veh.Name)
                end
            end)

            -- Bouton DETECTIVES BIZARD
            local mirrorActive = state.mirrorTargetPart == vehRoot
            local vMirrorBtn = Instance.new("TextButton")
            vMirrorBtn.Size = UDim2.new(0, 46, 1, -8)
            vMirrorBtn.Position = UDim2.new(1, -102, 0, 4)
            vMirrorBtn.BackgroundColor3 = mirrorActive and Color3.fromRGB(30, 140, 200) or Color3.fromRGB(38, 52, 70)
            vMirrorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            vMirrorBtn.TextSize = 14
            vMirrorBtn.Font = Enum.Font.GothamBold
            vMirrorBtn.Text = "DET"
            vMirrorBtn.BorderSizePixel = 0
            vMirrorBtn.ZIndex = 3
            vMirrorBtn.Parent = vBtn
            createRounded(vMirrorBtn, 6)

            vMirrorBtn.MouseButton1Click:Connect(function()
                local root = veh:IsA("Model") and (veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")) or veh
                if not root then return end

                if state.mirrorTargetPart == root then
                    -- Desactiver miroir
                    state.mirrorEnabled = false
                    state.mirrorTargetPart = nil
                    state.mirrorLastCFrame = nil
                    vMirrorBtn.BackgroundColor3 = Color3.fromRGB(38, 52, 70)
                    statusLabel.Text = t("status_mirror_off")
                    refreshModeButtons()
                else
                    -- Selectionner cette cible pour le miroir
                    local localVehicle = findVehicle()
                    if not localVehicle or not isLocalPlayerSeatedInVehicle(localVehicle) then
                        statusLabel.Text = t("status_no_veh")
                        return
                    end
                    -- Stop orbit si actif
                    if state.followEnabled then
                        state.followEnabled = false
                        state.followTargetPart = nil
                        stopTrollNoClipAndResolve()
                    end
                    state.mirrorTargetPart = root
                    state.mirrorEnabled = true
                    vMirrorBtn.BackgroundColor3 = Color3.fromRGB(30, 140, 200)
                    statusLabel.Text = string.format(t("status_mirror_on"), veh.Name)
                    refreshModeButtons()
                end
            end)

            -- Bouton INFO (details occupants + vitesse)
            local infoBtn = Instance.new("TextButton")
            infoBtn.Size = UDim2.new(0, 46, 1, -8)
            infoBtn.Position = UDim2.new(1, -52, 0, 4)
            infoBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 130)
            infoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            infoBtn.TextSize = 11
            infoBtn.Font = Enum.Font.GothamBold
            infoBtn.Text = t("veh_btn_details")
            infoBtn.BorderSizePixel = 0
            infoBtn.ZIndex = 3
            infoBtn.Parent = vBtn
            createRounded(infoBtn, 6)

            infoBtn.MouseButton1Click:Connect(function()
                if vehDetailsPopup.Visible and currentDetailsVeh == veh then
                    vehDetailsPopup.Visible = false
                else
                    openDetailsPopup(veh)
                end
            end)

            vBtn.MouseEnter:Connect(function() vBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 60) end)
            vBtn.MouseLeave:Connect(function() vBtn.BackgroundColor3 = btnColor end)

            vBtn.MouseButton1Click:Connect(function()
                local currentRoot = veh:IsA("Model") and (veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")) or veh
                if not currentRoot then
                    statusLabel.Text = "Vehicle introuvable"
                    return
                end
                local p = currentRoot.Position
                statusLabel.Text = string.format("TP vers %s ...", veh.Name)
                task.spawn(function()
                    microTeleport(p, statusLabel, {})
                end)
            end)
        end
    end

    local function refreshPlayersTab()
        local playersFrame = tabContents.players
        if not playersFrame then
            return
        end

        for _, child in ipairs(playersFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local currentChar = plr.Character
                local currentHrp = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
                if not currentHrp then
                    continue
                end

                local pNow = currentHrp.Position
                local roleLabel = getPlayerRoleLabel(plr)
                local roleColor = getRoleColor(roleLabel)
                local displayText = string.format(
                    "%s [%s] | X:%.0f Y:%.0f Z:%.0f",
                    plr.Name,
                    roleLabel,
                    pNow.X,
                    pNow.Y,
                    pNow.Z
                )

                -- Bouton joueur avec dot de role
                local btnColor = Color3.fromRGB(50, 90, 135)
                local playerBtn = Instance.new("TextButton")
                playerBtn.Size = UDim2.new(1, 0, 0, 66)
                playerBtn.BackgroundColor3 = btnColor
                playerBtn.TextColor3 = Color3.fromRGB(230, 245, 255)
                playerBtn.TextSize = 13
                playerBtn.Font = Enum.Font.GothamBold
                playerBtn.Text = ""
                playerBtn.BorderSizePixel = 0
                playerBtn.Parent = playersFrame
                createRounded(playerBtn, 8)

                -- Dot couleur role
                local dot = Instance.new("Frame")
                dot.Size = UDim2.new(0, 16, 0, 16)
                dot.Position = UDim2.new(0, 10, 0.5, -8)
                dot.BackgroundColor3 = roleColor
                dot.BorderSizePixel = 0
                dot.ZIndex = 2
                dot.Parent = playerBtn
                createRounded(dot, 8)

                -- Texte du bouton
                local btnLabel = Instance.new("TextLabel")
                btnLabel.Size = UDim2.new(1, -34, 1, 0)
                btnLabel.Position = UDim2.new(0, 32, 0, 0)
                btnLabel.BackgroundTransparency = 1
                btnLabel.TextColor3 = Color3.fromRGB(230, 245, 255)
                btnLabel.TextSize = 13
                btnLabel.Font = Enum.Font.GothamBold
                btnLabel.TextXAlignment = Enum.TextXAlignment.Left
                btnLabel.Text = displayText
                btnLabel.ZIndex = 2
                btnLabel.Parent = playerBtn

                playerBtn.MouseEnter:Connect(function()
                    playerBtn.BackgroundColor3 = Color3.fromRGB(70, 110, 160)
                end)
                playerBtn.MouseLeave:Connect(function()
                    playerBtn.BackgroundColor3 = btnColor
                end)

                playerBtn.MouseButton1Click:Connect(function()
                    local result = nil
                    if plr.Character then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local p = hrp.Position

                            local walkMode = false
                            local vehicle = findVehicle()
                            local root = vehicle and getVehicleRoot(vehicle)
                            local flatDistance = nil
                            if root then
                                local d = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(p.X, 0, p.Z)).Magnitude
                                flatDistance = d
                                local verticalGap = math.abs(root.Position.Y - p.Y)
                                walkMode = d <= CONFIG.PLAYER_WALK_DISTANCE_MAX and verticalGap <= 8
                            end

                            local tpOptions = {}
                            if walkMode then
                                tpOptions.walkMode = true
                            end

                            result = {
                                pos = p,
                                statusText = string.format(
                                    "%s vers %s [%s] | X:%.0f Y:%.0f Z:%.0f ...",
                                    walkMode and "WALK" or "TP",
                                    plr.Name,
                                    roleLabel,
                                    p.X,
                                    p.Y,
                                    p.Z
                                ),
                                tpOptions = tpOptions,
                                onSelect = function()
                                    state.followTarget = plr
                                end,
                            }
                        end
                    end

                    if not result then
                        statusLabel.Text = t("status_unavail")
                        return
                    end

                    local targetPos = result.pos
                    if result.onSelect then
                        result.onSelect()
                        refreshModeButtons()
                    end
                    statusLabel.Text = result.statusText or ("TP vers " .. plr.Name .. " ...")
                    task.spawn(function()
                        microTeleport(targetPos, statusLabel, result.tpOptions)
                    end)
                end)
            end
        end
    end

    do if false then -- OBJETS SUPPRIME
        local objBack = Instance.new("TextButton")
        objBack.Size = UDim2.new(0, 110, 0, 34)
        objBack.Position = UDim2.new(0, 10, 0, 8)
        objBack.BackgroundColor3 = Color3.fromRGB(38, 52, 82)
        objBack.TextColor3 = Color3.fromRGB(200, 220, 255)
        objBack.TextSize = 12
        objBack.Font = Enum.Font.GothamBold
        tReg(objBack, "obj_back")
        objBack.BorderSizePixel = 0
        objBack.Parent = objectScreen
        createRounded(objBack, 8)
        objBack.MouseButton1Click:Connect(function() showScreen("menu") end)

        local objTitle = Instance.new("TextLabel")
        objTitle.Size = UDim2.new(1, -130, 0, 34)
        objTitle.Position = UDim2.new(0, 130, 0, 8)
        objTitle.BackgroundTransparency = 1
        objTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
        objTitle.TextSize = 14
        objTitle.Font = Enum.Font.GothamBold
        tReg(objTitle, "obj_title")
        objTitle.TextXAlignment = Enum.TextXAlignment.Left
        objTitle.Parent = objectScreen

        local objScanBtn = Instance.new("TextButton")
        objScanBtn.Size = UDim2.new(1, -20, 0, 34)
        objScanBtn.Position = UDim2.new(0, 10, 0, 50)
        objScanBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 140)
        objScanBtn.TextColor3 = Color3.fromRGB(220, 240, 255)
        objScanBtn.TextSize = 13
        objScanBtn.Font = Enum.Font.GothamBold
        tReg(objScanBtn, "obj_scan")
        objScanBtn.BorderSizePixel = 0
        objScanBtn.Parent = objectScreen
        createRounded(objScanBtn, 8)

        local objStatusLabel = Instance.new("TextLabel")
        objStatusLabel.Size = UDim2.new(1, -20, 0, 18)
        objStatusLabel.Position = UDim2.new(0, 10, 0, 90)
        objStatusLabel.BackgroundTransparency = 1
        objStatusLabel.TextColor3 = Color3.fromRGB(130, 130, 160)
        objStatusLabel.TextSize = 11
        objStatusLabel.Font = Enum.Font.Gotham
        objStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
        objStatusLabel.Text = ""
        objStatusLabel.Parent = objectScreen

        local objScroll = Instance.new("ScrollingFrame")
        objScroll.Size = UDim2.new(1, -20, 1, -116)
        objScroll.Position = UDim2.new(0, 10, 0, 112)
        objScroll.BackgroundColor3 = Color3.fromRGB(14, 17, 28)
        objScroll.BorderSizePixel = 0
        objScroll.ScrollBarThickness = 5
        objScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 220)
        objScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        objScroll.Parent = objectScreen
        createRounded(objScroll, 8)

        local objLayout = Instance.new("UIListLayout")
        objLayout.FillDirection = Enum.FillDirection.Vertical
        objLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        objLayout.Padding = UDim.new(0, 6)
        objLayout.Parent = objScroll

        local objPadding = Instance.new("UIPadding")
        objPadding.PaddingTop = UDim.new(0, 6)
        objPadding.PaddingLeft = UDim.new(0, 6)
        objPadding.PaddingRight = UDim.new(0, 6)
        objPadding.Parent = objScroll

        local function clearObjList()
            for _, c in ipairs(objScroll:GetChildren()) do
                if c:IsA("Frame") then c:Destroy() end
            end
        end

        local function addObjEntry(toolObj, dist)
            local handle = toolObj:FindFirstChild("Handle")
            local meshId = ""
            local texId = ""
            if handle and handle:IsA("MeshPart") then
                meshId = handle.MeshId or ""
                texId = handle.TextureID or ""
            elseif handle and handle:IsA("SpecialMesh") then
                meshId = handle.MeshId or ""
                texId = handle.TextureId or ""
            end

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -12, 0, 74)
            row.BackgroundColor3 = Color3.fromRGB(22, 27, 45)
            row.BorderSizePixel = 0
            row.Parent = objScroll
            createRounded(row, 8)

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -160, 0, 22)
            nameLabel.Position = UDim2.new(0, 10, 0, 4)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Text = toolObj.Name
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Parent = row

            local distLabel = Instance.new("TextLabel")
            distLabel.Size = UDim2.new(0, 70, 0, 22)
            distLabel.Position = UDim2.new(1, -80, 0, 4)
            distLabel.BackgroundTransparency = 1
            distLabel.TextColor3 = Color3.fromRGB(160, 160, 200)
            distLabel.TextSize = 11
            distLabel.Font = Enum.Font.Gotham
            distLabel.TextXAlignment = Enum.TextXAlignment.Right
            distLabel.Text = math.floor(dist) .. t("obj_dist")
            distLabel.Parent = row

            local meshLabel = Instance.new("TextLabel")
            meshLabel.Size = UDim2.new(1, -20, 0, 16)
            meshLabel.Position = UDim2.new(0, 10, 0, 26)
            meshLabel.BackgroundTransparency = 1
            meshLabel.TextColor3 = Color3.fromRGB(100, 140, 200)
            meshLabel.TextSize = 10
            meshLabel.Font = Enum.Font.Gotham
            meshLabel.TextXAlignment = Enum.TextXAlignment.Left
            meshLabel.TextTruncate = Enum.TextTruncate.AtEnd
            meshLabel.Text = meshId ~= "" and (t("obj_mesh") .. meshId) or ""
            meshLabel.Parent = row

            local texLabel = Instance.new("TextLabel")
            texLabel.Size = UDim2.new(1, -20, 0, 16)
            texLabel.Position = UDim2.new(0, 10, 0, 42)
            texLabel.BackgroundTransparency = 1
            texLabel.TextColor3 = Color3.fromRGB(100, 140, 200)
            texLabel.TextSize = 10
            texLabel.Font = Enum.Font.Gotham
            texLabel.TextXAlignment = Enum.TextXAlignment.Left
            texLabel.TextTruncate = Enum.TextTruncate.AtEnd
            texLabel.Text = texId ~= "" and (t("obj_tex") .. texId) or ""
            texLabel.Parent = row

            local equipBtn = Instance.new("TextButton")
            equipBtn.Size = UDim2.new(0, 70, 0, 22)
            equipBtn.Position = UDim2.new(1, -160, 1, -28)
            equipBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 60)
            equipBtn.TextColor3 = Color3.fromRGB(200, 255, 210)
            equipBtn.TextSize = 11
            equipBtn.Font = Enum.Font.GothamBold
            tReg(equipBtn, "obj_equip")
            equipBtn.BorderSizePixel = 0
            equipBtn.Parent = row
            createRounded(equipBtn, 6)

            local takeBtn = Instance.new("TextButton")
            takeBtn.Size = UDim2.new(0, 70, 0, 22)
            takeBtn.Position = UDim2.new(1, -82, 1, -28)
            takeBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 20)
            takeBtn.TextColor3 = Color3.fromRGB(255, 230, 180)
            takeBtn.TextSize = 11
            takeBtn.Font = Enum.Font.GothamBold
            tReg(takeBtn, "obj_take")
            takeBtn.BorderSizePixel = 0
            takeBtn.Parent = row
            createRounded(takeBtn, 6)

            -- EQUIPER : parent Tool -> Backpack (le jeu l'equipe automatiquement)
            equipBtn.MouseButton1Click:Connect(function()
                local ok, err = pcall(function()
                    toolObj.Parent = player.Backpack
                end)
                if ok then
                    objStatusLabel.Text = "✓ " .. toolObj.Name .. " envoye au backpack"
                    objStatusLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
                    row:Destroy()
                else
                    objStatusLabel.Text = "✗ " .. tostring(err)
                    objStatusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
                end
            end)

            -- PRENDRE : parent Tool -> Character (equipe immediatement en main)
            takeBtn.MouseButton1Click:Connect(function()
                local char = player.Character
                local ok, err = pcall(function()
                    toolObj.Parent = char
                end)
                if ok then
                    objStatusLabel.Text = "✓ " .. toolObj.Name .. " equipe sur le perso"
                    objStatusLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
                    row:Destroy()
                else
                    objStatusLabel.Text = "✗ " .. tostring(err)
                    objStatusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
                end
            end)
        end

        objScanBtn.MouseButton1Click:Connect(function()
            clearObjList()
            objStatusLabel.Text = "Scan en cours..."
            objStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local myPos = root and root.Position

            local found = {}
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Tool") and obj.Parent ~= player.Backpack and obj.Parent ~= player.Character then
                    local handle = obj:FindFirstChild("Handle")
                    if handle then
                        local dist = myPos and (myPos - handle.Position).Magnitude or 0
                        table.insert(found, { tool = obj, dist = dist })
                    end
                end
            end

            table.sort(found, function(a, b) return a.dist < b.dist end)

            if #found == 0 then
                objStatusLabel.Text = t("obj_none")
                objStatusLabel.TextColor3 = Color3.fromRGB(160, 100, 100)
            else
                objStatusLabel.Text = #found .. " objet(s) trouve(s)"
                objStatusLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
                for _, entry in ipairs(found) do
                    addObjEntry(entry.tool, entry.dist)
                end
            end

            objScroll.CanvasSize = UDim2.new(0, 0, 0, objLayout.AbsoluteContentSize.Y + 16)
        end)
    end end -- fin OBJETS SUPPRIME

    -- ===== ECRAN ITEMS =====
    do
        local itemsBack = Instance.new("TextButton")
        itemsBack.Size = UDim2.new(0, 120, 0, 34)
        itemsBack.Position = UDim2.new(0, 10, 0, 8)
        itemsBack.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
        itemsBack.TextColor3 = Color3.fromRGB(200, 210, 255)
        itemsBack.TextSize = 13
        itemsBack.Font = Enum.Font.GothamBold
        itemsBack.BorderSizePixel = 0
        itemsBack.Parent = itemsScreen
        tReg(itemsBack, "items_back")
        createRounded(itemsBack, 8)
        itemsBack.MouseButton1Click:Connect(function() showScreen("menu") end)

        local itemsRemoveBtn = Instance.new("TextButton")
        itemsRemoveBtn.Size = UDim2.new(0, 160, 0, 34)
        itemsRemoveBtn.Position = UDim2.new(1, -170, 0, 8)
        itemsRemoveBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
        itemsRemoveBtn.TextColor3 = Color3.fromRGB(255, 220, 220)
        itemsRemoveBtn.TextSize = 13
        itemsRemoveBtn.Font = Enum.Font.GothamBold
        itemsRemoveBtn.BorderSizePixel = 0
        itemsRemoveBtn.Parent = itemsScreen
        tReg(itemsRemoveBtn, "items_remove")
        createRounded(itemsRemoveBtn, 8)
        itemsRemoveBtn.MouseButton1Click:Connect(function()
            local char = player.Character
            if char then
                for _, obj in ipairs(char:GetChildren()) do
                    if obj:IsA("Tool") then obj:Destroy() end
                end
            end
            local backpack = player:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, obj in ipairs(backpack:GetChildren()) do
                    if obj:IsA("Tool") then obj:Destroy() end
                end
            end
            itemsStatus.Text = t("items_removed")
            itemsStatus.TextColor3 = Color3.fromRGB(220, 100, 80)
        end)

        local itemsTitle = Instance.new("TextLabel")
        itemsTitle.Size = UDim2.new(1, -20, 0, 24)
        itemsTitle.Position = UDim2.new(0, 10, 0, 48)
        itemsTitle.BackgroundTransparency = 1
        itemsTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
        itemsTitle.TextSize = 15
        itemsTitle.Font = Enum.Font.GothamBold
        itemsTitle.TextXAlignment = Enum.TextXAlignment.Left
        itemsTitle.Parent = itemsScreen
        tReg(itemsTitle, "items_title")

        local itemsHint = Instance.new("TextLabel")
        itemsHint.Size = UDim2.new(1, -20, 0, 18)
        itemsHint.Position = UDim2.new(0, 10, 0, 74)
        itemsHint.BackgroundTransparency = 1
        itemsHint.TextColor3 = Color3.fromRGB(140, 150, 170)
        itemsHint.TextSize = 12
        itemsHint.Font = Enum.Font.Gotham
        itemsHint.TextXAlignment = Enum.TextXAlignment.Left
        itemsHint.Parent = itemsScreen
        tReg(itemsHint, "items_hint")

        local itemsStatus = Instance.new("TextLabel")
        itemsStatus.Size = UDim2.new(1, -20, 0, 20)
        itemsStatus.Position = UDim2.new(0, 10, 0, 96)
        itemsStatus.BackgroundTransparency = 1
        itemsStatus.TextColor3 = Color3.fromRGB(80, 220, 120)
        itemsStatus.TextSize = 12
        itemsStatus.Font = Enum.Font.Gotham
        itemsStatus.TextXAlignment = Enum.TextXAlignment.Left
        itemsStatus.Text = ""
        itemsStatus.Parent = itemsScreen

        local itemsScroll = Instance.new("ScrollingFrame")
        itemsScroll.Size = UDim2.new(1, -20, 1, -130)
        itemsScroll.Position = UDim2.new(0, 10, 0, 124)
        itemsScroll.BackgroundColor3 = Color3.fromRGB(20, 25, 38)
        itemsScroll.BorderSizePixel = 0
        itemsScroll.ScrollBarThickness = 5
        itemsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        itemsScroll.Parent = itemsScreen
        createRounded(itemsScroll, 8)

        local itemsLayout = Instance.new("UIListLayout")
        itemsLayout.SortOrder = Enum.SortOrder.Name
        itemsLayout.Padding = UDim.new(0, 4)
        itemsLayout.Parent = itemsScroll

        local itemsPad = Instance.new("UIPadding")
        itemsPad.PaddingTop = UDim.new(0, 6)
        itemsPad.PaddingLeft = UDim.new(0, 6)
        itemsPad.PaddingRight = UDim.new(0, 6)
        itemsPad.Parent = itemsScroll

        local function giveToolToCharacter(tool)
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            -- Supprimer tous les tools deja dans le character (equipes)
            for _, obj in ipairs(char:GetChildren()) do
                if obj:IsA("Tool") then obj:Destroy() end
            end
            -- Supprimer tous les tools dans le backpack
            local backpack = player:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, obj in ipairs(backpack:GetChildren()) do
                    if obj:IsA("Tool") then obj:Destroy() end
                end
            end
            local clone = tool:Clone()
            local handle = clone:FindFirstChild("Handle")
            local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
            -- Positionner le handle directement a la main avant de parenter
            if handle and rightHand then
                handle.CFrame = rightHand.CFrame
            end
            clone.Parent = char
            -- Creer le weld immediatement (synchrone, pas de wait)
            if handle and rightHand then
                local existing = rightHand:FindFirstChild("RightGrip")
                if existing then existing:Destroy() end
                local weld = Instance.new("Weld")
                weld.Name = "RightGrip"
                weld.Part0 = rightHand
                weld.Part1 = handle
                weld.C0 = clone.Grip
                weld.Parent = rightHand
            end
            itemsStatus.Text = string.format(t("items_given"), tool.Name)
            itemsStatus.TextColor3 = Color3.fromRGB(80, 220, 120)
        end

        local function refreshItemsList()
            -- Vider la liste
            for _, c in ipairs(itemsScroll:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end

            local toolsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Tools")
            if not toolsFolder then
                itemsStatus.Text = t("items_none")
                itemsStatus.TextColor3 = Color3.fromRGB(220, 100, 80)
                itemsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                return
            end

            local tools = {}
            for _, obj in ipairs(toolsFolder:GetChildren()) do
                if obj:IsA("Tool") then
                    table.insert(tools, obj)
                end
            end

            if #tools == 0 then
                itemsStatus.Text = t("items_none")
                itemsStatus.TextColor3 = Color3.fromRGB(220, 100, 80)
                itemsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                return
            end

            itemsStatus.Text = #tools .. " outil(s)"
            itemsStatus.TextColor3 = Color3.fromRGB(140, 150, 170)

            for _, tool in ipairs(tools) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -12, 0, 40)
                btn.BackgroundColor3 = Color3.fromRGB(30, 40, 62)
                btn.TextColor3 = Color3.fromRGB(220, 230, 255)
                btn.TextSize = 13
                btn.Font = Enum.Font.Gotham
                btn.Text = "🔧 " .. tool.Name
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.BorderSizePixel = 0
                btn.Parent = itemsScroll
                createRounded(btn, 7)

                local pad = Instance.new("UIPadding")
                pad.PaddingLeft = UDim.new(0, 10)
                pad.Parent = btn

                local toolRef = tool
                btn.MouseButton1Click:Connect(function()
                    giveToolToCharacter(toolRef)
                end)

                btn.MouseEnter:Connect(function()
                    btn.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
                end)
                btn.MouseLeave:Connect(function()
                    btn.BackgroundColor3 = Color3.fromRGB(30, 40, 62)
                end)
            end

            itemsScroll.CanvasSize = UDim2.new(0, 0, 0, itemsLayout.AbsoluteContentSize.Y + 16)
        end

        -- Rafraichir quand l'ecran devient visible
        itemsScreen:GetPropertyChangedSignal("Visible"):Connect(function()
            if itemsScreen.Visible then
                refreshItemsList()
            end
        end)
    end

    local mbTeleport = makeMenuButton(t("menu_teleport"), Color3.fromRGB(0, 150, 220), function()
        showScreen("teleport")
    end)
    tReg(mbTeleport, "menu_teleport")

    local mbCustom = makeMenuButton(t("menu_custom"), Color3.fromRGB(30, 80, 55), function()
        showScreen("custom")
    end)
    tReg(mbCustom, "menu_custom")

    local mbWp = makeMenuButton(t("menu_waypoints"), Color3.fromRGB(0, 120, 180), function()
        refreshWaypointList()
        refreshWaypointLiveLabels()
        showScreen("waypoints")
    end)
    tReg(mbWp, "menu_waypoints")

    -- Ecoute globale de la touche orbit
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode ~= state.orbitToggleKey then return end
        if not state.followTarget then return end

        state.followEnabled = not state.followEnabled
        if not state.followEnabled then
            stopTrollNoClipAndResolve()
        else
            state.trollAngle = 0
            state.trollTime = 0
        end
        refreshModeButtons()
    end)

    local mbItems = makeMenuButton(t("menu_items"), Color3.fromRGB(80, 50, 130), function()
        showScreen("items")
    end)
    tReg(mbItems, "menu_items")

    local mbRespawn = makeMenuButton(t("menu_respawn"), Color3.fromRGB(120, 40, 40), function()
        local char = player.Character
        if not char then return end
        local upperTorso = char:FindFirstChild("UpperTorso")
        if upperTorso then upperTorso:Destroy() end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end)
    tReg(mbRespawn, "menu_respawn")

    local mbDel = makeMenuButton(t("menu_delete"), Color3.fromRGB(145, 45, 45), function()
        destroyTeleportUI()
    end)
    tReg(mbDel, "menu_delete")

    backBtn.MouseButton1Click:Connect(function()
        state.isTPing = false
        showScreen("menu")
    end)

    cancelBtn.MouseButton1Click:Connect(function()
        state.isTPing = false
        statusLabel.Text = t("status_cancel")
    end)

    followBtn.MouseButton1Click:Connect(function()
        if not state.followTarget then
            statusLabel.Text = t("status_no_target")
            return
        end

        if not state.followEnabled then
            local localVehicle = findVehicle()
            if not localVehicle or not isLocalPlayerSeatedInVehicle(localVehicle) then
                statusLabel.Text = t("status_no_veh")
                return
            end
        end

        state.followEnabled = not state.followEnabled
        if not state.followEnabled then
            state.followTargetPart = nil
            statusLabel.Text = t("status_orbit_off")
            stopTrollNoClipAndResolve()
        else
            -- Stop mirror si actif
            if state.mirrorEnabled then
                state.mirrorEnabled = false
                state.mirrorTargetPart = nil
                state.mirrorLastCFrame = nil
            end
            local mode = state.orbitRotationEnabled and "rotation" or "suivi"
            statusLabel.Text = "ORBIT active (" .. mode .. "): " .. state.followTarget.Name
            state.trollAngle = 0
            state.trollTime = 0
        end
        refreshModeButtons()
    end)

    rotationBtn.MouseButton1Click:Connect(function()
        state.orbitRotationEnabled = not state.orbitRotationEnabled
        state.trollAngle = 0
        state.trollTime = 0
        if state.followEnabled then
            statusLabel.Text = state.orbitRotationEnabled and "Rotation orbit active" or "Rotation orbit desactive"
        else
            statusLabel.Text = state.orbitRotationEnabled and "Rotation prete (ORBIT OFF)" or "Rotation desactive"
        end
        refreshModeButtons()
    end)

    mirrorBtn.MouseButton1Click:Connect(function()
        if state.mirrorEnabled then
            -- Desactiver
            state.mirrorEnabled = false
            state.mirrorTargetPart = nil
            state.mirrorLastCFrame = nil

            statusLabel.Text = t("status_mirror_off")
            refreshModeButtons()
        else
            -- Activer : il faut une cible mirror selectionnee
            if not state.mirrorTargetPart then
                statusLabel.Text = state.lang == "en" and "Select a vehicle target (DET) first" or "Selectionne une cible vehicule (DET) d'abord"
                return
            end
            local localVehicle = findVehicle()
            if not localVehicle or not isLocalPlayerSeatedInVehicle(localVehicle) then
                statusLabel.Text = t("status_no_veh")
                return
            end
            -- Stop orbit si actif
            if state.followEnabled then
                state.followEnabled = false
                stopTrollNoClipAndResolve()
            end
            state.mirrorEnabled = true
            local vehName = state.mirrorTargetPart.Parent and state.mirrorTargetPart.Parent.Name or state.mirrorTargetPart.Name
            statusLabel.Text = string.format(t("status_mirror_on"), vehName)
            refreshModeButtons()
        end
    end)


    closeBtn.MouseButton1Click:Connect(function()
        state.isTPing = false
        screenGui.Enabled = false
    end)

    deleteBtn.MouseButton1Click:Connect(function()
        destroyTeleportUI()
    end)

    loadBuildings()
    loadPresetDestinations()
    addHomeDestination()
    loadDealersFolder()
    refreshPlayersTab()
    refreshVehiclesTab()
    refreshModeButtons()
    refreshWaypointList()
    refreshWaypointLiveLabels()

    if not state.followLoopRunning then
        state.followLoopRunning = true
        task.spawn(function()
            while screenGui.Parent do
                local dt = RunService.Heartbeat:Wait()

                if not state.followEnabled then
                    if state.trollNoClipActive then
                        stopTrollNoClipAndResolve()
                    end
                    continue
                end
                if state.isTPing then
                    continue
                end

                -- Cible : vehicle BasePart OU joueur
                local targetHrp = nil
                if state.followTargetPart then
                    if not state.followTargetPart.Parent then
                        state.followEnabled = false
                        state.followTargetPart = nil
                        stopTrollNoClipAndResolve()
                        refreshModeButtons()
                        statusLabel.Text = t("status_orbit_stop_part")
                        continue
                    end
                    targetHrp = state.followTargetPart
                else
                    local target = state.followTarget
                    if not target or not target.Parent then
                        state.followEnabled = false
                        stopTrollNoClipAndResolve()
                        refreshModeButtons()
                        statusLabel.Text = t("status_orbit_stop_gone")
                        continue
                    end
                    local targetChar = target.Character
                    targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                    if not targetHrp then
                        if state.trollNoClipActive then stopTrollNoClipAndResolve() end
                        continue
                    end
                end

                local localVehicle = findVehicle()
                if not localVehicle or not isLocalPlayerSeatedInVehicle(localVehicle) then
                    state.followEnabled = false
                    stopTrollNoClipAndResolve()
                    refreshModeButtons()
                    statusLabel.Text = t("status_orbit_stop_noveh")
                    continue
                end

                if isLocalPlayerDrivingInputActive(localVehicle) then
                    state.followEnabled = false
                    stopTrollNoClipAndResolve()
                    refreshModeButtons()
                    statusLabel.Text = t("status_orbit_stop_drive")
                    continue
                end

                performTrollStep(targetHrp, statusLabel, dt)
            end

            state.followLoopRunning = false
            stopTrollNoClipAndResolve()
        end)
    end

    task.spawn(function()
        while screenGui.Parent do
            task.wait(CONFIG.PLAYER_REFRESH_DELAY)
            if teleportScreen.Visible then
                refreshPlayersTab()
                if currentTab == "vehicles" then
                    refreshVehiclesTab()
                end
            end
        end
    end)

    task.spawn(function()
        while screenGui.Parent do
            task.wait(0.15)
            if waypointScreen.Visible then
                refreshWaypointLiveLabels()
            end
        end
    end)

    -- Boucle suivi jument
    task.spawn(function()
        while screenGui.Parent do
            local dt = RunService.Heartbeat:Wait()
            updateHorse(dt)
        end
    end)

    -- Boucle simulation vehicule (IsOn = false)
    task.spawn(function()
        while screenGui.Parent do
            local dt = RunService.Heartbeat:Wait()
            updateVehicleSim(dt)
        end
    end)

    -- Boucle mode DETECTIVES BIZARD
    task.spawn(function()
        while screenGui.Parent do
            RunService.Heartbeat:Wait()

            if not state.mirrorEnabled then continue end

            -- Verif cible (avant isTPing pour pouvoir annuler un microTeleport en cours)
            local targetPart = state.mirrorTargetPart
            if not targetPart or not targetPart.Parent then
                state.isTPing = false  -- annule microTeleport en cours si besoin
                state.mirrorEnabled = false
                state.mirrorTargetPart = nil
                refreshModeButtons()
                statusLabel.Text = t("status_mirror_stop")
                continue
            end

            -- Verif conduite manuelle (annule aussi le microTeleport)
            local localVehicle = findVehicle()
            if localVehicle and isLocalPlayerDrivingInputActive(localVehicle) then
                state.isTPing = false
                state.mirrorEnabled = false
                state.mirrorTargetPart = nil
                refreshModeButtons()
                statusLabel.Text = t("status_orbit_stop_drive")
                continue
            end

            -- Pendant un microTeleport (phase approche) : laisser tourner
            if state.isTPing then continue end

            -- Verif assis dans vehicule
            if not localVehicle or not isLocalPlayerSeatedInVehicle(localVehicle) then
                state.mirrorEnabled = false
                state.mirrorTargetPart = nil
                refreshModeButtons()
                statusLabel.Text = t("status_mirror_noveh")
                continue
            end

            local root = getVehicleRoot(localVehicle)
            if not root then continue end

            -- Position cible : 8 studs derriere dans l'espace local du vehicule cible
            local desiredCF  = targetPart.CFrame * CFrame.new(0, 0, state.mirrorStuds)
            local dist = (desiredCF.Position - root.Position).Magnitude


            if dist <= state.mirrorStuds + 2 then
                -- Phase verrouillage : meme rotation, meme hauteur, position exacte
                localVehicle:PivotTo(clampPivotMinY(desiredCF))
            else
                -- Phase approche : microTeleport (meme systeme que destination/joueur)
                local targetPos = desiredCF.Position
                task.spawn(function()
                    microTeleport(targetPos, statusLabel, { wallPass = true })
                end)
            end
        end
    end)


    return screenGui
end

local function createOpenButton(mainGui)
    local playerGui = player:WaitForChild("PlayerGui")

    local openGui = Instance.new("ScreenGui")
    openGui.Name = "VehicleTP_Open"
    openGui.ResetOnSpawn = false
    openGui.DisplayOrder = 998
    openGui.Parent = playerGui
    state.openGui = openGui

    local openBtn = Instance.new("TextButton")
    openBtn.Name = "OpenTeleport"
    openBtn.Size = UDim2.new(0, 48, 0, 48)
    openBtn.Position = UDim2.new(0, 20, 0.5, -28)
    openBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
    openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    openBtn.TextSize = 14
    openBtn.Font = Enum.Font.GothamBold
    openBtn.Text = "MOD"
    openBtn.BorderSizePixel = 0
    openBtn.Parent = openGui
    createRounded(openBtn, 10)

    -- Bouton engrenage sous MOD
    local gearBtn = Instance.new("TextButton")
    gearBtn.Size = UDim2.new(0, 48, 0, 30)
    gearBtn.Position = UDim2.new(0, 20, 0.5, 26)
    gearBtn.BackgroundColor3 = Color3.fromRGB(55, 35, 95)
    gearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    gearBtn.TextSize = 18
    gearBtn.Font = Enum.Font.GothamBold
    gearBtn.Text = "⚙"
    gearBtn.BorderSizePixel = 0
    gearBtn.Parent = openGui
    createRounded(gearBtn, 8)

    -- Panel keybind orbit (dans openGui = toujours visible)
    local KB_Z = 5
    local keybindPanel = Instance.new("ScrollingFrame")
    keybindPanel.Size = UDim2.new(0, 376, 0, 520)
    keybindPanel.Position = UDim2.new(0, 78, 0.5, -260)
    keybindPanel.CanvasSize = UDim2.new(0, 0, 0, 800)
    keybindPanel.ScrollingDirection = Enum.ScrollingDirection.Y
    keybindPanel.ScrollBarThickness = 5
    keybindPanel.ScrollBarImageColor3 = Color3.fromRGB(80, 90, 140)
    keybindPanel.BackgroundColor3 = Color3.fromRGB(15, 18, 32)
    keybindPanel.BorderSizePixel = 0
    keybindPanel.Visible = false
    keybindPanel.ZIndex = KB_Z
    keybindPanel.Parent = openGui
    createRounded(keybindPanel, 14)

    local kbTitleBar = Instance.new("Frame")
    kbTitleBar.Size = UDim2.new(1, 0, 0, 36)
    kbTitleBar.BackgroundColor3 = Color3.fromRGB(55, 35, 95)
    kbTitleBar.BorderSizePixel = 0
    kbTitleBar.ZIndex = KB_Z
    kbTitleBar.Parent = keybindPanel
    createRounded(kbTitleBar, 14)

    local kbTitleFix = Instance.new("Frame")
    kbTitleFix.Size = UDim2.new(1, 0, 0.5, 0)
    kbTitleFix.Position = UDim2.new(0, 0, 0.5, 0)
    kbTitleFix.BackgroundColor3 = Color3.fromRGB(55, 35, 95)
    kbTitleFix.BorderSizePixel = 0
    kbTitleFix.ZIndex = KB_Z
    kbTitleFix.Parent = kbTitleBar

    local kbTitle = Instance.new("TextLabel")
    kbTitle.Size = UDim2.new(1, -50, 1, 0)
    kbTitle.Position = UDim2.new(0, 14, 0, 0)
    kbTitle.BackgroundTransparency = 1
    kbTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    kbTitle.TextSize = 13
    kbTitle.Font = Enum.Font.GothamBold
    tReg(kbTitle, "kb_title")
    kbTitle.TextXAlignment = Enum.TextXAlignment.Left
    kbTitle.ZIndex = KB_Z
    kbTitle.Parent = kbTitleBar

    local kbCloseBtn = Instance.new("TextButton")
    kbCloseBtn.Size = UDim2.new(0, 32, 0, 32)
    kbCloseBtn.Position = UDim2.new(1, -36, 0, 2)
    kbCloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    kbCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    kbCloseBtn.TextSize = 15
    kbCloseBtn.Font = Enum.Font.GothamBold
    kbCloseBtn.Text = "✕"  -- icon, not translated
    kbCloseBtn.BorderSizePixel = 0
    kbCloseBtn.ZIndex = KB_Z
    kbCloseBtn.Parent = kbTitleBar
    createRounded(kbCloseBtn, 8)

    local kbCapOuter = Instance.new("Frame")
    kbCapOuter.Size = UDim2.new(0, 80, 0, 54)
    kbCapOuter.Position = UDim2.new(0, 14, 0, 46)
    kbCapOuter.BackgroundColor3 = Color3.fromRGB(0, 160, 220)
    kbCapOuter.BorderSizePixel = 0
    kbCapOuter.ZIndex = KB_Z
    kbCapOuter.Parent = keybindPanel
    createRounded(kbCapOuter, 10)

    local kbCapInner = Instance.new("Frame")
    kbCapInner.Size = UDim2.new(1, -6, 1, -8)
    kbCapInner.Position = UDim2.new(0, 3, 0, 3)
    kbCapInner.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    kbCapInner.BorderSizePixel = 0
    kbCapInner.ZIndex = KB_Z
    kbCapInner.Parent = kbCapOuter
    createRounded(kbCapInner, 8)

    local kbCapLabel = Instance.new("TextLabel")
    kbCapLabel.Size = UDim2.new(1, 0, 1, 0)
    kbCapLabel.BackgroundTransparency = 1
    kbCapLabel.TextColor3 = Color3.fromRGB(0, 210, 255)
    kbCapLabel.TextSize = 18
    kbCapLabel.Font = Enum.Font.GothamBold
    kbCapLabel.ZIndex = KB_Z
    kbCapLabel.Parent = kbCapInner

    local kbInfoLabel = Instance.new("TextLabel")
    kbInfoLabel.Size = UDim2.new(1, -110, 0, 54)
    kbInfoLabel.Position = UDim2.new(0, 104, 0, 46)
    kbInfoLabel.BackgroundTransparency = 1
    kbInfoLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    kbInfoLabel.TextSize = 12
    kbInfoLabel.Font = Enum.Font.Gotham
    kbInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    kbInfoLabel.TextWrapped = true
    kbInfoLabel.ZIndex = KB_Z
    kbInfoLabel.Parent = keybindPanel

    local kbSep = Instance.new("Frame")
    kbSep.Size = UDim2.new(1, -28, 0, 1)
    kbSep.Position = UDim2.new(0, 14, 0, 110)
    kbSep.BackgroundColor3 = Color3.fromRGB(50, 55, 80)
    kbSep.BorderSizePixel = 0
    kbSep.ZIndex = KB_Z
    kbSep.Parent = keybindPanel

    local waitingForKey = false

    local function setOrbitKey(keyCode)
        state.orbitToggleKey = keyCode
        local name = tostring(keyCode):gsub("Enum.KeyCode.", "")
        kbCapLabel.Text = name
        kbInfoLabel.Text = t("cv_apply_info")
        kbInfoLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
        kbCapOuter.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    end

    local function enterListenMode()
        waitingForKey = true
        kbCapLabel.Text = "?"
        kbCapOuter.BackgroundColor3 = Color3.fromRGB(220, 160, 0)
        kbInfoLabel.Text = t("cv_listen")
        kbInfoLabel.TextColor3 = Color3.fromRGB(255, 210, 60)
    end


    local kbCustomBtn = Instance.new("TextButton")
    kbCustomBtn.Size = UDim2.new(0, 100, 0, 30)
    kbCustomBtn.Position = UDim2.new(1, -114, 0, 46)
    kbCustomBtn.BackgroundColor3 = Color3.fromRGB(70, 40, 110)
    kbCustomBtn.TextColor3 = Color3.fromRGB(220, 200, 255)
    kbCustomBtn.TextSize = 11
    kbCustomBtn.Font = Enum.Font.GothamBold
    tReg(kbCustomBtn, "cv_other_key")
    kbCustomBtn.BorderSizePixel = 0
    kbCustomBtn.ZIndex = KB_Z
    kbCustomBtn.Parent = keybindPanel
    createRounded(kbCustomBtn, 8)

    kbCustomBtn.MouseButton1Click:Connect(enterListenMode)

    -- ---- Section studs Detectives Bizard ----
    local kbSep2 = Instance.new("Frame")
    kbSep2.Size = UDim2.new(1, -28, 0, 1)
    kbSep2.Position = UDim2.new(0, 14, 0, 114)
    kbSep2.BackgroundColor3 = Color3.fromRGB(50, 55, 80)
    kbSep2.BorderSizePixel = 0
    kbSep2.ZIndex = KB_Z
    kbSep2.Parent = keybindPanel

    local kbStudsLabel = Instance.new("TextLabel")
    kbStudsLabel.Size = UDim2.new(1, -28, 0, 16)
    kbStudsLabel.Position = UDim2.new(0, 14, 0, 119)
    kbStudsLabel.BackgroundTransparency = 1
    kbStudsLabel.TextColor3 = Color3.fromRGB(130, 130, 160)
    kbStudsLabel.TextSize = 11
    kbStudsLabel.Font = Enum.Font.Gotham
    kbStudsLabel.TextXAlignment = Enum.TextXAlignment.Left
    kbStudsLabel.Text = "DET Detectives Bizard — studs"
    kbStudsLabel.ZIndex = KB_Z
    kbStudsLabel.Parent = keybindPanel

    local kbStudsMinus = Instance.new("TextButton")
    kbStudsMinus.Size = UDim2.new(0, 34, 0, 26)
    kbStudsMinus.Position = UDim2.new(0, 14, 0, 138)
    kbStudsMinus.BackgroundColor3 = Color3.fromRGB(35, 40, 65)
    kbStudsMinus.TextColor3 = Color3.fromRGB(220, 220, 255)
    kbStudsMinus.TextSize = 16
    kbStudsMinus.Font = Enum.Font.GothamBold
    kbStudsMinus.Text = "−"
    kbStudsMinus.BorderSizePixel = 0
    kbStudsMinus.ZIndex = KB_Z
    kbStudsMinus.Parent = keybindPanel
    createRounded(kbStudsMinus, 7)

    local kbStudsVal = Instance.new("TextLabel")
    kbStudsVal.Size = UDim2.new(0, 60, 0, 26)
    kbStudsVal.Position = UDim2.new(0, 52, 0, 138)
    kbStudsVal.BackgroundColor3 = Color3.fromRGB(22, 26, 46)
    kbStudsVal.TextColor3 = Color3.fromRGB(255, 255, 255)
    kbStudsVal.TextSize = 14
    kbStudsVal.Font = Enum.Font.GothamBold
    kbStudsVal.Text = tostring(state.mirrorStuds) .. " st"
    kbStudsVal.BorderSizePixel = 0
    kbStudsVal.ZIndex = KB_Z
    kbStudsVal.Parent = keybindPanel
    createRounded(kbStudsVal, 7)

    local kbStudsPlus = Instance.new("TextButton")
    kbStudsPlus.Size = UDim2.new(0, 34, 0, 26)
    kbStudsPlus.Position = UDim2.new(0, 116, 0, 138)
    kbStudsPlus.BackgroundColor3 = Color3.fromRGB(35, 40, 65)
    kbStudsPlus.TextColor3 = Color3.fromRGB(220, 220, 255)
    kbStudsPlus.TextSize = 16
    kbStudsPlus.Font = Enum.Font.GothamBold
    kbStudsPlus.Text = "+"
    kbStudsPlus.BorderSizePixel = 0
    kbStudsPlus.ZIndex = KB_Z
    kbStudsPlus.Parent = keybindPanel
    createRounded(kbStudsPlus, 7)

    local function updateStudsDisplay()
        kbStudsVal.Text = tostring(state.mirrorStuds) .. " st"
    end

    kbStudsMinus.MouseButton1Click:Connect(function()
        state.mirrorStuds = math.max(6, state.mirrorStuds - 1)
        updateStudsDisplay()
    end)

    kbStudsPlus.MouseButton1Click:Connect(function()
        state.mirrorStuds = math.min(12, state.mirrorStuds + 1)
        updateStudsDisplay()
    end)

    -- Separateur sons
    local kbSoundSep = Instance.new("Frame")
    kbSoundSep.Size = UDim2.new(1, -28, 0, 1)
    kbSoundSep.Position = UDim2.new(0, 14, 0, 172)
    kbSoundSep.BackgroundColor3 = Color3.fromRGB(60, 65, 100)
    kbSoundSep.BorderSizePixel = 0
    kbSoundSep.ZIndex = KB_Z
    kbSoundSep.Parent = keybindPanel

    -- Bouton toggle son des poneys
    local kbPoneySndBtn = Instance.new("TextButton")
    kbPoneySndBtn.Size = UDim2.new(1, -28, 0, 28)
    kbPoneySndBtn.Position = UDim2.new(0, 14, 0, 180)
    kbPoneySndBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 65)
    kbPoneySndBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
    kbPoneySndBtn.TextSize = 13
    kbPoneySndBtn.Font = Enum.Font.GothamBold
    kbPoneySndBtn.BorderSizePixel = 0
    kbPoneySndBtn.ZIndex = KB_Z
    kbPoneySndBtn.Parent = keybindPanel
    createRounded(kbPoneySndBtn, 7)

    local function updatePoneySndBtn()
        kbPoneySndBtn.Text = state.poneySoundEnabled and t("kb_poney_snd_on") or t("kb_poney_snd_off")
        kbPoneySndBtn.BackgroundColor3 = state.poneySoundEnabled
            and Color3.fromRGB(30, 80, 50) or Color3.fromRGB(80, 30, 30)
    end
    updatePoneySndBtn()

    kbPoneySndBtn.MouseButton1Click:Connect(function()
        state.poneySoundEnabled = not state.poneySoundEnabled
        refreshPoneySounds()
        updatePoneySndBtn()
    end)

    -- Bouton toggle sirene police
    local kbPoliceSndBtn = Instance.new("TextButton")
    kbPoliceSndBtn.Size = UDim2.new(1, -28, 0, 28)
    kbPoliceSndBtn.Position = UDim2.new(0, 14, 0, 214)
    kbPoliceSndBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 65)
    kbPoliceSndBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
    kbPoliceSndBtn.TextSize = 13
    kbPoliceSndBtn.Font = Enum.Font.GothamBold
    kbPoliceSndBtn.BorderSizePixel = 0
    kbPoliceSndBtn.ZIndex = KB_Z
    kbPoliceSndBtn.Parent = keybindPanel
    createRounded(kbPoliceSndBtn, 7)

    local function updatePoliceSndBtn()
        kbPoliceSndBtn.Text = state.policeSoundEnabled and t("kb_police_snd_on") or t("kb_police_snd_off")
        kbPoliceSndBtn.BackgroundColor3 = state.policeSoundEnabled
            and Color3.fromRGB(30, 80, 50) or Color3.fromRGB(80, 30, 30)
    end
    updatePoliceSndBtn()

    kbPoliceSndBtn.MouseButton1Click:Connect(function()
        state.policeSoundEnabled = not state.policeSoundEnabled
        refreshPoliceSounds()
        updatePoliceSndBtn()
    end)

    setOrbitKey(state.orbitToggleKey)

    -- ---- Section touche accélération boost vitesse ----
    local kbAccelSep = Instance.new("Frame")
    kbAccelSep.Size = UDim2.new(1, -28, 0, 1)
    kbAccelSep.Position = UDim2.new(0, 14, 0, 248)
    kbAccelSep.BackgroundColor3 = Color3.fromRGB(60, 65, 100)
    kbAccelSep.BorderSizePixel = 0
    kbAccelSep.ZIndex = KB_Z
    kbAccelSep.Parent = keybindPanel

    local kbAccelLabel = Instance.new("TextLabel")
    kbAccelLabel.Size = UDim2.new(1, -28, 0, 16)
    kbAccelLabel.Position = UDim2.new(0, 14, 0, 254)
    kbAccelLabel.BackgroundTransparency = 1
    kbAccelLabel.TextColor3 = Color3.fromRGB(130, 130, 160)
    kbAccelLabel.TextSize = 11
    kbAccelLabel.Font = Enum.Font.Gotham
    kbAccelLabel.TextXAlignment = Enum.TextXAlignment.Left
    kbAccelLabel.Text = t("kb_accel_label")
    kbAccelLabel.ZIndex = KB_Z
    kbAccelLabel.Parent = keybindPanel

    local kbAccelKeyOuter = Instance.new("Frame")
    kbAccelKeyOuter.Size = UDim2.new(0, 70, 0, 40)
    kbAccelKeyOuter.Position = UDim2.new(0, 14, 0, 274)
    kbAccelKeyOuter.BackgroundColor3 = Color3.fromRGB(0, 140, 200)
    kbAccelKeyOuter.BorderSizePixel = 0
    kbAccelKeyOuter.ZIndex = KB_Z
    kbAccelKeyOuter.Parent = keybindPanel
    createRounded(kbAccelKeyOuter, 8)

    local kbAccelKeyInner = Instance.new("Frame")
    kbAccelKeyInner.Size = UDim2.new(1, -6, 1, -6)
    kbAccelKeyInner.Position = UDim2.new(0, 3, 0, 3)
    kbAccelKeyInner.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    kbAccelKeyInner.BorderSizePixel = 0
    kbAccelKeyInner.ZIndex = KB_Z
    kbAccelKeyInner.Parent = kbAccelKeyOuter
    createRounded(kbAccelKeyInner, 6)

    local kbAccelKeyLabel = Instance.new("TextLabel")
    kbAccelKeyLabel.Size = UDim2.new(1, 0, 1, 0)
    kbAccelKeyLabel.BackgroundTransparency = 1
    kbAccelKeyLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    kbAccelKeyLabel.TextSize = 16
    kbAccelKeyLabel.Font = Enum.Font.GothamBold
    kbAccelKeyLabel.ZIndex = KB_Z
    kbAccelKeyLabel.Parent = kbAccelKeyInner

    local kbAccelChangeBtn = Instance.new("TextButton")
    kbAccelChangeBtn.Size = UDim2.new(0, 110, 0, 30)
    kbAccelChangeBtn.Position = UDim2.new(0, 92, 0, 279)
    kbAccelChangeBtn.BackgroundColor3 = Color3.fromRGB(70, 40, 110)
    kbAccelChangeBtn.TextColor3 = Color3.fromRGB(220, 200, 255)
    kbAccelChangeBtn.TextSize = 11
    kbAccelChangeBtn.Font = Enum.Font.GothamBold
    kbAccelChangeBtn.Text = t("kb_accel_change")
    kbAccelChangeBtn.BorderSizePixel = 0
    kbAccelChangeBtn.ZIndex = KB_Z
    kbAccelChangeBtn.Parent = keybindPanel
    createRounded(kbAccelChangeBtn, 8)

    local kbAccelStatusLabel = Instance.new("TextLabel")
    kbAccelStatusLabel.Size = UDim2.new(0, 150, 0, 30)
    kbAccelStatusLabel.Position = UDim2.new(0, 210, 0, 279)
    kbAccelStatusLabel.BackgroundTransparency = 1
    kbAccelStatusLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
    kbAccelStatusLabel.TextSize = 11
    kbAccelStatusLabel.Font = Enum.Font.Gotham
    kbAccelStatusLabel.TextWrapped = true
    kbAccelStatusLabel.ZIndex = KB_Z
    kbAccelStatusLabel.Parent = keybindPanel

    local waitingForAccelKey = false

    local function setAccelKey(keyCode)
        state.accelKey = keyCode
        local name = tostring(keyCode):gsub("Enum%.KeyCode%.", "")
        kbAccelKeyLabel.Text = name
        kbAccelKeyOuter.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        kbAccelStatusLabel.Text = t("kb_accel_saved")
        kbAccelStatusLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
        waitingForAccelKey = false
    end

    setAccelKey(state.accelKey)

    kbAccelChangeBtn.MouseButton1Click:Connect(function()
        waitingForAccelKey = true
        waitingForKey = false  -- desactive l'ecoute orbit si active
        kbAccelKeyLabel.Text = "?"
        kbAccelKeyOuter.BackgroundColor3 = Color3.fromRGB(220, 160, 0)
        kbAccelStatusLabel.Text = t("kb_accel_listen")
        kbAccelStatusLabel.TextColor3 = Color3.fromRGB(255, 210, 60)
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not waitingForAccelKey then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode == Enum.KeyCode.Escape then
            waitingForAccelKey = false
            setAccelKey(state.accelKey)
            return
        end
        setAccelKey(input.KeyCode)
    end)

    -- ---- Section toggles police notif & role badge ----
    local kbToggleSep = Instance.new("Frame")
    kbToggleSep.Size = UDim2.new(1, -28, 0, 1)
    kbToggleSep.Position = UDim2.new(0, 14, 0, 324)
    kbToggleSep.BackgroundColor3 = Color3.fromRGB(60, 65, 100)
    kbToggleSep.BorderSizePixel = 0
    kbToggleSep.ZIndex = KB_Z
    kbToggleSep.Parent = keybindPanel

    local kbToggleSepLabel = Instance.new("TextLabel")
    kbToggleSepLabel.Size = UDim2.new(1, -28, 0, 14)
    kbToggleSepLabel.Position = UDim2.new(0, 14, 0, 330)
    kbToggleSepLabel.BackgroundTransparency = 1
    kbToggleSepLabel.TextColor3 = Color3.fromRGB(130, 130, 160)
    kbToggleSepLabel.TextSize = 11
    kbToggleSepLabel.Font = Enum.Font.Gotham
    kbToggleSepLabel.TextXAlignment = Enum.TextXAlignment.Left
    kbToggleSepLabel.Text = t("kb_hud_section")
    kbToggleSepLabel.ZIndex = KB_Z
    kbToggleSepLabel.Parent = keybindPanel

    local kbPoliceNotifBtn = Instance.new("TextButton")
    kbPoliceNotifBtn.Size = UDim2.new(1, -28, 0, 28)
    kbPoliceNotifBtn.Position = UDim2.new(0, 14, 0, 348)
    kbPoliceNotifBtn.TextSize = 13
    kbPoliceNotifBtn.Font = Enum.Font.GothamBold
    kbPoliceNotifBtn.BorderSizePixel = 0
    kbPoliceNotifBtn.ZIndex = KB_Z
    kbPoliceNotifBtn.Parent = keybindPanel
    createRounded(kbPoliceNotifBtn, 7)

    local kbRoleBtn = Instance.new("TextButton")
    kbRoleBtn.Size = UDim2.new(1, -28, 0, 28)
    kbRoleBtn.Position = UDim2.new(0, 14, 0, 382)
    kbRoleBtn.TextSize = 13
    kbRoleBtn.Font = Enum.Font.GothamBold
    kbRoleBtn.BorderSizePixel = 0
    kbRoleBtn.ZIndex = KB_Z
    kbRoleBtn.Parent = keybindPanel
    createRounded(kbRoleBtn, 7)

    local function updatePoliceNotifBtn()
        kbPoliceNotifBtn.Text = state.policeNotifEnabled
            and t("kb_police_notif_on")
            or  t("kb_police_notif_off")
        kbPoliceNotifBtn.BackgroundColor3 = state.policeNotifEnabled
            and Color3.fromRGB(30, 80, 50) or Color3.fromRGB(80, 30, 30)
        kbPoliceNotifBtn.TextColor3 = Color3.fromRGB(220, 255, 220)
    end

    local function updateRoleBtn()
        kbRoleBtn.Text = state.roleDisplayEnabled
            and t("kb_role_badge_on")
            or  t("kb_role_badge_off")
        kbRoleBtn.BackgroundColor3 = state.roleDisplayEnabled
            and Color3.fromRGB(30, 80, 50) or Color3.fromRGB(80, 30, 30)
        kbRoleBtn.TextColor3 = Color3.fromRGB(220, 255, 220)
    end

    updatePoliceNotifBtn()
    updateRoleBtn()

    kbPoliceNotifBtn.MouseButton1Click:Connect(function()
        state.policeNotifEnabled = not state.policeNotifEnabled
        updatePoliceNotifBtn()
    end)

    kbRoleBtn.MouseButton1Click:Connect(function()
        state.roleDisplayEnabled = not state.roleDisplayEnabled
        updateRoleBtn()
    end)

    -- ---- Slider detection policier ----
    local kbDistSep = Instance.new("Frame")
    kbDistSep.Size = UDim2.new(1, -28, 0, 1)
    kbDistSep.Position = UDim2.new(0, 14, 0, 418)
    kbDistSep.BackgroundColor3 = Color3.fromRGB(60, 65, 100)
    kbDistSep.BorderSizePixel = 0
    kbDistSep.ZIndex = KB_Z
    kbDistSep.Parent = keybindPanel

    local kbDistLabel = Instance.new("TextLabel")
    kbDistLabel.Size = UDim2.new(0, 220, 0, 14)
    kbDistLabel.Position = UDim2.new(0, 14, 0, 425)
    kbDistLabel.BackgroundTransparency = 1
    kbDistLabel.TextColor3 = Color3.fromRGB(130, 130, 160)
    kbDistLabel.TextSize = 11
    kbDistLabel.Font = Enum.Font.Gotham
    kbDistLabel.TextXAlignment = Enum.TextXAlignment.Left
    kbDistLabel.Text = t("kb_police_dist")
    kbDistLabel.ZIndex = KB_Z
    kbDistLabel.Parent = keybindPanel

    local kbDistValLabel = Instance.new("TextLabel")
    kbDistValLabel.Size = UDim2.new(0, 80, 0, 14)
    kbDistValLabel.Position = UDim2.new(1, -94, 0, 425)
    kbDistValLabel.BackgroundTransparency = 1
    kbDistValLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    kbDistValLabel.TextSize = 11
    kbDistValLabel.Font = Enum.Font.GothamBold
    kbDistValLabel.TextXAlignment = Enum.TextXAlignment.Right
    kbDistValLabel.Text = tostring(state.policeDetectDist) .. " m"
    kbDistValLabel.ZIndex = KB_Z
    kbDistValLabel.Parent = keybindPanel

    -- Rail du slider
    local kbDistTrack = Instance.new("Frame")
    kbDistTrack.Size = UDim2.new(1, -28, 0, 8)
    kbDistTrack.Position = UDim2.new(0, 14, 0, 445)
    kbDistTrack.BackgroundColor3 = Color3.fromRGB(35, 40, 65)
    kbDistTrack.BorderSizePixel = 0
    kbDistTrack.ZIndex = KB_Z
    kbDistTrack.Parent = keybindPanel
    createRounded(kbDistTrack, 4)

    local kbDistFill = Instance.new("Frame")
    kbDistFill.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    kbDistFill.BorderSizePixel = 0
    kbDistFill.ZIndex = KB_Z
    kbDistFill.Parent = kbDistTrack
    createRounded(kbDistFill, 4)

    local kbDistHandle = Instance.new("TextButton")
    kbDistHandle.Size = UDim2.new(0, 18, 0, 18)
    kbDistHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    kbDistHandle.Text = ""
    kbDistHandle.BorderSizePixel = 0
    kbDistHandle.ZIndex = KB_Z + 1
    kbDistHandle.Parent = kbDistTrack
    createRounded(kbDistHandle, 9)

    local DIST_MIN, DIST_MAX = 50, 500

    local function updateDistSlider()
        local pct = (state.policeDetectDist - DIST_MIN) / (DIST_MAX - DIST_MIN)
        kbDistFill.Size = UDim2.new(pct, 0, 1, 0)
        kbDistHandle.Position = UDim2.new(pct, -9, 0.5, -9)
        kbDistValLabel.Text = tostring(state.policeDetectDist) .. " m"
    end
    updateDistSlider()

    local draggingDist = false
    kbDistHandle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingDist = true
            keybindPanel.ScrollingEnabled = false
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingDist = false
            keybindPanel.ScrollingEnabled = true
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not draggingDist then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local trackPos = kbDistTrack.AbsolutePosition
        local trackSize = kbDistTrack.AbsoluteSize
        local relX = math.clamp(inp.Position.X - trackPos.X, 0, trackSize.X)
        local pct = relX / trackSize.X
        local raw = DIST_MIN + pct * (DIST_MAX - DIST_MIN)
        state.policeDetectDist = math.floor(raw / 10 + 0.5) * 10  -- snap 10m
        updateDistSlider()
    end)

    -- ---- Toggle simulation vehicule ----
    local kbVehSimSep = Instance.new("Frame")
    kbVehSimSep.Size = UDim2.new(1, -28, 0, 1)
    kbVehSimSep.Position = UDim2.new(0, 14, 0, 464)
    kbVehSimSep.BackgroundColor3 = Color3.fromRGB(60, 65, 100)
    kbVehSimSep.BorderSizePixel = 0
    kbVehSimSep.ZIndex = KB_Z
    kbVehSimSep.Parent = keybindPanel

    local kbVehSimBtn = Instance.new("TextButton")
    kbVehSimBtn.Size = UDim2.new(1, -28, 0, 28)
    kbVehSimBtn.Position = UDim2.new(0, 14, 0, 472)
    kbVehSimBtn.TextSize = 13
    kbVehSimBtn.Font = Enum.Font.GothamBold
    kbVehSimBtn.BorderSizePixel = 0
    kbVehSimBtn.ZIndex = KB_Z
    kbVehSimBtn.Parent = keybindPanel
    createRounded(kbVehSimBtn, 7)

    local function updateVehSimBtn()
        if state.vehSimEnabled then
            -- Verifier si le vehicule du joueur a le contact ON (sim inutile)
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local seat = hum and hum.SeatPart
            local vehModel = seat and seat:FindFirstAncestorOfClass("Model")
            local contactOn = vehModel and vehModel:GetAttribute("IsOn")
            if contactOn then
                kbVehSimBtn.Text = t("kb_vehsim_contact_on")
                kbVehSimBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 20)
                kbVehSimBtn.TextColor3 = Color3.fromRGB(255, 200, 180)
                return
            end
            kbVehSimBtn.Text = t("kb_vehsim_on")
            kbVehSimBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 50)
        else
            kbVehSimBtn.Text = t("kb_vehsim_off")
            kbVehSimBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
        end
        kbVehSimBtn.TextColor3 = Color3.fromRGB(220, 255, 220)
    end
    updateVehSimBtn()

    -- Mise a jour periodique du bouton (detecte changement IsOn)
    task.spawn(function()
        while keybindPanel.Parent do
            task.wait(0.5)
            if state.vehSimEnabled then updateVehSimBtn() end
        end
    end)

    kbVehSimBtn.MouseButton1Click:Connect(function()
        state.vehSimEnabled = not state.vehSimEnabled
        if not state.vehSimEnabled then
            -- Reset attributs et donnees quand on desactive
            local vehiclesFolder = workspace:FindFirstChild("Vehicles")
            if vehiclesFolder then
                for _, veh in ipairs(vehiclesFolder:GetChildren()) do
                    if veh:IsA("Model") and not veh:GetAttribute("IsOn") then
                        pcall(function() veh:SetAttribute("Throttle", 0) end)
                        pcall(function() veh:SetAttribute("Steering", 0) end)
                    end
                end
            end
            vehSimData = {}
        end
        updateVehSimBtn()
    end)

    -- ---- Controles Sim Vehicule (touches + vitesses) ----
    local kbSimCtrlSep = Instance.new("Frame")
    kbSimCtrlSep.Size = UDim2.new(1, -28, 0, 1)
    kbSimCtrlSep.Position = UDim2.new(0, 14, 0, 504)
    kbSimCtrlSep.BackgroundColor3 = Color3.fromRGB(50, 55, 80)
    kbSimCtrlSep.BorderSizePixel = 0
    kbSimCtrlSep.ZIndex = KB_Z
    kbSimCtrlSep.Parent = keybindPanel

    -- Touche avancer
    local kbSimFwdLabel = Instance.new("TextLabel")
    kbSimFwdLabel.Size = UDim2.new(1, -28, 0, 14)
    kbSimFwdLabel.Position = UDim2.new(0, 14, 0, 510)
    kbSimFwdLabel.BackgroundTransparency = 1
    kbSimFwdLabel.TextColor3 = Color3.fromRGB(130, 130, 160)
    kbSimFwdLabel.TextSize = 11
    kbSimFwdLabel.Font = Enum.Font.Gotham
    kbSimFwdLabel.TextXAlignment = Enum.TextXAlignment.Left
    kbSimFwdLabel.Text = t("kb_sim_fwd_label")
    kbSimFwdLabel.ZIndex = KB_Z
    kbSimFwdLabel.Parent = keybindPanel

    local kbSimFwdOuter = Instance.new("Frame")
    kbSimFwdOuter.Size = UDim2.new(0, 50, 0, 32)
    kbSimFwdOuter.Position = UDim2.new(0, 14, 0, 526)
    kbSimFwdOuter.BackgroundColor3 = Color3.fromRGB(0, 140, 200)
    kbSimFwdOuter.BorderSizePixel = 0
    kbSimFwdOuter.ZIndex = KB_Z
    kbSimFwdOuter.Parent = keybindPanel
    createRounded(kbSimFwdOuter, 7)

    local kbSimFwdInner = Instance.new("Frame")
    kbSimFwdInner.Size = UDim2.new(1, -6, 1, -6)
    kbSimFwdInner.Position = UDim2.new(0, 3, 0, 3)
    kbSimFwdInner.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    kbSimFwdInner.BorderSizePixel = 0
    kbSimFwdInner.ZIndex = KB_Z
    kbSimFwdInner.Parent = kbSimFwdOuter
    createRounded(kbSimFwdInner, 5)

    local kbSimFwdKeyLabel = Instance.new("TextLabel")
    kbSimFwdKeyLabel.Size = UDim2.new(1, 0, 1, 0)
    kbSimFwdKeyLabel.BackgroundTransparency = 1
    kbSimFwdKeyLabel.TextColor3 = Color3.fromRGB(0, 210, 255)
    kbSimFwdKeyLabel.TextSize = 14
    kbSimFwdKeyLabel.Font = Enum.Font.GothamBold
    kbSimFwdKeyLabel.ZIndex = KB_Z
    kbSimFwdKeyLabel.Parent = kbSimFwdInner

    local kbSimFwdChangeBtn = Instance.new("TextButton")
    kbSimFwdChangeBtn.Size = UDim2.new(0, 100, 0, 26)
    kbSimFwdChangeBtn.Position = UDim2.new(0, 70, 0, 529)
    kbSimFwdChangeBtn.BackgroundColor3 = Color3.fromRGB(70, 40, 110)
    kbSimFwdChangeBtn.TextColor3 = Color3.fromRGB(220, 200, 255)
    kbSimFwdChangeBtn.TextSize = 11
    kbSimFwdChangeBtn.Font = Enum.Font.GothamBold
    kbSimFwdChangeBtn.Text = "CHANGER TOUCHE"
    kbSimFwdChangeBtn.BorderSizePixel = 0
    kbSimFwdChangeBtn.ZIndex = KB_Z
    kbSimFwdChangeBtn.Parent = keybindPanel
    createRounded(kbSimFwdChangeBtn, 7)

    local kbSimFwdStatus = Instance.new("TextLabel")
    kbSimFwdStatus.Size = UDim2.new(0, 120, 0, 26)
    kbSimFwdStatus.Position = UDim2.new(0, 176, 0, 529)
    kbSimFwdStatus.BackgroundTransparency = 1
    kbSimFwdStatus.TextColor3 = Color3.fromRGB(80, 220, 120)
    kbSimFwdStatus.TextSize = 11
    kbSimFwdStatus.Font = Enum.Font.Gotham
    kbSimFwdStatus.TextWrapped = true
    kbSimFwdStatus.ZIndex = KB_Z
    kbSimFwdStatus.Parent = keybindPanel

    -- Touche reculer
    local kbSimRevLabel = Instance.new("TextLabel")
    kbSimRevLabel.Size = UDim2.new(1, -28, 0, 14)
    kbSimRevLabel.Position = UDim2.new(0, 14, 0, 564)
    kbSimRevLabel.BackgroundTransparency = 1
    kbSimRevLabel.TextColor3 = Color3.fromRGB(130, 130, 160)
    kbSimRevLabel.TextSize = 11
    kbSimRevLabel.Font = Enum.Font.Gotham
    kbSimRevLabel.TextXAlignment = Enum.TextXAlignment.Left
    kbSimRevLabel.Text = t("kb_sim_rev_label")
    kbSimRevLabel.ZIndex = KB_Z
    kbSimRevLabel.Parent = keybindPanel

    local kbSimRevOuter = Instance.new("Frame")
    kbSimRevOuter.Size = UDim2.new(0, 50, 0, 32)
    kbSimRevOuter.Position = UDim2.new(0, 14, 0, 580)
    kbSimRevOuter.BackgroundColor3 = Color3.fromRGB(0, 140, 200)
    kbSimRevOuter.BorderSizePixel = 0
    kbSimRevOuter.ZIndex = KB_Z
    kbSimRevOuter.Parent = keybindPanel
    createRounded(kbSimRevOuter, 7)

    local kbSimRevInner = Instance.new("Frame")
    kbSimRevInner.Size = UDim2.new(1, -6, 1, -6)
    kbSimRevInner.Position = UDim2.new(0, 3, 0, 3)
    kbSimRevInner.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    kbSimRevInner.BorderSizePixel = 0
    kbSimRevInner.ZIndex = KB_Z
    kbSimRevInner.Parent = kbSimRevOuter
    createRounded(kbSimRevInner, 5)

    local kbSimRevKeyLabel = Instance.new("TextLabel")
    kbSimRevKeyLabel.Size = UDim2.new(1, 0, 1, 0)
    kbSimRevKeyLabel.BackgroundTransparency = 1
    kbSimRevKeyLabel.TextColor3 = Color3.fromRGB(0, 210, 255)
    kbSimRevKeyLabel.TextSize = 14
    kbSimRevKeyLabel.Font = Enum.Font.GothamBold
    kbSimRevKeyLabel.ZIndex = KB_Z
    kbSimRevKeyLabel.Parent = kbSimRevInner

    local kbSimRevChangeBtn = Instance.new("TextButton")
    kbSimRevChangeBtn.Size = UDim2.new(0, 100, 0, 26)
    kbSimRevChangeBtn.Position = UDim2.new(0, 70, 0, 583)
    kbSimRevChangeBtn.BackgroundColor3 = Color3.fromRGB(70, 40, 110)
    kbSimRevChangeBtn.TextColor3 = Color3.fromRGB(220, 200, 255)
    kbSimRevChangeBtn.TextSize = 11
    kbSimRevChangeBtn.Font = Enum.Font.GothamBold
    kbSimRevChangeBtn.Text = "CHANGER TOUCHE"
    kbSimRevChangeBtn.BorderSizePixel = 0
    kbSimRevChangeBtn.ZIndex = KB_Z
    kbSimRevChangeBtn.Parent = keybindPanel
    createRounded(kbSimRevChangeBtn, 7)

    local kbSimRevStatus = Instance.new("TextLabel")
    kbSimRevStatus.Size = UDim2.new(0, 120, 0, 26)
    kbSimRevStatus.Position = UDim2.new(0, 176, 0, 583)
    kbSimRevStatus.BackgroundTransparency = 1
    kbSimRevStatus.TextColor3 = Color3.fromRGB(80, 220, 120)
    kbSimRevStatus.TextSize = 11
    kbSimRevStatus.Font = Enum.Font.Gotham
    kbSimRevStatus.TextWrapped = true
    kbSimRevStatus.ZIndex = KB_Z
    kbSimRevStatus.Parent = keybindPanel

    -- Logique key listeners sim
    local waitingSimFwd, waitingSimRev = false, false

    local function setSimFwdKey(kc)
        state.simFwdKey = kc
        kbSimFwdKeyLabel.Text = tostring(kc):gsub("Enum%.KeyCode%.", "")
        kbSimFwdOuter.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        kbSimFwdStatus.Text = "Sauvegarde !"
        kbSimFwdStatus.TextColor3 = Color3.fromRGB(80, 220, 120)
        waitingSimFwd = false
    end

    local function setSimRevKey(kc)
        state.simRevKey = kc
        kbSimRevKeyLabel.Text = tostring(kc):gsub("Enum%.KeyCode%.", "")
        kbSimRevOuter.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        kbSimRevStatus.Text = "Sauvegarde !"
        kbSimRevStatus.TextColor3 = Color3.fromRGB(80, 220, 120)
        waitingSimRev = false
    end

    setSimFwdKey(state.simFwdKey)
    setSimRevKey(state.simRevKey)

    kbSimFwdChangeBtn.MouseButton1Click:Connect(function()
        waitingSimFwd = true
        waitingSimRev = false
        kbSimFwdKeyLabel.Text = "?"
        kbSimFwdOuter.BackgroundColor3 = Color3.fromRGB(220, 160, 0)
        kbSimFwdStatus.Text = "Appuie une touche..."
        kbSimFwdStatus.TextColor3 = Color3.fromRGB(255, 210, 60)
    end)

    kbSimRevChangeBtn.MouseButton1Click:Connect(function()
        waitingSimRev = true
        waitingSimFwd = false
        kbSimRevKeyLabel.Text = "?"
        kbSimRevOuter.BackgroundColor3 = Color3.fromRGB(220, 160, 0)
        kbSimRevStatus.Text = "Appuie une touche..."
        kbSimRevStatus.TextColor3 = Color3.fromRGB(255, 210, 60)
    end)

    UserInputService.InputBegan:Connect(function(input, _gp)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode == Enum.KeyCode.Escape then
            if waitingSimFwd then setSimFwdKey(state.simFwdKey) end
            if waitingSimRev then setSimRevKey(state.simRevKey) end
            return
        end
        if waitingSimFwd then setSimFwdKey(input.KeyCode) return end
        if waitingSimRev then setSimRevKey(input.KeyCode) return end
    end)

    -- Sliders vitesses sim
    local kbSimSpeedSep = Instance.new("Frame")
    kbSimSpeedSep.Size = UDim2.new(1, -28, 0, 1)
    kbSimSpeedSep.Position = UDim2.new(0, 14, 0, 620)
    kbSimSpeedSep.BackgroundColor3 = Color3.fromRGB(50, 55, 80)
    kbSimSpeedSep.BorderSizePixel = 0
    kbSimSpeedSep.ZIndex = KB_Z
    kbSimSpeedSep.Parent = keybindPanel

    -- Slider vitesse max avancer
    local kbSimFwdSpdLabel = Instance.new("TextLabel")
    kbSimFwdSpdLabel.Size = UDim2.new(0, 220, 0, 14)
    kbSimFwdSpdLabel.Position = UDim2.new(0, 14, 0, 626)
    kbSimFwdSpdLabel.BackgroundTransparency = 1
    kbSimFwdSpdLabel.TextColor3 = Color3.fromRGB(130, 130, 160)
    kbSimFwdSpdLabel.TextSize = 11
    kbSimFwdSpdLabel.Font = Enum.Font.Gotham
    kbSimFwdSpdLabel.TextXAlignment = Enum.TextXAlignment.Left
    kbSimFwdSpdLabel.Text = t("kb_sim_speed_fwd")
    kbSimFwdSpdLabel.ZIndex = KB_Z
    kbSimFwdSpdLabel.Parent = keybindPanel

    local kbSimFwdSpdVal = Instance.new("TextLabel")
    kbSimFwdSpdVal.Size = UDim2.new(0, 60, 0, 14)
    kbSimFwdSpdVal.Position = UDim2.new(1, -74, 0, 626)
    kbSimFwdSpdVal.BackgroundTransparency = 1
    kbSimFwdSpdVal.TextColor3 = Color3.fromRGB(0, 200, 255)
    kbSimFwdSpdVal.TextSize = 11
    kbSimFwdSpdVal.Font = Enum.Font.GothamBold
    kbSimFwdSpdVal.TextXAlignment = Enum.TextXAlignment.Right
    kbSimFwdSpdVal.ZIndex = KB_Z
    kbSimFwdSpdVal.Parent = keybindPanel

    local kbSimFwdSpdTrack = Instance.new("Frame")
    kbSimFwdSpdTrack.Size = UDim2.new(1, -28, 0, 8)
    kbSimFwdSpdTrack.Position = UDim2.new(0, 14, 0, 642)
    kbSimFwdSpdTrack.BackgroundColor3 = Color3.fromRGB(35, 40, 65)
    kbSimFwdSpdTrack.BorderSizePixel = 0
    kbSimFwdSpdTrack.ZIndex = KB_Z
    kbSimFwdSpdTrack.Parent = keybindPanel
    createRounded(kbSimFwdSpdTrack, 4)

    local kbSimFwdSpdFill = Instance.new("Frame")
    kbSimFwdSpdFill.BackgroundColor3 = Color3.fromRGB(0, 160, 220)
    kbSimFwdSpdFill.BorderSizePixel = 0
    kbSimFwdSpdFill.ZIndex = KB_Z
    kbSimFwdSpdFill.Parent = kbSimFwdSpdTrack
    createRounded(kbSimFwdSpdFill, 4)

    local kbSimFwdSpdHandle = Instance.new("TextButton")
    kbSimFwdSpdHandle.Size = UDim2.new(0, 18, 0, 18)
    kbSimFwdSpdHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    kbSimFwdSpdHandle.Text = ""
    kbSimFwdSpdHandle.BorderSizePixel = 0
    kbSimFwdSpdHandle.ZIndex = KB_Z + 1
    kbSimFwdSpdHandle.Parent = kbSimFwdSpdTrack
    createRounded(kbSimFwdSpdHandle, 9)

    -- Slider vitesse max reculer
    local kbSimRevSpdLabel = Instance.new("TextLabel")
    kbSimRevSpdLabel.Size = UDim2.new(0, 220, 0, 14)
    kbSimRevSpdLabel.Position = UDim2.new(0, 14, 0, 658)
    kbSimRevSpdLabel.BackgroundTransparency = 1
    kbSimRevSpdLabel.TextColor3 = Color3.fromRGB(130, 130, 160)
    kbSimRevSpdLabel.TextSize = 11
    kbSimRevSpdLabel.Font = Enum.Font.Gotham
    kbSimRevSpdLabel.TextXAlignment = Enum.TextXAlignment.Left
    kbSimRevSpdLabel.Text = t("kb_sim_speed_rev")
    kbSimRevSpdLabel.ZIndex = KB_Z
    kbSimRevSpdLabel.Parent = keybindPanel

    local kbSimRevSpdVal = Instance.new("TextLabel")
    kbSimRevSpdVal.Size = UDim2.new(0, 60, 0, 14)
    kbSimRevSpdVal.Position = UDim2.new(1, -74, 0, 658)
    kbSimRevSpdVal.BackgroundTransparency = 1
    kbSimRevSpdVal.TextColor3 = Color3.fromRGB(0, 200, 255)
    kbSimRevSpdVal.TextSize = 11
    kbSimRevSpdVal.Font = Enum.Font.GothamBold
    kbSimRevSpdVal.TextXAlignment = Enum.TextXAlignment.Right
    kbSimRevSpdVal.ZIndex = KB_Z
    kbSimRevSpdVal.Parent = keybindPanel

    local kbSimRevSpdTrack = Instance.new("Frame")
    kbSimRevSpdTrack.Size = UDim2.new(1, -28, 0, 8)
    kbSimRevSpdTrack.Position = UDim2.new(0, 14, 0, 674)
    kbSimRevSpdTrack.BackgroundColor3 = Color3.fromRGB(35, 40, 65)
    kbSimRevSpdTrack.BorderSizePixel = 0
    kbSimRevSpdTrack.ZIndex = KB_Z
    kbSimRevSpdTrack.Parent = keybindPanel
    createRounded(kbSimRevSpdTrack, 4)

    local kbSimRevSpdFill = Instance.new("Frame")
    kbSimRevSpdFill.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    kbSimRevSpdFill.BorderSizePixel = 0
    kbSimRevSpdFill.ZIndex = KB_Z
    kbSimRevSpdFill.Parent = kbSimRevSpdTrack
    createRounded(kbSimRevSpdFill, 4)

    local kbSimRevSpdHandle = Instance.new("TextButton")
    kbSimRevSpdHandle.Size = UDim2.new(0, 18, 0, 18)
    kbSimRevSpdHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    kbSimRevSpdHandle.Text = ""
    kbSimRevSpdHandle.BorderSizePixel = 0
    kbSimRevSpdHandle.ZIndex = KB_Z + 1
    kbSimRevSpdHandle.Parent = kbSimRevSpdTrack
    createRounded(kbSimRevSpdHandle, 9)

    -- Logique sliders sim
    local SIM_FWD_MIN, SIM_FWD_MAX = 10, 200
    local SIM_REV_MIN, SIM_REV_MAX = 5,  80

    local function updateSimFwdSlider()
        local pct = (state.simMaxFwd - SIM_FWD_MIN) / (SIM_FWD_MAX - SIM_FWD_MIN)
        kbSimFwdSpdFill.Size = UDim2.new(pct, 0, 1, 0)
        kbSimFwdSpdHandle.Position = UDim2.new(pct, -9, 0.5, -9)
        kbSimFwdSpdVal.Text = tostring(state.simMaxFwd)
    end

    local function updateSimRevSlider()
        local pct = (state.simMaxRev - SIM_REV_MIN) / (SIM_REV_MAX - SIM_REV_MIN)
        kbSimRevSpdFill.Size = UDim2.new(pct, 0, 1, 0)
        kbSimRevSpdHandle.Position = UDim2.new(pct, -9, 0.5, -9)
        kbSimRevSpdVal.Text = tostring(state.simMaxRev)
    end

    updateSimFwdSlider()
    updateSimRevSlider()

    local draggingSimFwd, draggingSimRev, draggingSimAccel = false, false, false
    local SIM_ACCEL_MIN, SIM_ACCEL_MAX = 5, 120

    local function startDrag(which)
        draggingSimFwd   = which == "fwd"
        draggingSimRev   = which == "rev"
        draggingSimAccel = which == "accel"
        keybindPanel.ScrollingEnabled = false  -- empeche le ScrollingFrame de voler l'input
    end

    local function stopDrag()
        draggingSimFwd = false
        draggingSimRev = false
        draggingSimAccel = false
        keybindPanel.ScrollingEnabled = true
    end

    kbSimFwdSpdHandle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then startDrag("fwd") end
    end)
    kbSimRevSpdHandle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then startDrag("rev") end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then stopDrag() end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if draggingSimFwd then
            local tp = kbSimFwdSpdTrack.AbsolutePosition
            local ts = kbSimFwdSpdTrack.AbsoluteSize
            local pct = math.clamp((inp.Position.X - tp.X) / ts.X, 0, 1)
            state.simMaxFwd = math.floor(SIM_FWD_MIN + pct * (SIM_FWD_MAX - SIM_FWD_MIN) + 0.5)
            updateSimFwdSlider()
        elseif draggingSimRev then
            local tp = kbSimRevSpdTrack.AbsolutePosition
            local ts = kbSimRevSpdTrack.AbsoluteSize
            local pct = math.clamp((inp.Position.X - tp.X) / ts.X, 0, 1)
            state.simMaxRev = math.floor(SIM_REV_MIN + pct * (SIM_REV_MAX - SIM_REV_MIN) + 0.5)
            updateSimRevSlider()
        end
    end)

    -- Slider acceleration
    local kbSimAccelLabel = Instance.new("TextLabel")
    kbSimAccelLabel.Size = UDim2.new(0, 220, 0, 14)
    kbSimAccelLabel.Position = UDim2.new(0, 14, 0, 690)
    kbSimAccelLabel.BackgroundTransparency = 1
    kbSimAccelLabel.TextColor3 = Color3.fromRGB(130, 130, 160)
    kbSimAccelLabel.TextSize = 11
    kbSimAccelLabel.Font = Enum.Font.Gotham
    kbSimAccelLabel.TextXAlignment = Enum.TextXAlignment.Left
    kbSimAccelLabel.Text = t("kb_sim_accel_label")
    kbSimAccelLabel.ZIndex = KB_Z
    kbSimAccelLabel.Parent = keybindPanel

    local kbSimAccelVal = Instance.new("TextLabel")
    kbSimAccelVal.Size = UDim2.new(0, 60, 0, 14)
    kbSimAccelVal.Position = UDim2.new(1, -74, 0, 690)
    kbSimAccelVal.BackgroundTransparency = 1
    kbSimAccelVal.TextColor3 = Color3.fromRGB(0, 200, 255)
    kbSimAccelVal.TextSize = 11
    kbSimAccelVal.Font = Enum.Font.GothamBold
    kbSimAccelVal.TextXAlignment = Enum.TextXAlignment.Right
    kbSimAccelVal.ZIndex = KB_Z
    kbSimAccelVal.Parent = keybindPanel

    local kbSimAccelTrack = Instance.new("Frame")
    kbSimAccelTrack.Size = UDim2.new(1, -28, 0, 8)
    kbSimAccelTrack.Position = UDim2.new(0, 14, 0, 706)
    kbSimAccelTrack.BackgroundColor3 = Color3.fromRGB(35, 40, 65)
    kbSimAccelTrack.BorderSizePixel = 0
    kbSimAccelTrack.ZIndex = KB_Z
    kbSimAccelTrack.Parent = keybindPanel
    createRounded(kbSimAccelTrack, 4)

    local kbSimAccelFill = Instance.new("Frame")
    kbSimAccelFill.BackgroundColor3 = Color3.fromRGB(200, 140, 0)
    kbSimAccelFill.BorderSizePixel = 0
    kbSimAccelFill.ZIndex = KB_Z
    kbSimAccelFill.Parent = kbSimAccelTrack
    createRounded(kbSimAccelFill, 4)

    local kbSimAccelHandle = Instance.new("TextButton")
    kbSimAccelHandle.Size = UDim2.new(0, 18, 0, 18)
    kbSimAccelHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    kbSimAccelHandle.Text = ""
    kbSimAccelHandle.BorderSizePixel = 0
    kbSimAccelHandle.ZIndex = KB_Z + 1
    kbSimAccelHandle.Parent = kbSimAccelTrack
    createRounded(kbSimAccelHandle, 9)

    local function updateSimAccelSlider()
        local pct = (state.simAccel - SIM_ACCEL_MIN) / (SIM_ACCEL_MAX - SIM_ACCEL_MIN)
        kbSimAccelFill.Size = UDim2.new(pct, 0, 1, 0)
        kbSimAccelHandle.Position = UDim2.new(pct, -9, 0.5, -9)
        kbSimAccelVal.Text = tostring(state.simAccel)
    end
    updateSimAccelSlider()

    kbSimAccelHandle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then startDrag("accel") end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not draggingSimAccel then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local tp = kbSimAccelTrack.AbsolutePosition
        local ts = kbSimAccelTrack.AbsoluteSize
        local pct = math.clamp((inp.Position.X - tp.X) / ts.X, 0, 1)
        state.simAccel = math.floor(SIM_ACCEL_MIN + pct * (SIM_ACCEL_MAX - SIM_ACCEL_MIN) + 0.5)
        updateSimAccelSlider()
    end)

    -- ---- Toggle panel occupants vehicule ----
    local kbOccSep = Instance.new("Frame")
    kbOccSep.Size = UDim2.new(1, -28, 0, 1)
    kbOccSep.Position = UDim2.new(0, 14, 0, 730)
    kbOccSep.BackgroundColor3 = Color3.fromRGB(60, 65, 100)
    kbOccSep.BorderSizePixel = 0
    kbOccSep.ZIndex = KB_Z
    kbOccSep.Parent = keybindPanel

    local kbOccBtn = Instance.new("TextButton")
    kbOccBtn.Size = UDim2.new(1, -28, 0, 28)
    kbOccBtn.Position = UDim2.new(0, 14, 0, 738)
    kbOccBtn.TextSize = 13
    kbOccBtn.Font = Enum.Font.GothamBold
    kbOccBtn.BorderSizePixel = 0
    kbOccBtn.ZIndex = KB_Z
    kbOccBtn.Parent = keybindPanel
    createRounded(kbOccBtn, 7)

    local function updateOccBtn()
        kbOccBtn.Text = state.occPanelEnabled and t("kb_occ_panel_on") or t("kb_occ_panel_off")
        kbOccBtn.BackgroundColor3 = state.occPanelEnabled
            and Color3.fromRGB(30, 80, 50) or Color3.fromRGB(80, 30, 30)
        kbOccBtn.TextColor3 = Color3.fromRGB(220, 255, 220)
    end
    updateOccBtn()

    kbOccBtn.MouseButton1Click:Connect(function()
        state.occPanelEnabled = not state.occPanelEnabled
        updateOccBtn()
    end)

    -- ===== PANNEAU OCCUPANTS VEHICLE (persistant, toujours visible, togglable) =====
    local occPanel = Instance.new("Frame")
    occPanel.Name = "OccupantsPanel"
    occPanel.Size = UDim2.new(0, 210, 0, 14)
    occPanel.Position = UDim2.new(0, 10, 0, 10)
    occPanel.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    occPanel.BorderSizePixel = 0
    occPanel.Visible = false
    occPanel.Parent = openGui
    createRounded(occPanel, 10)

    local occStroke = Instance.new("UIStroke")
    occStroke.Color = Color3.fromRGB(200, 160, 40)
    occStroke.Thickness = 1.5
    occStroke.Parent = occPanel

    local occIcon = Instance.new("TextLabel")
    occIcon.Size = UDim2.new(0, 26, 0, 26)
    occIcon.Position = UDim2.new(0, 6, 0, 6)
    occIcon.BackgroundTransparency = 1
    occIcon.TextColor3 = Color3.fromRGB(255, 200, 80)
    occIcon.TextSize = 16
    occIcon.Font = Enum.Font.GothamBold
    occIcon.Text = "👥"
    occIcon.Parent = occPanel

    local occLines = {}
    for i = 1, 6 do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -42, 0, 16)
        lbl.Position = UDim2.new(0, 36, 0, 4 + (i - 1) * 17)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
        lbl.TextSize = 12
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Text = ""
        lbl.Visible = false
        lbl.Parent = occPanel
        occLines[i] = lbl
    end

    local function updateOccupantsPanel()
        if not state.occPanelEnabled then
            occPanel.Visible = false
            return
        end
        local veh = findVehicle()
        if not veh or not veh:IsA("Model") then
            occPanel.Visible = false
            return
        end
        local found = {}
        for _, seat in ipairs(veh:GetDescendants()) do
            if (seat:IsA("VehicleSeat") or seat:IsA("Seat")) and seat.Occupant then
                local hum = seat.Occupant
                local isDriver = seat:IsA("VehicleSeat")
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("Humanoid") == hum then
                        table.insert(found, { name = p.Name, seat = seat.Name, isDriver = isDriver })
                        break
                    end
                end
            end
        end
        table.sort(found, function(a, b) return (a.isDriver and 1 or 0) > (b.isDriver and 1 or 0) end)
        if #found == 0 then
            occPanel.Visible = false
            return
        end
        for i = 1, 6 do
            local occ = found[i]
            if occ then
                if occ.isDriver then
                    occLines[i].Text = "🚗 CONDUCTEUR  " .. occ.name
                    occLines[i].TextColor3 = Color3.fromRGB(255, 220, 60)
                else
                    occLines[i].Text = "👤  " .. occ.name
                    occLines[i].TextColor3 = Color3.fromRGB(200, 200, 200)
                end
                occLines[i].Visible = true
            else
                occLines[i].Text = ""
                occLines[i].Visible = false
            end
        end
        local count = math.min(#found, 6)
        occPanel.Size = UDim2.new(0, 210, 0, 10 + count * 17)
        occPanel.Visible = true
    end

    task.spawn(function()
        while openGui.Parent do
            task.wait(0.5)
            pcall(updateOccupantsPanel)
        end
    end)

    -- ---- Badge role (persistant, au-dessus du bouton MOD) ----
    local roleBadge = Instance.new("Frame")
    roleBadge.Size = UDim2.new(0, 90, 0, 20)
    roleBadge.Position = UDim2.new(0, 9, 0.5, -56)
    roleBadge.BackgroundColor3 = Color3.fromRGB(40, 42, 52)
    roleBadge.BorderSizePixel = 0
    roleBadge.Parent = openGui
    createRounded(roleBadge, 5)

    local roleColorDot = Instance.new("Frame")
    roleColorDot.Size = UDim2.new(0, 12, 0, 12)
    roleColorDot.Position = UDim2.new(0, 4, 0.5, -6)
    roleColorDot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    roleColorDot.BorderSizePixel = 0
    roleColorDot.Parent = roleBadge
    createRounded(roleColorDot, 6)

    local roleBadgeLabel = Instance.new("TextLabel")
    roleBadgeLabel.Size = UDim2.new(1, -22, 1, 0)
    roleBadgeLabel.Position = UDim2.new(0, 20, 0, 0)
    roleBadgeLabel.BackgroundTransparency = 1
    roleBadgeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    roleBadgeLabel.TextSize = 10
    roleBadgeLabel.Font = Enum.Font.GothamBold
    roleBadgeLabel.Text = "..."
    roleBadgeLabel.TextXAlignment = Enum.TextXAlignment.Left
    roleBadgeLabel.TextTruncate = Enum.TextTruncate.AtEnd
    roleBadgeLabel.Parent = roleBadge

    -- ---- Notif police (bas droite, persistante) ----
    local policeNotifFrame = Instance.new("Frame")
    policeNotifFrame.Size = UDim2.new(0, 210, 0, 50)
    policeNotifFrame.Position = UDim2.new(1, -220, 1, -68)
    policeNotifFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 36)
    policeNotifFrame.BorderSizePixel = 0
    policeNotifFrame.Visible = false
    policeNotifFrame.Parent = openGui
    createRounded(policeNotifFrame, 10)

    local policeAccent = Instance.new("Frame")
    policeAccent.Size = UDim2.new(0, 4, 1, -10)
    policeAccent.Position = UDim2.new(0, 5, 0, 5)
    policeAccent.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    policeAccent.BorderSizePixel = 0
    policeAccent.Parent = policeNotifFrame
    createRounded(policeAccent, 3)

    local policeMainLabel = Instance.new("TextLabel")
    policeMainLabel.Size = UDim2.new(1, -22, 0, 24)
    policeMainLabel.Position = UDim2.new(0, 18, 0, 5)
    policeMainLabel.BackgroundTransparency = 1
    policeMainLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    policeMainLabel.TextSize = 13
    policeMainLabel.Font = Enum.Font.GothamBold
    policeMainLabel.TextXAlignment = Enum.TextXAlignment.Left
    policeMainLabel.Text = t("notif_police_one")
    policeMainLabel.Parent = policeNotifFrame

    local policeSubLabel = Instance.new("TextLabel")
    policeSubLabel.Size = UDim2.new(1, -22, 0, 16)
    policeSubLabel.Position = UDim2.new(0, 18, 0, 28)
    policeSubLabel.BackgroundTransparency = 1
    policeSubLabel.TextColor3 = Color3.fromRGB(160, 160, 200)
    policeSubLabel.TextSize = 11
    policeSubLabel.Font = Enum.Font.Gotham
    policeSubLabel.TextXAlignment = Enum.TextXAlignment.Left
    policeSubLabel.Text = string.format(t("notif_police_sub"), 0)
    policeSubLabel.Parent = policeNotifFrame

    -- ---- Notif sim airborne ----
    local simNotifFrame = Instance.new("Frame")
    simNotifFrame.Size = UDim2.new(0, 210, 0, 50)
    simNotifFrame.Position = UDim2.new(1, -220, 1, -126)
    simNotifFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 36)
    simNotifFrame.BorderSizePixel = 0
    simNotifFrame.Visible = false
    simNotifFrame.Parent = openGui
    createRounded(simNotifFrame, 10)

    local simNotifAccent = Instance.new("Frame")
    simNotifAccent.Size = UDim2.new(0, 4, 1, -10)
    simNotifAccent.Position = UDim2.new(0, 5, 0, 5)
    simNotifAccent.BackgroundColor3 = Color3.fromRGB(220, 130, 0)
    simNotifAccent.BorderSizePixel = 0
    simNotifAccent.Parent = simNotifFrame
    createRounded(simNotifAccent, 3)

    local simNotifMain = Instance.new("TextLabel")
    simNotifMain.Size = UDim2.new(1, -22, 0, 24)
    simNotifMain.Position = UDim2.new(0, 18, 0, 5)
    simNotifMain.BackgroundTransparency = 1
    simNotifMain.TextColor3 = Color3.fromRGB(255, 255, 255)
    simNotifMain.TextSize = 13
    simNotifMain.Font = Enum.Font.GothamBold
    simNotifMain.TextXAlignment = Enum.TextXAlignment.Left
    simNotifMain.Text = t("notif_airborne")
    simNotifMain.Parent = simNotifFrame

    local simNotifSub = Instance.new("TextLabel")
    simNotifSub.Size = UDim2.new(1, -22, 0, 16)
    simNotifSub.Position = UDim2.new(0, 18, 0, 28)
    simNotifSub.BackgroundTransparency = 1
    simNotifSub.TextColor3 = Color3.fromRGB(200, 160, 100)
    simNotifSub.TextSize = 11
    simNotifSub.Font = Enum.Font.Gotham
    simNotifSub.TextXAlignment = Enum.TextXAlignment.Left
    simNotifSub.Text = t("notif_airborne_sub")
    simNotifSub.Parent = simNotifFrame

    local simNotifTimer = 0
    local simWasAirborne = false

    RunService.Heartbeat:Connect(function(dt)
        -- Detecter passage airborne pour afficher notif
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local seat = hum and hum.SeatPart
        local vehModel = seat and seat:FindFirstAncestorOfClass("Model")
        if state.vehSimEnabled and vehModel then
            local airTime = vehAirTime[vehModel] or 0
            local isAir = airTime >= 0.3
            if isAir and not simWasAirborne then
                simNotifFrame.Visible = true
                simNotifTimer = 2.5
            end
            simWasAirborne = isAir
        else
            simWasAirborne = false
        end
        if simNotifTimer > 0 then
            simNotifTimer = simNotifTimer - dt
            if simNotifTimer <= 0 then
                simNotifFrame.Visible = false
            end
        end
    end)

    -- ---- Boucle scan policier (0.5s) + mise a jour role ----
    local POLICE_KW = {"police"}
    local function matchesPolice(name)
        local low = name:lower()
        for _, kw in ipairs(POLICE_KW) do
            if low:find(kw) then return true end
        end
        return false
    end

    local scanTimer = 0
    RunService.Heartbeat:Connect(function(dt)
        -- Badge role (chaque frame, léger)
        if state.roleDisplayEnabled then
            roleBadge.Visible = true
            local team = player.Team
            if team then
                roleBadgeLabel.Text = team.Name
                local ok, col = pcall(function() return team.TeamColor.Color end)
                roleColorDot.BackgroundColor3 = ok and col or Color3.fromRGB(150, 150, 150)
            else
                local ok, role = pcall(function()
                    return player:GetAttribute("role") or player:GetAttribute("Role")
                end)
                roleBadgeLabel.Text = (ok and role) and tostring(role) or "—"
                roleColorDot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
            end
        else
            roleBadge.Visible = false
        end

        -- Scan policier throttle 0.5s
        scanTimer = scanTimer + dt
        if scanTimer < 0.5 then return end
        scanTimer = 0

        if not state.policeNotifEnabled then
            policeNotifFrame.Visible = false
            return
        end

        local char = player.Character
        if not char then policeNotifFrame.Visible = false return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then policeNotifFrame.Visible = false return end

        local myPos = root.Position
        local closestDist = math.huge
        local copCount = 0

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                local isPolic = false
                if p.Team and matchesPolice(p.Team.Name) then isPolic = true end
                if not isPolic then
                    local ok, role = pcall(function()
                        return p:GetAttribute("role") or p:GetAttribute("Role")
                    end)
                    if ok and role and matchesPolice(tostring(role)) then isPolic = true end
                end
                if isPolic then
                    local pChar = p.Character
                    if pChar then
                        local pRoot = pChar:FindFirstChild("HumanoidRootPart")
                        if pRoot then
                            local dist = (myPos - pRoot.Position).Magnitude
                            if dist <= state.policeDetectDist then
                                copCount = copCount + 1
                                if dist < closestDist then closestDist = dist end
                            end
                        end
                    end
                end
            end
        end

        if copCount > 0 then
            policeNotifFrame.Visible = true
            policeMainLabel.Text = copCount == 1
                and t("notif_police_one")
                or  string.format(t("notif_police_many"), copCount)
            policeSubLabel.Text = string.format(t("notif_police_sub"), math.floor(closestDist))
        else
            policeNotifFrame.Visible = false
        end
    end)

    kbCloseBtn.MouseButton1Click:Connect(function()
        waitingForKey = false
        keybindPanel.Visible = false
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not waitingForKey then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode == Enum.KeyCode.Escape then
            waitingForKey = false
            setOrbitKey(state.orbitToggleKey)
            return
        end
        waitingForKey = false
        setOrbitKey(input.KeyCode)
    end)

    gearBtn.MouseButton1Click:Connect(function()
        keybindPanel.Visible = not keybindPanel.Visible
        if keybindPanel.Visible then
            setOrbitKey(state.orbitToggleKey)
        else
            waitingForKey = false
        end
    end)

    openBtn.MouseButton1Click:Connect(function()
        if mainGui then
            mainGui.Enabled = not mainGui.Enabled
        end
    end)
end

local existing = player:WaitForChild("PlayerGui"):FindFirstChild("VehicleTPUI")
if existing then
    existing:Destroy()
end

player.CharacterAdded:Connect(function()
    state.cachedVehicle = nil
    state.followEnabled = false
    state.mirrorEnabled = false
    state.mirrorTargetPart = nil
    state.mirrorLastCFrame = nil
    stopTrollNoClipAndResolve()
end)

startGroundGuard()

local mainGui = createMainUI()
state.mainGui = mainGui
createOpenButton(mainGui)
print("ELIX Mod Menu charge")
