import time
# Here is an example of how to run the program on a group with a large character table.  Assuming the program is stored on euclid or some hitherto nonexistant futuristic math department server with a copy of sage and a bash interface, just set the variables "gap_group_name" and "short_group_nickname" as needed, execute the command "nohup sage large_example.sage &", and forget.
# While the script is running, a tally of supercharacter theories will be kept up to date in a text file in the present directory called "short_group_nickname_delete_when_done.txt".  Once the main algorithm has finished finding supercharacter theories, they will be stored as a sage LatticePoset object in this directory.  Finally, some GAP scripts will run to compute verious "canonical" (although less interesting every day) subposets of SCT(G) and store those here as well.
# You will know the script is complete if you don't see it in top, also the delete_when_done file will have a note at the bottom saying the sage script is done.

# Here is a basic example of running a group.
gap_group_name = 'SymmetricGroup(5)' # This is something GAP understands.
short_group_nickname = 'S5' # This will the "tag" used to label the data later.

load('../sct_finder.sage')
sct_theories = sct_finder(gap_group_name,short_group_nickname)
start_time = time.time()
sct_theories.go()
end_time = time.time()
sct_theories.export_data()
f = open(short_group_nickname+'_delete_when_done.txt','a')
f.write('\nTotal running time: '+str(end_time - start_time)+' seconds.')
f.close()
