library(chromote)

# Store chromote downloads in a temporary directory 
temp_dir <- tempdir()

b <- ChromoteSession$new()
b$Browser$setDownloadBehavior(
  behavior = "allow",
  downloadPath = normalizePath(temp_dir)
)

# Open chromote viewer
b$view()

# Go to CIHR website
b$Page$navigate("https://webapps.cihr-irsc.gc.ca/decisions/p/main.html?lang=en")
Sys.sleep(20)

# Click Project Grant filter
b$Runtime$evaluate('document.querySelector("input[type=\'checkbox\'][value=\'Project Grant\']").click()')
Sys.sleep(10)

# Click export
b$Runtime$evaluate('document.querySelector(".ExcelExport").click()')

# Wait for download
Sys.sleep(60)

# Load cihr data
cihr_data <- read.csv(file.path(temp_dir, "fdd-report.csv"))

# Write cihr data to raw-data folder
write.csv(cihr_data, file.path("data", "raw-data", "RAW_CIHR.csv"))
