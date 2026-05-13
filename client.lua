local activeIndicator = nil
local indicatorTimeout = 0

-- Vehicle classes to ignore
local ignoredClasses = {
    [8] = true, -- motorcycles
    [13] = true -- bicycles
}

CreateThread(function()
    while true do
        local sleep = 1500
        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)

            if GetPedInVehicleSeat(vehicle, -1) == ped then

                local vehClass = GetVehicleClass(vehicle)

                if not ignoredClasses[vehClass] then
                    sleep = 200

                    ------------------------------------------------
                    -- SMART LIGHTS
                    ------------------------------------------------
                    local hour = GetClockHours()
                    local weather = GetPrevWeatherTypeHashName()

                    local isNight = (hour >= 20 or hour <= 6)
                    local isTunnel = (GetInteriorFromEntity(vehicle) ~= 0)

                    local badWeather =
                        weather == GetHashKey("RAIN") or
                        weather == GetHashKey("THUNDER") or
                        weather == GetHashKey("FOGGY")

                    if isNight or isTunnel or badWeather then
                        SetVehicleLights(vehicle, 2)
                    else
                        SetVehicleLights(vehicle, 1)
                    end

                    ------------------------------------------------
                    -- SMART INDICATORS
                    ------------------------------------------------
                    local speed = GetEntitySpeed(vehicle) * 3.6
                    local steering = GetVehicleSteeringAngle(vehicle)

                    -- Only at realistic city speeds
                    if speed > 8.0 and speed < 55.0 then

                        -- Left turn
                        if steering > 18.0 and activeIndicator ~= "left" then
                            activeIndicator = "left"
                            indicatorTimeout = GetGameTimer() + 3500

                            SetVehicleIndicatorLights(vehicle, 0, true)
                            SetVehicleIndicatorLights(vehicle, 1, false)

                        -- Right turn
                        elseif steering < -18.0 and activeIndicator ~= "right" then
                            activeIndicator = "right"
                            indicatorTimeout = GetGameTimer() + 3500

                            SetVehicleIndicatorLights(vehicle, 0, false)
                            SetVehicleIndicatorLights(vehicle, 1, true)
                        end
                    end

                    -- Auto cancel indicators
                    if activeIndicator and GetGameTimer() > indicatorTimeout then
                        if steering > -6.0 and steering < 6.0 then
                            SetVehicleIndicatorLights(vehicle, 0, false)
                            SetVehicleIndicatorLights(vehicle, 1, false)

                            activeIndicator = nil
                        end
                    end
                end
            end
        else
            activeIndicator = nil
        end

        Wait(sleep)
    end
end)
