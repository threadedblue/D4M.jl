function findtrackgraph(Atrack)
    #TRACKGRAPH forms graph of locations from Track Associative array.
    
        # Find 1 hop and >1 hop tracks.
        AtrackHop = sum(Atrack,1)
        Hop1 = getcol(AtrackHop == 1)
        Hop2 = getcol(AtrackHop > 1) 
    
        # Get track list.  Naturally comes out sorted by p.
        t1,p1,x1 = find(Atrack[:,Hop1])
        AtrackGraph1 = Assoc(x1,x1,1,(+))
    
        t2,p2,x2 = find(Atrack[:,Hop2])
    
        # Create matrices and shifted matrices.
        p22 = circshift(p2,-1)
        x22 = circshift(x2,-1)
    
        # Find where p21 and p22 are the same.
        test = p2 .== p22  
        x21 = x2[test]
        x22 = x22[test]
    
        AtrackGraph2 = Assoc(x21,x22,1)
    
        AtrackGraph = AtrackGraph1 + AtrackGraph2
    
    end