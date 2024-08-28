local tau = math.pi * 2
local exp = math.exp
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

local Spring = {}
Spring.__index = Spring

local EPSILON = 1e-4

function Spring.new(position:{}, velocity:{}, goal:{})
    local self = setmetatable({
        position = position, 
        velocity = velocity, 
        goal = goal,

        speed = 1,
        dampener = 0.7
    }, Spring)

    return self
end

local function springCoefficients(timeStep: number, damping: number, speed: number): (number, number, number, number)
	-- if time step or speed is 0, then the spring won't move, so an identity
	-- matrix can be returned early
	if timeStep == 0 or speed == 0 then
		return
			1, 0,
			0, 1
	end

	if damping > 1 then
		-- overdamped spring

		-- solutions to the characteristic equation
		-- z = -ζω ± Sqrt[ζ^2 - 1] ω

		local zRoot = math.sqrt(damping^2 - 1)

		local z1 = (-zRoot - damping)*speed
		local z2 = (zRoot - damping)*speed

		-- x[t] -> x0(e^(t z2) z1 - e^(t z1) z2)/(z1 - z2)
		--		 + v0(e^(t z1) - e^(t z2))/(z1 - z2)

		local zDivide = 1/(z1 - z2)

		local z1Exp = math.exp(timeStep * z1)
		local z2Exp = math.exp(timeStep * z2)

		local posPosCoef = (z2Exp * z1 - z1Exp * z2) * zDivide
		local posVelCoef = (z1Exp - z2Exp) * zDivide

		-- v[t] -> x0(z1 z2(-e^(t z1) + e^(t z2)))/(z1 - z2)
		--		 + v0(z1 e^(t z1) - z2 e^(t z2))/(z1 - z2)

		local velPosCoef = z1*z2 * (-z1Exp + z2Exp) * zDivide
		local velVelCoef = (z1*z1Exp - z2*z2Exp) * zDivide

		return
			posPosCoef, posVelCoef,
			velPosCoef, velVelCoef

	elseif damping == 1 then
		-- critically damped spring

		-- x[t] -> x0(e^-tω)(1+tω) + v0(e^-tω)t

		local timeStepSpeed = timeStep * speed
		local negSpeedExp = math.exp(-timeStepSpeed)

		local posPosCoef = negSpeedExp * (1 + timeStepSpeed)
		local posVelCoef = negSpeedExp * timeStep

		-- v[t] -> x0(t ω^2)(-e^-tω) + v0(1 - tω)(e^-tω)

		local velPosCoef = -negSpeedExp * (timeStep * speed*speed)
		local velVelCoef = negSpeedExp * (1 - timeStepSpeed)

		return
			posPosCoef, posVelCoef,
			velPosCoef, velVelCoef

	else
		-- underdamped spring

		-- factored out of the solutions to the characteristic equation, to make
		-- the math cleaner

		local alpha = math.sqrt(1 - damping^2) * speed

		-- x[t] -> x0(e^-tζω)(α Cos[tα] + ζω Sin[tα])/α
		--       + v0(e^-tζω)(Sin[tα])/α

		local negDampSpeedExp = math.exp(-timeStep * damping * speed)

		local sinAlpha = math.sin(timeStep*alpha)
		local alphaCosAlpha = alpha * math.cos(timeStep*alpha)
		local dampSpeedSinAlpha = damping*speed*sinAlpha

		local invAlpha = 1 / alpha

		local posPosCoef = negDampSpeedExp * (alphaCosAlpha + dampSpeedSinAlpha) * invAlpha
		local posVelCoef = negDampSpeedExp * sinAlpha * invAlpha

		-- v[t] -> x0(-e^-tζω)(α^2 + ζ^2 ω^2)(Sin[tα])/α
		--       + v0(e^-tζω)(α Cos[tα] - ζω Sin[tα])/α

		local velPosCoef = -negDampSpeedExp * (alpha*alpha + damping*damping * speed*speed) * sinAlpha * invAlpha
		local velVelCoef = negDampSpeedExp * (alphaCosAlpha - dampSpeedSinAlpha) * invAlpha

		return
			posPosCoef, posVelCoef,
			velPosCoef, velVelCoef
	end
end

function Spring:adjust(key: string, dt: number)
    local goal = self.goal[key]
    local p0 = self.position[key]
    local v0 = self.velocity[key]

    local posPosCoef, posVelCoef, velPosCoef, velVelCoef = springCoefficients(dt, self.speed, self.dampener)
    local oldDisplacement = p0 - goal

    local newDisplacement = oldDisplacement * posPosCoef + v0 * posVelCoef
    local newVelocity = oldDisplacement * velPosCoef + v0 * velVelCoef

    self.position[key] = newDisplacement + goal 
    self.velocity[key] = newVelocity 
end

function Spring:update(dt:number)
    local t = {}

    for key, _ in self.goal do 
        self:adjust(key, dt)

        t[key] = self.position[key]
    end

    return CFrame.fromMatrix(t.Position, t.RightVector, t.UpVector):Orthonormalize()
end

return Spring 