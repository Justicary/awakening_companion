local ADDON, ns = ...

local TravelPlanner = {}
ns.TravelPlanner = TravelPlanner
ns.Modules = ns.Modules or {}
ns.Modules.TravelPlanner = TravelPlanner

-- =========================================================================
-- COLA DE PRIORIDAD (MIN-HEAP) - Adaptada de Mapzeroth (Pathfinder.lua)
-- =========================================================================
-- Reduce la complejidad de búsqueda de O(V^2) a O((V+E) log V), eliminando tirones de FPS.
local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

function PriorityQueue:new()
    local obj = {
        heap = {},
        size = 0,
    }
    setmetatable(obj, PriorityQueue)
    return obj
end

function PriorityQueue:push(item, priority)
    self.size = self.size + 1
    self.heap[self.size] = {
        item = item,
        priority = priority,
    }
    self:bubbleUp(self.size)
end

function PriorityQueue:pop()
    if self.size == 0 then return nil end

    local min = self.heap[1]
    self.heap[1] = self.heap[self.size]
    self.heap[self.size] = nil
    self.size = self.size - 1

    if self.size > 0 then
        self:bubbleDown(1)
    end

    return min.item, min.priority
end

function PriorityQueue:bubbleUp(index)
    while index > 1 do
        local parentIndex = math.floor(index / 2)
        if self.heap[index].priority >= self.heap[parentIndex].priority then
            break
        end
        self.heap[index], self.heap[parentIndex] = self.heap[parentIndex], self.heap[index]
        index = parentIndex
    end
end

function PriorityQueue:bubbleDown(index)
    while true do
        local leftChild = index * 2
        local rightChild = index * 2 + 1
        local smallest = index

        if leftChild <= self.size and self.heap[leftChild].priority < self.heap[smallest].priority then
            smallest = leftChild
        end
        if rightChild <= self.size and self.heap[rightChild].priority < self.heap[smallest].priority then
            smallest = rightChild
        end

        if smallest == index then
            break
        end

        self.heap[index], self.heap[smallest] = self.heap[smallest], self.heap[index]
        index = smallest
    end
end

function PriorityQueue:isEmpty()
    return self.size == 0
end

-- =========================================================================
-- CONSTRUCCIÓN Y CACHÉ DEL GRAFO DE TRANSPORTE
-- =========================================================================
local graph -- Lista de adyacencia: graph[nodeId] = { {to=id, mode=.., minutes=.., costCopper=.., faction=..}, ... }
local warnedNodes = {}

local function DeriveEdgeFaction(edge, fromNode, toNode)
    if edge.faction then return edge.faction end
    if fromNode.faction and fromNode.faction ~= "neutral" then return fromNode.faction end
    if toNode.faction and toNode.faction ~= "neutral" then return toNode.faction end
    return "neutral"
end

local function BuildGraph()
    if graph then return graph end
    graph = {}

    local travel = ns.Data and ns.Data.Travel
    if not travel or not travel.nodes then return graph end

    for id in pairs(travel.nodes) do
        graph[id] = graph[id] or {}
    end

    for _, edge in ipairs(travel.edges or {}) do
        local fromNode = travel.nodes[edge.from]
        local toNode = travel.nodes[edge.to]
        if fromNode and toNode then
            local faction = DeriveEdgeFaction(edge, fromNode, toNode)
            local cost = edge.costCopper or 0

            -- Tramo en sentido directo
            table.insert(graph[edge.from], {
                to = edge.to, mode = edge.mode, minutes = edge.minutes or 1.0,
                costCopper = cost, faction = faction,
                waypoints = edge.waypoints, danger = edge.danger, tip = edge.tip,
            })

            -- Tramo en sentido inverso (waypoints invertidos si existen)
            local reverseWaypoints
            if edge.waypoints then
                reverseWaypoints = {}
                for i = #edge.waypoints, 1, -1 do
                    table.insert(reverseWaypoints, edge.waypoints[i])
                end
            end

            table.insert(graph[edge.to], {
                to = edge.from, mode = edge.mode, minutes = edge.minutes or 1.0,
                costCopper = cost, faction = faction,
                waypoints = reverseWaypoints, danger = edge.danger, tip = edge.tip,
            })
        end
    end

    return graph
end

-- =========================================================================
-- NORMALIZACIÓN Y RESOLUCIÓN DE DESTINOS
-- =========================================================================
local function NormalizeText(s)
    return (tostring(s or ""):lower():gsub("^%s+", ""):gsub("%s+$", ""))
end

function TravelPlanner:FindNodeByZoneName(query)
    local travel = ns.Data and ns.Data.Travel
    if not travel or not travel.nodes or not query or query == "" then return nil end

    local norm = NormalizeText(query)
    local exactId, substringId, bestLen

    for id, node in pairs(travel.nodes) do
        local name = NormalizeText(node.name)
        local zone = NormalizeText(node.zoneName)
        if name == norm or zone == norm or id == norm then
            exactId = id
            break
        elseif (name:find(norm, 1, true) or zone:find(norm, 1, true)) then
            if not bestLen or #name < bestLen then
                substringId = id
                bestLen = #name
            end
        end
    end

    return exactId or substringId
end

function TravelPlanner:FindNearestNode(uiMapID, x, y)
    local travel = ns.Data and ns.Data.Travel
    if not travel or not travel.nodes or not uiMapID then return nil end

    local bestId, bestDist
    for id, node in pairs(travel.nodes) do
        if node.uiMapID == uiMapID then
            local dx, dy = (node.x or 0) - (x or 0), (node.y or 0) - (y or 0)
            local dist = dx * dx + dy * dy
            if not bestDist or dist < bestDist then
                bestDist = dist
                bestId = id
            end
        end
    end

    if bestId then
        local bestNode = travel.nodes[bestId]
        local distYards = nil
        if ns.GetDistanceAndHeading and bestNode and bestNode.x and bestNode.y then
            distYards = ns.GetDistanceAndHeading(uiMapID, x, y, bestNode.uiMapID, bestNode.x, bestNode.y)
        end
        if not distYards and bestDist then
            distYards = math.sqrt(bestDist) * (ns.MAP_SCALE or 100)
        end
        return bestId, distYards, bestNode
    end

    -- Fallback para subzonas: consultar el mapa padre
    if C_Map and C_Map.GetMapInfo then
        local ok, mapInfo = pcall(C_Map.GetMapInfo, uiMapID)
        local parentMapID = ok and mapInfo and mapInfo.parentMapID
        if parentMapID and parentMapID > 0 and parentMapID ~= uiMapID then
            return self:FindNearestNode(parentMapID, x, y)
        end
    end

    return nil
end

function TravelPlanner:ResolveEndpoint(query)
    local travel = ns.Data and ns.Data.Travel
    if not travel or not travel.nodes then return nil, "Base de datos de viaje no disponible." end

    local nodeId

    -- 1. Origen dinámico: Posición actual del jugador
    if query == "__player__" then
        local uiMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
        local pos = uiMapID and C_Map.GetPlayerMapPosition(uiMapID, "player")
        if not pos then return nil, "No se pudo determinar tu posición actual en el mapa." end
        local px, py = pos:GetXY()
        local playerX, playerY = (px or 0) * 100, (py or 0) * 100
        nodeId = self:FindNearestNode(uiMapID, playerX, playerY)
        if not nodeId then
            return nil, "No hay ningún nodo de transporte registrado en tu zona actual."
        end

        local node = travel.nodes[nodeId]

        return {
            realNodeId = nodeId,
            displayName = string.format("Mi ubicación (%s)", node.name),
            isPlayerLocation = true,
            playerX = playerX,
            playerY = playerY,
            playerMapID = uiMapID,
            walkHop = nil, -- Dijkstra resolverá la salida óptima desde __player__ dinámicamente
            nearestNode = node,
        }
    end

    -- 2. Destino dinámico: Tabla con coordenadas explícitas (Hito de Secreto / Coordenada personalizada)
    if type(query) == "table" and query.uiMapID and query.x and query.y then
        local wpMapID = query.uiMapID
        local wpX = query.x
        local wpY = query.y
        local wpName = query.name or query.title or "Hito de Secreto"

        nodeId = self:FindNearestNode(wpMapID, wpX, wpY)
        if not nodeId then
            return nil, "No hay ningún nodo de transporte o ruta registrada en la zona del objetivo."
        end

        local node = travel.nodes[nodeId]
        local distYards = nil
        if ns.GetDistanceAndHeading then
            distYards = ns.GetDistanceAndHeading(node.uiMapID, node.x, node.y, wpMapID, wpX, wpY)
        end

        local walkMins = 1.0
        if distYards then
            walkMins = math.max(0.3, math.floor((distYards / 420) * 10) / 10)
        else
            local dx = (node.x or 0) - wpX
            local dy = (node.y or 0) - wpY
            walkMins = math.max(0.3, math.floor(math.sqrt(dx * dx + dy * dy) * 0.06 * 10) / 10)
        end

        local walkHop = {
            fromId = nodeId,
            toId = "__secret_milestone__",
            mode = "walk",
            minutes = walkMins,
            costCopper = 0,
            isFinalPinHop = true,
            fromName = node.name,
            toName = wpName,
            targetNode = {
                name = wpName,
                zoneName = query.zoneName or (C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(wpMapID) and C_Map.GetMapInfo(wpMapID).name) or node.zoneName or "Destino",
                uiMapID = wpMapID,
                x = wpX,
                y = wpY,
                type = "walk",
            }
        }

        return {
            realNodeId = nodeId,
            displayName = string.format("%s (%s)", wpName, node.name),
            isWaypoint = true,
            waypointX = wpX,
            waypointY = wpY,
            waypointMapID = wpMapID,
            walkHopToPin = walkHop,
            nearestNode = node,
        }
    end

    -- 2. Destino dinámico: Marcador del Mapa / Waypoint (Inspirado en WaypointService de Mapzeroth)
    if query == "__waypoint__" or query == "map_pin" then
        local wpMapID, wpX, wpY, wpName

        -- Intento 1: API nativa de Blizzard (Ctrl+Clic en Mapa del Mundo)
        if C_Map and C_Map.GetUserWaypoint then
            local wp = C_Map.GetUserWaypoint()
            if wp and wp.uiMapID and wp.position then
                wpMapID = wp.uiMapID
                local wx, wy = wp.position:GetXY()
                wpX = (wx or 0) * 100
                wpY = (wy or 0) * 100
                wpName = "Marcador del mapa (Pin)"
            end
        end

        -- Intento 2: TomTom waypoints si está instalado
        if not wpMapID and _G.TomTom and _G.TomTom.waypoints then
            for mapID, wpsOnMap in pairs(_G.TomTom.waypoints) do
                for uid, wpData in pairs(wpsOnMap) do
                    if wpData[1] and wpData[2] and wpData[3] then
                        wpMapID = wpData[1]
                        wpX = wpData[2] * 100
                        wpY = wpData[3] * 100
                        wpName = wpData.title or "Punto de TomTom"
                        break
                    end
                end
                if wpMapID then break end
            end
        end

        if not wpMapID or not wpX or not wpY then
            return nil, "No hay ningún marcador colocado en el mapa (usa Ctrl + Clic en el Mapa del Mundo para colocar un pin)."
        end

        nodeId = self:FindNearestNode(wpMapID, wpX, wpY)
        if not nodeId then
            return nil, "No hay ningún nodo de transporte o ruta registrada en la zona de tu marcador."
        end

        local node = travel.nodes[nodeId]
        local distYards = nil
        if ns.GetDistanceAndHeading then
            distYards = ns.GetDistanceAndHeading(node.uiMapID, node.x, node.y, wpMapID, wpX, wpY)
        end

        local walkMins = 1.0
        if distYards then
            walkMins = math.max(0.3, math.floor((distYards / 420) * 10) / 10)
        else
            local dx = (node.x or 0) - wpX
            local dy = (node.y or 0) - wpY
            walkMins = math.max(0.3, math.floor(math.sqrt(dx * dx + dy * dy) * 0.06 * 10) / 10)
        end

        local walkHop = {
            fromId = nodeId,
            toId = "__waypoint__",
            mode = "walk",
            minutes = walkMins,
            costCopper = 0,
            isFinalPinHop = true,
            fromName = node.name,
            toName = wpName or "Marcador del mapa",
            targetNode = {
                name = wpName or "Marcador del mapa",
                zoneName = node.zoneName,
                uiMapID = wpMapID,
                x = wpX,
                y = wpY,
                type = "walk",
            }
        }

        return {
            realNodeId = nodeId,
            displayName = string.format("Marcador (%s)", node.name),
            isWaypoint = true,
            waypointX = wpX,
            waypointY = wpY,
            waypointMapID = wpMapID,
            walkHopToPin = walkHop,
            nearestNode = node,
        }
    end

    -- 3. Destino dinámico: Piedra de Hogar / Taberna vinculada
    if query == "__hearthstone__" then
        local hs = AwakeningDB and AwakeningDB.hearthstone
        local hsMapID = hs and hs.mapID
        local hsX = hs and hs.x
        local hsY = hs and hs.y
        local bindLoc = hs and hs.locationName or (GetBindLocation and GetBindLocation())

        if hsMapID and hsX and hsY then
            nodeId = self:FindNearestNode(hsMapID, hsX, hsY)
        elseif bindLoc and bindLoc ~= "" then
            nodeId = self:FindNodeByZoneName(bindLoc)
        end

        if not nodeId then
            return nil, "No se ha podido localizar tu Piedra de Hogar en la base de datos de viaje."
        end

        local node = travel.nodes[nodeId]
        return {
            realNodeId = nodeId,
            displayName = string.format("Piedra de Hogar (%s)", bindLoc or node.name),
            isHearthstone = true,
            nearestNode = node,
        }
    end

    -- 4. Búsqueda por ID directo o nombre de zona
    if travel.nodes[query] then
        nodeId = query
    else
        nodeId = self:FindNodeByZoneName(query)
    end

    if not nodeId then
        return nil, string.format('No se reconoce la ubicación o zona "%s".', tostring(query))
    end

    local node = travel.nodes[nodeId]
    if node.type == "alias" and node.aliasOf then
        return {
            realNodeId = node.aliasOf,
            displayName = node.name,
            walkHop = { fromId = nodeId, toId = node.aliasOf, mode = "walk", minutes = node.walkMinutes or 2, costCopper = 0 },
        }
    end

    return { realNodeId = nodeId, displayName = node.name }
end

local function PlayerFactionKey()
    local faction = UnitFactionGroup and UnitFactionGroup("player")
    return faction and faction:lower() or "neutral"
end

-- =========================================================================
-- DESCUBRIMIENTO DE MAESTROS DE VUELOS (C_TaxiMap)
-- =========================================================================
local discoveryCache = {}
local warnedDiscoveryAPI = false

local function TaxiNodeIsReachable(state)
    if not Enum or not Enum.FlightPathState then return true end
    return state == Enum.FlightPathState.Reachable or state == Enum.FlightPathState.Current
end

function TravelPlanner:IsFlightNodeDiscovered(nodeId, node)
    if not node or node.type ~= "flightmaster" then return true end
    if not (C_TaxiMap and C_TaxiMap.GetAllTaxiNodes) then return true end

    if AwakeningDB and AwakeningDB.discoveredTaxiNodes and AwakeningDB.discoveredTaxiNodes[nodeId] then
        return true
    end

    if discoveryCache[nodeId] ~= nil then return discoveryCache[nodeId] end

    local ok, taxiNodes = pcall(C_TaxiMap.GetAllTaxiNodes, node.uiMapID)
    -- Si la llamada falla o la tabla está vacía (diálogo de vuelo no abierto actualmente):
    -- asumimos disponible (fail-open) para no bloquear la planificación.
    if not ok or type(taxiNodes) ~= "table" or #taxiNodes == 0 then
        return true
    end

    local targetX, targetY = (node.x or 0) / 100, (node.y or 0) / 100
    local bestDist, bestState

    for _, taxiNode in ipairs(taxiNodes) do
        local pos = taxiNode.position
        if pos then
            local dx, dy = (pos.x or 0) - targetX, (pos.y or 0) - targetY
            local dist = dx * dx + dy * dy
            if not bestDist or dist < bestDist then
                bestDist, bestState = dist, taxiNode.state
            end
        end
    end

    local discovered = bestDist ~= nil and bestDist < 0.003 and TaxiNodeIsReachable(bestState)
    discoveryCache[nodeId] = discovered
    if discovered and AwakeningDB then
        AwakeningDB.discoveredTaxiNodes = AwakeningDB.discoveredTaxiNodes or {}
        AwakeningDB.discoveredTaxiNodes[nodeId] = true
    end
    return discovered
end

-- =========================================================================
-- DIJKSTRA MULTICRITERIO (Rápido, Seguro, Económico)
-- =========================================================================
local function ComputeEdgeWeight(edge, routingMode)
    local baseMinutes = edge.minutes or 1.0
    if routingMode == "safest" then
        local dangerPenalty = edge.danger and 18.0 or 0
        return baseMinutes + dangerPenalty
    elseif routingMode == "economy" then
        local copper = edge.costCopper or 0
        local costPenalty = copper / 35.0 -- 1 plata añade ~3 min de penalización
        return baseMinutes + costPenalty
    else
        -- "fastest": minimiza exclusivamente el tiempo
        return baseMinutes
    end
end

function TravelPlanner:GetDepartureCandidateNodes(playerMapID, playerX, playerY, factionKey)
    local travel = ns.Data and ns.Data.Travel
    if not travel or not travel.nodes or not playerMapID then return {} end

    factionKey = factionKey or PlayerFactionKey()
    local candidates = {}
    local parentMapID

    if C_Map and C_Map.GetMapInfo then
        local ok, mapInfo = pcall(C_Map.GetMapInfo, playerMapID)
        parentMapID = ok and mapInfo and mapInfo.parentMapID
    end

    for id, node in pairs(travel.nodes) do
        local matchesMap = (node.uiMapID == playerMapID)
        if not matchesMap and parentMapID and parentMapID > 0 and node.uiMapID == parentMapID then
            matchesMap = true
        end

        if matchesMap then
            local okFaction = (not node.faction or node.faction == "neutral" or node.faction == factionKey)
            if okFaction then
                local distYards = nil
                if ns.GetDistanceAndHeading then
                    distYards = ns.GetDistanceAndHeading(playerMapID, playerX, playerY, node.uiMapID, node.x, node.y)
                end

                local walkMins = 0.5
                if distYards then
                    walkMins = math.max(0.1, math.floor((distYards / 420) * 10) / 10)
                else
                    local dx = (node.x or 0) - playerX
                    local dy = (node.y or 0) - playerY
                    local distSq = dx * dx + dy * dy
                    walkMins = math.max(0.1, math.floor((math.sqrt(distSq) * 0.06) * 10) / 10)
                end

                local hopDestName = node.name
                local tip = nil
                if node.type == "flightmaster" then
                    hopDestName = string.format("%s (Maestro de Vuelos)", node.name)
                    tip = "Ir al Maestro de Vuelos para tomar ruta aérea"
                elseif node.type == "boat" then
                    tip = "Ir al muelle para tomar barco"
                elseif node.type == "tram" then
                    tip = "Ir a la estación del tranvía subterráneo"
                end

                candidates[id] = {
                    node = node,
                    walkMins = walkMins,
                    distYards = distYards,
                    toName = hopDestName,
                    tip = tip,
                }
            end
        end
    end

    -- 2. Nodos externos adyacentes conectados a pie desde los nodos de la zona actual
    -- (Ej: Desde Ventormenta existe camino a pie a Villadorada; desde Forjaz a Thelsamar; desde Orgrimmar a Cerrotajo)
    local adjacentWalkNodes = {}
    for localId in pairs(candidates) do
        for _, edge in ipairs(travel.edges or {}) do
            if edge.mode == "walk" then
                local targetId = nil
                if edge.from == localId and not candidates[edge.to] then
                    targetId = edge.to
                elseif edge.to == localId and not candidates[edge.from] then
                    targetId = edge.from
                end

                if targetId and travel.nodes[targetId] then
                    local adjNode = travel.nodes[targetId]
                    local okFaction = (not adjNode.faction or adjNode.faction == "neutral" or adjNode.faction == factionKey)
                    if okFaction and not adjacentWalkNodes[targetId] then
                        adjacentWalkNodes[targetId] = {
                            node = adjNode,
                            baseMinutes = edge.minutes or 2.5,
                        }
                    end
                end
            end
        end
    end

    for adjId, adjData in pairs(adjacentWalkNodes) do
        local adjNode = adjData.node
        local distYards = nil
        if ns.GetDistanceAndHeading then
            distYards = ns.GetDistanceAndHeading(playerMapID, playerX, playerY, adjNode.uiMapID, adjNode.x, adjNode.y)
        end

        local walkMins = adjData.baseMinutes
        if distYards then
            walkMins = math.max(0.2, math.floor((distYards / 420) * 10) / 10)
        end

        candidates[adjId] = {
            node = adjNode,
            walkMins = walkMins,
            distYards = distYards,
            toName = adjNode.name,
            tip = "Camino a pie hacia " .. adjNode.name,
        }
    end

    -- Si no hubo candidatos en el mapa actual (ej. zona remota sin nodo de transporte):
    -- Fallback: encontrar el nodo más cercano
    if not next(candidates) then
        local nearestId = self:FindNearestNode(playerMapID, playerX, playerY)
        if nearestId and travel.nodes[nearestId] then
            local node = travel.nodes[nearestId]
            local distYards = ns.GetDistanceAndHeading and ns.GetDistanceAndHeading(playerMapID, playerX, playerY, node.uiMapID, node.x, node.y)
            local walkMins = distYards and math.max(0.2, math.floor((distYards / 420) * 10) / 10) or 1.5
            candidates[nearestId] = {
                node = node,
                walkMins = walkMins,
                distYards = distYards,
                toName = (node.type == "flightmaster") and string.format("%s (Maestro de Vuelos)", node.name) or node.name,
            }
        end
    end

    return candidates
end

function TravelPlanner:Dijkstra(startId, endId, factionKey, requireDiscovery, routingMode, playerLocation)
    local g = BuildGraph()
    local travel = ns.Data and ns.Data.Travel
    if not g then return nil end

    local virtualPlayerAdded = false
    if startId == "__player__" then
        if not playerLocation or not playerLocation.playerMapID then return nil end
        local candidates = self:GetDepartureCandidateNodes(playerLocation.playerMapID, playerLocation.playerX, playerLocation.playerY, factionKey)
        if not next(candidates) then return nil end

        g["__player__"] = {}
        for candId, cData in pairs(candidates) do
            table.insert(g["__player__"], {
                to = candId,
                mode = "walk",
                minutes = cData.walkMins,
                costCopper = 0,
                faction = "neutral",
                tip = cData.tip,
                toName = cData.toName,
                isInitialPlayerHop = true,
                targetNode = cData.node,
            })
        end
        virtualPlayerAdded = true
    end

    if not g[startId] or not g[endId] then
        if virtualPlayerAdded then g["__player__"] = nil end
        return nil
    end

    if startId == endId then
        if virtualPlayerAdded then g["__player__"] = nil end
        return {}
    end

    routingMode = routingMode or "fastest"

    local dist, prevHop, visited = {}, {}, {}
    dist[startId] = 0

    local pq = PriorityQueue:new()
    pq:push(startId, 0)

    while not pq:isEmpty() do
        local currentId, currentDist = pq:pop()

        if not visited[currentId] then
            visited[currentId] = true

            if currentId == endId then break end

            for _, edge in ipairs(g[currentId] or {}) do
                local okFaction = (edge.faction == "neutral" or edge.faction == factionKey)
                local okDiscovery = true
                if okFaction and requireDiscovery and edge.mode == "flight" then
                    okDiscovery = self:IsFlightNodeDiscovered(currentId, travel.nodes[currentId])
                        and self:IsFlightNodeDiscovered(edge.to, travel.nodes[edge.to])
                end

                if okFaction and okDiscovery and not visited[edge.to] then
                    local weight = ComputeEdgeWeight(edge, routingMode)

                    -- Anti-desvío universal: Si el nodo origen ya fue alcanzado a pie desde __player__,
                    -- y esta arista TAMBIÉN es a pie (ej. Maestro de Vuelos -> Villadorada o Maestro -> Puerto):
                    -- penalizar fuertemente caminar a un nodo de transporte para luego seguir a pie,
                    -- obligando a preferir la caminata directa desde la posición del jugador.
                    if currentId ~= "__player__" and edge.mode == "walk" and prevHop[currentId] and prevHop[currentId].fromId == "__player__" then
                        local nodeCurrent = travel.nodes[currentId]
                        local nodeTo = travel.nodes[edge.to]
                        if nodeCurrent then
                            if nodeCurrent.type == "flightmaster" or nodeCurrent.type == "boat" or nodeCurrent.type == "tram" or nodeCurrent.type == "zeppelin" then
                                weight = weight + 25.0
                            elseif nodeTo and nodeCurrent.uiMapID == nodeTo.uiMapID then
                                weight = weight + 15.0
                            end
                        end
                    end

                    local newDist = currentDist + weight
                    if not dist[edge.to] or newDist < dist[edge.to] then
                        dist[edge.to] = newDist
                        prevHop[edge.to] = {
                            fromId = currentId, toId = edge.to, mode = edge.mode,
                            minutes = edge.minutes, costCopper = edge.costCopper or 0,
                            waypoints = edge.waypoints, danger = edge.danger, tip = edge.tip,
                            toName = edge.toName, isInitialPlayerHop = edge.isInitialPlayerHop,
                            targetNode = edge.targetNode,
                        }
                        pq:push(edge.to, newDist)
                    end
                end
            end
        end
    end

    if virtualPlayerAdded then
        g["__player__"] = nil
    end

    if not dist[endId] then return nil end

    local hops = {}
    local cursor = endId
    while cursor ~= startId do
        local hop = prevHop[cursor]
        if not hop then return nil end
        table.insert(hops, 1, hop)
        cursor = hop.fromId
    end

    return hops, dist[endId]
end

-- =========================================================================
-- FORMATEO Y ICONOGRAFÍA ESTILO CASINO
-- =========================================================================
local MODE_LABELS = {
    flight    = "Vuelo hacia %s",
    boat      = "Barco hacia %s",
    zeppelin  = "Zepelín hacia %s",
    tram      = "Tranvía Subterráneo a %s",
    walk      = "A pie hacia %s",
    swim      = "Nado hacia %s",
    hearthstone = "Piedra de Hogar hacia %s",
    portal    = "Portal mágico hacia %s",
}

function TravelPlanner:GetModeIcon(mode, faction)
    local icons = ns.Data and ns.Data.Travel and ns.Data.Travel.MODE_ICONS
    if not icons then return "Interface\\Icons\\inv_misc_map_01" end

    if mode == "flight" then
        faction = faction or PlayerFactionKey()
        if faction == "horde" then
            return icons.flight_horde or icons.flight_neutral
        else
            return icons.flight_alliance or icons.flight_neutral
        end
    elseif mode == "boat" then
        return icons.boat
    elseif mode == "zeppelin" then
        return icons.zeppelin
    elseif mode == "tram" then
        return icons.tram
    elseif mode == "walk" then
        return icons.walk
    elseif mode == "swim" then
        return icons.swim
    elseif mode == "hearthstone" then
        return icons.hearthstone
    elseif mode == "portal" then
        return icons.portal or "Interface\\Icons\\spell_arcane_teleportstormwind"
    end

    return "Interface\\Icons\\inv_misc_map_01"
end

function TravelPlanner:FormatMoney(copper)
    copper = copper or 0
    if copper <= 0 then return "|cFF888888Gratis|r" end

    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local cop = copper % 100

    local str = ""
    if gold > 0 then
        str = str .. string.format("|cFFFFD100%dg|r ", gold)
    end
    if silver > 0 or gold > 0 then
        str = str .. string.format("|cFFE6E6E6%ds|r ", silver)
    end
    if cop > 0 or (gold == 0 and silver == 0) then
        str = str .. string.format("|cFFC87533%dc|r", cop)
    end
    return str:gsub("%s+$", "")
end

function TravelPlanner:GetPopularDestinations()
    local hubs = ns.Data and ns.Data.Travel and ns.Data.Travel.POPULAR_HUBS
    if not hubs then return {} end
    local faction = PlayerFactionKey()
    return (faction == "horde") and hubs.horde or hubs.alliance
end

-- =========================================================================
-- CONSTRUCCIÓN DE LA GUÍA PARA GuideHUD
-- =========================================================================
local function AppendStep(steps, node, nodeId, mode, danger, costCopper, tip)
    local travel = ns.Data and ns.Data.Travel
    local title = node.name
    local instruction = string.format(MODE_LABELS[mode] or "Dirígete a %s", node.name)

    if node.npcName and mode == "flight" then
        instruction = string.format("%s\n|cFF88AAFFMaestro de Vuelos: %s|r", instruction, node.npcName)
    elseif node.npcName and mode == "walk" and node.type == "flightmaster" then
        title = string.format("%s (Maestro de Vuelos)", node.name)
        instruction = string.format("Dirígete al Maestro de Vuelos en %s\n|cFF88AAFFHabla con: %s|r", node.name, node.npcName)
    elseif mode == "walk" and node.type == "boat" then
        instruction = string.format("Camina hacia el embarcadero en %s\n|cFF88AAFFAborda el barco en el muelle|r", node.name)
    elseif mode == "walk" and node.type == "tram" then
        instruction = string.format("Dirígete a la estación de tranvía en %s\n|cFF88AAFFSube al vagón del tranvía subterráneo|r", node.name)
    end
    if costCopper and costCopper > 0 then
        instruction = string.format("%s · Coste: %s", instruction, TravelPlanner:FormatMoney(costCopper))
    end
    if danger then
        instruction = string.format("%s\n|cFFFF5533Peligro: %s|r", instruction, danger)
    end
    if tip then
        instruction = string.format("%s\n|cFF00FFCCConsejo: %s|r", instruction, tip)
    end

    local icon = (mode == "walk" and node.type == "flightmaster") and "Interface\\Icons\\ability_rogue_sprint" or TravelPlanner:GetModeIcon(mode, node.faction)

    table.insert(steps, {
        title = title,
        instruction = instruction,
        uiMapID = node.uiMapID,
        zoneName = node.zoneName,
        x = node.x,
        y = node.y,
        icon = icon,
    })
end

local function AppendWaypointStep(steps, waypoint, mode, destName)
    local instruction = string.format(MODE_LABELS[mode] or "Avanza hacia %s", destName)
    if waypoint.danger then
        instruction = string.format("%s\n|cFFFF5533Peligro: %s|r", instruction, waypoint.danger)
    end

    local icon = TravelPlanner:GetModeIcon(mode)

    table.insert(steps, {
        title = string.format("Ruta hacia %s", destName),
        instruction = instruction,
        uiMapID = waypoint.uiMapID,
        x = waypoint.x,
        y = waypoint.y,
        icon = icon,
    })
end

function TravelPlanner:BuildGuideFromPath(fromEndpoint, toEndpoint, hops)
    local travel = ns.Data and ns.Data.Travel
    local steps = {}
    local legs = {}

    local allHops = {}
    if fromEndpoint.walkHop and (not hops or not hops[1] or hops[1].fromId ~= "__player__") then
        table.insert(allHops, fromEndpoint.walkHop)
    end
    for _, h in ipairs(hops or {}) do
        table.insert(allHops, h)
    end
    if toEndpoint.walkHop then
        table.insert(allHops, {
            fromId = toEndpoint.walkHop.toId,
            toId = toEndpoint.walkHop.fromId,
            mode = "walk",
            minutes = toEndpoint.walkHop.minutes,
            costCopper = 0,
        })
    end
    if toEndpoint.walkHopToPin then
        table.insert(allHops, toEndpoint.walkHopToPin)
    end

    -- Colapso universal de desvíos innecesarios a pie desde la ubicación del jugador:
    -- Si el primer salto es a pie desde __player__ hacia un nodo intermedio A,
    -- y el segundo salto también es a pie desde A hacia B:
    -- Si A es un nodo de transporte (flightmaster, boat, tram, zeppelin) o está en la misma zona:
    -- ¡El jugador NUNCA debe visitar un maestro de vuelo o muelle si no aborda ningún transporte!
    -- Colapsar ambos tramos en una caminata directa desde __player__ hacia B.
    if #allHops >= 2 and allHops[1].fromId == "__player__" and allHops[1].mode == "walk" and allHops[2].mode == "walk" then
        local nodeA = travel.nodes[allHops[1].toId]
        local nodeB = travel.nodes[allHops[2].toId] or allHops[2].targetNode
        local shouldCollapse = false
        if nodeA then
            if nodeA.type == "flightmaster" or nodeA.type == "boat" or nodeA.type == "tram" or nodeA.type == "zeppelin" then
                shouldCollapse = true
            elseif nodeB and nodeA.uiMapID == nodeB.uiMapID then
                shouldCollapse = true
            elseif fromEndpoint.playerMapID and nodeA.uiMapID == fromEndpoint.playerMapID then
                shouldCollapse = true
            end
        end

        if shouldCollapse and nodeB then
            allHops[2].fromId = "__player__"
            allHops[2].fromName = "Mi ubicación"
            allHops[2].isInitialPlayerHop = true
            if fromEndpoint.playerMapID and fromEndpoint.playerX and fromEndpoint.playerY then
                local distYards = ns.GetDistanceAndHeading and ns.GetDistanceAndHeading(fromEndpoint.playerMapID, fromEndpoint.playerX, fromEndpoint.playerY, nodeB.uiMapID, nodeB.x, nodeB.y)
                if distYards then
                    allHops[2].minutes = math.max(0.1, math.floor((distYards / 420) * 10) / 10)
                end
            end
            table.remove(allHops, 1)
        end
    end

    -- Caso especial: Cuando origen y destino están en la misma zona o no hubo saltos de transporte intermedios,
    -- allHops solo contiene el walkHopToPin (desde el nodo más cercano hacia el destino).
    -- Ajustar para que el inicio de la caminata sea la posición del jugador (__player__) en vez del nodo de transporte.
    if #allHops == 1 and allHops[1].isFinalPinHop and fromEndpoint.isPlayerLocation and fromEndpoint.playerMapID then
        local target = allHops[1].targetNode
        if target and (target.uiMapID == fromEndpoint.playerMapID or target.continent == fromEndpoint.continent) then
            allHops[1].fromId = "__player__"
            allHops[1].fromName = "Mi ubicación"
            allHops[1].isInitialPlayerHop = true
            local distYards = ns.GetDistanceAndHeading and ns.GetDistanceAndHeading(fromEndpoint.playerMapID, fromEndpoint.playerX, fromEndpoint.playerY, target.uiMapID, target.x, target.y)
            if distYards then
                allHops[1].minutes = math.max(0.1, math.floor((distYards / 420) * 10) / 10)
            end
        end
    end

    local totalMinutes = 0
    local totalCostCopper = 0
    local hasDanger = false

    if #allHops == 0 then
        local onlyNode = travel.nodes[fromEndpoint.realNodeId]
        AppendStep(steps, onlyNode, fromEndpoint.realNodeId, "walk", nil, 0)
    else
        for i, hop in ipairs(allHops) do
            local fromNode = (hop.fromId ~= "__player__") and travel.nodes[hop.fromId] or nil
            local toNode = hop.targetNode or travel.nodes[hop.toId]

            if hop.waypoints then
                for _, wp in ipairs(hop.waypoints) do
                    AppendWaypointStep(steps, wp, hop.mode, toNode and toNode.name or "Destino")
                end
            end

            AppendStep(steps, toNode, hop.toId, hop.mode, hop.danger, hop.costCopper, hop.tip)

            totalMinutes = totalMinutes + (hop.minutes or 0)
            totalCostCopper = totalCostCopper + (hop.costCopper or 0)
            if hop.danger then hasDanger = true end

            local fromName = hop.fromName or (fromNode and fromNode.name) or "Inicio"
            local toName = hop.toName or (toNode and toNode.name) or "Destino"
            if hop.isInitialPlayerHop and toNode and toNode.type == "flightmaster" then
                toName = string.format("%s (Maestro de Vuelos)", toNode.name)
            end

            table.insert(legs, {
                index = i,
                fromId = hop.fromId,
                toId = hop.toId,
                fromName = fromName,
                toName = toName,
                mode = hop.mode,
                minutes = hop.minutes or 1.0,
                costCopper = hop.costCopper or 0,
                danger = hop.danger,
                tip = hop.tip,
                icon = (hop.isInitialPlayerHop and "Interface\\Icons\\ability_rogue_sprint") or self:GetModeIcon(hop.mode, toNode and toNode.faction),
                isInitialPlayerHop = hop.isInitialPlayerHop,
                isFinalPinHop = hop.isFinalPinHop,
                toNode = toNode,
            })
        end
    end

    local rewardText = string.format("~%.1f min", totalMinutes)
    if totalCostCopper > 0 then
        rewardText = string.format("%s · %s", rewardText, self:FormatMoney(totalCostCopper))
    end

    local guideData = {
        title = string.format("Viaje: %s -> %s", fromEndpoint.displayName, toEndpoint.displayName),
        category = "Planeador de Viaje",
        icon = "Interface\\Icons\\inv_misc_map_01",
        reward = rewardText,
        steps = steps,
    }

    return guideData, totalMinutes, totalCostCopper, legs, hasDanger
end

-- =========================================================================
-- EVALUACIÓN INTELIGENTE DE PIEDRA DE HOGAR (Hearthstone Intelligence)
-- =========================================================================
function TravelPlanner:EvaluateHearthstoneOption(fromEndpoint, toEndpoint, totalRouteMinutes)
    if not (GetHearthstoneLocation and GetItemCooldown) then return nil end

    local hs = AwakeningDB and AwakeningDB.hearthstone
    local bindLoc = (hs and hs.locationName) or GetHearthstoneLocation()
    if not bindLoc or bindLoc == "" then return nil end

    local start, duration = GetItemCooldown(6948)
    local cdRemaining = 0
    if start and duration and duration > 0 then
        cdRemaining = (start + duration) - GetTime()
    end

    local bindNodeId = (hs and hs.mapID and self:FindNearestNode(hs.mapID, hs.x, hs.y)) or self:FindNodeByZoneName(bindLoc)
    if not bindNodeId then return nil end

    local factionKey = PlayerFactionKey()
    local hsHops, hsDist = self:Dijkstra(bindNodeId, toEndpoint.realNodeId, factionKey, false, "fastest")
    local hsMinutes = hsDist or 999
    local timeSaved = (totalRouteMinutes or 999) - hsMinutes
    local isBeneficial = (cdRemaining <= 0) and (timeSaved >= 2.0) and (fromEndpoint and bindNodeId ~= fromEndpoint.realNodeId)

    return {
        available = (cdRemaining <= 0),
        cdMinutes = math.max(0, math.floor((cdRemaining / 60) * 10) / 10),
        bindLocation = bindLoc,
        bindNodeId = bindNodeId,
        hsMinutes = hsMinutes,
        timeSaved = timeSaved,
        isBeneficial = isBeneficial,
    }
end

-- =========================================================================
-- CÁLCULO ESTRUCTURADO DE RUTA (Planificador Completo)
-- =========================================================================
function TravelPlanner:CalculateRoute(fromQuery, toQuery, options)
    options = options or {}
    local routingMode = options.routingMode or "fastest"

    local fromEndpoint, errFrom = self:ResolveEndpoint(fromQuery)
    if not fromEndpoint then
        return { success = false, error = errFrom or "No se pudo resolver el origen." }
    end

    local toEndpoint, errTo = self:ResolveEndpoint(toQuery)
    if not toEndpoint then
        return { success = false, error = errTo or "No se pudo resolver el destino." }
    end

    local startNodeId = fromEndpoint.isPlayerLocation and "__player__" or fromEndpoint.realNodeId
    local targetNodeId = toEndpoint.realNodeId

    if startNodeId == targetNodeId and not toEndpoint.walkHop and not toEndpoint.walkHopToPin then
        return { success = false, error = "El origen y el destino son el mismo punto." }
    end

    local factionKey = PlayerFactionKey()
    local requireDiscovery = (options.requireDiscovery == true)

    -- Ejecución de Dijkstra
    local hops = self:Dijkstra(startNodeId, targetNodeId, factionKey, requireDiscovery, routingMode, fromEndpoint)
    local missingDiscoveries = {}

    if not hops and requireDiscovery then
        -- Si no hubo ruta restringida a nodos descubiertos, intentar con la red completa
        hops = self:Dijkstra(startNodeId, targetNodeId, factionKey, false, routingMode, fromEndpoint)
    end

    if not hops then
        return {
            success = false,
            error = "No existe una ruta conocida entre estos destinos para tu facción.",
        }
    end

    -- Revisar si algún salto de vuelo requiere ser descubierto en el mundo
    local travel = ns.Data and ns.Data.Travel
    for _, h in ipairs(hops) do
        if h.mode == "flight" and travel and travel.nodes then
            local node = travel.nodes[h.toId]
            if node and not self:IsFlightNodeDiscovered(h.toId, node) then
                table.insert(missingDiscoveries, node.name)
            end
        end
    end

    local guideData, totalMinutes, totalCostCopper, legs, hasDanger = self:BuildGuideFromPath(fromEndpoint, toEndpoint, hops)

    local dangerRating = "Bajo"
    if hasDanger then dangerRating = "Moderado" end

    -- Evaluación de Piedra de Hogar inteligente
    local hearthstoneInfo
    if options.checkHearthstone ~= false and fromEndpoint.isPlayerLocation then
        hearthstoneInfo = self:EvaluateHearthstoneOption(fromEndpoint, toEndpoint, totalMinutes)
    end

    local routeKey = string.format("travel_%s_%s", fromEndpoint.realNodeId, toEndpoint.realNodeId)

    return {
        success = true,
        fromEndpoint = fromEndpoint,
        toEndpoint = toEndpoint,
        hops = hops,
        legs = legs,
        guideData = guideData,
        routeKey = routeKey,
        totalMinutes = totalMinutes,
        totalCostCopper = totalCostCopper,
        dangerRating = dangerRating,
        routingMode = routingMode,
        missingDiscoveries = missingDiscoveries,
        hearthstone = hearthstoneInfo,
    }
end

-- =========================================================================
-- LANZAMIENTO DE LA RUTA EN GUIDE HUD
-- =========================================================================
function TravelPlanner:StartPlannedRoute(plan)
    if not plan or not plan.guideData or not plan.routeKey then return false end

    if ns.GuideHUD then
        ns.GuideHUD:StartRoute(plan.guideData, plan.routeKey, 1)
    end

    -- Efecto sonoro de vuelo nativo
    if PlaySound then
        pcall(PlaySound, 644)
    end

    local costStr = (plan.totalCostCopper > 0) and (" · " .. self:FormatMoney(plan.totalCostCopper)) or ""
    ns.Print(string.format("Ruta iniciada: %s (|cFF00FF00~%.1f min|r%s). Sigue la Crazy Arrow 3D de TomTom.",
        ns.Gold(plan.guideData.title), plan.totalMinutes or 0, costStr))

    return true
end

function TravelPlanner:PlanAndStart(fromQuery, toQuery, options)
    local plan = self:CalculateRoute(fromQuery, toQuery, options)
    if not plan.success then
        ns.Print(ns.Red(plan.error or "No se pudo calcular la ruta."))
        if plan.missingDiscoveries and #plan.missingDiscoveries > 0 then
            ns.Print(ns.Grey("Vuelos pendientes por descubrir: " .. table.concat(plan.missingDiscoveries, ", ")))
        end
        return false
    end

    return self:StartPlannedRoute(plan)
end
