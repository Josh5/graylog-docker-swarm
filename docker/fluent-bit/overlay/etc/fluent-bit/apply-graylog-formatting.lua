--[[
--File: apply-graylog-formatting.lua
--Project: fluent-bit
--File Created: Tuesday, 29th October 2024 3:18:29 pm
--Author: Josh5 (jsunnex@gmail.com)
-------
--Last Modified: Tuesday, 29th October 2024 4:28:46 pm
--Modified By: Josh5 (jsunnex@gmail.com)
--]]


function graylog_formatting(tag, timestamp, record)
    -- Check if "short_message" exists and is a non-empty string
    if record["short_message"] then
        if type(record["short_message"]) == "string" and record["short_message"] == "" then
            record["short_message"] = nil  -- Remove if it's an empty string
        end
    end

    -- Ensure "message" exists; if not, create one with "NO MESSAGE" or from "log"
    if not record["message"] or (type(record["message"]) ~= "string" or record["message"] == "") then
        if record["log"] and (type(record["log"]) == "string" and record["log"] ~= "") then
            record["message"] = record["log"]   -- Use log if it exists and is not empty
            record["log"] = nil                 -- Remove "log" after transferring its value
        else
            record["message"] = "NO MESSAGE"    -- Default to "NO MESSAGE"
        end
    end

    -- Ensure "source" exists; if not, create one with "unknown" or from tag
    if not record["source"] or (type(record["source"]) ~= "string" or record["source"] == "") then
        if tag and (type(tag) == "string" and tag ~= "") then
            record["source"] = tag          -- Use tag if it exists and is not empty
        else
            record["source"] = "unknown"    -- Default to "unknown"
        end
    end

    -- Check if "timestamp" exists; if not, use the provided timestamp from Fluent Bit
    if not record["timestamp"] then
        record["timestamp"] = timestamp     -- Use Fluent Bit timestamp
    end

    -- Check and convert "level" to syslog standard int
    if record["level"] then
        local level_string = record["level"]:gsub("^%s*(.-)%s*$", "%1")  -- Trim whitespace
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
            record["level"] = level_map[lower_level_string]     -- Set level to the corresponding integer
            record["levelname"] = level_string                  -- Move the original level string to "levelname"
        else
            record["level"] = 6                                 -- Default to Info if level is unrecognized
            record["levelname"] = level_string                  -- Move original level string to "levelname"
        end
    end

    -- Return the modified record
    return 1, timestamp, record
end
