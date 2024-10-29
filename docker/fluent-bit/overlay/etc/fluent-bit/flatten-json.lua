--[[
--File: flatten-json.lua
--Project: fluent-bit
--File Created: Tuesday, 29th October 2024 2:29:53 pm
--Author: Josh5 (jsunnex@gmail.com)
-------
--Last Modified: Tuesday, 29th October 2024 5:45:57 pm
--Modified By: Josh5 (jsunnex@gmail.com)
--]]

local cjson = require "cjson"

-- Function to check if a string is valid JSON and decode it
local function is_json(str)
    local success, result = pcall(cjson.decode, str)
    return success, result  -- Return both success status and decoded result
end

function flatten_json(tag, timestamp, record)
    -- Create a new record to hold the flattened data
    local new_record = {}

    -- Iterate through each key in the original record
    for key, value in pairs(record) do
        -- Check if the value is a string
        if type(value) == "string" then
            local success, decoded_value = is_json(value)
            if success and type(decoded_value) == "table" then
                -- If the value is valid JSON, merge it into new_record
                for k, v in pairs(decoded_value) do
                    new_record[k] = v
                end
            else
                -- If it's not valid JSON, keep the original value
                new_record[key] = value
            end
        else
            -- If the value is not a string, keep the original value
            new_record[key] = value
        end
    end

    -- Create a new flat record to hold the final flattened data
    local flat_record = {}

    -- Function to recursively flatten the JSON
    local function flatten(parent, record)
        for key, value in pairs(record) do
            if type(value) == "table" then
                -- If the value is a table, flatten it recursively
                flatten(parent, value)
            else
                -- If it's not a table, add it to the flat record
                parent[key] = value
            end
        end
    end

    -- Flatten the new_record
    flatten(flat_record, new_record)

    -- Return the flattened record
    return 1, timestamp, flat_record
end
