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
    NEAR_TARGET_SNAP_DISTANCE = 7,
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
    MAX_STEP_RISE = 1.5,
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
    followTarget = nil,
    followTargetPart = nil,
    followLoopRunning = false,
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
}

-- ===== SYSTEME DE TRADUCTION =====
local TRANSLATIONS = {
    fr = {
        menu_teleport   = "TELEPORTER",
        menu_waypoints  = "HOME / WAYPOINTS",
        menu_custom     = "⚙ CUSTOM VEHICULE",
        menu_delete     = "SUPPRIMER UI",
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

local function findVehicle()
    if state.cachedVehicle and state.cachedVehicle.Parent and isPlayerVehicleModel(state.cachedVehicle) then
        return state.cachedVehicle
    end
    state.cachedVehicle = nil

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

        if humanoid then
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


local function destroyTeleportUI()
    state.isTPing = false
    state.followEnabled = false
    state.followTarget = nil
    state.selectedWaypointId = nil
    stopTrollNoClipAndResolve()
    clearWaypointMarker()

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

local function createMainUI()
    local playerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VehicleTPUI"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999
    screenGui.Parent = playerGui

    -- Badge role haut-gauche
    local roleBadge = Instance.new("Frame")
    roleBadge.Name = "RoleBadge"
    roleBadge.Size = UDim2.new(0, 175, 0, 36)
    roleBadge.Position = UDim2.new(0, 10, 0, 10)
    roleBadge.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    roleBadge.BorderSizePixel = 0
    roleBadge.Parent = screenGui
    createRounded(roleBadge, 10)

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
        if r:find("police") or r:find("cop") or r:find("officer") or r:find("policier") then
            return Color3.fromRGB(50, 110, 220), "POLICIER"
        elseif r:find("prison") or r:find("inmate") or r:find("prisonnier") then
            return Color3.fromRGB(220, 185, 30), "PRISONNIER"
        else
            return Color3.fromRGB(210, 50, 50), "CITIZEN"
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

    local function showScreen(screenKey)
        menuScreen.Visible   = screenKey == "menu"
        teleportScreen.Visible = screenKey == "teleport"
        waypointScreen.Visible = screenKey == "waypoints"
        customScreen.Visible = screenKey == "custom"
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
        csBtn.Text = "CAST SHADOW : ON"
        csBtn.BorderSizePixel = 0
        csBtn.Parent = rightPanel
        createRounded(csBtn, 7)

        local cvCastShadow = true
        csBtn.MouseButton1Click:Connect(function()
            cvCastShadow = not cvCastShadow
            csBtn.Text = cvCastShadow and "CAST SHADOW : ON" or "CAST SHADOW : OFF"
            csBtn.BackgroundColor3 = cvCastShadow and Color3.fromRGB(60,165,95) or Color3.fromRGB(145,45,45)
            cvApplyProp("CastShadow", cvCastShadow)
        end)

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
        gridLayout.CellSize = UDim2.new(0.5, -8, 0, 66)
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
        end)
    end

    tabButtons[currentTab].BackgroundColor3 = Color3.fromRGB(0, 150, 220)
    tabButtons[currentTab].TextColor3 = Color3.fromRGB(255, 255, 255)

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
    followBtn.Size = UDim2.new(0, 120, 0, 34)
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
    rotationBtn.Size = UDim2.new(0, 120, 0, 34)
    rotationBtn.Position = UDim2.new(0, 400, 0, 8)
    rotationBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    rotationBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rotationBtn.TextSize = 12
    rotationBtn.Font = Enum.Font.GothamBold
    tReg(rotationBtn, "btn_rot_off")
    rotationBtn.BorderSizePixel = 0
    rotationBtn.Parent = controlPanel
    createRounded(rotationBtn, 8)

    local function refreshModeButtons()
        followBtn.Text = state.followEnabled and t("btn_orbit_on") or t("btn_orbit_off")
        followBtn.BackgroundColor3 = state.followEnabled and Color3.fromRGB(170, 75, 210) or Color3.fromRGB(90, 90, 90)

        rotationBtn.Text = state.orbitRotationEnabled and t("btn_rot_on") or t("btn_rot_off")
        rotationBtn.BackgroundColor3 = state.orbitRotationEnabled and Color3.fromRGB(60, 165, 95) or Color3.fromRGB(90, 90, 90)

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
            pingBtn.Size = UDim2.new(0, 40, 1, -8)
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

    local function loadDealersFolder()
        local function processFolder(dealersFolder)
            local added = 0
            for _, dealer in ipairs(dealersFolder:GetDescendants()) do
                if dealer:IsA("Model") and dealer:FindFirstChildOfClass("Humanoid") then
                    local captured = dealer
                    addDestinationButton("dealer", captured.Name, Color3.fromRGB(65, 110, 65), function()
                        local part = findBasePart(captured)
                        if not part then
                            return nil
                        end
                        return {
                            pos = part.Position,
                        }
                    end, captured)
                    added = added + 1
                end
            end
            -- Fallback: inclure tous les modeles meme sans Humanoid si rien trouv‌e
            if added == 0 then
                for _, dealer in ipairs(dealersFolder:GetChildren()) do
                    if dealer:IsA("Model") then
                        local captured = dealer
                        addDestinationButton("dealer", captured.Name, Color3.fromRGB(65, 110, 65), function()
                            local part = findBasePart(captured)
                            if not part then
                                return nil
                            end
                            return {
                                pos = part.Position,
                            }
                        end, captured)
                    end
                end
            end
        end

        local dealersFolder = workspace:FindFirstChild("Dealers")
        if dealersFolder then
            processFolder(dealersFolder)
        else
            -- Attendre jusqu'a 10s si le dossier n'est pas encore charge
            task.spawn(function()
                local found = workspace:WaitForChild("Dealers", 10)
                if found then
                    processFolder(found)
                end
            end)
        end
    end

    local function refreshVehiclesTab()
        local vehiclesFrame = tabContents.vehicles
        if not vehiclesFrame then return end

        for _, child in ipairs(vehiclesFrame:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end
        end

        local vehiclesFolder = workspace:FindFirstChild("Vehicles")
        if not vehiclesFolder then
            statusLabel.Text = "Dossier Vehicles introuvable"
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

            local btnColor = Color3.fromRGB(30, 48, 38)
            local vBtn = Instance.new("TextButton")
            vBtn.Size = UDim2.new(1, 0, 0, 76)
            vBtn.BackgroundColor3 = btnColor
            vBtn.Text = ""
            vBtn.BorderSizePixel = 0
            vBtn.Parent = vehiclesFrame
            createRounded(vBtn, 8)

            -- Dot etat
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 12, 0, 12)
            dot.Position = UDim2.new(0, 10, 0, 10)
            dot.BackgroundColor3 = fuelColor
            dot.BorderSizePixel = 0
            dot.ZIndex = 2
            dot.Parent = vBtn
            createRounded(dot, 6)

            -- Ligne 1 : nom + position
            local lblName = Instance.new("TextLabel")
            lblName.Size = UDim2.new(1, -30, 0, 28)
            lblName.Position = UDim2.new(0, 26, 0, 4)
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
            sep.Size = UDim2.new(1, -20, 0, 1)
            sep.Position = UDim2.new(0, 10, 0, 34)
            sep.BackgroundColor3 = Color3.fromRGB(50, 80, 60)
            sep.BorderSizePixel = 0
            sep.ZIndex = 2
            sep.Parent = vBtn

            -- Ligne 2 : rim + fuel + health
            local fuelStr   = fuelNum   and string.format("%.1f", fuelNum)   or tostring(fuelVal)
            local healthStr = healthNum and string.format("%.1f", healthNum) or tostring(healthVal)

            local lblInfo = Instance.new("TextLabel")
            lblInfo.Size = UDim2.new(1, -16, 0, 34)
            lblInfo.Position = UDim2.new(0, 10, 0, 38)
            lblInfo.BackgroundTransparency = 1
            lblInfo.TextColor3 = Color3.fromRGB(160, 210, 180)
            lblInfo.TextSize = 11
            lblInfo.Font = Enum.Font.Gotham
            lblInfo.TextXAlignment = Enum.TextXAlignment.Left
            lblInfo.Text = string.format("⚙ Rim: %s     ⛽ Fuel: %s     ❤ Health: %s", tostring(rimVal), fuelStr, healthStr)
            lblInfo.ZIndex = 2
            lblInfo.Parent = vBtn

            -- Bouton PING
            local pingActive = state.vehiclePings[veh] ~= nil
            local pingBtn = Instance.new("TextButton")
            pingBtn.Size = UDim2.new(0, 46, 1, -8)
            pingBtn.Position = UDim2.new(1, -104, 0, 4)
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

            -- Bouton CIBLE (suit le vehicle)
            local vehRoot = veh:IsA("Model") and (veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")) or veh
            local targetActive = state.followTargetPart == vehRoot
            local targetBtn = Instance.new("TextButton")
            targetBtn.Size = UDim2.new(0, 46, 1, -8)
            targetBtn.Position = UDim2.new(1, -54, 0, 4)
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
                    statusLabel.Text = "ORBIT vehicle desactive"
                else
                    local localVehicle = findVehicle()
                    if not localVehicle or not isLocalPlayerSeatedInVehicle(localVehicle) then
                        statusLabel.Text = t("status_no_veh")
                        return
                    end
                    state.followTargetPart = root
                    state.followTarget = nil
                    state.followEnabled = true
                    state.trollAngle = 0
                    state.trollTime = 0
                    refreshModeButtons()
                    targetBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 0)
                    statusLabel.Text = "ORBIT vehicle: " .. veh.Name
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
    local keybindPanel = Instance.new("Frame")
    keybindPanel.Size = UDim2.new(0, 370, 0, 240)
    keybindPanel.Position = UDim2.new(0, 78, 0.5, -120)
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

    local kbQuickLabel = Instance.new("TextLabel")
    kbQuickLabel.Size = UDim2.new(1, -28, 0, 18)
    kbQuickLabel.Position = UDim2.new(0, 14, 0, 118)
    kbQuickLabel.BackgroundTransparency = 1
    kbQuickLabel.TextColor3 = Color3.fromRGB(130, 130, 160)
    kbQuickLabel.TextSize = 11
    kbQuickLabel.Font = Enum.Font.Gotham
    tReg(kbQuickLabel, "kb_quick")
    kbQuickLabel.TextXAlignment = Enum.TextXAlignment.Left
    kbQuickLabel.ZIndex = KB_Z
    kbQuickLabel.Parent = keybindPanel

    local quickKeys = {
        { Enum.KeyCode.F1,"F1" }, { Enum.KeyCode.F2,"F2" }, { Enum.KeyCode.F3,"F3" },
        { Enum.KeyCode.F4,"F4" }, { Enum.KeyCode.F5,"F5" }, { Enum.KeyCode.F6,"F6" },
        { Enum.KeyCode.G,"G" }, { Enum.KeyCode.H,"H" }, { Enum.KeyCode.J,"J" },
        { Enum.KeyCode.K,"K" }, { Enum.KeyCode.L,"L" }, { Enum.KeyCode.N,"N" },
        { Enum.KeyCode.Zero,"0" }, { Enum.KeyCode.Nine,"9" }, { Enum.KeyCode.Eight,"8" },
        { Enum.KeyCode.Seven,"7" }, { Enum.KeyCode.Six,"6" }, { Enum.KeyCode.Five,"5" },
    }
    local KB_BTN_W = 46
    local KB_BTN_H = 30
    local KB_BTN_PAD = 5
    local KB_COLS = 6
    local kbQuickBtns = {}
    local waitingForKey = false

    local function setOrbitKey(keyCode)
        state.orbitToggleKey = keyCode
        local name = tostring(keyCode):gsub("Enum.KeyCode.", "")
        kbCapLabel.Text = name
        kbInfoLabel.Text = t("cv_apply_info")
        kbInfoLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
        kbCapOuter.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        for _, entry in ipairs(kbQuickBtns) do
            entry.btn.BackgroundColor3 = (entry.code == keyCode)
                and Color3.fromRGB(0, 160, 80)
                or Color3.fromRGB(35, 40, 65)
        end
    end

    local function enterListenMode()
        waitingForKey = true
        kbCapLabel.Text = "?"
        kbCapOuter.BackgroundColor3 = Color3.fromRGB(220, 160, 0)
        kbInfoLabel.Text = t("cv_listen")
        kbInfoLabel.TextColor3 = Color3.fromRGB(255, 210, 60)
    end

    for i, entry in ipairs(quickKeys) do
        local col = (i - 1) % KB_COLS
        local row = math.floor((i - 1) / KB_COLS)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, KB_BTN_W, 0, KB_BTN_H)
        btn.Position = UDim2.new(0, 14 + col * (KB_BTN_W + KB_BTN_PAD), 0, 140 + row * (KB_BTN_H + KB_BTN_PAD))
        btn.BackgroundColor3 = Color3.fromRGB(35, 40, 65)
        btn.TextColor3 = Color3.fromRGB(220, 220, 255)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.Text = entry[2]
        btn.BorderSizePixel = 0
        btn.ZIndex = KB_Z
        btn.Parent = keybindPanel
        createRounded(btn, 6)
        table.insert(kbQuickBtns, { btn = btn, code = entry[1] })

        btn.MouseEnter:Connect(function()
            if entry[1] ~= state.orbitToggleKey then
                btn.BackgroundColor3 = Color3.fromRGB(60, 65, 100)
            end
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = (entry[1] == state.orbitToggleKey)
                and Color3.fromRGB(0, 160, 80)
                or Color3.fromRGB(35, 40, 65)
        end)
        btn.MouseButton1Click:Connect(function()
            waitingForKey = false
            setOrbitKey(entry[1])
        end)
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

    setOrbitKey(state.orbitToggleKey)

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
    stopTrollNoClipAndResolve()
end)

startGroundGuard()

local mainGui = createMainUI()
state.mainGui = mainGui
createOpenButton(mainGui)
print("ELIX Mod Menu charge")
