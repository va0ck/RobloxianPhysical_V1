local RunService = game:GetService("RunService")

local ResourceConstants = require(script.Parent.Parent.ResourceConstants)
if RunService:IsServer() then
    return function (folderName: string, eventName: string)
        assert(type(folderName) == "string", "Bad folderName")
		assert(type(eventName) == "string", "Bad eventName")

		--Makes sure shared folder exists.
        local storage = script.Parent.Parent.Parent:FindFirstChild(ResourceConstants.SHARED_FOLDER_NAME)
		if not storage then
			storage = Instance.new("Folder")
			storage.Name = ResourceConstants.SHARED_FOLDER_NAME
			storage.Archivable = false
			storage.Parent = script.Parent.Parent.Parent
		end

		--Makes sure folderName exists.
        local folder = storage:FindFirstChild(folderName)
        if not folder then
            folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Archivable = false
			folder.Parent = storage
        end

		--Setups up a new folder to hold multiple unreliable events.
		local folder2 = folder:FindFirstChild(ResourceConstants.UNRELIABLE_REMOTE_EVENTS_FOLDER_NAME)
		if not folder2 then
			folder2 = Instance.new("Folder")
			folder2.Name = ResourceConstants.UNRELIABLE_REMOTE_EVENTS_FOLDER_NAME
			folder2.Archivable = false
			folder2.Parent = folder
		end

		--Returns event if it exists.
        local event = folder:FindFirstChild(eventName)
		if event then
			return event
		end

        event = Instance.new("UnreliableRemoteEvent")
		event.Name = eventName
		event.Archivable = false
		event.Parent = folder2

		return event
    end
elseif  RunService:IsClient() then
    return function (folderName: string, eventName: string)
		assert(type(folderName) == "string", "Bad folderName")
		assert(type(eventName) == "string", "Bad eventName")

        return script.Parent.Parent.Parent
			:FindFirstChild(ResourceConstants.SHARED_FOLDER_NAME)
			:WaitForChild(folderName, ResourceConstants.MAX_FOLDERWAIT)
			:WaitForChild(ResourceConstants.UNRELIABLE_REMOTE_EVENTS_FOLDER_NAME, ResourceConstants.MAX_INSTANCEFOLDERWAIT)
			:WaitForChild(eventName, ResourceConstants.MAX_INSTANCEWAIT)
    end
else
    error("[GetUnreliableRemoteEvent] - Unknown RunService state")
end