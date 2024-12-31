--[[
    Orginzation module for networking.

    Credits [Modules I've ported over.]:
        @Quenty/Remoting [General layout to create instances. (Modules/Bindables & Modules/Remotes)]
        @Quenty/Table [Alternative to table.freeze. (Modules/ResourceConstants)]
]]--

local BindableEventInstance = require(script.Modules.Bindables.GetBindableEvent)
local BindableFunctionInstance = require(script.Modules.Bindables.GetBindableFunction)
local RemoteEventInstance = require(script.Modules.Remotes.GetRemoteEvent)
local RemoteFunctionInstance = require(script.Modules.Remotes.GetRemoteFunction)
local UnreliableRemoteEventInstance = require(script.Modules.Remotes.GetUnreliableRemoteEvent)

return {
    GetBindableEvent = function(folderName: string, eventName: string) :BindableEvent
        assert(type(folderName) == "string", "Bad folder name")
	    assert(type(eventName) == "string", "Bad event name")

        return BindableEventInstance(folderName, eventName)
    end,

    GetBindableFunction = function(folderName: string, functionName: string) :BindableFunction
        assert(type(folderName) == "string", "Bad folder name")
	    assert(type(functionName) == "string", "Bad function name")

        return BindableFunctionInstance(folderName, functionName)
    end,

    GetRemoteEvent = function(folderName: string, eventName: string) :RemoteEvent
        assert(type(folderName) == "string", "Bad folder name")
	    assert(type(eventName) == "string", "Bad event name")

        return RemoteEventInstance(folderName, eventName)
    end,

    GetRemoteFunction = function(folderName: string, functionName: string) :RemoteFunction
        assert(type(folderName) == "string", "Bad folder name")
	    assert(type(functionName) == "string", "Bad function name")
        
        return RemoteFunctionInstance(folderName, functionName)
    end,

    GetUnreliableRemoteEvent =  function(folderName: string, eventName: string) :UnreliableRemoteEvent
        assert(type(folderName) == "string", "Bad folder name")
	    assert(type(eventName) == "string", "Bad event name")

        return UnreliableRemoteEventInstance(folderName, eventName)
    end
}