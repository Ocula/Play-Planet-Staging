local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PIDController = {}
PIDController.__index = PIDController

function PIDController.new(kP, kI, kD)
    return setmetatable({
        kP = kP,
        kI = kI,
        kD = kD,
        previousError = 0,
        integral = 0,
        maxintegral = 10, 
    }, PIDController)
end

function PIDController:Update(setpoint, measured_value, dt)
    local error = setpoint - measured_value
    local max_integral = self.maxintegral
    local integral = self.integral + error * dt

    self.integral = integral

    if integral > max_integral then
        integral = max_integral
    elseif integral < -max_integral then
        integral = -max_integral
    end

    local derivative = (error - self.previousError) / dt
    local output = self.kP * error + self.kI * integral + self.kD * derivative

    self.previousError = error

    return output
end

return PIDController