def tuplefun(filename):
    with open(filename) as file:
        megacoordslist = []
        for line in file:
            coords_list = []
            strip_line = line.strip()
            line_list = strip_line.split()
            for item in line_list:
                coords_list.append(float(item))
            megacoordslist.append(tuple(coords_list))
        megacoordstuple = tuple(megacoordslist)
        print(tuple(coords_list))
       # print(megacoordstuple)

def extractfirstcoord(filename):
    with open(filename) as file:
        for line_num, line in enumerate(file,1):
            strip_line = line.strip(' ')
            # print(strip_line)
            line_list = strip_line.split()
            # print(line_list)
            region1 = []
            region2 = []
            for x in range(0,3): region1.append(float(line_list[x]))
            for y in range(3,6): region2.append(float(line_list[y]))
            region1convert = []
            region2convert = []
            region1convert.append(tuple(region1))
            region2convert.append(tuple(region2))
            region1final = tuple(region1convert)
            region2final = tuple(region2convert)
            constraintname = str(line_list[6])
            print(region1final)
            print(region2final)
            print(constraintname)

testfile = "C:\\Users\\harsh\\Desktop\\testcoords.txt"
extractfirstcoord(testfile)