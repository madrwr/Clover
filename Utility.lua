local Util = {}

function Util:Create(instanceType)
	return function(data)
		local obj = Instance.new(instanceType)
		local parent = nil
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			elseif k == 'Parent' then
				parent = v
			else
				obj[k] = v
			end
		end
		if parent then
			obj.Parent = parent
		end
		return obj
	end
end

function Util.RayPlaneIntersection(ray, planeNormal, pointOnPlane)
	planeNormal = planeNormal.unit
	ray = ray.Unit
	-- compute Pn (dot) Rd = Vd and check if Vd == 0 then we know ray is parallel to plane
	local Vd = planeNormal:Dot(ray.Direction)

	-- could fuzzy equals this a little bit to account for imprecision or very close angles to zero
	if Vd == 0 then -- parallel, no intersection
		return nil
	end

	local V0 = planeNormal:Dot(pointOnPlane - ray.Origin)
	local t = V0 / Vd

	if t < 0 then --plane is behind ray origin, and thus there is no intersection
		return nil
	end

	return ray.Origin + ray.Direction * t
end

return Util