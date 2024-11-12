--[[
--File: apply-graylog-formatting.lua
--Project: fluent-bit
--File Created: Tuesday, 29th October 2024 3:18:29 pm
--Author: Josh5 (jsunnex@gmail.com)
-------
--Last Modified: Wednesday, 13th November 2024 9:39:05 am
--Modified By: Josh5 (jsunnex@gmail.com)
--]]


function graylog_formatting(tag, timestamp, record)
    -- Create a new record
    local new_record = {}
    for key, value in pairs(record) do
        print(key, value)
        new_record[key] = value

        -- Convert any "source." keys to "source_". Graylog will do this already, but lets do it here so anything
        --  sent to another index not managed by Graylog will be uniform.
        if key:sub(1, 7) == "source." then
            local new_key = "source_" .. key:sub(8)
            new_record[new_key] = value
            new_record[key] = nil  -- Remove the original "source." key
        end
    end
    
    -- Check if "short_message" exists and is a non-empty string
    if new_record["short_message"] then
        if type(new_record["short_message"]) == "string" and new_record["short_message"] == "" then
            new_record["short_message"] = nil  -- Remove if it's an empty string
        end
    end

    -- Ensure "message" exists; if not, create one with "NO MESSAGE" or from "log"
    if not new_record["message"] or (type(new_record["message"]) ~= "string" or new_record["message"] == "") then
        if new_record["log"] and (type(new_record["log"]) == "string" and new_record["log"] ~= "") then
            new_record["message"] = new_record["log"]   -- Use log if it exists and is not empty
            new_record["log"] = nil                 -- Remove "log" after transferring its value
        else
            new_record["message"] = "NO MESSAGE"    -- Default to "NO MESSAGE"
        end
    end

    -- Ensure "source" exists; if not, create one with "unknown" or from tag
    if not new_record["source"] or (type(new_record["source"]) ~= "string" or new_record["source"] == "") then
        if tag and (type(tag) == "string" and tag ~= "") then
            new_record["source"] = tag          -- Use tag if it exists and is not empty
        else
            new_record["source"] = "unknown"    -- Default to "unknown"
        end
    end

    -- Check if "timestamp" exists; if not, use the provided timestamp from Fluent Bit
    if not new_record["timestamp"] then
        new_record["timestamp"] = timestamp     -- Use Fluent Bit timestamp
    end

    -- Check and convert "level" to syslog standard int
    if new_record["level"] then
        local level_string = new_record["level"]:gsub("^%s*(.-)%s*$", "%1")  -- Trim whitespace
        local level_map = {
            emergency = 0,
            alert = 1,
            critical = 2,
            error = 3,
            warning = 4,
            warn = 4,
            notice = 5,
            informational = 6,
            info = 6,
            debug = 7
        }

        -- Convert level string to lowercase for case-insensitive matching
        local lower_level_string = level_string:lower()

        -- Check if the lowercased level string exists in the map
        if level_map[lower_level_string] then
            new_record["level"] = level_map[lower_level_string]     -- Set level to the corresponding integer
            new_record["levelname"] = level_string                  -- Move the original level string to "levelname"
        else
            new_record["level"] = 6                                 -- Default to Info if level is unrecognized
            new_record["levelname"] = level_string                  -- Move original level string to "levelname"
        end
    end

    -- Ensure "service_name" exists. 
    -- A service name is something required by Open Telemetry semantic conventions. Grafana will automatically apply this as "fluent-bit" if it does not exist.
    if not new_record["service_name"] or (type(new_record["service_name"]) ~= "string" or new_record["service_name"] == "") then
        if new_record["source_service"] and (type(new_record["source_service"]) == "string" and new_record["source_service"] ~= "") then
            new_record["service_name"] = new_record["source_service"]   -- Use "source_service" record if it exists and is not empty
        else
            new_record["service_name"] = new_record["source"]           -- Default to "source" record
        end
    end

    -- Return the modified new_record
    return 1, timestamp, new_record
end
