local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Roact = require(Knit.Library.Roact)

local ChoiceComponent = Roact.Component:extend("Choice")

return Roact.createElement("SurfaceGui", {
	ClipsDescendants = true,
	SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, {
	frame = Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.93, 0.93),
	}, {
		frame1 = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(95, 90, 80),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.311, 0.311),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
		}, {
			imageLabel = Roact.createElement("ImageLabel", {
				Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
				ImageTransparency = 0.9,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}),

			textLabel = Roact.createElement("TextLabel", {
				FontFace = Font.new("rbxasset://fonts/families/AccanthisADFStd.json"),
				Text = "MapName",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 36,
				TextWrapped = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}),
		}),

		uIListLayout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0.0333, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		frame2 = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(95, 90, 80),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.311, 0.311),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
		}, {
			imageLabel1 = Roact.createElement("ImageLabel", {
				Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
				ImageTransparency = 0.9,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}),

			textLabel1 = Roact.createElement("TextLabel", {
				FontFace = Font.new("rbxasset://fonts/families/AccanthisADFStd.json"),
				Text = "MapName",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 36,
				TextWrapped = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}),
		}),

		frame3 = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(95, 90, 80),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.311, 0.311),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
		}, {
			imageLabel2 = Roact.createElement("ImageLabel", {
				Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
				ImageTransparency = 0.9,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}),

			textLabel2 = Roact.createElement("TextLabel", {
				FontFace = Font.new("rbxasset://fonts/families/AccanthisADFStd.json"),
				Text = "MapName",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 36,
				TextWrapped = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}),
		}),
	}),
})
