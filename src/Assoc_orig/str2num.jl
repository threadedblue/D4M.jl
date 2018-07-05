# Function to convert string values to numeric values

function str2num(A::Assoc)
    r,c,v = find(A)
    v = parse.(v)
    A = Assoc(r,c,v)
end