local Gaia = nil

if IsDuplicityVersion() then
    AddEventHandler('onServerResourceStart', function(resourceName)
        if resourceName == 'gaia_core' then
            Gaia = exports['gaia_core']:exportedObject()
            Gaia.print.success('Linked to gaia_core')
        end
    end)
else
    AddEventHandler('onClientResourceStart', function(resourceName)
        if resourceName == 'gaia_core' then
            Gaia = exports['gaia_core']:exportedObject()
        end
    end)
end

--- Get the Gaia framework object or nil if not available.
---@return table|nil Gaia The framework object.
function GetGaia()
    return Gaia
end
