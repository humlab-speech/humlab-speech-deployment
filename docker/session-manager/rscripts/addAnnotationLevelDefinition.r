library(emuR);
dbPath = file.path("/home/rstudio", "humlabspeech_emuDB")
dbHandle = load_emuDB(dbPath)

add_levelDefinition(dbHandle, name = Sys.getenv("ANNOT_LEVEL_DEF_NAME"), type = Sys.getenv("ANNOT_LEVEL_DEF_TYPE"))

