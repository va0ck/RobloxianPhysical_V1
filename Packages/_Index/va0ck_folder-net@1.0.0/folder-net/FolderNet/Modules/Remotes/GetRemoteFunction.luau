local RunService = game:GetService("RunService")

local ResourceConstants = require(script.Parent.Parent.ResourceConstants)

if RunService:IsServer() then
    return function (folderName: string, functionName: string)
        assert(type(folderName) == "string", "Bad folderName")
		assert(type(functionName) == "string", "Bad functionName")

		--Checks if main shared folder exists.
        local storage = script.Parent.Parent.Parent:FindFirstChild(ResourceConstants.SHARED_FOLDER_NAME)
		if not storage then
			storage = Instance.new("Folder")
			storage.Name = ResourceConstants.SHARED_FOLDER_NAME
			storage.Archivable = false
			storage.Parent = script.Parent.Parent.Parent
		end

		--Checks if folderName already exists.
        local folder = storage:FindFirstChild(folderName)
        if not folder then
            folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Archivable = false
			folder.Parent = storage
        end

		--To allow multiple RemoteFunction in the same folderName.
		local folder2 = folder:FindFirstChild(ResourceConstants.REMOTE_FUNCTIONS_FOLDER_NAME)
		if not folder2 then
			folder2 = Instance.new("Folder")
			folder2.Name = ResourceConstants.REMOTE_FUNCTIONS_FOLDER_NAME
			folder2.Archivable = false
			folder2.Parent = folder
		end

		--Checks for functionName.
        local func = folder2:FindFirstChild(functionName)
		if func then
			return func
		end

        func = Instance.new("RemoteFunction")
		func.Name = functionName
		func.Archivable = false
		func.Parent = folder2

		return func
    end
elseif  RunService:IsClient() then
    return function (folderName: string, functionName: string)
        assert(type(folderName) == "string", "Bad folderName")
		assert(type(functionName) == "string", "Bad functionName")

        return script.Parent.Parent.Parent
			:FindFirstChild(ResourceConstants.SHARED_FOLDER_NAME)
			:WaitForChild(folderName, ResourceConstants.MAX_FOLDERWAIT)
			:WaitForChild(ResourceConstants.REMOTE_FUNCTIONS_FOLDER_NAME, ResourceConstants.MAX_INSTANCEFOLDERWAIT)
			:WaitForChild(functionName, ResourceConstants.MAX_INSTANCEWAIT)
    end
else
    error("[GetRemoteFunction] - Unknown RunService state")
end