function findtracks(A,t,p,l);
    #FINDTRACKS creates track associative array.
    
        # Find docs that have person
        DocIDwPer = row(A[:,p])
    
        # Find docs that have person and location.
        DocIDwPerLoc = row(A[DocIDwPer,l])
    
        # Find docs that have person, location and time.
        DocIDwPerLocTime = row(A[DocIDwPerLoc,t])
    
        # Limit to these documents.
        AA = A[DocIDwPerLocTime,:]
    
        # Get person sub array.
        Aper = AA[DocIDwPerLocTime,p]
        TrackPer,DocAper = find(Aper')
    
        # Get location sub array.
        Aloc = AA[DocIDwPerLocTime,l]
        EntAloc,DocAloc = find(Aloc')
    
        # Get Single location per document- order by actors
        uLocDocs = unique(DocAloc)
        uLocDocIdx = indexin(uLocDocs,DocAloc) # get first index of unique docs (correct for getting highest)
        uDocLocs = EntAloc[uLocDocIdx] # single locations per document
        uLocDocIdxinDocAper = indexin(DocAper,uLocDocs) # locations of unique loc docs in per doc list
        TrackLoc = uDocLocs[uLocDocIdxinDocAper]
    
        # Get time sub array.
        Atime = AA[DocIDwPerLocTime,t]
        EntAtime,DocAtime = find(Atime')
    
        # Get Single time per document- order by actors
        uTimeDocs = unique(DocAtime)
        uTimeDocIdx = indexin(uTimeDocs,DocAtime) # get first index of unique docs (correct for getting highest)
        uDocTimes = EntAtime[uTimeDocIdx] # single times per document
        uTimeDocIdxinDocAper = indexin(DocAper,uTimeDocs) # locations of unique time docs in per doc list
        TrackTime = uDocTimes[uTimeDocIdxinDocAper]
    
        Tr = Assoc(TrackTime,TrackPer,TrackLoc);
                        
    end