-- MovementSystem.lua
-- Simple movement system script for Roblox Studio
-- Place this LocalScript inside StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Configuration
local WALK_SPEED = 16
local SPRINT_SPEED = 24
local CROUCH_SPEED = 8
local JUMP_POWER = 50

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = WALK_SPEED
    humanoid.JumpPower = JUMP_POWER

    local sprinting = false
    local crouching = false

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or humanoid.Health <= 0 then return end

        if input.KeyCode == Enum.KeyCode.LeftShift then
            sprinting = true
            humanoid.WalkSpeed = SPRINT_SPEED
        elseif input.KeyCode == Enum.KeyCode.C then
            crouching = true
            humanoid.WalkSpeed = CROUCH_SPEED
            humanoid.JumpPower = 0
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if humanoid.Health <= 0 then return end

        if input.KeyCode == Enum.KeyCode.LeftShift then
            sprinting = false
            if crouching then
                humanoid.WalkSpeed = CROUCH_SPEED
            else
                humanoid.WalkSpeed = WALK_SPEED
            end
        elseif input.KeyCode == Enum.KeyCode.C then
            crouching = false
            if sprinting then
                humanoid.WalkSpeed = SPRINT_SPEED
            else
                humanoid.WalkSpeed = WALK_SPEED
            end
            humanoid.JumpPower = JUMP_POWER
        end
    end)
end

if player.Character then
    setupCharacter(player.Character)
end
player.CharacterAdded:Connect(setupCharacter)

return nil
