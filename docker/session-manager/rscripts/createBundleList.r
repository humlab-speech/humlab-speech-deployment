library(emuR);

dbPath = file.path("/home/rstudio", "humlabspeech_emuDB")
dbHandle = load_emuDB(dbPath)

bndls = list_bundles(dbHandle);

write_bundleList(dbHandle, name = "user.user", bndls);
