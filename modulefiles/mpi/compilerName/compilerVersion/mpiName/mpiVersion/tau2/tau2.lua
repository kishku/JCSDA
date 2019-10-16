help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,2)
local mpiNameVer   = hierA[1]
local compNameVer  = hierA[2]
local mpiNameVerD  = mpiNameVer:gsub("/","-")
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

local opt = os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,mpiNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"x86_64/bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"x86_64/lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"x86_64/lib"))
prepend_path("LIBRARY_PATH", pathJoin(base,"x86_64/lib"))

local dwarf = pathJoin(base,"x86_64/libdwarf-gcc")
prepend_path("PATH", pathJoin(dwarf,"bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(dwarf,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(dwarf,"lib"))
prepend_path("LIBRARY_PATH", pathJoin(dwarf,"lib"))
prepend_path("CPATH", pathJoin(dwarf,"include"))

local binutils = pathJoin(base,"x86_64/binutils-2.23.2")
prepend_path("PATH", pathJoin(binutils,"bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(binutils,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(binutils,"lib"))
prepend_path("LIBRARY_PATH", pathJoin(binutils,"lib"))
prepend_path("CPATH", pathJoin(binutils,"include"))

local elf = pathJoin(base,"x86_64/libelf-devel-0.158-6.1.x86_64")
prepend_path("PATH", pathJoin(elf,"bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(elf,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(elf,"lib"))
prepend_path("LIBRARY_PATH", pathJoin(elf,"lib"))
prepend_path("CPATH", pathJoin(elf,"include"))

local unwind = pathJoin(base,"x86_64/libunwind-1.3.1-gcc")
prepend_path("PATH", pathJoin(unwind,"bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(unwind,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(unwind,"lib"))
prepend_path("LIBRARY_PATH", pathJoin(unwind,"lib"))
prepend_path("CPATH", pathJoin(unwind,"include"))

setenv("TAU_ROOT", base)
setenv("TAU_PATH", base)
setenv("TAU_INCLUDES", pathJoin(base,"x86_64/include"))
setenv("TAU_LIBRARIES", pathJoin(base,"x86_64/lib"))
setenv("TAU_MAKEFILE", pathJoin(base,"x86_64","lib","Makefile.tau-ompt-tr4-mpi-pdt-openmp"))
setenv("TAU_VERSION", pkgVersion)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: TAU (Tuning and Analysis Utilities) Version 2 library")
