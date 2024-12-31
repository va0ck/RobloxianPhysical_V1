local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ResourceConstants = require(script.Parent.Parent.ResourceConstants)

if RunService:IsServer() then
    return function (folderName: string, eventName: string)
        assert(type(folderName) == "string", "Bad folder name")
        assert(type(eventName) == "string", "Bad event name")

        --Creates the main folder to store server bindables.
        local storage = ServerStorage:FindFirstChild(ResourceConstants.SERVER_BINDABLES_FOLDER_NAME)
		if not storage then
			storage = Instance.new("Folder")
			storage.Name = ResourceConstants.SERVER_BINDABLES_FOLDER_NAME
			storage.Archivable = false
			storage.Parent = ServerStorage
		end

        --Main first argument.
        local folder = storage:FindFirstChild(folderName)
        if not folder then
            folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Archivable = false
			folder.Parent = storage
        end

        --To support multiple eventBindables in one folder.
        local folder2 = folder:FindFirstChild(ResourceConstants.SERVER_BINDABLES_EVENT_FOLDER_NAME)
        if not folder2 then
            folder2 = Instance.new("Folder")
            folder2.Name = ResourceConstants.SERVER_BINDABLES_EVENT_FOLDER_NAME
            folder2.Archivable = false
            folder2.Parent = folder
        end

        --Second argument to grab the eventBindable.
        local event = folder2:FindFirstChild(eventName)
        if event then
            return event
        end

        event = Instance.new("BindableEvent")
		event.Name = eventName
		event.Archivable = false
		event.Parent = folder2

        return event
    end

elseif RunService:IsClient() then

    return function (folderName: string, eventName: string)
        assert(type(folderName) == "string", "Bad folder name")
        assert(type(eventName) == "string", "Bad event name")

        local storage = script.Parent.Parent.Parent:FindFirstChild(ResourceConstants.SHARED_FOLDER_NAME)
		if not storage then
			storage = Instance.new("Folder")
			storage.Name = ResourceConstants.SHARED_FOLDER_NAME
			storage.Archivable = false
			storage.Parent = script.Parent.Parent.Parent
		end

        --Grabs the first argument folder.
        local folder = storage:FindFirstChild(folderName)
        if not folder then
            folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Archivable = false
			folder.Parent = storage
        end

        --Setup folder to store multiple bindable client events.
        local folder2 = folder:FindFirstChild(ResourceConstants.CLIENT_BINDABLES_EVENT_FOLDER_NAME)
        if not folder2 then
            folder2 = Instance.new("Folder")
            folder2.Name = ResourceConstants.CLIENT_BINDABLES_EVENT_FOLDER_NAME
            folder2.Archivable = false
            folder2.Parent = folder
        end

        --Second argument to return client eventBindable.
        local event = folder2:FindFirstChild(eventName)
        if event then
            return event
        end

        event = Instance.new("BindableEvent")
		event.Name = eventName
		event.Archivable = false
		event.Parent = folder2

        return event
    end
else
    error("[GetBindableEvent] - Unknown RunService state")
end