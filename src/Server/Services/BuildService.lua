-- Build Service
-- @ocula
-- January 6, 2022

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local BuildService = Knit.CreateService({
    Name = "BuildService", 
    Client = {}
})

BuildService.SpawnTween = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false, 0); 

function BuildService.Client:Build(player, id, cf)
    local ItemIndexService = Knit.GetService("ItemIndexService") 

    local _item = ItemIndexService:GetItem(id)
    local _obj  = _item.Object:Clone()

    _obj.Parent = workspace.game.bin.server
    _obj:SetPrimaryPartCFrame(cf) 

    -- Set all tags 
    for index, descendant in pairs(_obj:GetDescendants()) do
        if (descendant:IsA("BasePart") or descendant:IsA("UnionOperation")) then 
            game:GetService("CollectionService"):AddTag(descendant, "PlacedObject") 
        end 
    end 

    -- Tween Object in
    --[[for i = 0,1,.1 do
        wait(.001) 
        self.Server.Shared.Utility:ScaleModel(_obj, i) 
    end 

    self.Server.Shared.Utility:ScaleModel(_obj, 1)--]]

end

function BuildService.Client:_useSpringPad(player, pad)
    -- Lets CF check the player to be certain they used this SpringPad 
    if (pad) then 
        local _padUses = pad:GetAttribute("Uses") 

        if (_padUses) then 
            local _amount  = _padUses - 1

            if (_amount <= 0) then
                for i,v in pairs(pad:GetDescendants()) do 
                    if (v:IsA("BasePart")) then 
                        v.Anchored = false 
                        v.Velocity = Vector3.new(math.random(-50,50),math.random(50,80),math.random(-50,50))
                    elseif (v:IsA("UnionOperation")) then 
                        v:Destroy() -- Save us physics lag. 
                    end 
                end 

                task.delay(2, function()
                    pad:Destroy() 
                end)
            else
                pad:SetAttribute("Uses", _amount) 
            end 
        end
    end 
end

function BuildService:Start()
	
end

function BuildService:Init()
	
end


return BuildService