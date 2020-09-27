local index = {}
 
local parent = {}
local g_score = {}
local f_score = {}
 
function round(n)
    local i = math.ceil(n)
    if i - n <= .5 then
        return i
    else
        return i-1
    end
end
 
function sort(list, index)
    while true do
        local p_index = round((index-1) / 2)
        if p_index == 0 then return list end
        if f_score[list[p_index]] > f_score[list[index]] then
            list[p_index], list[index] = list[index], list[p_index]
            index = p_index
        else
            return list
        end
    end
end
 
function get_h(a, b)
    if not (a and b) then return math.huge end
    return (a.Position - b.Position).Magnitude
end

function closest_node(coord, nodeList)
	local cap, output = math.huge
	for _,v in ipairs(nodeList)do
		local dist = (v.Position - coord).Magnitude
		if dist < cap then
			output = v
			cap = dist
		end
	end
	
	return output
end
 
function a_star(a, b, nodeMap)
	local nodeList = nodeMap:GetChildren()
	
    a = closest_node(a, nodeList)
	b = closest_node(b, nodeList)
   
    local closed_list = {}
    local open_list = {a}
	local current
	
   
    parent  = {}
    g_score  = {}
    f_score  = {}
   
    g_score[a] = 0
    f_score[a] = get_h(a, b)
    parent[a] = a
   
    repeat
        current = open_list[1]
       
        if current == b then
            break
        end
       
        table.remove(open_list, 1)
        closed_list[current] = parent[current]
       
        for _,v in ipairs(current:GetChildren())do
            if v:IsA("ObjectValue") then
                local node = v.Value
               
                local h = get_h(node, b)
                local g = g_score[current] + get_h(current, node)
                local f = g + h
               
                if not parent[node] and not closed_list[node] then
                    parent[node] = current
                    f_score[node] = f
                    g_score[node] = g
                    table.insert(open_list, node)
                    open_list = sort(open_list, #open_list)
                end
                if g < g_score[node] then
                    parent[node] = current
                    g_score[node] = g
                    f_score[node] = f
                end
            end
        end
    until #open_list <= 0
 
    if #open_list <= 0 then
        -- No path.
        return {}, "No path"
    end
   
    -- Retrace path.
    local path = {current}
    current = parent[current]
    repeat
        if current then
            table.insert(path, current)
            if parent[current] == current then
                break
            end
            current = parent[current]
        end
    until not current
   
    local output = {}
    -- Reverse path.
    for i = #path, 1, -1 do
        table.insert(output, path[i].Position)
    end
    if current then
        return output, "Success"
    end
	return {}, "Failure"
end
 
return a_star
