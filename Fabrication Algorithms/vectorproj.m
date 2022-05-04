function vectorprojunit = vectorproj(a,b)
%% Function which gives the unit projection of vector A onto vector B
% https://en.wikipedia.org/wiki/Vector_projection
    vectorproj = dot(a,b)/dot(b,b) * b;
    vectorprojunit = vectorproj/norm(vectorproj);
end