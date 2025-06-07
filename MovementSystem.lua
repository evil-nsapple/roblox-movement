-- MovementSystem.lua
-- Simple movement system script for Roblox Studio
-- Place this LocalScript inside StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Configuration
local WALK_SPEED = 16
local SPRINT_SPEED = 24
local CROUCH_SPEED = 8
local JUMP_POWER = 50
-- Momentum settings
local MOMENTUM_MAX = 16 -- extra speed over base
local MOMENTUM_GAIN = 40
local MOMENTUM_DECAY = 20

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = WALK_SPEED
    humanoid.JumpPower = JUMP_POWER

    local sprinting = false
    local crouching = false
    local momentum = 0
    local jumpsLeft = 2
    local sliding = false

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or humanoid.Health <= 0 then return end

        if input.KeyCode == Enum.KeyCode.LeftShift then
            sprinting = true
        elseif input.KeyCode == Enum.KeyCode.C then
            crouching = true
            if momentum > 0 then
                sliding = true
            end
            humanoid.JumpPower = 0
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if humanoid.Health <= 0 then return end

        if input.KeyCode == Enum.KeyCode.LeftShift then
            sprinting = false
        elseif input.KeyCode == Enum.KeyCode.C then
            crouching = false
            sliding = false
            humanoid.JumpPower = JUMP_POWER
        end
    end)

    humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Landed then
            jumpsLeft = 2
            sliding = false
        end
    end)

    UserInputService.JumpRequest:Connect(function()
        if jumpsLeft > 0 then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            jumpsLeft -= 1
        end
    end)

    RunService.Heartbeat:Connect(function(dt)
        local base = WALK_SPEED
        if sprinting then
            base = SPRINT_SPEED
        elseif crouching and not sliding then
            base = CROUCH_SPEED
        end

        if humanoid.MoveDirection.Magnitude > 0 then
            momentum = math.min(MOMENTUM_MAX, momentum + MOMENTUM_GAIN * dt)
        else
            local decay = MOMENTUM_DECAY
            if sliding then
                decay = MOMENTUM_DECAY * 0.5
            end
            momentum = math.max(0, momentum - decay * dt)
        end

        humanoid.WalkSpeed = base + momentum

        if momentum <= 0 then
            sliding = false
        end
    end)
end

if player.Character then
    setupCharacter(player.Character)
end
player.CharacterAdded:Connect(setupCharacter)

return nil
