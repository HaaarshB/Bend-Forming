function f = fourthnode3D(x,x1,x2,x3,sidelength)
    % System of three equations for finding fourth node
    f(1) = sidelength - sqrt( (x(1)-x1(1))^2 + (x(2)-x1(2))^2 + (x(3)-x1(3))^2);
    f(2) = sidelength - sqrt( (x(1)-x2(1))^2 + (x(2)-x2(2))^2 + (x(3)-x2(3))^2);
    f(3) = sidelength - sqrt( (x(1)-x3(1))^2 + (x(2)-x3(2))^2 + (x(3)-x3(3))^2);
end