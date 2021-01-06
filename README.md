# zeromq_ios_libraries

code to compile the zeromq, czmq, and libsodium statically for ios

# why does this exist?

i was trying to use zeromq for an ios project and i couldn't find an easy way to do it so i modified some scripts i found to generate the libraries i needed. 

# how does it work?

you run `build.sh` and it will download version of zmq, czmq, and libsodium (the versions are defined at the top of build.sh). then it will call each of the subscripts: libzmq.sh, libczmq.sh, and libsodium.sh. when they finish you'll have a `dist` folder which contains all of the libraries. 

# random note

when using these on ios you might need to explicitly link libc++. 
