local reqxi = {}
local HttpService = game:GetService("HttpService")


local function parseResponse(response)
	local result = {
		status_code = response.StatusCode,
		headers = response.Headers,
		encoding = "utf-8",
		text = response.Body,
		json = function()
			return HttpService:JSONDecode(response.Body)
		end
	}
	return result
end

-- Helper function to send requests with specified method
local function sendRequest(method, url, data)
	local jsonData = data and HttpService:JSONEncode(data) or ""
	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = method,
			Headers = { ["Content-Type"] = "application/json" },
			Body = jsonData
		})
	end)

	if success then
		return parseResponse(response)
	else
		warn("Failed to send " .. method .. " request: " .. tostring(response))
		return nil
	end
end

-- GET request
function reqxi.get(Website)
	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = Website,
			Method = "GET"
		})
	end)

	if success then
		return parseResponse(response)
	else
		warn("Failed to GET: " .. tostring(response))
		return nil
	end
end

-- POST request
function reqxi.post(Website, Data)
	return sendRequest("POST", Website, Data)
end

-- PUT request
function reqxi.put(Website, Data)
	return sendRequest("PUT", Website, Data)
end

-- PATCH request
function reqxi.patch(Website, Data)
	return sendRequest("PATCH", Website, Data)
end

-- DELETE request (with optional data)
function reqxi.delete(Website, Data)
	return sendRequest("DELETE", Website, Data)
end

-- Discord Webhook function
function reqxi.discordhook(User, pfp, data, webhook)
	local payload = {
		content = data
	}

	if User then
		payload.username = User
	end
	if pfp then
		payload.avatar_url = pfp
	end

	return reqxi.post(webhook, payload)
end

return reqxi
