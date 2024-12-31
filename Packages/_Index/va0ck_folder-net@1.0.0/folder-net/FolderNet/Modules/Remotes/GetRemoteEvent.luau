local RunService = game:GetService("RunService")

local ResourceConstants = require(script.Parent.Parent.ResourceConstants)
if RunService:IsServer() then
    return function (folderName: string, eventName: string)
        assert(type(folderName) == "string", "Bad folderName")
		assert(type(eventName) == "string", "Bad eventName")

		--Check if main Shared_Folder exists, if not creates.
        local storage = script.Parent.Parent.Parent:FindFirstChild(ResourceConstants.SHARED_FOLDER_NAME)
		if not storage then
			storage = Instance.new("Folder")
			storage.Name = ResourceConstants.SHARED_FOLDER_NAME
			storage.Archivable = false
			storage.Parent = script.Parent.Parent.Parent
		end

		--Checks if folderName is already created.
        local folder = storage:FindFirstChild(folderName)
        if not folder then
            folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Archivable = false
			folder.Parent = storage
        end

		--To setup multiple events being able to be created in the same folderName.
		local folder2 = folder:FindFirstChild(ResourceConstants.REMOTE_EVENTS_FOLDER_NAME)
		if not folder2 then
			folder2 = Instance.new("Folder")
			folder2.Name = ResourceConstants.REMOTE_EVENTS_FOLDER_NAME
			folder2.Archivable = false
			folder2.Parent = folder
		end

		--Find if the eventName already exists in folderName.
        local event = folder2:FindFirstChild(eventName)
		if event then
			return event
		end

        event = Instance.new("RemoteEvent")
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
			:WaitForChild(ResourceConstants.REMOTE_EVENTS_FOLDER_NAME, ResourceConstants.MAX_INSTANCEFOLDERWAIT)
			:WaitForChild(eventName, ResourceConstants.MAX_INSTANCEWAIT)
    end
else
    error("[GetRemoteEvent] - Unknown RunService state")
end