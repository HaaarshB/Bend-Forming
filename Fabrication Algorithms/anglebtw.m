function f = anglebtw(a,b)
    % Finds the angle between vectors a and b in radians
    f = acos(dot(a,b)/(norm(a)*norm(b)));
end