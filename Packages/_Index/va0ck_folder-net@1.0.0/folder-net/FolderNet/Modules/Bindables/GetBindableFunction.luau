local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ResourceConstants = require(script.Parent.Parent.ResourceConstants)

if RunService:IsServer() then
    return function (folderName: string, functionName: string)
        assert(type(folderName) == "string", "Bad folder name")
        assert(type(functionName) == "string", "Bad function name")

        --Checks if main server folder exist.
        local storage = ServerStorage:FindFirstChild(ResourceConstants.SERVER_BINDABLES_FOLDER_NAME)
		if not storage then
			storage = Instance.new("Folder")
			storage.Name = ResourceConstants.SERVER_BINDABLES_FOLDER_NAME
			storage.Archivable = false
			storage.Parent = ServerStorage
		end

        --Checks if the folder to store server folderName exists.
        local folder = storage:FindFirstChild(folderName)
        if not folder then
            folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Archivable = false
			folder.Parent = storage
        end

        --Setup to store multiple ServerBindables.
        local folder2 = folder:FindFirstChild(ResourceConstants.SERVER_BINDABLES_FUNCTION_FOLDER_NAME)
        if not folder2 then
            folder2 = Instance.new("Folder")
            folder2.Name = ResourceConstants.SERVER_BINDABLES_FUNCTION_FOLDER_NAME
            folder2.Archivable = false
            folder2.Parent = folder
        end

        --Checks if the serverBindable already exitss, if not then create new.
        local func = folder2:FindFirstChild(functionName)
        if func then
            return func
        end

        func = Instance.new("BindableFunction")
		func.Name = functionName
		func.Archivable = false
		func.Parent = folder2

        return func
    end

elseif RunService:IsClient() then

    return function (folderName: string, functionName: string)
        assert(type(folderName) == "string", "Bad folder name")
        assert(type(functionName) == "string", "Bad function name")

        --Check if Shared_Folder exists.
        local storage = script.Parent.Parent.Parent:FindFirstChild(ResourceConstants.SHARED_FOLDER_NAME)
		if not storage then
			storage = Instance.new("Folder")
			storage.Name = ResourceConstants.SHARED_FOLDER_NAME
			storage.Archivable = false
			storage.Parent = script.Parent.Parent.Parent
		end

        --Main folder to store shared.
        local folder = storage:FindFirstChild(folderName)
        if not folder then
            folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Archivable = false
			folder.Parent = storage
        end

        --Setup to have multiple bindable function
        local folder2 = folder:FindFirstChild(ResourceConstants.CLIENT_BINDABLES_FUNCTION_FOLDER_NAME)
        if not folder2 then
            folder2 = Instance.new("Folder")
            folder2.Name = ResourceConstants.CLIENT_BINDABLES_FUNCTION_FOLDER_NAME
            folder2.Archivable = false
            folder2.Parent = folder
        end

        --Second arg, grabs the bindable function.
        local func = folder2:FindFirstChild(functionName)
        if func then
            return func
        end

        func = Instance.new("BindableFunction")
		func.Name = functionName
		func.Archivable = false
		func.Parent = folder2

        return func
    end
else
    error("[GetBindableFunction] - Unknown RunService state")
end