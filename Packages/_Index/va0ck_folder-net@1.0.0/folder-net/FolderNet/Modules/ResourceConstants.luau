local ReadOnlyTable = require(script.Parent.ReadOnlyTable)

--[[
    You should be able to change the string to what you want,
    the variable names [not string value] though needs to stay the same unless if you want to rework everything.
]]--

return ReadOnlyTable({
    SHARED_FOLDER_NAME = "SharedNet";
    SERVER_BINDABLES_FOLDER_NAME = "FolderNet_Server";

    REMOTE_EVENTS_FOLDER_NAME = "RemoteEvents";
    REMOTE_FUNCTIONS_FOLDER_NAME = "RemoteFunctions";
    UNRELIABLE_REMOTE_EVENTS_FOLDER_NAME = "UnreliableRemoteEvents";

    CLIENT_BINDABLES_EVENT_FOLDER_NAME = "BindableEvents";
    CLIENT_BINDABLES_FUNCTION_FOLDER_NAME = "BindableFunctions";

    SERVER_BINDABLES_EVENT_FOLDER_NAME = "BindableEvents";
    SERVER_BINDABLES_FUNCTION_FOLDER_NAME = "BindableFunctions";

    MAX_FOLDERWAIT = 10,
    MAX_INSTANCEFOLDERWAIT = 10,
    MAX_INSTANCEWAIT = 10
})